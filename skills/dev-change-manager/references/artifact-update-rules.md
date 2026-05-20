# Artifact Update Rules

## 3A — Update requirements.md

Append changed sections. Mark changes with `<!-- CHANGE-REQUEST-[CR-id]: [YYYY-MM-DD] -->`.

## 3B — Update SPEC.md and TASKS.md

- **Small:** skip SPEC.md. Patch TASKS.md per 3C below.
- **Medium:** append to relevant SPEC.md sections only. Patch TASKS.md per 3C below.
- **Large:** re-invoke `dev-task-planner` with updated `requirements.md`. The planner fully regenerates `SPEC.md`, `TASKS.md`, and `TODO.md`. Skip 3C entirely — the planner owns those outputs.

```
Skill: dev-task-planner
Input: path to updated requirements.md
Goal: Regenerated SPEC.md, TASKS.md, TODO.md
```

## 3C — Patch TASKS.md (Small and Medium only)

- New tasks: append with next available ID
- Modified tasks: mark old as `[SUPERSEDED by TASK-NNN]`, add new task with new ID
- Removed tasks: mark as `[REMOVED by CR-[id]]` — do not delete rows

`TASKS.md` is the historical record, so superseded task entries remain there. `EXECUTION_PLAN.md` is the active execution graph, so superseded or removed tasks must not remain as active execution rows.

## 3D — Update EXECUTION_PLAN.md

**Small / Medium:** patch in place.

- Add rows for new tasks
- Replace modified task rows with the new active task rows
- Preserve all unchanged task rows
- Remove superseded or removed task rows from the active execution plan so scheduling uses only current tasks

**Large:** re-derive from scratch using the new `TASKS.md`, following the same rules as `dev-manager` Phase 2.5:

1. Create exactly one execution row per task
2. Assign `task_id`, `output_dir`, `parallel_group`, `depends_on_task_ids`, `upstream_dirs`, `interface_contract`, `owner_role`, and `workstream` for each row
3. Build dependency graph from `depends_on` fields
4. Overwrite `EXECUTION_PLAN.md` completely — do not carry forward any rows from the previous version

The previous `EXECUTION_PLAN.md` may have stale `parallel_group`, `depends_on`, or task boundaries after a Large change. It must not be used as a base.
