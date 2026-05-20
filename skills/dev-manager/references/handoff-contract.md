# Phase Handoff Contract

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

`MANAGER_STATE.md` is a persistent state file — not a one-time handoff artifact. Created at end of Phase 2.75, maintained through Phase 7. See `references/state-management.md` for format and update rules.
