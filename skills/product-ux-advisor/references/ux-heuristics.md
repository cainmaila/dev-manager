# UX Heuristics Reference

Detailed criteria for each review dimension. Use during Step 2 of the UX review workflow.

---

## Dimension 1: Visibility of System Status

**Core question:** Does the user always know what is happening?

Criteria to check:
- Loading states defined for all async operations (API calls, file uploads, processing)
- Progress indicators for operations > 1 second
- Success confirmations for all write operations
- Error states with specific (not generic) messages
- Current state visible at all times (active tab, selected item, current step)
- Background operations surfaced (sync status, background jobs)

**Requirements red flags:**
- "Submit the form" — no mention of what happens after submit
- "Save the record" — no success/failure feedback specified
- API integration — no loading state specified
- Batch operation — no progress or count feedback

---

## Dimension 2: Learnability

**Core question:** Can a first-time user figure this out?

Criteria to check:
- Labels use words the user knows, not internal system names
- Primary action is obvious — visually dominant, logically placed
- Icons have labels (icon-only is a learnability risk)
- Empty states explain what to do next, not just that there's no data
- Onboarding or first-use states defined for complex features
- Terminology matches the user's domain (not the developer's)

**Requirements red flags:**
- Technical field names exposed to users ("entity_id", "foreign_key", "payload")
- Feature named after its implementation, not its purpose
- No empty state described
- Icon-only buttons without labels or tooltips
- Jargon without explanation

---

## Dimension 3: Consistency

**Core question:** Does this behave like the rest of the product?

Criteria to check:
- Same action uses same label across all surfaces ("Delete" not "Delete"/"Remove"/"Clear" for same action)
- Same interaction pattern for same type of action (all list items delete the same way)
- Visual hierarchy: primary CTA always primary style, destructive actions always destructive style
- Navigation: same back/cancel behavior across all flows
- Date/time formats consistent
- Currency/number formats consistent
- Terminology: product-level glossary maintained (user vs. member vs. account)

**Requirements red flags:**
- New feature introduces a different word for existing concept
- "Delete" in new feature but "Remove" in old feature for identical action
- New modal doesn't have same button layout as other modals
- New form doesn't follow same validation pattern as other forms

---

## Dimension 4: Error Prevention & Recovery

**Core question:** What happens when things go wrong?

Criteria to check:
- Destructive actions require confirmation
- Irreversible actions clearly labeled as such
- Undo available for reversible destructive actions (30-second window)
- Form validation: inline, real-time, specific
- Error messages: explain what went wrong + how to fix it
- Required fields marked before submit (not after)
- Data preserved on error — user doesn't lose work
- Network errors have retry option
- Session expiry handled gracefully — redirect to login, not blank page, work preserved

**Requirements red flags:**
- "Delete [item]" with no confirmation dialog
- "Submit form" — error handling not specified
- Required fields not specified in requirements
- Network failure behavior not specified
- No mention of data persistence on error

---

## Dimension 5: Efficiency

**Core question:** Can users accomplish the task without unnecessary friction?

Criteria to check:
- Minimum clicks to complete primary task (count them)
- Default values reduce input for common cases
- Smart defaults based on context (pre-fill user info, remember last selection)
- Bulk actions for repeated operations
- Keyboard shortcuts for power users (especially admin/ops tools)
- Auto-save reduces explicit save requirement
- Search/filter available when list > 10 items
- Pagination vs. infinite scroll appropriate for use case

**Requirements red flags:**
- Multi-step flow where single step would suffice
- Required fields that can be inferred from context
- No bulk action for list management
- No search when listing potentially large datasets
- Manual save required when auto-save is feasible

---

## Dimension 6: Cognitive Load

**Core question:** Is the user asked to remember or decide too much?

Criteria to check:
- No more than 7 items in any list/menu before grouping or search
- Wizard/multi-step flows: each step has single clear purpose
- No more than 2-3 primary actions on a screen
- Related information grouped visually
- Progressive disclosure: advanced options hidden by default
- No jargon requiring user to know internal system logic
- Decision points have enough context to decide (no "Are you sure?" without explaining consequences)

**Requirements red flags:**
- Feature dumps all options on a single screen
- Multi-step form with more than 5-7 fields per step
- Confirmation dialog without explaining what will happen
- User must remember information from previous step to complete current step
- All features at same visual hierarchy

---

## Dimension 7: Trust & Feedback

**Core question:** Does the user trust the system and know their actions worked?

Criteria to check:
- Explicit confirmation for important actions ("Your changes have been saved")
- Undo option after destructive/irreversible action
- Data displayed matches what was saved (optimistic UI must reconcile)
- No silent failures — all failures surfaced
- Sensitive operations explain why data is needed
- External links open in new tab with indication
- File operations (upload/download) show result clearly

**Requirements red flags:**
- Write operation with no success confirmation
- Optimistic UI update without reconciliation handling
- Silent error swallowing ("best effort" delivery without user notification)
- Explanation missing for why sensitive data is collected

---

## Nielsen's 10 Heuristics Mapping

| Nielsen Heuristic | Maps to Dimension |
|-------------------|-------------------|
| 1. Visibility of system status | Visibility |
| 2. Match between system and real world | Learnability |
| 3. User control and freedom | Error Recovery |
| 4. Consistency and standards | Consistency |
| 5. Error prevention | Error Prevention |
| 6. Recognition rather than recall | Cognitive Load |
| 7. Flexibility and efficiency of use | Efficiency |
| 8. Aesthetic and minimalist design | Cognitive Load |
| 9. Help users recognize, diagnose, and recover from errors | Error Recovery |
| 10. Help and documentation | Learnability |
