# MANAGER_STATE.md Update Rules for Dev Change Manager

If `MANAGER_STATE.md` exists at project root, update it throughout Phase 4 using these rules:

| Moment                                       | What to update                                                                                                                                                                          |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Before spawning a re-spawned task            | Reset its gate columns to `—`, set `Accepted: no`, increment `Attempts`, append `[task_id] attempt N: initial spawn (change request [CR-id])` to `## Attempt Log`, update `Next Action` |
| After agent returns (before reading DONE.md) | Set `Spawned: yes`, set `Gate1: pending`, update `Next Action`                                                                                                                          |
| After Gate 1 passes                          | Set `Gate1: pass`; leave `Gate2` and `Gate3` as `—` (not run in this skill); set `Accepted: yes`, update `Next Action`                                                                  |
| On Gate 1 failure / re-spawn                 | Increment `Attempts`, append to `## Attempt Log` with root cause, reset `Gate1: —`, update `Next Action`                                                                                |
| After all re-spawned tasks accepted          | Update `Next Action` to `Enter Phase 5 Re-integration (change request [CR-id])`                                                                                                         |

Note: this skill runs Gate 1 (delivery evidence) only — it does not run independent Gate 2 (spec review) or Gate 3 (quality review) sub-agents.
