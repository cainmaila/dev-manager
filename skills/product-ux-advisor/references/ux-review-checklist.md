# UX Review Checklist

**Use for Full Review.** For Quick Review, sample only the sections relevant to the spec — do not run through every item. The goal is a targeted scan, not a complete audit.

Systematic per-feature checklist for Full Review (Step 3-5 of the review workflow).

Mark each item: ✅ Addressed | ❌ Missing | ⚠️ Unclear | N/A Not applicable

---

## A. Requirements Completeness

### A1. User Context
- [ ] Target user role defined
- [ ] User's technical level implied or stated
- [ ] Context of use specified (desktop/mobile, urgent/casual, expert/novice)
- [ ] Primary job-to-be-done stated

### A2. States Coverage
- [ ] Happy path (success) defined
- [ ] Loading/processing state defined
- [ ] Empty state defined (zero data, first use)
- [ ] Error state defined (what message, how to recover)
- [ ] Partial success state defined (if applicable)
- [ ] Offline/network failure state defined (if applicable)
- [ ] Permission-denied state defined (if applicable)

### A3. Actions Coverage
- [ ] All user-initiated actions listed
- [ ] System-initiated actions listed (notifications, auto-updates)
- [ ] Destructive actions flagged and confirmation specified
- [ ] Irreversible actions clearly marked as such
- [ ] Success confirmation for each write action specified

---

## B. Flow Analysis

### B1. Entry & Exit
- [ ] How user arrives at this feature (entry points)
- [ ] Where user goes after completing the task (exit)
- [ ] Back/cancel behavior defined at each step
- [ ] What happens if user navigates away mid-task (data preserved?)

### B2. Multi-Step Flows
- [ ] Number of steps reasonable (< 5 for most flows)
- [ ] Each step has single clear purpose
- [ ] Progress indicator specified (for flows ≥ 3 steps)
- [ ] User can go back and change earlier steps
- [ ] Skippable steps marked as optional

### B3. Edge Cases
- [ ] What if no data exists?
- [ ] What if maximum limits reached?
- [ ] What if user has insufficient permissions?
- [ ] What if concurrent edit conflict occurs?
- [ ] What if session expires mid-flow?

---

## C. Language & Labels

### C1. Terminology
- [ ] All labels match user's vocabulary (not developer's)
- [ ] No internal system names exposed (IDs, field names, enum values)
- [ ] Consistent with existing product glossary
- [ ] Action labels are verb-noun ("Save Changes") not noun ("Changes")
- [ ] Destructive actions clearly named ("Delete permanently" not "Remove")

### C2. Error Messages
- [ ] Error messages are specific (not "Something went wrong")
- [ ] Error messages explain what happened
- [ ] Error messages tell user what to do next
- [ ] Validation messages appear inline on blur (default); submit-only acceptable for very short forms — flag if form is long and submit-only

### C3. Empty States
- [ ] Empty state has headline (what this area is for)
- [ ] Empty state has CTA (what to do to get started)
- [ ] Tone matches the product voice

---

## D. Consistency Check

### D1. Pattern Consistency
- [ ] Interaction pattern matches how similar features work elsewhere
- [ ] Modal/drawer/page pattern consistent with existing choices
- [ ] Form layout consistent with other forms
- [ ] Button placement consistent (primary right/bottom? always same)
- [ ] Table/list behavior consistent with existing tables/lists

### D2. Naming Consistency
- [ ] "Delete" vs "Remove" vs "Clear" — same action, same word
- [ ] "User" vs "Member" vs "Account" — same entity, same word
- [ ] "Save" vs "Submit" vs "Confirm" — used appropriately
- [ ] Date format matches product standard
- [ ] Currency/number format matches product standard

### D3. Visual Hierarchy Consistency
- [ ] Primary CTA is visually primary (not competing with secondary actions)
- [ ] Destructive actions are visually differentiated (red, secondary position)
- [ ] New feature doesn't introduce new button variants arbitrarily

---

## E. Cognitive Load

### E1. Simplicity
- [ ] Screen has ≤ 2-3 primary actions (default; admin/power-user tools may justify more — note if so)
- [ ] Form has ≤ 7 fields per step (default; flag if significantly over without progressive disclosure)
- [ ] Lists/menus with > ~20 items have search or filter (default; flag if no mechanism and dataset can grow large)
- [ ] Advanced/optional options hidden behind progressive disclosure
- [ ] No information required from memory from a previous step

### E2. Decision Support
- [ ] Confirmation dialogs explain consequences (not just "Are you sure?")
- [ ] Radio/select options have enough context to choose
- [ ] Default selection pre-set for most common case
- [ ] Warnings appear before the point of no return (not after)

---

## F. Technical-UX Interface Points

Flag these when reviewing technical plans or architecture:

| Technical Decision | UX Implication to Specify |
|-------------------|--------------------------|
| Async API call | Loading state required |
| Long-running operation (> 3s) | Progress bar + estimated time |
| Batch operation | Progress count ("3 of 10 done") + cancellation |
| Soft delete | Undo/restore option in UI |
| Hard delete | Confirmation dialog + irreversibility warning |
| File upload | Size limit, format restrictions, upload progress |
| Pagination | Page size, total count, navigation pattern |
| Search | Latency, no-results state, typo tolerance |
| Real-time updates | Notification strategy, conflict resolution |
| Permission model | What users see when denied (403 vs. hidden) |
| Rate limiting | User-facing message + retry guidance |
