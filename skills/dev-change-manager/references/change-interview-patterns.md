# Change Request Interview Patterns

Structured question bank for eliciting change requests against existing projects.

---

## Interview Phases

### Phase 1 — Change Identification

Goal: establish what the user wants to change and why.

Questions (ask one at a time):

1. "What is this change? Describe in one sentence what you want to add, modify, or remove."
2. "What is the context for this change? Is it user feedback, new business requirements, or a discovered issue?"
3. "Does this change have a priority or deadline?"

---

### Phase 2 — Scope Boundaries

Goal: identify exactly which parts of the system are in/out of scope for this change.

Questions:

1. "Does this change only affect [feature area from existing spec], or will it touch other features?"
2. "What existing behaviors must not be affected by this change?" (Preserve these as `unchanged_outputs_to_preserve`)
3. "After this change is complete, what new thing should the system be able to do? Give me a specific usage scenario."

---

### Phase 3 — Acceptance Criteria

Goal: define done conditions for the change.

Questions:

1. "After the change is complete, how will you verify it is correct?"
2. "Are there any side effects you don't want? For example, must not affect existing [feature]."
3. "Does this change have testing requirements? New unit tests, integration tests, or E2E?"

---

### Phase 4 — Conflict Check

Goal: identify contradictions with existing SPEC.md and requirements.md.

After collecting the change, scan existing artifacts for conflicts:

1. Does the change contradict any existing acceptance criteria in TASKS.md?
   → If yes: "This change affects the acceptance criteria of existing task [T-XX: title]. Should we update it as well?"

2. Does the change require a data model change that conflicts with existing schema?
   → If yes: "This change requires modifying [table/field], which will affect the behavior of [existing module]. Confirm modification?"

3. Does the change alter an interface contract that other units depend on?
   → If yes: "Modifying [contract] will affect [unit-A] and [unit-B]. They will also need to be redeveloped. Confirm?"

---

## CHANGE-REQUEST-[CR-id].md Template

```markdown
# Change Request — CR-[id]
<!-- id assigned by Phase 0: scan for existing CHANGE-REQUEST-CR-*.md, increment highest N, zero-pad to 3 digits -->

**Date:** [YYYY-MM-DD]
**Status:** PENDING

## Summary
[One-paragraph description of the change]

## Motivation
[Why this change is needed]

## Priority
[High / Medium / Low]
**Deadline:** [date or "none"]

## Scope

### In Scope
- [Feature or behavior being added/modified/removed]

### Out of Scope
- [What must not change]

## Acceptance Criteria

| # | Given | When | Then |
|---|---|---|---|
| CR-AC-01 | [context] | [action] | [expected outcome] |

## Unchanged Behaviors to Preserve
- [behavior 1]
- [behavior 2]

## Testing Requirements
- [ ] [test type]: [what to verify]

## Conflict Notes
[Any identified conflicts with existing spec, or "none"]
```

---

## Language Guidelines

- Match user's language at all times.
- Keep questions functional — do not ask about implementation details.
- When the user says "just add X", probe scope: "When you say 'add X', should it replace Y, or work alongside Y?"
- If user is unsure about acceptance criteria, offer examples:
  > "For example: 'User can change language on the settings page; after refresh, the language setting persists.' Does this format work?"

---

## Completion Signal

Interview complete when all four phases have no open questions and the `CHANGE-REQUEST-[CR-id].md` draft has:
- [ ] Summary filled
- [ ] At least one acceptance criterion
- [ ] Unchanged behaviors listed (or explicitly "none")
- [ ] Scope boundary confirmed by user

Then ask: "Does this change request document (CHANGE-REQUEST-[CR-id].md) fully capture your intent? Confirm and I will begin impact analysis."
