---
name: dev-change-manager
description: Applies change requests to dev-manager projects: impact analysis and targeted re-spawn. Triggers: modify requirements, add feature to existing project, requirements changed, change request.
argument-hint: <project root path> <brief change description>
user-invocable: true
---

# Dev Change Manager

**Initial request:** $ARGUMENTS

## Purpose

Handle change requests against projects built by `dev-manager`. Collect the change, analyze its impact on existing pipeline artifacts, determine the minimal re-entry point, and re-trigger only the affected tasks — without rebuilding what has not changed.

Never re-run the full pipeline when a targeted update suffices. Never skip integration and deployment verification after any re-spawn.

---

## Handoff Contract (Inherited + Extended)

All state is file-based. Distinguish two error classes before starting:

**Class A — Path unknown:** User has not provided a project root. Ask for it. Do not proceed until a valid path is given.

**Class B — Artifacts missing:** Project root is known but one or more artifacts are absent.

| Artifact            | Location             | If missing                                                                          |
| ------------------- | -------------------- | ----------------------------------------------------------------------------------- |
| `requirements.md`   | User-provided path   | Ask user for path — may differ from project root                                    |
| `SPEC.md`           | Project root         | Fatal — cannot proceed                                                              |
| `TASKS.md`          | Project root         | Fatal — cannot proceed                                                              |
| `EXECUTION_PLAN.md` | Project root         | Fatal — cannot proceed                                                              |
| `modules/*/DONE.md` | Each task output dir | Fatal — pipeline not complete; use `dev-manager` to finish it first                 |
| `MANAGER_STATE.md`  | Project root         | Non-fatal — if absent, skip state updates; if present, update it throughout Phase 4 |

If any DONE.md is missing, stop and tell the user: "Pipeline is not complete — task `[task_id]` has no DONE.md. Re-run `dev-manager` to finish the pipeline before applying a change request."

**Change artifacts produced by this skill (one file per CR):**

| Artifact                    | Location     | Phase   |
| --------------------------- | ------------ | ------- |
| `CHANGE-REQUEST-[CR-id].md` | Project root | Phase 1 |
| `CHANGE-IMPACT-[CR-id].md`  | Project root | Phase 2 |

---

## Phase 0 — Load Project Context

**Trigger:** User invokes this skill.

1. Ask for the project root path if not provided in `$ARGUMENTS`.
2. Read `EXECUTION_PLAN.md`, `SPEC.md`, `TASKS.md` from that root. Also ask for (or infer) the `requirements.md` path and read it — it is the authoritative source for what the system must and must not do.
3. Apply the artifact check table above. Stop with a clear message on any fatal missing item.
4. Assign a change request ID: scan project root for files matching `CHANGE-REQUEST-CR-*.md`, take the highest N found, increment it, and always zero-pad to 3 digits. Examples: `CR-001`, `CR-009`, `CR-010`. If none exist, assign `CR-001`.

Confirm to the user:

> "Project documents loaded. Starting change request collection."

---

## Phase 1 — Change Request Interview

**Trigger:** Project context loaded.

Invoke the change interview workflow from `references/change-interview-patterns.md`. Conduct a structured interview:

- One question per turn — never batch
- Follow the four interview phases: Change Identification → Scope Boundaries → Acceptance Criteria → Conflict Check
- After each answer, scan existing `requirements.md`, `SPEC.md`, and `TASKS.md` for contradictions — `requirements.md` is authoritative for constraints the existing system must honour; `SPEC.md`/`TASKS.md` are authoritative for what was actually built
- If contradiction found → surface explicitly and resolve before proceeding

**Phase 1 completion conditions (all must be true):**

1. Change summary is unambiguous
2. Scope boundary (in/out) confirmed by user
3. At least one acceptance criterion defined
4. Unchanged behaviors listed
5. User confirms `CHANGE-REQUEST-[CR-id].md` is complete

Write `CHANGE-REQUEST-[CR-id].md` to project root. Confirm path with user before writing.

---

## Phase 2 — Impact Analysis

**Trigger:** `CHANGE-REQUEST-[CR-id].md` confirmed on disk.

This is a manager-only step — do not spawn sub-agents for it.

1. Read `CHANGE-REQUEST-[CR-id].md`, `requirements.md`, `SPEC.md`, `TASKS.md`, `EXECUTION_PLAN.md`
2. Apply the decision tree in `references/change-impact-rules.md` to classify: **Small / Medium / Large**
3. Identify:
   - Which tasks are modified, new, or removed

- Which downstream tasks are additionally affected
- Whether `SPEC.md` needs updating
- Whether `dev-task-planner` must be re-run

4. Build the tasks-to-re-spawn list and tasks-to-preserve list
5. Write `CHANGE-IMPACT-[CR-id].md` to project root (format in `references/change-impact-rules.md`)

Show the user a summary table:

```
Classification: [Small / Medium / Large]
Artifacts to update: [list]
Tasks to re-spawn: [list]
Tasks to preserve: [list]
Re-run dev-task-planner: [Yes / No]
```

Ask: "Is this impact analysis correct? Confirm to begin updating documents."

Do not proceed without user confirmation.

---

## Phase 3 — Artifact Update

**Trigger:** CHANGE-IMPACT-[CR-id].md confirmed by user.

Update `requirements.md`, `SPEC.md`, `TASKS.md`, and `EXECUTION_PLAN.md` per classification (Small/Medium/Large). See `references/artifact-update-rules.md` for the full update procedure (3A–3D).

**Phase 3 completion condition:** All artifact updates confirmed on disk.

---

## Phase 4 — Re-spawn Affected Tasks

**Trigger:** Updated artifacts confirmed on disk.

Spawn `senior-engineer` sub-agents for each task in the `CHANGE-IMPACT-[CR-id].md` "Tasks to Re-spawn" list. Use the same payload pattern as `dev-manager` Phase 3, with `change_context` added. See `references/spawn-payload.md` for the full template.

### Spawn Order

- Determine dependency order from updated `EXECUTION_PLAN.md`
- Recompute the dependency-ready set from `depends_on_task_ids` before each spawn wave
- Spawn every ready task whose upstream dependencies are complete and whose `parallel_group` does not trail an unresolved prerequisite tier
- Wait for each tier to complete before spawning the next tier
- Preserved tasks are skipped — do not spawn them

### Supervision Loop

After each agent completes, apply the same Phase 4 checks as `dev-manager`:

| Check                                  | Pass condition                    | Action if fail             |
| -------------------------------------- | --------------------------------- | -------------------------- |
| Status = DONE                          | Field is exactly `DONE`           | Re-spawn with feedback     |
| Acceptance criteria met                | Verified against updated TASKS.md | Re-spawn with specific gap |
| Interface contract honored             | All items marked "honored"        | Re-spawn with correction   |
| `unchanged_outputs_to_preserve` intact | No removed or regressed behaviors | Re-spawn with correction   |

Loop until all re-spawned tasks have `DONE.md` Status = DONE.

### MANAGER_STATE.md Updates in Phase 4

Update `MANAGER_STATE.md` throughout Phase 4 per `references/state-update-rules.md`.

---

## Phase 5 — Re-integration

**Trigger:** All re-spawned tasks DONE.

Always re-run integration — even if only one task changed.

Spawn the integration agent from `dev-manager` Phase 5 with the updated task output directory list.

If integration fails on a **preserved task** (one that was not re-spawned), it needs re-spawning due to upstream contract drift. Use the integration-failure `change_context` template from `references/spawn-payload.md`.

Loop until `integration-report.md` shows all integration points passing.

---

## Phase 6 — Deployment Verification

**Trigger:** `integration-report.md` all passing.

Spawn the `deployment-verifier` verification sub-agent (same as `dev-manager` Phase 6):

```
Skill: deployment-verifier
Args: [project-root path]
```

Apply same verdict handling:

| Verdict    | Action                                                                                                     |
| ---------- | ---------------------------------------------------------------------------------------------------------- |
| ✅ PASS    | Proceed to completion report                                                                               |
| ⚠️ PARTIAL | Re-spawn failing tasks → apply Phase 4 supervision checks → re-run Phase 5 integration → return to Phase 6 |
| ❌ FAIL    | Re-spawn failing tasks → apply Phase 4 supervision checks → re-run Phase 5 integration → return to Phase 6 |

---

## Completion Report

Write completion report per `references/completion-template.md`.

---

## Manager Decision Protocol

At every loop iteration, state explicitly:

```
CR-[id] Status: [phase] — [what completed, what failed]
Decision: [proceed / re-spawn <task_id> / escalate to user]
Reason: [one sentence]
```

Escalate to user only when:

- A conflict between the change request and existing spec cannot be resolved without user input
- A preserved task fails integration for a reason unrelated to the change
- The same task fails Phase 6 verification 3+ times with the same root cause

---

## Additional Resources

- **`references/change-impact-rules.md`** — Impact classification matrix, decision tree, artifact update rules, `CHANGE-IMPACT-[CR-id].md` format
- **`references/change-interview-patterns.md`** — Structured interview phases, `CHANGE-REQUEST-[CR-id].md` template, completion signals
