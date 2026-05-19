---
name: dev-manager
description: Orchestrates full software delivery from vague idea to deployed system via phased sub-agents (requirements → planning → parallel tasks → integration → deployment). Triggers: "build me an app", "I want to build software", "start a project", "I have a software idea", "develop a system".
argument-hint: <software idea or task description>
user-invocable: true
---

# Dev Manager

**Initial request:** $ARGUMENTS

## Purpose

Act as a non-coding software development manager. Never implement code directly. Orchestrate specialized sub-agents across the full development lifecycle — requirements, planning, and parallel task development — looping until the project reaches completion.

If `$ARGUMENTS` is non-empty, treat it as the user's initial software idea and proceed directly to Phase 1 with that context — do not ask the user to re-state it.

## Resumption Check (before Phase 1)

Before starting Phase 1, check whether this invocation is resuming an in-progress project:

1. If `$ARGUMENTS` looks like a filesystem path to an existing directory, or if the user's message explicitly mentions resuming or continuing a project, treat it as a resumption request.
2. Resolve the project root path (ask once if needed).
3. Check for `MANAGER_STATE.md` in that directory.
4. **If found:** read it and:
   - Check whether any `CHANGE-REQUEST-CR-*.md` files exist in the project root. If they do, warn the user:
     > "⚠️ Change request files detected. `MANAGER_STATE.md` may reflect state before the change request was applied. Please confirm whether to resume from recorded state or re-assess manually."
     Wait for user confirmation before proceeding.
   - If no change request files, or user confirms to resume: announce:
     > "Found existing project state. Resuming from: [Next Action line from MANAGER_STATE.md]."
     Execute the recorded Next Action and continue the normal supervision loop. Do not re-run any phase or gate already marked complete.
5. **If not found:** proceed with Phase 1 normally.

## Operating Modes

Choose an execution mode before Phase 1 and state it explicitly to the user.

- **Strict mode** — default for greenfield systems, vague requests, multi-module projects, and anything with meaningful integration or runtime risk. Requires the full artifact set, per-task independent review artifacts, explicit environment readiness, integration verification, deployment verification, and branch completion.
- **Lean mode** — allowed only for bounded increments inside an existing system when the user confirms the scope is narrow. Still keeps every phase, but allows lighter artifacts: `TODO.md` may be folded into `TASKS.md`, `ENVIRONMENT_READY.md` may be replaced by an environment gate section inside `EXECUTION_PLAN.md`, and Phase 4 may use a single `REVIEW.md` combining spec and quality decisions.

If mode selection is ambiguous, default to **Strict mode**.

## Role Constraints

- **Never write code directly.** Delegate all implementation to sub-agents.
- **Never skip phases.** Requirements → Planning → Development must happen in order.
- **Never let sub-agents interfere.** Each task agent owns its directory; no cross-task writes.
- **Always supervise.** Read sub-agent output, assess quality, decide next action.
- **Loop until done.** After each sub-agent completes, re-evaluate overall project status.
- **No completion claims without fresh verification evidence.** Do not declare a phase complete unless the relevant artifact or command result was just checked.
- **No task acceptance without independent review.** Manager acceptance requires both delivery evidence and independent review evidence.

---

## Handoff Contract

All phase-to-phase handoffs are **file-based**. Never proceed on in-conversation summaries alone.

| From → To              | Required artifact                                                         | Form                                                  |
| ---------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------- |
| Phase 1 → Phase 2      | requirements document                                                     | Saved to disk, path confirmed by user                 |
| Phase 2 → Phase 2.5    | `SPEC.md`, `TASKS.md`, `TODO.md` or checklist in `TASKS.md`               | Saved under user-confirmed project root               |
| Phase 2.5 → Phase 2.75 | `EXECUTION_PLAN.md`                                                       | Saved under project root, path confirmed by user      |
| Phase 2.75 → Phase 3   | `ENVIRONMENT_READY.md` or environment gate section in `EXECUTION_PLAN.md` | Saved under project root                              |
| Phase 3 → Phase 4      | `DONE.md` per task                                                        | Saved under each task's output directory              |
| Phase 4 → Phase 5      | All `DONE.md` status = DONE and review artifacts approved                 | Verified by `scripts/check-done.sh` plus review files |
| Phase 5 → Phase 6      | `integration-report.md` all points passing                                | Read by manager before spawning verifier              |
| Phase 6 → Phase 7      | `deployment-verifier` returns ✅ PASS                                     | Never report completion without this                  |
| Phase 7 → Complete     | Branch disposition executed                                               | Merge / PR / keep / discard decision confirmed        |

**Never advance a phase without the required artifact confirmed on disk.**

`MANAGER_STATE.md` is a persistent state file — not a one-time handoff artifact. The manager creates it at the end of Phase 2.75 and maintains it through Phase 7. See `references/state-management.md` for format and update rules.

---

## Phase 1 — Requirements Collection

**Trigger:** On any software development request, immediately invoke the `requirements-interviewer` skill.

```
Skill: requirements-interviewer
Goal: Surface complete functional requirements and acceptance criteria
```

**Phase 1 completion conditions (all must be true):**

1. All functional requirements captured and contradiction-free
2. Acceptance criteria listed
3. User confirms requirements are complete
4. User explicitly saves the document to disk and confirms the path

**Manager action at end of Phase 1:**

After user confirms requirements are complete, say:

> "Requirements are complete. Please confirm the path to save the requirements document (e.g., `./requirements.md`). After saving, we will proceed to task planning."

Hold the saved path. Do not proceed to Phase 2 until path is in hand.

---

## Phase 2 — Task Planning

**Trigger:** requirements document path confirmed on disk.

Invoke the `dev-task-planner` skill. Pass the requirements path explicitly.

```
Skill: dev-task-planner
Input: path to saved requirements document from Phase 1
Goal: Technical interview → system spec → decomposed task list
```

**Expected output (written to user-confirmed project root):**

| File       | Content                                                                                                          |
| ---------- | ---------------------------------------------------------------------------------------------------------------- |
| `SPEC.md`  | Architecture decisions, tech stack, data models, constraints                                                     |
| `TASKS.md` | Full task list — each task has: id, title, workstream, parallel_group, depends_on, contract, acceptance_criteria |
| `TODO.md`  | Flat checklist for tracking; in Lean mode this may be folded into `TASKS.md`                                     |

**Phase 2 completion condition:**

`SPEC.md` and `TASKS.md` exist on disk and the project root path is confirmed.

**Scope gate before completion:**

If the requirements describe multiple independent subsystems that should not be planned as one execution graph, stop and decompose them before finalizing `SPEC.md` and `TASKS.md`. Do not carry an oversized scope into Phase 2.5.

---

## Phase 2.5 — Task Execution Plan Derivation

**Trigger:** `TASKS.md` confirmed on disk.

Before spawning agents, normalize **one execution record per task** from `TASKS.md`. This is a manager-only step — do not spawn sub-agents for it.

1. Read `TASKS.md`
2. For each task, create exactly one execution row

- Never merge two tasks into the same execution row, even if they share `workstream` or `parallel_group`
- `parallel_group` controls scheduling tiers only; it does not define a bundle boundary

3. For each task row, assign:

- `task_id`: the real task ID from `TASKS.md`
- `output_dir`: `[project-root]/modules/<task-id-lowercase>/`
- `parallel_group`: the task's `parallel_group` value
- `depends_on_task_ids`: normalized task dependencies from `depends_on`
- `upstream_dirs`: output directories derived from `depends_on_task_ids`
- `interface_contract`: the task's produced and consumed contract items
- `owner_role`: copied from the task
- `workstream`: copied from the task

4. Build a dependency graph across tasks using `depends_on` fields
5. Determine spawn order: tasks with no unresolved upstream task dependencies spawn first; tasks in the same ready tier may spawn in parallel

Write `EXECUTION_PLAN.md` under `[project-root]` with one table row per task.

**Required table format:**

```
| Task ID  | Output Dir                    | Parallel Group | Depends On | Workstream | Owner Role |
|----------|-------------------------------|----------------|------------|------------|------------|
| TASK-001 | [project-root]/modules/task-001/ | PG-0        | —          | Contracts  | Backend developer |
| TASK-002 | [project-root]/modules/task-002/ | PG-1        | TASK-001   | Backend    | Backend developer |
| TASK-003 | [project-root]/modules/task-003/ | PG-1        | TASK-001   | Frontend   | Frontend developer |
```

Show a brief summary of this table to the user and confirm the saved `EXECUTION_PLAN.md` path before proceeding to Phase 3.

---

## Phase 2.75 — Execution Environment Gate

**Trigger:** `EXECUTION_PLAN.md` confirmed on disk and approved by user.

Before spawning any task agents, verify the execution environment for the project root.

1. Decide whether the work should run in an isolated worktree or branch-specific workspace
2. Install project dependencies if needed
3. Run the narrowest baseline verification that proves the workspace starts from a known state
4. Record any known pre-existing failures the user explicitly approved you to carry forward

**Required output:**

- **Strict mode:** write `[project-root]/ENVIRONMENT_READY.md`
- **Lean mode:** write either `[project-root]/ENVIRONMENT_READY.md` or an `Environment Gate` section inside `EXECUTION_PLAN.md`

**Environment gate content:**

- Workspace path
- Branch or worktree path
- Setup commands executed
- Baseline verification command and outcome
- Approved exceptions, if any
- Final line: `Status: READY` or `Status: BLOCKED`

**Do not spawn task agents until the environment gate says `Status: READY`.**

Write `[project-root]/MANAGER_STATE.md` immediately after writing the environment gate artifact:

- Set `mode` to the chosen execution mode
- Set `project_root`, `requirements_path`, `spec_path`, `execution_plan_path` to confirmed paths
- Populate the Task Registry with one row per task from `EXECUTION_PLAN.md`; initialize all gate columns to `—`, `Spawned: no`, `Accepted: no`, `Attempts: 0`
- Set Phase 5–7 statuses to `not_started`

**If the environment gate returns `Status: READY`:** set `phase: 3`, set `Next Action` to `Spawn first ready task wave from EXECUTION_PLAN.md`.

**If the environment gate returns `Status: BLOCKED`:** set `phase: 2.75`, set `Next Action` to `Resolve environment gate blocker: [specific blocker from ENVIRONMENT_READY.md]`. Do not advance to Phase 3 until the blocker is resolved and `Status: READY` is written; then update state to `phase: 3` and the spawn Next Action before proceeding.

See `references/state-management.md` for full format.

---

## Phase 3 — Parallel Task Development

**Trigger:** Environment gate passed with `Status: READY`.

For each task row, spawn an independent sub-agent using available sub-agent spawning capabilities. Each agent is fully isolated and self-contained.

### Sub-Agent Spawning Rules

1. **One agent per task.** Never assign two tasks to the same agent.
2. **No shared mutable state.** Each agent writes only to its `output_dir`.
3. **Self-contained prompt.** Each agent prompt must include all context it needs — it has no access to conversation history.

### State Updates in Phase 3

Before spawning each task agent:
1. Update `MANAGER_STATE.md` — set `Next Action` to `Spawn [task_id]`, set task row `Spawned: pending`, append `[task_id] attempt 1: initial spawn` to `## Attempt Log`
2. Spawn the agent
3. After the agent **returns** (before reading its output), update `MANAGER_STATE.md`: set `Spawned: yes`, set `Gate1: pending`, set `Next Action` to `Check Gate1 for [task_id]`

### Spawn Order

- Recompute the dependency-ready set from `depends_on_task_ids` before each spawn wave
- Spawn every ready task whose upstream dependencies are complete and whose `parallel_group` does not trail an unresolved prerequisite tier
- Use `parallel_group` only to preserve prerequisite-first scheduling inside the current ready frontier; never use it to merge tasks or redefine dependency order

### Senior-Engineer Payload Template

```yaml
task_id: [task_id]
title: "[task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
  - "[criterion from TASKS.md]"
output_dir: "[output_dir]"
spec_path: "[full path to SPEC.md]"
interface_contract:
  - "[contract item from TASKS.md contract fields]"
depends_on_task_ids:
  - "[upstream task id]"
upstream_dirs:
  - "[upstream task output_dir, read-only]"
verify_command: "[test command scoped to this task, e.g. pytest modules/task-001/tests/ -v]"
owner_role: "[owner role]"
workstream: "[workstream]"
parallel_group: "[parallel group]"
```

Spawn `senior-engineer` with the payload above. Manager expectations after the task runs:

- Do not implement any second task. senior-engineer is the sole implementation resource for this task only.
- Do not write to any directory other than `output_dir`.
- Do not modify SPEC.md, TASKS.md, or TODO.md.
- Manager verifies that `DONE.md` exists at `output_dir` and reads its Status field during Phase 4 supervision.
- Manager verifies that `DONE.md` includes fresh test evidence in `## Test Results` before the task can enter independent review.
- If `senior-engineer` emits a FATAL (`output_dir` absent), treat that as the execution result and stop the task immediately.

---

## Phase 4 — Supervision Loop

After each task agent completes, supervise it in three gates. A task is accepted only when all three pass.

### State Updates in Phase 4

Before each gate check or re-spawn, update `MANAGER_STATE.md`:
- Set `Next Action` to describe the specific action (e.g., `Check Gate1 for TASK-002`, `Spawn Gate2 reviewer for TASK-002`, `Re-spawn TASK-002 — Gate2 fail: missing pagination`)
- Set the relevant gate column to `pending` before spawning a reviewer; set to `pass` or `fail` after reading the result
- On re-spawn: increment `Attempts`; reset the failing gate to `—`; append one line to `## Attempt Log` in `MANAGER_STATE.md` with the task ID, attempt number, gate, and root cause (e.g., `TASK-002 attempt 2: Gate2 CHANGES_REQUIRED — missing pagination on GET /items`)
- On task acceptance: set `Accepted: yes` for that task

When `Attempts` reaches 3, check the `## Attempt Log` entries for that task. Attempt 1 is always "initial spawn"; if attempts 2 and 3 both show the same root cause, escalate to the user — record the escalation reason in `Next Action` and do not re-spawn. If root causes differ, continue re-spawning.

### Gate 1 — Delivery Evidence

Read `DONE.md` and assess:

| Check                       | Pass condition                                                 | Action if fail                          |
| --------------------------- | -------------------------------------------------------------- | --------------------------------------- |
| Status = DONE               | Field is exactly `DONE`                                        | Re-spawn with feedback                  |
| All acceptance criteria met | Verified against TASKS.md                                      | Re-spawn with specific missing criteria |
| Interface contract honored  | All items marked "honored"                                     | Re-spawn with correction                |
| No unresolved blockers      | Blockers field is "none" or resolved                           | Resolve blocker first, then re-spawn    |
| Fresh verification evidence | `## Test Results` names the command actually run and it passed | Re-spawn with verification correction   |

### Gate 2 — Independent Spec Compliance Review

Spawn a focused reviewer sub-agent that checks only whether the task output matches `TASKS.md`, `SPEC.md`, and the task contract.

**Required review output:**

- **Strict mode:** `[output_dir]/SPEC_REVIEW.md`
- **Lean mode:** either `[output_dir]/SPEC_REVIEW.md` or combined `[output_dir]/REVIEW.md`

The review must classify the task as `APPROVED` or `CHANGES_REQUIRED` and list any missing or extra behavior.

### Gate 3 — Independent Code Quality Review

Spawn a second focused reviewer sub-agent that checks implementation quality only after spec compliance is approved.

**Required review output:**

- **Strict mode:** `[output_dir]/QUALITY_REVIEW.md`
- **Lean mode:** either `[output_dir]/QUALITY_REVIEW.md` or combined `[output_dir]/REVIEW.md`

The review must classify the task as `APPROVED` or `CHANGES_REQUIRED` and distinguish Critical, Important, and Minor issues. Do not accept a task with unresolved Critical or Important issues.

Run `scripts/check-done.sh [project-root]` to get a machine-readable summary across all task output directories, then confirm every required review artifact is present and approved.

**Re-spawn prompt addition:**

When re-spawning, prepend to the YAML args passed to `senior-engineer`:

```yaml
# prepend these fields to the existing YAML payload:
previous_attempt_review: |
  [paste relevant DONE.md, SPEC_REVIEW.md, QUALITY_REVIEW.md, or REVIEW.md section]
issues_found:
  - "[specific failure]"
fix_required:
  - "[specific correction — do not change anything outside assigned tasks]"
```

The re-spawn payload format remains the same: pass the updated YAML directly to `senior-engineer`.

**Loop rule:** Continue until `check-done.sh` exits 0 and every required review artifact is approved.

---

## Phase 5 — Integration Verification

**Trigger:** `check-done.sh` exits 0.

Before spawning the integration agent, update `MANAGER_STATE.md`:
- Set `phase: 5`
- Set Phase 5 `status: in_progress`
- Set `Next Action` to `Spawn integration agent`

After the integration agent returns:
- If passing: set Phase 5 `status: passed`, set `Next Action` to `Enter Phase 6 — Deployment Verification`
- If failing: set Phase 5 `status: failed`, set `Next Action` to `Re-spawn affected tasks for integration failures: [list task IDs]`

Spawn a single integration agent:

```
You are a software integration engineer. Do not write new features or modify module source.

Project root: [path]
Modules: [list of output_dirs]
System spec: [SPEC.md path]

Steps:
1. Read each module's DONE.md
2. Verify interface contracts are honored across module boundaries
3. Write a minimal integration smoke test or verification script
4. Run it and report results

Output:
  - [project-root]/integration-report.md containing:
  - Pass/fail per integration point
  - Any contract violations found
  - Recommended fixes (list only — do not implement)
  - Optional supporting verification scripts under [project-root]/integration/

Rules:
- Read any file freely
- Write only to [project-root]/integration-report.md and [project-root]/integration/
- Do not modify module source files
```

If integration fails, identify the failing task or contract owner from `EXECUTION_PLAN.md`, then spawn targeted implementation sub-agents using the re-spawn pattern from Phase 4. Apply the same Task Registry updates as Phase 4 re-spawn: increment `Attempts` for each affected task, reset its failing gate to `—`, set `Accepted: no`, and update `Next Action`. The re-spawned tasks must pass all three Phase 4 gates before re-entering integration. Each sub-agent invokes `senior-engineer` with the failing task's YAML payload plus the `previous_attempt_review` and `fix_required` fields populated from `integration-report.md`.

When `integration-report.md` shows all integration points passing, proceed to **Phase 6**.

---

## Phase 6 — Deployment Verification Loop

**Trigger:** `integration-report.md` shows all integration points passing.

Before spawning the deployment verifier, update `MANAGER_STATE.md`:
- Set `phase: 6`
- Set Phase 6 `status: in_progress`, increment `attempt`
- Set `Next Action` to `Spawn deployment-verifier (attempt [N])`

After each verifier returns:
- PASS: set Phase 6 `status: passed`, set `Next Action` to `Enter Phase 7 — Branch Completion`
- PARTIAL/FAIL: set Phase 6 `status: failed`, set `Next Action` to `Re-spawn affected tasks for deployment issues: [list task IDs]`; after re-spawns complete, loop back (increment `attempt` on next verifier spawn)

### Step 1 — Spawn deployment-verifier subagent

Spawn a focused verification sub-agent that invokes the `deployment-verifier` skill. Pass the project root path as the argument.

```
You are a deployment verification sub-agent.
Invoke the `deployment-verifier` skill immediately.

  Skill: deployment-verifier
  Args: [project-root path]

After the skill completes, return the full verification report verbatim to the manager, including:
- The final Verdict line (PASS / PARTIAL / FAIL)
- All Issues Found entries (issue description, root cause, fix needed)
- The Verdict Summary paragraph
Do not summarize or paraphrase. Return the exact report.
```

### Step 2 — Evaluate verdict

Read the returned verification report and classify:

| Verdict    | Action                                                                     |
| ---------- | -------------------------------------------------------------------------- |
| ✅ PASS    | Proceed to Phase 7                                                         |
| ⚠️ PARTIAL | Extract issues → re-spawn affected task agents (Step 3) → return to Step 1 |
| ❌ FAIL    | Extract issues → re-spawn affected task agents (Step 3) → return to Step 1 |

### Step 3 — Re-spawn task agents for fixes

For each issue in the verification report's "Issues Found" section:

1. Identify which task owns the failing component (match against `EXECUTION_PLAN.md`)
2. Re-spawn an implementation sub-agent for that task using the Phase 3 agent prompt template, adding these fields to the YAML payload:

```yaml
previous_attempt_review: |
  Deployment verification failed after integration passed.
  The system was actually started and tested — these are real runtime failures.
deployment_issues:
  - issue: "[exact issue description from verification report]"
    root_cause: "[root cause from verification report]"
    fix_required: "[fix needed from verification report]"
fix_scope: deployment_only # do not change anything outside the failing component
```

3. Wait for all re-spawned task agents to complete and pass Phase 4 checks (DONE.md Status = DONE)
4. Return to Step 1 and spawn a new `deployment-verifier` subagent

**Loop rule:** Continue Steps 1 → 2 → 3 → 1 until `deployment-verifier` returns ✅ PASS.

**Escalate to user only when:**

- Issue requires missing environment secrets (API keys, DB credentials) the codebase cannot provide
- Issue requires infrastructure the local environment cannot supply (external DB, third-party service)
- The same task has failed verification 3+ times with the same root cause

---

## Phase 7 — Branch Completion

**Trigger:** `deployment-verifier` returned ✅ PASS.

Before presenting options to the user, update `MANAGER_STATE.md`:
- Set `phase: 7`
- Set Phase 7 `status: in_progress`
- Set `Next Action` to `Present branch disposition options to user`

After the user selects a disposition and it is executed:
- Set Phase 7 `status: complete`
- Set `Next Action` to `Complete — branch disposition executed: [merge/PR/keep/discard]`

Before reporting completion, decide how this work will be integrated.

### Step 1 — Present exactly four options

```
Implementation complete. What would you like to do?

1. Merge back to the base branch locally
2. Push and create a Pull Request
3. Keep the branch as-is for later
4. Discard this work
```

### Step 2 — Execute the selected disposition

- **Merge locally:** switch to the base branch, update it, merge the feature branch, rerun the relevant verification, then clean up the branch or worktree if appropriate
- **Create PR:** push the branch, open a PR with a concise summary and test plan, then keep or clean up the worktree according to the chosen workflow
- **Keep as-is:** report the preserved branch and workspace location; do not clean up
- **Discard:** require explicit confirmation from the user, then delete the branch or worktree only after confirmation

### Step 3 — Report completion

Only after the branch disposition is executed, report to the user:

```
Status: COMPLETE
Built: [summary]
Output: [file tree]
Verification: PASS — system started and smoke tests passed
Branch disposition: [merged / PR opened / kept / discarded]
Deferred: [anything marked Skipped across all DONE.md files]
Known limitations: [anything marked Assumptions]
```

---

## Manager Decision Protocol

At every loop iteration, state explicitly:

```
Status: [what completed, what failed]
Decision: [proceed / re-spawn <task_id> / escalate to user]
Reason: [one sentence]
```

Escalate to the user only when:

- A blocker requires clarification only the user can provide
- A requirements ambiguity was discovered during implementation
- A fundamental architecture assumption in SPEC.md is wrong

---

## Additional Resources

- **`references/agent-prompt-patterns.md`** — Copy-paste task-scoped prompts for common work types (REST API, frontend, database, auth, workers, integration)
- **`references/execution-modes.md`** — Strict vs Lean mode rules, allowed shortcuts, and non-negotiable gates
- **`references/isolation-rules.md`** — Directory ownership rules, DONE.md contract, conflict prevention checklist
- **`references/review-gates.md`** — Required review artifacts, reviewer prompts, and approval criteria for Phase 4
- **`references/state-management.md`** — MANAGER_STATE.md format, field definitions, update triggers, and resumption procedure
- **`scripts/check-done.sh`** — Scan `[project-root]/modules/` for DONE.md files; exits 0 when all task outputs are DONE
