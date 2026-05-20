# Senior-Engineer Payload Patterns

Reference payload patterns for common task types. Copy and adapt when spawning `senior-engineer` sub-agents. Every example below is a direct `senior-engineer` payload: one `TASK-NNN`, one `output_dir`, one acceptance boundary.

---

## Base Payload Template

```yaml
task_id: [task_id]
title: "[task title]"
acceptance_criteria:
  - "[criterion from TASKS.md]"
  - "[criterion from TASKS.md]"
output_dir: "[output_dir]"
spec_path: "[full path to SPEC.md]"
interface_contract:
  - "[contract item from TASKS.md contract fields]"
depends_on_task_ids:
  - "[upstream task id]"
upstream_dirs:
  - "[upstream task output_dir, read-only]"
verify_command: "[test command scoped to this task, e.g. pytest modules/task-001/tests/ -v]"
owner_role: "[owner role]"
workstream: "[workstream]"
parallel_group: "[parallel group]"
```

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

Spawn once after all task outputs complete. Write only to `[project-root]/integration-report.md` and `[project-root]/integration/`.

```
You are a software integration engineer. Do not write new features or modify module source.

Project root: [path]
Modules: [list of output_dirs]
System spec: [SPEC.md path]

Steps:
1. Read each module's DONE.md
2. Verify interface contracts are honored across module boundaries
3. Write a minimal integration smoke test or verification script
4. Run it and report results

Output:
  - [project-root]/integration-report.md containing:
  - Pass/fail per integration point
  - Any contract violations found
  - Recommended fixes (list only — do not implement)
  - Optional supporting verification scripts under [project-root]/integration/

Rules:
- Read any file freely
- Write only to [project-root]/integration-report.md and [project-root]/integration/
- Do not modify module source files
```

---

## Deployment Re-spawn Payload Additions

When re-spawning for deployment failures, add these fields to the standard task YAML payload:

```yaml
previous_attempt_review: |
  Deployment verification failed after integration passed.
  The system was actually started and tested — these are real runtime failures.
deployment_issues:
  - issue: "[exact issue description from verification report]"
    root_cause: "[root cause from verification report]"
    fix_required: "[fix needed from verification report]"
fix_scope: deployment_only # do not change anything outside the failing component
```
