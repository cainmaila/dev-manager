# Module Isolation Rules

Rules for preventing cross-module interference during parallel development.

---

## Directory Ownership

Each sub-agent owns exactly one directory. Ownership is exclusive:

```
project/
├── modules/
│   ├── task-001/    ← owned by TASK-001 agent only
│   ├── task-002/    ← owned by TASK-002 agent only
│   ├── task-003/    ← owned by TASK-003 agent only
│   ├── task-004/    ← owned by TASK-004 agent only
│   └── task-005/    ← owned by TASK-005 agent only
├── SPEC.md          ← read-only for all agents
├── TASKS.md         ← read-only for all agents
└── integration-report.md  ← written by integration-agent only
```

**Rules:**

- Agent may read any file in the project.
- Agent may write only inside its own task directory.
- Manager (Claude) writes to project root only.

---

## Interface Contracts

Prevent tight coupling by defining contracts before development starts.

Define in SPEC.md §API-Contracts:

- Endpoint paths and HTTP methods
- Request/response JSON schemas
- Auth header format
- Error response format

All task agents refer to SPEC.md — they do not negotiate contracts with each other.

---

## Shared Data / Config

If modules need shared config (e.g., DB connection string, API base URL):

1. Manager defines shared config in `project/shared/config.template.env`
2. Each module reads from this file — never writes to it
3. Task-specific config lives in `project/modules/[task-id]/.env.example`

---

## Dependency Graph

Before spawning parallel agents, draw a dependency graph:

```
TASK-001 ──► TASK-002 ──► TASK-004
         └──► TASK-003 ──► TASK-004
```

Spawn rule:

- Spawn nodes with no unresolved upstream dependencies first
- Only spawn downstream nodes after upstream DONE.md confirms completion
- Parallel spawn is safe only within the same dependency tier

---

## Conflict Prevention Checklist

Before spawning any agent, verify:

- [ ] Output directory assigned and unique
- [ ] No two agents share the same output path
- [ ] Interface contracts sourced from SPEC.md / TASKS.md contract fields
- [ ] Shared config template exists if needed
- [ ] Dependency order determined from the task execution plan (Phase 2.5)
- [ ] Agent prompt explicitly states "write only to [your directory]"

---

## When Conflicts Occur

If two agents write to the same path (rare but possible if prompts are wrong):

1. Stop both agents immediately
2. Read both outputs
3. Manually merge or pick one
4. Re-assign clear directory boundaries
5. Re-spawn with corrected prompts

---

## DONE.md Contract

Every task agent must write `DONE.md` in its `output_dir` before finishing.

**Format is strict** — `check-done.sh` parses these exact headings. Do not rename or reorder them.

```markdown
## Status: DONE | BLOCKED | PARTIAL

## Built

- [file or feature created]
- (or "none")

## Skipped

- [explicitly deferred item]
- (or "none")

## Assumptions

- [any spec ambiguity resolved by assumption]
- (or "none")

## Blockers

- [anything preventing completion]
- (or "none")

## Contract compliance

- [contract item]: honored | not honored — [note]
```

**Rules:**

- `## Status:` must be the first heading, value must be exactly `DONE`, `BLOCKED`, or `PARTIAL`
- `## Blockers` must be present even if empty (write "none")
- No extra headings between `## Status:` and `## Blockers` that could shift the parse offset
- `check-done.sh` reads Status from line matching `^## Status:` and Blockers from lines after `^## Blockers`

Manager reads DONE.md to decide: accept, re-spawn, or escalate.
