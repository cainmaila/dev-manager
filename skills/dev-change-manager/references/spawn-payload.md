# Re-spawn Payload Template

Use when spawning `senior-engineer` sub-agents in Phase 4. Add `change_context` to the standard payload.

```yaml
task_id: [task_id]
title: "[task title]"
acceptance_criteria:
  - "[from updated TASKS.md]"
output_dir: "[task output dir]"
spec_path: "[path to SPEC.md]"
interface_contract:
  - "[updated contract items]"
depends_on_task_ids:
  - "[upstream task ids]"
upstream_dirs:
  - "[upstream dirs — include re-spawned upstream tasks]"
verify_command: "[test command for this task]"
owner_role: "[owner role]"
workstream: "[workstream]"
parallel_group: "[parallel group]"
change_context:
  change_request_id: "[CR-id]"
  change_summary: "[one-line change description]"
  changed_tasks:
    - "[task id]: [what changed]"
  unchanged_outputs_to_preserve:
    - "[files or behaviors that must not change]"
```

---

## Integration Failure on Preserved Task

When a preserved task fails integration due to upstream contract drift, re-spawn it with:

```yaml
change_context:
  change_request_id: "[CR-id]"
  change_summary: "Integration failure due to upstream contract change from CR-[id]"
  changed_tasks: []
  unchanged_outputs_to_preserve: []
```
