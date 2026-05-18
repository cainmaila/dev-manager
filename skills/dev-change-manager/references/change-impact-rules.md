# Change Impact Rules

Reference for determining which pipeline phases to re-enter and which artifacts to update.

---

## Impact Classification Matrix

| Change Type                      | SPEC.md update?      | TASKS.md update?     | Re-run dev-task-planner? | Tasks to re-spawn |
| -------------------------------- | -------------------- | -------------------- | ------------------------ | ----------------- |
| Bug fix / small tweak            | No                   | Patch only           | No                       | 1–2 affected      |
| New field / endpoint             | Minor (data model)   | Add 1–3 tasks        | No                       | Affected tasks    |
| New feature (fits existing arch) | Yes (section append) | Add workstream       | Recommended              | New + downstream  |
| Architecture change              | Yes (major)          | Full re-decompose    | Required                 | All affected      |
| Removal / deprecation            | Yes (remove section) | Remove + update deps | No                       | All dependents    |

---

## Decision Tree

```
Is the change scoped to one existing task or one tightly-coupled task chain?
  YES → Patch TASKS.md, re-spawn only the affected task(s) (Small)
  NO ↓

Does the change require new architecture decisions in SPEC.md?
  YES → Re-run dev-task-planner with updated requirements.md (Large)
  NO ↓

Does the change add tasks to an existing workstream without cross-task contract changes?
  YES → Append tasks to TASKS.md, update EXECUTION_PLAN.md, re-spawn affected tasks (Medium)
  NO → Re-run dev-task-planner (Large)
```

---

## Artifact Update Rules

### requirements.md

- Always update. Mark changed sections with `<!-- CHANGE-REQUEST-[CR-id]: [YYYY-MM-DD] -->` comment.
- Append new features as new sections — do not rewrite existing sections unless they conflict.

### SPEC.md

- Small: skip
- Medium: append to relevant section (e.g., add endpoint to §API-Contracts, add table to §Data-Models)
- Large: re-run dev-task-planner; the planner produces new SPEC.md

### TASKS.md

- Small/Medium: Patch directly.
  - New tasks: append with new IDs (e.g., existing max is TASK-012, new tasks start TASK-013)
  - Modified tasks: mark old task as `[SUPERSEDED by TASK-NNN]`, add new task
  - Removed tasks: mark as `[REMOVED by CR-[id]]`, do not delete rows
- Large: full regeneration via dev-task-planner

### EXECUTION_PLAN.md

- Small/Medium: patch in place.
  - Add new rows for new tasks
  - Replace modified task rows with the new active task rows
  - Do not remove rows for unchanged tasks — they remain valid
  - Remove superseded or removed task rows so the active execution graph contains only current tasks
- Large: re-derive one execution row per task from the regenerated `TASKS.md` using the same dependency and scheduling rules as `dev-manager` Phase 2.5, then overwrite `EXECUTION_PLAN.md` completely.
  - Do not carry forward rows from the previous plan; old `parallel_group`, `depends_on`, or task boundaries may be stale.

---

## Task Re-spawn Rules

### When to re-spawn a task

- The task itself is modified or newly added
- Its interface contract changed (another task now consumes or produces differently)
- A task it depends on was re-spawned and produced different outputs

### When NOT to re-spawn a task

- No tasks changed
- Its interface contract is unchanged
- It has Status = DONE and no upstream changes touched its consumed interfaces

### Re-spawn payload additions

Always add to the YAML when re-spawning for a change:

```yaml
change_context:
  change_request_id: "[CR-id]"
  change_summary: "[one-line description of what changed]"
  changed_tasks:
    - "[task id]: [what changed]"
  unchanged_outputs_to_preserve:
    - "[file or behavior that must not be modified]"
```

---

## Integration Re-run Rules

Always re-run integration (Phase 5) after any re-spawn.
Reason: contract changes in one task can break adjacent tasks even if those tasks were not re-spawned.

Always re-run deployment-verifier (Phase 6) after integration passes.
Reason: integration checks contracts; deployment-verifier checks runtime.

---

## CHANGE-IMPACT-[CR-id].md Format

```markdown
# Change Impact — CR-[id]

## Change Summary

[One paragraph description]

## Classification

[Small / Medium / Large]

## Artifacts to Update

- [ ] requirements.md — [what to change]
- [ ] SPEC.md — [what to change, or "no change"]
- [ ] TASKS.md — [task IDs affected: new / modified / removed]
- [ ] EXECUTION_PLAN.md — [patch or regenerate; tasks added / modified / unchanged]

## Tasks to Re-spawn

| Task ID | Reason | Change Type              |
| ------- | ------ | ------------------------ |
| [task]  | [why]  | [new/modified/unchanged] |

## Tasks to Preserve

| Task ID | Reason                 |
| ------- | ---------------------- |
| [task]  | [why no change needed] |

## Re-integration Required

[Yes / No — reason]
```
