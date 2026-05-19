# Cleanup Rules Reference

## Document Inventory

All documents managed by `dev-manager` and `dev-change-manager` that this skill audits:

### Project-level documents

| File                        | Owner skill          | Authoritative? |
| --------------------------- | -------------------- | -------------- |
| `requirements.md`           | dev-manager (Ph1)    | Yes — source of truth for what system must do |
| `SPEC.md`                   | dev-manager (Ph2)    | Yes — architecture and tech stack decisions |
| `TASKS.md`                  | dev-manager (Ph2)    | Yes — task definitions; accumulates superseded rows |
| `TODO.md`                   | dev-manager (Ph2)    | Derived — checklist; may be folded into TASKS.md |
| `EXECUTION_PLAN.md`         | dev-manager (Ph2.5)  | Yes — active task execution graph |
| `ENVIRONMENT_READY.md`      | dev-manager (Ph2.75) | Yes — environment gate record |
| `MANAGER_STATE.md`          | dev-manager (Ph2.75) | Yes — live state; must stay accurate |
| `integration-report.md`     | dev-manager (Ph5)    | Latest run only — previous runs obsolete |
| `CHANGE-REQUEST-CR-*.md`    | dev-change-manager   | Historical record |
| `CHANGE-IMPACT-CR-*.md`     | dev-change-manager   | Historical record |

### Per-task documents (under `modules/<task-id>/`)

| File                | Owner skill         | Authoritative? |
| ------------------- | ------------------- | -------------- |
| `DONE.md`           | senior-engineer     | Yes — delivery record for that task |
| `SPEC_REVIEW.md`    | manager (Ph4 Gate2) | Yes for that review cycle only |
| `QUALITY_REVIEW.md` | manager (Ph4 Gate3) | Yes for that review cycle only |
| `REVIEW.md`         | manager (Lean mode) | Combined review; same as above |

---

## Classification Rules by Document Type

### TASKS.md

**Current** when: all active tasks in EXECUTION_PLAN.md have matching, non-superseded rows.

**Needs compaction** when: contains rows marked `[SUPERSEDED by TASK-NNN]` or `[REMOVED by CR-NNN]`.

Compaction format:
1. Keep all active task rows unchanged (top section)
2. Add a `## Change History` section at the bottom
3. Move all superseded/removed rows there with their original content intact
4. Add a one-line note: `<!-- Moved to Change History by dev-doc-cleaner on [date] -->`

Do not delete superseded task rows entirely — they are the historical record.

### CHANGE-REQUEST-CR-*.md and CHANGE-IMPACT-CR-*.md

**Current** when: the CR was applied in the current project state (i.e., EXECUTION_PLAN.md reflects its changes).

**Stale** when: CR was applied, all affected tasks are DONE, and the project has since had further CRs applied on top. The original CR is no longer the most recent change.

**Obsolete** when: CR was applied and fully superseded by a later CR (same scope, newer version). The older one can be archived.

Archive decision matrix:
| CR applied? | Superseded by later CR? | Action |
| ----------- | ----------------------- | ------ |
| No          | —                       | Keep — in-progress CR |
| Yes         | No                      | Keep — latest applied CR |
| Yes         | Yes (partial overlap)   | Stale → archive |
| Yes         | Yes (full overlap)      | Obsolete → archive |

Never delete CHANGE-REQUEST or CHANGE-IMPACT files. Archive only (move to `.archive/`).

### MANAGER_STATE.md

**Current** when: phase matches actual project phase, task registry rows match EXECUTION_PLAN.md active tasks, gate columns reflect actual artifact presence.

**Conflict** when any of:
- Task row shows `Accepted: no` but `DONE.md` Status = DONE
- Task row exists for a task not in EXECUTION_PLAN.md (removed/superseded tasks)
- Phase number is behind what the artifact set indicates
- `Next Action` references a task ID that no longer exists

Conflict resolution:
- `Accepted: no` + `DONE.md Status = DONE` → set `Accepted: yes`, set gates to `pass` where evidence exists
- Stale task row (removed from EXECUTION_PLAN.md) → move row to an `## Archived Tasks` section at the bottom
- Stale Next Action → update to reflect current actual next step

### integration-report.md

**Current** when: matches the most recent Phase 5/6 integration run.

**Obsolete** when: a later CR triggered re-integration and a newer `integration-report.md` exists.

If only one exists → always keep. If multiple exist (unlikely but possible after CRs) → keep latest, archive rest.

### ENVIRONMENT_READY.md

**Current** when: Status field is READY and workspace path still exists.

**Stale** when: workspace path no longer exists (worktree was cleaned up) but Status is READY.

**Obsolete** when: project was completed and branch disposed.

For stale environments: add a note at the top `<!-- Workspace no longer available — verified [date] by dev-doc-cleaner -->`. Do not delete — it is a record of what was done.

### Per-task review files (SPEC_REVIEW.md, QUALITY_REVIEW.md, REVIEW.md)

**Current** when: task is in EXECUTION_PLAN.md as an active task AND review status is APPROVED.

**Obsolete** when:
- Task is marked superseded in TASKS.md
- Task was re-spawned due to a CR and a newer review exists

For obsolete per-task modules (entire module superseded): archive the whole `modules/<task-id>/` directory.

For re-spawned tasks with older reviews: the old review files are overwritten by the re-spawn — no action needed unless orphaned files exist.

### TODO.md

**Current** when: items match current TASKS.md active tasks.

**Obsolete** when: fully folded into TASKS.md, all items checked, and MANAGER_STATE.md shows phase 7 complete.

Safe to archive if phase 7 is complete and TASKS.md is the source of truth.

---

## Archive vs Delete Decision Matrix

| Condition | Action |
| --------- | ------ |
| File is historical record (CR files, review artifacts) | Archive to `.archive/` |
| File is derived/transient and superseded | Archive to `.archive/` |
| File is a duplicate of current content | Archive |
| File contains no information not in a newer artifact | Archive |
| User explicitly approved deletion | Delete |

Default to archive over delete when uncertain. Deletion requires explicit approval per file in the cleanup plan.

---

## .archive/ Directory

- Location: `[project-root]/.archive/`
- Create if absent
- Preserve original filenames
- For per-task module archives: `[project-root]/.archive/modules/<task-id>/`
- Add a one-line `README.md` to `.archive/` if it does not exist:
  ```
  # Archive
  Documents moved here by dev-doc-cleaner. Safe to delete if project is complete.
  ```

---

## What Never to Touch

- `requirements.md` — only user modifies this directly (or via dev-change-manager)
- `SPEC.md` — only dev-task-planner or dev-change-manager modifies this
- `TASKS.md` active rows — compaction moves superseded rows to history section, never edits active rows
- Any `DONE.md` — delivery record; read-only for this skill
- Any file outside the project root — this skill is scoped strictly to the project directory
