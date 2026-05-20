# Task Design Rules

Every task in TASKS.md must satisfy all nine rules:

1. **Single responsibility** — one clear deliverable
2. **Independently verifiable** — has a concrete "done" condition that can be checked without running the entire system
3. **No hidden dependencies** — all dependencies are explicitly listed
4. **Estimable** — small enough that a developer can estimate it confidently (target: hours, not days)
5. **Named for outcome** — title describes the result, not the activity (e.g., "User can log in with email/password" not "Implement auth")
6. **Parallel-safe** — one developer can complete it without coordinating ongoing edits to the same shared contract, schema, or core file as sibling tasks; if not, extract a prerequisite contract/setup task first
7. **Contract-explicit** — the task states what it produces and what it consumes (API schema, migration, shared component contract, fixture, stub, event payload, etc.)
8. **Ownership-clear** — the task is assigned to a workstream and owner role so routing to the right developer is obvious
9. **Execution-scoped** — the task is small and cohesive enough that one implementation sub-agent can complete it in one isolated output directory without having to split or bundle work again

If a task cannot meet these rules, split it further.

---

## Parallel-First Decomposition

When the work is intended for multiple developers:

- Create shared prerequisite tasks first (contracts, schemas, migrations, SDK wrappers, design tokens, infrastructure setup)
- Place those prerequisites in an earlier parallel group before dependent implementation tasks
- Group implementation tasks into explicit workstreams and parallel groups
- Treat `parallel_group` as a scheduling tier only — it is not permission for later orchestrators to merge multiple tasks into one execution payload
- Prefer mocks/stubs when they let dependent tasks proceed independently without waiting on another developer's unfinished branch
