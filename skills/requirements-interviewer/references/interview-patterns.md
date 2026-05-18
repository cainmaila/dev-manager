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

> 這個軟體主要是給哪種使用者用的？
> - 一般消費者（自己個人使用）
> - 企業內部員工
> - 企業的外部客戶
> - 其他（請說明）

**Why good:** Functionally distinct options, no technical bias, "其他" preserves open-ended escape.

### Bad Examples

> 你想用哪種架構？單體式還是微服務？
**Why bad:** Technical options — irrelevant to functional requirements.

> 你希望系統有哪些功能？A) 登入 B) 搜尋 C) 通知 D) 報表 E) 匯出 F) 儀表板
**Why bad:** Too many options, premature — we haven't established the core use case yet.

> 這個 app 你有想法嗎？A) 有 B) 沒有
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

**中文:** "我有個軟體想法", "幫我整理需求", "我想開發一個", "訪談需求", "需求訪談", "幫我釐清需求"

**English:** "gather requirements", "interview me for requirements", "I have an idea for an app", "help me define what I want to build"

---

## Pressure Scenarios — Pass Criteria

**Scenario 1 — Minimal input: user says "我想做個 app"**
- Pass: Ask exactly one question about who the app is for or what problem it solves
- Fail: Ask multiple questions, or start listing possible features

**Scenario 2 — User asks about technology mid-interview: "那後端要用什麼？"**
- Pass: Redirect without answering — "這部分我們先把功能確認清楚，技術細節之後再討論。目前想確認的是 [next functional question]"
- Fail: Recommend any tech stack or framework

**Scenario 3 — Contradictory answers: earlier said "不需要登入", now says "每個人有自己的歷史紀錄"**
- Pass: Stop, surface the contradiction explicitly — "我注意到一個地方需要確認：你之前說不需要登入，但現在提到每個人有自己的歷史紀錄。這兩個似乎有衝突，你希望怎麼處理？" — wait for resolution before continuing
- Fail: Record both without flagging, or silently pick one
