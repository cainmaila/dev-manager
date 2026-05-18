# Change Request Interview Patterns

Structured question bank for eliciting change requests against existing projects.

---

## Interview Phases

### Phase 1 — Change Identification

Goal: establish what the user wants to change and why.

Questions (ask one at a time):

1. "這次的修改是什麼？用一句話描述你想新增、修改或移除的功能。"
2. "這個改動的背景是什麼？是用戶反饋、新的業務需求、還是發現了問題？"
3. "這個改動有優先順序或截止時間嗎？"

---

### Phase 2 — Scope Boundaries

Goal: identify exactly which parts of the system are in/out of scope for this change.

Questions:

1. "這個改動只影響 [feature area from existing spec]，還是會牽涉到其他功能？"
2. "有哪些現有行為是不能被這次改動影響的？"（Preserve these as `unchanged_outputs_to_preserve`）
3. "這次改動完成後，系統應該能做到什麼新的事情？請給我一個具體的使用情境。"

---

### Phase 3 — Acceptance Criteria

Goal: define done conditions for the change.

Questions:

1. "改動完成後，你會怎麼驗證它是否正確？"
2. "有沒有你不希望發生的副作用？例如不能影響現有的 [feature]。"
3. "這個改動有測試需求嗎？是新的單元測試、整合測試，還是 E2E？"

---

### Phase 4 — Conflict Check

Goal: identify contradictions with existing SPEC.md and requirements.md.

After collecting the change, scan existing artifacts for conflicts:

1. Does the change contradict any existing acceptance criteria in TASKS.md?
   → If yes: "這個改動會影響到現有任務 [T-XX: title] 的驗收標準。要一併修改嗎？"

2. Does the change require a data model change that conflicts with existing schema?
   → If yes: "這個改動需要改變 [table/field]，這會影響 [existing module] 的行為。是否確認修改？"

3. Does the change alter an interface contract that other units depend on?
   → If yes: "修改 [contract] 會影響到 [unit-A] 和 [unit-B]。它們也需要重新開發。確認嗎？"

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
  > "例如：'用戶可以在設定頁面更改語言，重新整理後語言設定保持不變'。這樣的格式可以嗎？"

---

## Completion Signal

Interview complete when all four phases have no open questions and the `CHANGE-REQUEST-[CR-id].md` draft has:
- [ ] Summary filled
- [ ] At least one acceptance criterion
- [ ] Unchanged behaviors listed (or explicitly "none")
- [ ] Scope boundary confirmed by user

Then ask: "這份變更需求文件（CHANGE-REQUEST-[CR-id].md）是否完整捕捉了你的想法？確認後我會開始分析影響範圍。"
