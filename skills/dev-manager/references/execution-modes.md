# Execution Modes

Use execution modes to tune workflow weight without skipping lifecycle gates.

---

## Strict Mode

Use for:

- Greenfield systems
- Vague or under-specified requests
- Multi-module delivery
- Any project with meaningful integration or runtime risk

Strict mode requires:

- Separate `SPEC.md`, `TASKS.md`, and `TODO.md`
- `EXECUTION_PLAN.md` with one row per task
- `ENVIRONMENT_READY.md`
- Per-task `DONE.md`
- Per-task `SPEC_REVIEW.md`
- Per-task `QUALITY_REVIEW.md`
- `integration-report.md`
- Deployment verification PASS before branch completion

---

## Lean Mode

Use only when:

- The user confirms the work is a bounded increment inside an existing system
- The execution graph is small and easy to reason about
- Runtime risk is limited or localized

Lean mode may lighten artifacts:

- `TODO.md` may be folded into `TASKS.md`
- `ENVIRONMENT_READY.md` may be replaced by an `Environment Gate` section inside `EXECUTION_PLAN.md`
- `SPEC_REVIEW.md` and `QUALITY_REVIEW.md` may be combined into a single `REVIEW.md`

Lean mode does **not** allow:

- Skipping requirements capture
- Skipping execution planning
- Skipping independent review
- Skipping integration verification when multiple task outputs interact
- Skipping deployment verification when the deliverable changes a runnable system

---

## Selection Rule

If there is doubt, choose Strict mode.

If the manager later discovers the scope or risk was underestimated, immediately promote the project from Lean to Strict and say so explicitly.
