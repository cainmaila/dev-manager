# Output File Templates

## Folder Structure

```
{project-name}/
├── SPEC.md       # System specification
├── TASKS.md      # Full task breakdown
└── TODO.md       # Flat tracking checklist
```

---

## SPEC.md Template

```markdown
# System Specification: {Project Name}

**Generated:** {date}
**Status:** Draft

---

## 1. Overview

{2–3 sentence description of what the system does and who uses it}

---

## 2. Technical Stack

| Layer               | Decision        | Notes                |
| ------------------- | --------------- | -------------------- |
| Language            | {value}         | version: {value}     |
| Backend Framework   | {value}         |                      |
| Frontend Framework  | {value or N/A}  |                      |
| Database            | {value or N/A}  | ORM: {value or none} |
| Cache               | {value or none} |                      |
| Migration strategy  | {value or N/A}  |                      |
| Auth method         | {value or none} |                      |
| Authorization model | {value or none} |                      |
| Infrastructure      | {value}         | Containers: {yes/no} |
| Environments        | {list}          |                      |
| CI/CD               | {value or none} |                      |

---

## 3. Architecture Overview

{Brief description of system layers and how they interact.
Keep it to the decisions made — no speculation.}

---

## 4. Integrations

| Service | Purpose   | Credentials            | Webhooks                     |
| ------- | --------- | ---------------------- | ---------------------------- |
| {name}  | {purpose} | {available/needed/N/A} | {inbound/outbound/both/none} |

<!-- If no integrations: replace the table with a single line: "None." -->

---

## 5. Constraints

- **Team:** {size and roles}
- **Deadline:** {date or "none stated"}
- **Budget:** {description or "none stated"}
- **Repo structure:** {monorepo / separate repos / N/A}
- **Existing codebase:** {description or "none"}
- **Compliance:** {requirements or "none"}
- **Must-use tech:** {list or "none"}
- **Forbidden tech:** {list or "none"}

---

## 6. Non-Functional Requirements

- **Scale target:** {value or "not specified"}
- **Response time target:** {value or "not specified"}
- **Availability SLA:** {value or "not specified"}
- **Observability:** {list or "none"}

---

## 7. MVP Scope

Features included in MVP:

- {feature}

Features deferred:

- {feature} — reason: {reason}

---

## 8. Parallel Development Plan

- **Expected parallel developers:** {value or "not specified"}
- **Split strategy:** {by layer / by domain / by user journey / no preference / "not specified"}
- **Contract-first boundaries:** {list or "none"}
- **Mock/stub policy:** {allowed / not allowed / limited / "not specified"}
- **Integration checkpoints:** {value or "none stated"}

---

## 9. Open Risks

| Risk          | Impact  | Mitigation       |
| ------------- | ------- | ---------------- |
| {description} | {H/M/L} | {plan or "none"} |
```

---

## TASKS.md Template

```markdown
# Development Tasks: {Project Name}

**Total tasks:** {n}
**Generated:** {date}
**Parallel planning:** shared prerequisites first, then fan out by workstream and parallel group

---

## Workstream Summary

| Workstream  | Goal                       | Can start after | Notes                                        |
| ----------- | -------------------------- | --------------- | -------------------------------------------- |
| {Contracts} | {freeze shared interfaces} | {none}          | {feeds multiple downstream tasks}            |
| {Backend}   | {deliver backend slice}    | {TASK-NNN}      | {parallel with Frontend after contract task} |

## Task Format

Each task follows this structure:

Each task maps to exactly one execution payload and one isolated output directory. `parallel_group` decides scheduling order only; it does not allow later orchestration to merge sibling tasks back together.

### TASK-{NNN}: {Outcome-oriented title}

**Area:** {Backend / Frontend / Infra / Data / Auth / Integration / Testing}
**Workstream:** {Contracts / Backend / Frontend / Infra / Data / QA / Integration}
**Parallel Group:** {PG-0 / PG-1 / PG-2 / none}
**Owner Role:** {Backend developer / Frontend developer / Platform developer / Full-stack developer / QA}
**Size:** {S = hours | M = 1 day}
**Depends on:** {TASK-NNN, TASK-NNN | none}
**Execution Output Dir:** {[project-root]/modules/task-{nnn}/}
**Produces:** {artifact, contract, fixture, schema, migration, component API | none}
**Consumes:** {artifact, contract, fixture, schema, migration, component API | none}

**Description:**
{One paragraph. What needs to exist when this task is done. No implementation details.}

**Acceptance Criteria:**

- [ ] {Concrete, checkable condition}
- [ ] {Concrete, checkable condition}
- [ ] {Concrete, checkable condition}

---

## Tasks

### TASK-001: {title}

**Area:** {area}
**Workstream:** {workstream}
**Parallel Group:** {parallel group}
**Owner Role:** {owner role}
**Size:** S
**Depends on:** none
**Execution Output Dir:** {[project-root]/modules/task-001/}
**Produces:** {artifact or contract}
**Consumes:** none

**Description:**
{description}

**Acceptance Criteria:**

- [ ] {criterion}
- [ ] {criterion}

---

### TASK-002: {title}

...
```

---

## TODO.md Template

```markdown
# Task TODO: {Project Name}

Generated from TASKS.md. Use this for integration with task managers, or as a flat checklist.

---

## Backlog

- [ ] TASK-001 [Contracts][PG-0][Backend]: {title}
- [ ] TASK-002 [Backend][PG-1][Backend]: {title}
- [ ] TASK-003 [Frontend][PG-1][Frontend]: {title}

## In Progress

(move tasks here when started)

## Done

(move tasks here when all acceptance criteria pass)

---

## Stats

- Total: {n}
- Backlog: {n}
- In Progress: 0
- Done: 0
```

---

## Example: Minimal Task

### TASK-003: User can register with email and password

**Area:** Backend
**Workstream:** Backend
**Parallel Group:** PG-1
**Owner Role:** Backend developer
**Size:** S
**Depends on:** TASK-001 (database schema), TASK-002 (password hashing library installed)
**Execution Output Dir:** {[project-root]/modules/task-003/}
**Produces:** POST /auth/register contract implementation
**Consumes:** auth API schema, user table schema, password hashing helper

**Description:**
A POST endpoint `/auth/register` accepts email and password, validates format, hashes the password, stores the user record, and returns a success response. Duplicate email returns a 409.

**Acceptance Criteria:**

- [ ] POST `/auth/register` with valid email + password returns 201 and a user ID
- [ ] Duplicate email returns 409 with error message
- [ ] Password is stored as a hash, never plaintext
- [ ] Invalid email format returns 400

---

## Task Splitting Signals

Split a task further if any of these are true:

- Acceptance criteria has more than 5 items
- "Done" condition requires the entire system to be running
- The task touches more than one data model AND more than one API endpoint
- A developer cannot describe what "done looks like" in one sentence
- Estimated time exceeds one full working day
- Two sibling tasks would need to edit the same shared contract, schema, or core file at the same time
- Acceptance depends on another developer's unfinished local branch rather than a stable produced artifact
- Multiple developers would need ad-hoc coordination to decide ownership while implementing
- One focused sub-agent would need to implement more than one independently verifiable deliverable inside the same task

When multiple tasks depend on the same interface, create a contract task first, then let downstream tasks consume that artifact in parallel.
