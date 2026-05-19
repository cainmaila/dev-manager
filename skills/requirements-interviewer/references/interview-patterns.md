# Requirements Interview Patterns

## Question Categories

### Phase 1 — Core Identity
Establish WHAT the software is before diving into features.

- "Who is the primary user of this software?"
- "What is the single most important thing this software must do?"
- "What problem does this solve that current tools don't?"

### Phase 2 — User & Role Mapping
Identify actors and their goals.

- "Who else (besides the primary user) will use this system?"
- "What does [role X] need to accomplish with this software?"
- "Are there admin vs. end-user distinctions?"

### Phase 3 — Core Features
One feature area at a time.

- "Walk me through a typical session using this software, step by step."
- "After [action X], what happens next?"
- "What triggers [event Y]?"

### Phase 4 — Data & State
Understand what the system stores and tracks.

- "What information needs to be saved between sessions?"
- "Can [entity X] be edited after creation? Deleted?"
- "How long is data kept?"

### Phase 5 — Constraints & Rules
Business rules and limits.

- "Are there any actions that only certain users can do?"
- "Are there quantities or counts that matter (max items, limits)?"
- "What should happen if [rule X] is violated?"

### Phase 6 — Edge Cases & Exceptions
Validate completeness.

- "What happens if [step X] fails or is interrupted?"
- "Can two users do conflicting actions at the same time?"
- "Is there an offline/no-internet scenario to handle?"

### Phase 7 — Acceptance Criteria Validation
Confirm requirements are testable.

- "How would you know if this feature is working correctly?"
- "What does success look like for [feature X]?"
- "Is there anything I haven't asked about that's important?"

---

## Contradiction Detection Checklist

After each answer, scan the requirements document for:

| Pattern | Example Contradiction |
|---------|----------------------|
| Role conflict | "Anyone can edit" vs "only admins can edit" |
| Data conflict | "No login needed" vs "save user history" |
| Flow conflict | "Real-time sync" vs "offline-first" |
| Scope conflict | Feature A implies Feature B that was excluded |

When contradiction found: surface it explicitly, ask user to resolve before continuing.

---

## Structured Suggestion Guidelines

If the environment provides a structured multiple-choice / suggestion tool, use it for bounded questions. If no such tool is available, ask as plain text. Never reference a specific tool by name (e.g. `AskUserQuestion`) — describe the behavior instead so the skill works across environments.

**Use structured suggestions when:**
- 2–4 mutually exclusive options exist
- Options are functionally meaningful and require no technical knowledge
- Answers are meaningfully different and non-overlapping

**Use plain text question when:**
- Open-ended answer needed (describe a workflow, name something, explain a process)
- More than 4 valid options exist
- Nuance would be flattened by a fixed list

Always: one question per turn, regardless of format.

### Good Example

> Who is the primary user of this software?
> - Individual consumer (personal use)
> - Internal business employees
> - External business customers
> - Other (please describe)

**Why good:** Functionally distinct options, no technical bias, "Other" preserves open-ended escape.

### Bad Examples

> Which architecture do you want? Monolithic or microservices?
**Why bad:** Technical options — irrelevant to functional requirements.

> What features do you want in the system? A) Login B) Search C) Notifications D) Reports E) Export F) Dashboard
**Why bad:** Too many options, premature — we haven't established the core use case yet.

> Do you have ideas for this app? A) Yes B) No
**Why bad:** Yes/no that yields no useful information — ask as open-ended plain text instead.

---

## Requirements Document Template

```markdown
# Requirements: [Project Name]

## Overview
[1-3 sentences — what it is, who it's for, core problem solved]

## Users / Roles
| Role | Description | Key Permissions |
|------|-------------|-----------------|
| | | |

## Functional Requirements

### [Feature Area 1]
- FR-01: [Requirement statement]
- FR-02: [Requirement statement]

### [Feature Area 2]
- FR-03: [Requirement statement]

## Business Rules
- BR-01: [Rule statement]

## Acceptance Criteria

| ID | Feature | Given | When | Then |
|----|---------|-------|------|------|
| AC-01 | | | | |

## Out of Scope
- [Explicitly excluded items]

## Open Questions
- [Unresolved items pending user clarification]
```

---

## Interview Completion Signals

End the interview when:
1. All 7 phases covered with no open questions
2. Requirements document has no contradictions
3. Every functional requirement has at least one acceptance criterion
4. "Out of Scope" section is explicitly confirmed by user
5. User confirms: "This captures everything"

---

## Trigger Phrases

Use these to recognize when this skill applies:

**Chinese:** "I have a software idea", "help me organize requirements", "I want to develop a", "interview requirements", "requirements interview", "help me clarify requirements"

**English:** "gather requirements", "interview me for requirements", "I have an idea for an app", "help me define what I want to build"

---

## Pressure Scenarios — Pass Criteria

**Scenario 1 — Minimal input: user says "I want to build an app"**
- Pass: Ask exactly one question about who the app is for or what problem it solves
- Fail: Ask multiple questions, or start listing possible features

**Scenario 2 — User asks about technology mid-interview: "What should we use for the backend?"**
- Pass: Redirect without answering — "Let's first clarify the functional requirements; technical details can be discussed later. Currently I'd like to confirm [next functional question]"
- Fail: Recommend any tech stack or framework

**Scenario 3 — Contradictory answers: earlier said "login is not needed", now says "everyone has their own history"**
- Pass: Stop, surface the contradiction explicitly — "I noticed something to confirm: you said earlier that login is not needed, but now you mentioned everyone has their own history. These seem to conflict — how would you like to handle this?" — wait for resolution before continuing
- Fail: Record both without flagging, or silently pick one
