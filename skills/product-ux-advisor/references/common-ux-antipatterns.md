# Common UX Anti-Patterns

30+ anti-patterns organized by category. Each entry: symptom in requirements, user impact, recommended fix.

---

## Category 1: Missing States

### 1.1 The Void Submit
**Symptom in requirements:** "User clicks submit → data saved."  
**User impact:** User has no idea if it worked. Clicks again. Submits twice.  
**Fix:** Specify: (a) button disabled during submission, (b) loading spinner, (c) success confirmation, (d) what happens to the form after success (reset? redirect? stay?).

### 1.2 The Blank Empty State
**Symptom:** Empty list/table with no explanation.  
**User impact:** User thinks the feature is broken, not that there's no data yet.  
**Fix:** Empty state must have: headline (what this section is), subtext (why it's empty), CTA (how to add the first item).

### 1.3 The Silent Error
**Symptom:** "On error, show error message."  
**User impact:** Generic "Something went wrong" tells user nothing. They cannot recover.  
**Fix:** Every error case needs specific message + recovery action. Network error ≠ validation error ≠ permission error.

### 1.4 The Eternal Loader
**Symptom:** Loading state specified, no timeout or failure state.  
**User impact:** Page loads forever. User doesn't know if it's their network or the system.  
**Fix:** Define timeout threshold + what user sees after timeout (error + retry button).

---

## Category 2: Destructive Action Traps

### 2.1 The Oops Delete
**Symptom:** Delete button with no confirmation.  
**User impact:** Accidental deletion, data loss, loss of trust.  
**Fix:** Confirmation dialog for all destructive actions. For irreversible: state explicitly "This cannot be undone." For reversible: offer undo within 30 seconds instead of confirmation.

### 2.2 The Invisible Irreversibility
**Symptom:** Destructive action labeled same as non-destructive action.  
**User impact:** User doesn't understand consequence. Clicks without realizing.  
**Fix:** Label irreversible actions explicitly: "Delete permanently" not "Delete." Visually differentiate (red button, secondary position).

### 2.3 The Cascade Trap
**Symptom:** Requirements say "delete X" but don't specify what happens to related data Y and Z.  
**User impact:** User deletes X expecting Y to be preserved. Y disappears. Data loss.  
**Fix:** Confirmation dialog must list all cascading effects: "Deleting this project will also delete 5 tasks and 3 files."

### 2.4 The Mid-Form Abandon
**Symptom:** User navigates away mid-form. Requirements don't specify what happens to data.  
**User impact:** Typed half a long form, accidentally clicks browser back, loses everything.  
**Fix:** Specify: auto-save draft, or "You have unsaved changes" confirmation on navigation.

---

## Category 3: Consistency Violations

### 3.1 Synonym Creep
**Symptom:** Requirements use "delete" for one feature and "remove" for another that do the same thing.  
**User impact:** User confused about whether these are different operations. Hesitates. Loses trust.  
**Fix:** Establish and enforce a product glossary. Pick one word per concept. "Delete" means delete everywhere.

### 3.2 The Rogue Modal
**Symptom:** New feature uses a bottom sheet where the product uses modals, or vice versa, with no justification.  
**User impact:** Cognitive surprise. User's muscle memory from other parts of the product doesn't apply.  
**Fix:** Match existing interaction patterns unless there's a deliberate, documented reason to deviate.

### 3.3 Button Position Whiplash
**Symptom:** Some dialogs have Cancel/OK, others have OK/Cancel.  
**User impact:** Users click wrong button. Especially on destructive confirmations.  
**Fix:** Define and enforce button order product-wide. Primary action consistent position (typically right).

### 3.4 The Terminology Drift
**Symptom:** Feature says "User" but rest of product says "Member."  
**User impact:** User confused: are these different things? Is "User" a different permission level?  
**Fix:** Use product glossary. If concept is genuinely different, justify explicitly in requirements.

---

## Category 4: Cognitive Overload

### 4.1 The Kitchen Sink Screen
**Symptom:** Requirements list 8+ actions available on one screen at equal priority.  
**User impact:** Paralysis. User doesn't know what to do. Ignores secondary features entirely or makes errors.  
**Fix:** Identify primary action. Make it visually primary. Group or hide secondary actions (overflow menu, accordion, separate screen).

### 4.2 The Memory Tax
**Symptom:** Step 3 of a form requires user to recall information shown only in Step 1.  
**User impact:** User must remember or go back. Error rate increases.  
**Fix:** Surface relevant context at the point of decision. Don't require memory across steps.

### 4.3 The Undecipherable Confirmation
**Symptom:** "Are you sure?" dialog with Yes/No.  
**User impact:** User uncertain what they're confirming. May click wrong answer.  
**Fix:** Confirmation dialogs must: (a) describe the specific action, (b) label buttons with verbs matching the action ("Delete Project" / "Cancel"), not "Yes"/"No".

### 4.4 The Form Avalanche
**Symptom:** Registration/onboarding form with 15+ fields.  
**User impact:** Abandonment. Cognitive fatigue.  
**Fix:** Split into steps (3-5 fields each). Defer optional fields. Pre-fill where possible.

---

## Category 5: Feedback & Trust Failures

### 5.1 The Optimistic Ghost
**Symptom:** UI updates immediately (optimistic update) but doesn't handle failure.  
**User impact:** User sees their change, navigates away. Change silently failed. They don't find out.  
**Fix:** Optimistic updates must have failure reconciliation: revert + notify + offer retry.

### 5.2 The Double Submit
**Symptom:** Submit button not disabled during processing.  
**User impact:** User double-clicks → double submission → duplicate records, duplicate charges.  
**Fix:** Disable submit button on first click. Re-enable only on error (for retry).

### 5.3 The Validation Afterthought
**Symptom:** "Validate on submit."  
**User impact:** User fills long form, submits, sees errors at top. Must hunt for which fields need fixing.  
**Fix:** Inline validation on blur (field loses focus). Show error immediately next to field.

### 5.4 The Phantom Success
**Symptom:** Action completes but no visible confirmation. User must look elsewhere to verify.  
**User impact:** User unsure if it worked. Checks again. Performs action twice.  
**Fix:** Success confirmation immediately after action. Toast, inline message, or state change — something visible near where the action occurred.

---

## Category 6: Flow & Navigation

### 6.1 The Dead End
**Symptom:** Flow ends but doesn't tell user what to do next.  
**User impact:** User stranded. Clicks around aimlessly.  
**Fix:** Every terminal state has a clear next action: return to list, start new, explore related feature.

### 6.2 The No-Back Multi-Step
**Symptom:** Multi-step flow without back navigation.  
**User impact:** User makes mistake in step 2, cannot fix without starting over.  
**Fix:** Back navigation available at every step (except step 1). Going back preserves previous answers.

### 6.3 The Buried Primary Action
**Symptom:** Primary CTA not visually dominant, placed below secondary actions.  
**User impact:** User clicks wrong action first. Confusion about what to do.  
**Fix:** Primary action: filled button, visually prominent, right or bottom-right position. Secondary: text or outlined button.

### 6.4 The Unauthorized Blank
**Symptom:** Unauthorized user sees blank page or generic 404.  
**User impact:** User confused: is this a bug? Is the feature gone? Do they have access?  
**Fix:** Permission-denied state: explain what they can't access and why (if safe to say), offer path to request access or go back.

---

## Category 7: Labels & Language

### 7.1 The Tech Leak
**Symptom:** Internal field names or IDs exposed in UI ("entity_id", "config.yaml", "ENUM_VALUE").  
**User impact:** Confusion, loss of trust, looks unfinished.  
**Fix:** Map all internal names to user-facing labels. Never expose raw field names, enum values, or system IDs.

### 7.2 The Vague Button
**Symptom:** Buttons labeled "OK", "Submit", "Proceed" without context.  
**User impact:** User unsure what will happen when they click.  
**Fix:** Buttons use specific verb-noun: "Save Changes", "Send Message", "Delete Account". The label describes what happens next.

### 7.3 The Jargon Wall
**Symptom:** Feature uses domain jargon without explanation, assuming all users are experts.  
**User impact:** New users lost. Adoption barrier.  
**Fix:** Either simplify language or add contextual help (tooltip, info icon). Jargon acceptable in expert tools only with known expert audience.
