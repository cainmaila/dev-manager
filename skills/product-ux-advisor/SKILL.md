---
name: product-ux-advisor
description: "This skill should be used when the user explicitly asks for UX feedback on requirements, user stories, a PRD, feature specs, or UI descriptions. Trigger phrases: 'review UX', 'check usability', 'UX recommendations', 'is this user-friendly', 'review from user perspective', 'check UI consistency', 'any UX issues', 'UX review this spec', 'does this make sense to users', 'check the flow', 'review this requirement'. Engage during requirements review, PRD/spec discussion, or feature design evaluation — not during implementation, debugging, or refactoring tasks."
---

# Product UX Advisor

## When to Engage

- **Full review:** user requests UX review of requirements, PRD, spec, or asks "does this make sense to users"
- **1-3 sentence warning only:** mid-implementation/debugging and a change would cause data loss, dead end, or broken destructive action — flag it then return to original task
- **Don't engage:** pure implementation, debugging, refactoring, non-product config/infra tasks

---

## Step 1 — Assess Context Before Reviewing

Identify from the input:
- **Who is the user?** (role, technical level, context of use)
- **What is the primary task?** (job-to-be-done)
- **What does success look like for the user?**

If unclear: ask only when the answer would change which issues are CRITICAL vs. MINOR or change the flow structure. Max 3 questions. Otherwise state assumptions at the top ("Assuming: consumer-facing, non-technical users; primary task is X") and proceed.

Do not block the review on incomplete context.

---

## Step 2 — Choose Review Mode

**Quick Review** (default: single screen, single action, simple spec):
- Scan all 7 dimensions; report top 3 highest-impact findings
- Flag missing specifications
- No Structure Sketch

**Full Review** (multiple screens, multi-step flows, IA-level changes):
- Complete analysis across all 7 dimensions
- Full missing specifications
- UX Structure Sketch + Terminology Table

**Hard rule:** Always lead with top 3 issues regardless of mode.

---

## Step 3 — Analyze Across 7 UX Dimensions

| Dimension | Key Question |
|-----------|-------------|
| **Visibility** | Does the system communicate what's happening? |
| **Learnability** | Can a new user understand this without training? |
| **Consistency** | Does this match existing patterns and mental models? |
| **Error Prevention & Recovery** | What happens when things go wrong? |
| **Efficiency** | Can users accomplish the task without unnecessary steps? |
| **Cognitive Load** | Is the user asked to remember or decide too much? |
| **Trust & Feedback** | Does the user know their action worked? |

---

## Step 4 — Flag Missing Specifications

Requirements commonly omit:
- Loading/processing states
- Empty states (first use, zero results, no data)
- Error messages (what they say, how to recover)
- Confirmation dialogs for destructive actions
- Success feedback
- Permission-denied states

Flag each gap as: "spec does not address X — required before implementation."

---

## Step 5 — Identify Consistency Violations

- **Terminology:** same concept named differently ("delete" vs. "remove" vs. "clear")
- **Interaction pattern:** same action behaves differently in different contexts
- **Visual hierarchy:** primary actions buried or competing with secondary actions
- **Navigation:** back/cancel behavior inconsistent with existing flows

---

## Output Format

```
## UX Review: [Feature Name]

**Assumptions** (if context was incomplete)
[State assumptions made]

### Top 3 Issues
[Highest-impact findings, most impactful first]

### Missing Specifications
[States, flows, or behaviors not addressed]

### Summary
[1-2 sentences: overall risk level + single most important fix]
```

**Full review adds:**
- `### Additional Issues` — MINOR and SUGGESTION findings
- `### UX Structure Sketch` — screen flow + inventory + state matrix
- `### Terminology Table` — when naming inconsistency is a risk

**Finding format:**
```
[SEVERITY] Area: Issue description
→ Recommendation: What to change
→ Why: User impact if not addressed
```

**Severity:**
- **CRITICAL** — user cannot complete task, will lose data, or will be misled
- **MAJOR** — user will struggle, make errors, or likely abandon
- **MINOR** — friction point; reduces satisfaction but doesn't block completion
- **SUGGESTION** — enhancement with no current deficiency

---

## UX Structure Sketch (Full Review only)

Include when: multiple screens, multi-step flow, or IA-level changes. Skip for single-action or single-screen features.

Required: Screen Flow + Screen Inventory + State Matrix.

### 1. Screen Flow (ASCII)

```
[Entry Point] ──── action ────▶ [Screen A]
                                    │
                              confirm/cancel
                               ┌────┴────┐
                               ▼         ▼
                          [Screen B]  [Screen A] (stay)
                               │
                           success
                               ▼
                          [Screen C]
```

Label every arrow with user action or trigger. Dead ends must have a return path.

### 2. Screen Inventory

| Screen | Purpose | Key UI Elements | States Required |
|--------|---------|-----------------|-----------------|
| [Screen A] | [What user does here] | [Specific components] | Loading, Empty, Error, Success |

### 3. State Matrix

| State | Trigger | What user sees | Action available |
|-------|---------|----------------|-----------------|
| Loading | API call in flight | Spinner / skeleton | None (controls disabled) |
| Empty | No data | Empty state + primary CTA | [CTA] |
| Populated | Data loaded | Content | Edit, Delete, etc. |
| Error | API failed | Error message + retry | Retry / Go back |
| Success | Write completed | Confirmation | [Next action] |

---

## Default UX Heuristics for Technical Decisions

| Technical decision | Default UX requirement |
|-------------------|----------------------|
| Async operation | Loading indicator (skeleton or spinner) |
| Operation > 3s | Progress indication + estimated completion |
| Batch operation | Item count + cancellation option |
| Destructive operation | Confirmation step; irreversible = explicit label |
| Destructive but reversible | Undo window instead of confirmation |
| Form validation | Inline on blur (default); on submit OK for very short forms |
| Multi-step flow | Back navigation + progress indicator for ≥ 3 steps |
| Permission-denied | Explain why + path to resolve, not blank or generic 403 |
| Large list (> ~20 items) | Search or filter |

Defaults, not rules. If context makes a default inappropriate, note the tradeoff explicitly.

---

## Additional Resources

- **`references/ux-heuristics.md`** — Full criteria for all 7 UX dimensions + Nielsen's 10 heuristics mapping
- **`references/ux-review-checklist.md`** — Systematic per-feature checklist
- **`references/common-ux-antipatterns.md`** — 30+ anti-patterns with symptom, user impact, and fix
