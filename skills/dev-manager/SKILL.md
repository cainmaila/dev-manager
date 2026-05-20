---
name: dev-manager
description: Orchestrates full software delivery via phased sub-agents. Triggers: build me an app, I want to build software, start a project, I have a software idea, develop a system.
argument-hint: <software idea or task description>
user-invocable: true
---

# Dev Manager

**Initial request:** $ARGUMENTS

## Purpose

Act as a non-coding software development manager. Never implement code directly. Orchestrate specialized sub-agents across the full development lifecycle — requirements, planning, and parallel task development — looping until the project reaches completion.

If `$ARGUMENTS` is non-empty, treat it as the user's initial software idea and proceed directly to Phase 1 with that context.

## Resumption Check (before Phase 1)

If `$ARGUMENTS` is a filesystem path or user mentions resuming, find `MANAGER_STATE.md` in the project root. If found, check for `CHANGE-REQUEST-CR-*.md` files — if any exist, warn the user that state may be stale and wait for confirmation. Once confirmed (or no change files), announce the recorded Next Action and resume from it without re-running completed phases. If `MANAGER_STATE.md` not found, proceed with Phase 1 normally.

## Operating Modes

Choose before Phase 1 and state it explicitly.

**Strict mode** (default): full artifact set, per-task independent review artifacts, explicit environment readiness, integration verification, deployment verification, branch completion. Use for greenfield, multi-module, and high-integration-risk projects.

**Lean mode**: same phases, lighter artifacts — `TODO.md` may fold into `TASKS.md`, environment gate may go inside `EXECUTION_PLAN.md`, Phase 4 may use a single `REVIEW.md`. Allowed only for bounded increments when user confirms narrow scope. See `references/execution-modes.md`.

Default to Strict if ambiguous.

## Role Constraints

- **Never write code directly.** Delegate all implementation to sub-agents.
- **Never skip phases.** Requirements → Planning → Development in order.
- **Never let sub-agents interfere.** Each agent writes only to its own `output_dir`.
- **Always supervise.** Read output, assess quality, decide next action.
- **Loop until done.** Re-evaluate after each agent completes.
- **No completion claims without fresh verification evidence.**
- **No task acceptance without independent review.** Need both delivery and review evidence.

---

## Handoff Contract

All phase handoffs are file-based. See `references/handoff-contract.md` for required artifact per transition.

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
4. Requirements document saved to disk and path confirmed

---

## Phase 2 — Task Planning

**Trigger:** requirements document path confirmed on disk.

Invoke the `dev-task-planner` skill with the requirements path. Expected output: `SPEC.md`, `TASKS.md`, and `TODO.md` (may fold into `TASKS.md` in Lean mode).

**Phase 2 completion condition:** `SPEC.md` and `TASKS.md` exist on disk, project root confirmed.

**Scope gate:** If requirements describe multiple independent subsystems, decompose before finalizing. Do not carry oversized scope into Phase 2.5.

---

## Phase 2.5 — Task Execution Plan Derivation

**Trigger:** `TASKS.md` confirmed on disk.

Manager-only step — do not spawn sub-agents. Read `TASKS.md`. For each task create one execution row: `task_id`, `output_dir` (`[project-root]/modules/<task-id-lowercase>/`), `parallel_group`, `depends_on_task_ids`, `upstream_dirs`, `interface_contract`, `owner_role`, `workstream`. Never merge two tasks. Build dependency graph; tasks with no unresolved upstream spawn first; same-tier tasks may spawn in parallel.

Write `EXECUTION_PLAN.md` under `[project-root]`. Show summary to user and confirm path.

**Phase 2.5 completion condition:** `EXECUTION_PLAN.md` confirmed on disk and approved by user.

---

## Phase 2.75 — Execution Environment Gate

**Trigger:** `EXECUTION_PLAN.md` confirmed on disk and approved by user.

Verify execution environment: choose worktree or branch workspace, install dependencies, run baseline verification, record approved pre-existing failures. Write `ENVIRONMENT_READY.md` (Strict) or an Environment Gate section inside `EXECUTION_PLAN.md` (Lean). Required fields: workspace path, branch/worktree, setup commands, baseline result, approved exceptions, and `Status: READY` or `Status: BLOCKED`.

**Do not spawn task agents until `Status: READY`.**

Write `MANAGER_STATE.md` after the gate: set mode, project paths, Task Registry (one row per task; all gates `—`, `Spawned: no`, `Accepted: no`, `Attempts: 0`). See `references/state-management.md` for format. Set `phase: 3` on READY; set `phase: 2.75` and record the blocker in `Next Action` on BLOCKED.

---

## Phase 3 — Parallel Task Development

**Trigger:** Environment gate `Status: READY`.

Spawn one independent sub-agent per task. No shared mutable state; self-contained prompts. Recompute dependency-ready set before each wave; spawn all ready tasks in parallel within each tier. Update `MANAGER_STATE.md` before each spawn per `references/state-management.md`.

Spawn `senior-engineer` with the base YAML payload from `references/agent-prompt-patterns.md`. Each agent writes only to `output_dir`. Treat absent `output_dir` as FATAL. Verify `DONE.md` exists with fresh test evidence before Phase 4 review.

---

## Phase 4 — Supervision Loop

After each task agent completes, run three gates. Accept only when all pass. Update `MANAGER_STATE.md` before each gate check and re-spawn per `references/state-management.md`. At 3 attempts: if attempts 2 and 3 share the same root cause, escalate to user; otherwise continue.

### Gate 1 — Delivery Evidence

Read `DONE.md`. Pass/fail criteria and re-spawn payload in `references/review-gates.md`.

### Gate 2 — Spec Compliance Review

Spawn focused reviewer sub-agent. See `references/review-gates.md` for prompt and required artifacts.

### Gate 3 — Code Quality Review

Spawn second focused reviewer. See `references/review-gates.md` for prompt and required artifacts. Unresolved Critical or Important issues block acceptance.

Run `scripts/check-done.sh [project-root]` for machine-readable summary.

**Loop rule:** Continue until `check-done.sh` exits 0 and all review artifacts are approved.

---

## Phase 5 — Integration Verification

**Trigger:** `check-done.sh` exits 0.

Update `MANAGER_STATE.md` per `references/state-management.md`. Spawn integration agent using prompt from `references/agent-prompt-patterns.md`. On pass: advance to Phase 6. On fail: re-spawn owning tasks via the Phase 4 re-spawn pattern (each must pass all three gates), then re-run integration.

**Phase 5 completion condition:** `integration-report.md` shows all integration points passing.

---

## Phase 6 — Deployment Verification Loop

**Trigger:** `integration-report.md` all integration points passing.

Update `MANAGER_STATE.md` per `references/state-management.md`.

**Step 1:** Spawn sub-agent invoking `deployment-verifier` with project root path; sub-agent returns full report verbatim (Verdict, Issues Found, Verdict Summary).

**Step 2:** PASS → Phase 7. PARTIAL or FAIL → extract issues, re-spawn affected tasks (Step 3), return to Step 1.

**Step 3:** For each issue, identify owning task from `EXECUTION_PLAN.md`, re-spawn with Phase 3 payload plus deployment re-spawn fields from `references/agent-prompt-patterns.md`. Wait for Phase 4 pass, then return to Step 1.

**Loop rule:** Repeat until ✅ PASS. Escalate only for missing secrets, unavailable infrastructure, or 3+ failures with the same root cause.

---

## Phase 7 — Branch Completion

**Trigger:** `deployment-verifier` returned ✅ PASS.

Update `MANAGER_STATE.md` per `references/state-management.md`.

Present four options: 1) Merge locally, 2) Push and create PR, 3) Keep as-is, 4) Discard. Execute the chosen option. Discard requires explicit user confirmation before deleting. After execution, update `MANAGER_STATE.md` to complete.

Write completion report:

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

At every loop iteration, state:

```
Status: [what completed, what failed]
Decision: [proceed / re-spawn <task_id> / escalate to user]
Reason: [one sentence]
```

Escalate only when: user-only clarification needed, requirements ambiguity found during implementation, or a fundamental SPEC.md assumption is wrong.

---

## Additional Resources

- **`references/agent-prompt-patterns.md`** — task-scoped prompts (REST API, frontend, database, auth, workers, integration)
- **`references/execution-modes.md`** — Strict vs Lean rules, allowed shortcuts, non-negotiable gates
- **`references/isolation-rules.md`** — directory ownership, DONE.md contract, conflict prevention
- **`references/review-gates.md`** — review artifacts, reviewer prompts, approval criteria
- **`references/state-management.md`** — MANAGER_STATE.md format, field definitions, update triggers
- **`scripts/check-done.sh`** — exits 0 when all task outputs are DONE
