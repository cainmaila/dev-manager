# Senior-Engineer Payload Patterns

Reference payload patterns for common task types. Copy and adapt when spawning `senior-engineer` sub-agents. Every example below is a direct `senior-engineer` payload: one `TASK-NNN`, one `output_dir`, one acceptance boundary.

---

## REST API Task

```yaml
task_id: TASK-00X
title: "[REST API task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
output_dir: "project/modules/task-00x/"
spec_path: "[path to SPEC.md]"
interface_contract:
  - "Expose only the endpoint or contract slice assigned to TASK-00X"
  - "Request/response schemas must match spec exactly"
depends_on_task_ids:
  - "[upstream task id if any]"
upstream_dirs:
  - "[upstream output dir if any]"
verify_command: "[task-scoped test command]"
owner_role: "Backend developer"
workstream: "Backend"
parallel_group: "PG-1"
```

Pass this payload directly to `senior-engineer`.

---

## Frontend Task

```yaml
task_id: TASK-00X
title: "[Frontend task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
output_dir: "project/modules/task-00x/"
spec_path: "[path to SPEC.md]"
interface_contract:
  - "Consume only the API contract slice needed by TASK-00X"
  - "Do not implement API logic; call the endpoints only"
depends_on_task_ids:
  - "[upstream task id if any]"
upstream_dirs:
  - "[upstream output dir if any]"
verify_command: "[task-scoped test command]"
owner_role: "Frontend developer"
workstream: "Frontend"
parallel_group: "PG-1"
```

Pass this payload directly to `senior-engineer`.

---

## Database / Schema Task

```yaml
task_id: TASK-00X
title: "[Database task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
output_dir: "project/modules/task-00x/"
spec_path: "[path to SPEC.md]"
interface_contract:
  - "Table names and column names must match the contract slice assigned to TASK-00X exactly"
depends_on_task_ids:
  - "[upstream task id if any]"
upstream_dirs:
  - "[upstream output dir if any]"
verify_command: "[task-scoped test command]"
owner_role: "Platform developer"
workstream: "Data"
parallel_group: "PG-1"
```

Pass this payload directly to `senior-engineer`.

---

## Auth Task

```yaml
task_id: TASK-00X
title: "[Auth task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
output_dir: "project/modules/task-00x/"
spec_path: "[path to SPEC.md]"
interface_contract:
  - "Expose only the auth contract slice assigned to TASK-00X"
  - "Token format: [JWT / session / as specified in spec]"
depends_on_task_ids:
  - "[upstream task id if any]"
upstream_dirs:
  - "[upstream output dir if any]"
verify_command: "[task-scoped test command]"
owner_role: "Backend developer"
workstream: "Auth"
parallel_group: "PG-1"
```

Pass this payload directly to `senior-engineer`.

---

## Background Worker / Queue Task

```yaml
task_id: TASK-00X
title: "[Worker task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
output_dir: "project/modules/task-00x/"
spec_path: "[path to SPEC.md]"
interface_contract:
  - "Consume only the queue contract assigned to TASK-00X"
  - "Produce output to: [destination from spec]"
depends_on_task_ids:
  - "[upstream task id if any]"
upstream_dirs:
  - "[upstream output dir if any]"
verify_command: "[task-scoped test command]"
owner_role: "Platform developer"
workstream: "Workers"
parallel_group: "PG-1"
```

Pass this payload directly to `senior-engineer`.

---

## Integration Agent

Use after all task outputs complete:

```
You are a software integration engineer. Do not write new features.

Your task: Assemble all task outputs and verify they work together.
Task outputs location: project/modules/
System spec: [path]

Steps:
1. Read each task output's DONE.md
2. Verify interface contracts are honored between tasks
3. Write a minimal integration test or smoke test script
4. Run it and report results

Output: project/integration-report.md containing:
  - Pass/fail per integration point
  - Any contract violations found
  - Recommended fixes (do not implement them yourself)

Rules:
- Read files freely across all task outputs
- Do not modify task output source files
- Write only to project/integration-report.md
```
