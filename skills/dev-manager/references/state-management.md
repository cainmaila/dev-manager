# Manager State Management

`MANAGER_STATE.md` is the manager's persistent recovery file. It is written at project root by the manager and by no other agent. Its purpose is to allow resumption after any interruption — session end, context loss, or crash — without re-running completed work.

---

## When to Create

At the end of Phase 2.75, immediately after writing `ENVIRONMENT_READY.md` (or the environment gate section). Before this point, no task agents exist and recovery is trivial: re-read requirements and planning artifacts and re-run the phase.

---

## When to Update

Update `MANAGER_STATE.md` **before executing** each of the following actions, not after. If interrupted mid-action, the recorded "Next Action" will reflect what needs to be retried:

| Trigger | What to update |
|---|---|
| About to spawn a Phase 3 task agent | Set `Next Action`, set task row `Spawned: pending`, append `[task_id] attempt 1: initial spawn` to `## Attempt Log` |
| Task agent returns, about to check Gate 1 | Set task row `Spawned: yes`, set `Gate1: pending`, update `Next Action` |
| Gate 1 result known | Set `Gate1: pass` or `Gate1: fail`; update `Next Action` |
| About to spawn Gate 2 reviewer | Set `Gate2: pending`, update `Next Action` |
| Gate 2 result known | Set `Gate2: pass` or `Gate2: fail`; update `Next Action` |
| About to spawn Gate 3 reviewer | Set `Gate3: pending`, update `Next Action` |
| Gate 3 result known | Set `Gate3: pass` or `Gate3: fail`; update `Next Action` |
| Task accepted | Set `Accepted: yes`, update `Next Action` |
| Re-spawning a task | Increment `Attempts`, reset failing gate to `—`, append `[task_id] attempt N: [gate] [result] — [root cause]` to `## Attempt Log`, update `Next Action` |
| All tasks accepted, about to enter Phase 5 | Set `phase: 5`, set integration `status: in_progress`, update `Next Action` |
| Integration result known | Set integration `status: passed` or `status: failed`, update `Next Action` |
| About to enter Phase 6 (each verifier spawn) | Set `phase: 6`, set deployment `status: in_progress`, increment `attempt`, update `Next Action` |
| Deployment verifier returns | Set deployment `status: passed/partial/failed`, update `Next Action` |
| Entering Phase 7 | Set `phase: 7`, set branch `status: in_progress`, update `Next Action` |
| Branch disposition executed | Set branch `status: complete`, update `Next Action` |

---

## File Format

Write this exact structure. Do not add sections or rename headings — the manager reads this file programmatically on resumption.

```markdown
# Manager State

mode: Strict
phase: 4
project_root: ./myproject
requirements_path: ./requirements.md
spec_path: ./myproject/SPEC.md
execution_plan_path: ./myproject/EXECUTION_PLAN.md

## Next Action

Re-spawn TASK-002 — Gate2 (Spec Compliance) returned CHANGES_REQUIRED: missing pagination support on GET /items.

## Task Registry

| Task ID  | Spawned | Gate1   | Gate2 | Gate3 | Accepted | Attempts |
|----------|---------|---------|-------|-------|----------|----------|
| TASK-001 | yes     | pass    | pass  | pass  | yes      | 1        |
| TASK-002 | yes     | pass    | fail  | —     | no       | 2        |
| TASK-003 | yes     | pending | —     | —     | no       | 1        |

## Phase 5 — Integration
status: not_started

## Phase 6 — Deployment
status: not_started
attempt: 0

## Phase 7 — Branch
status: not_started

## Attempt Log

- TASK-001 attempt 1: initial spawn
- TASK-002 attempt 1: initial spawn
- TASK-003 attempt 1: initial spawn
- TASK-002 attempt 2: Gate2 CHANGES_REQUIRED — missing pagination on GET /items
```

---

## Field Definitions

**Header fields:**

| Field | Values | Notes |
|---|---|---|
| `mode` | `Strict` / `Lean` | Set once at mode selection; never changes |
| `phase` | `3` / `4` / `5` / `6` / `7` | Current execution phase; advance when entering a new phase |
| `project_root` | path string | Confirmed by user at Phase 2 completion |
| `requirements_path` | path string | Confirmed by user at Phase 1 completion |
| `spec_path` | path string | Path to SPEC.md |
| `execution_plan_path` | path string | Path to EXECUTION_PLAN.md |

**Next Action field:**

One sentence describing the single next action the manager is about to take. This is the primary recovery anchor — on resumption, read this line and execute it. Be specific: include task ID, gate number, and reason.

**Task Registry gate values:**

| Value | Meaning |
|---|---|
| `—` | Gate not yet reached for this task |
| `pending` | Manager has spawned the agent or reviewer but not yet read the result |
| `pass` | Gate passed |
| `fail` | Gate failed; task needs re-spawn |

**Lean mode — combined REVIEW.md:** In Lean mode, Gates 2 and 3 may use a single combined `REVIEW.md` instead of separate `SPEC_REVIEW.md` and `QUALITY_REVIEW.md`. Still populate `Gate2` and `Gate3` as separate columns: set `Gate2` from the `## Spec Compliance` decision and `Gate3` from the `## Code Quality` decision in the combined file. Read them sequentially. Both columns remain required even when sourced from one artifact.

**Phase 5–7 status values:**

| Value | Meaning |
|---|---|
| `not_started` | Phase not yet entered |
| `in_progress` | Agent or verifier spawned; result not yet read |
| `passed` | Phase complete with passing result |
| `failed` | Phase returned failure; re-spawn loop active |
| `complete` | Final state; used for Phase 7 only |

---

## Resumption Procedure

When the manager re-enters an existing project (e.g., user re-invokes `dev-manager` with a project path, or references an in-progress project):

1. Check for `MANAGER_STATE.md` in the project root.
2. If found: read it. Announce to the user:
   > "Found existing project state. Resuming from: [Next Action line]."
3. Execute the recorded Next Action.
4. Continue the normal supervision loop from that point.
5. Task skip rule: if a task row has `Accepted: yes`, skip it entirely — do not re-check any of its gate columns regardless of their values. `Accepted: yes` is the authoritative final state; gate columns for that task are informational only.
6. For tasks not yet accepted: do not re-run a gate already marked `pass`; pick up from the lowest gate column that is `pending` or `—` after the last `pass`.

**Conflict resolution on resumption:**

If `MANAGER_STATE.md` says a gate is `pending` but the artifact file (e.g. `SPEC_REVIEW.md`) already exists on disk, read the artifact and update the state to `pass` or `fail` before proceeding. The artifact on disk is authoritative; `pending` means the result was not yet recorded in state.

---

## Attempt Log

The `Attempts` column counts spawn attempts but does not preserve root cause history — the `Next Action` field is overwritten on every update. To support the "same root cause 3 times" escalation rule, append an `## Attempt Log` section to `MANAGER_STATE.md`. Each entry is one line per spawn attempt, starting from attempt 1:

```markdown
## Attempt Log

- TASK-002 attempt 1: initial spawn
- TASK-002 attempt 2: Gate2 CHANGES_REQUIRED — missing pagination on GET /items
- TASK-002 attempt 3: Gate2 CHANGES_REQUIRED — missing pagination on GET /items
```

Log attempt 1 when first spawning the task (root cause = "initial spawn"). Log subsequent attempts at re-spawn time with the specific gate failure and root cause.

**Escalation rule:** When `Attempts` for a task reaches 3, read its last three `Attempt Log` entries. If the root cause description (after `—`) is substantively the same across attempts 2 and 3 (the two re-spawn attempts), escalate to the user instead of re-spawning. Record the escalation in `Next Action`:

```
Escalate TASK-002 to user — same root cause in 3 attempts: [root cause]
```

If the root causes differ across attempts, continue re-spawning with the latest feedback.
