# Review Gates

Phase 4 has three gates: Gate 1 (delivery evidence), Gate 2 (spec compliance), Gate 3 (code quality).

---

## Gate 1 — Delivery Evidence

Read `DONE.md` and assess:

| Check                       | Pass condition                                                 | Action if fail                          |
| --------------------------- | -------------------------------------------------------------- | --------------------------------------- |
| Status = DONE               | Field is exactly `DONE`                                        | Re-spawn with feedback                  |
| All acceptance criteria met | Verified against TASKS.md                                      | Re-spawn with specific missing criteria |
| Interface contract honored  | All items marked "honored"                                     | Re-spawn with correction                |
| No unresolved blockers      | Blockers field is "none" or resolved                           | Resolve blocker first, then re-spawn    |
| Fresh verification evidence | `## Test Results` names the command actually run and it passed | Re-spawn with verification correction   |

---

## Gate 2 and Gate 3

---

## Gate Order

1. Delivery evidence (`DONE.md`)
2. Spec compliance review
3. Code quality review

Never start code quality review before spec compliance is approved.

---

## Spec Compliance Review

Purpose: verify the task matches `TASKS.md`, `SPEC.md`, and the declared interface contract.

Required output:

- Strict mode: `SPEC_REVIEW.md`
- Lean mode: `SPEC_REVIEW.md` or combined `REVIEW.md`

Required fields:

```markdown
## Decision: APPROVED | CHANGES_REQUIRED

## Missing

- [missing requirement]
- (or "none")

## Extra

- [unrequested behavior]
- (or "none")

## Notes

- [short explanation]
- (or "none")
```

---

## Code Quality Review

Purpose: verify implementation quality only after scope correctness is approved.

Required output:

- Strict mode: `QUALITY_REVIEW.md`
- Lean mode: `QUALITY_REVIEW.md` or combined `REVIEW.md`

Required fields:

```markdown
## Decision: APPROVED | CHANGES_REQUIRED

## Critical

- [issue]
- (or "none")

## Important

- [issue]
- (or "none")

## Minor

- [issue]
- (or "none")

## Notes

- [short explanation]
- (or "none")
```

Tasks with unresolved `Critical` or `Important` issues are not accepted.

---

## Combined Review In Lean Mode

If Lean mode uses one `REVIEW.md`, it must contain both sections below in this order:

```markdown
## Spec Compliance: APPROVED | CHANGES_REQUIRED

## Missing

- [entry]
- (or "none")

## Extra

- [entry]
- (or "none")

## Code Quality: APPROVED | CHANGES_REQUIRED

## Critical

- [entry]
- (or "none")

## Important

- [entry]
- (or "none")

## Minor

- [entry]
- (or "none")

## Notes

- [entry]
- (or "none")
```

---

## Re-Spawn Payload Additions

When re-spawning, prepend to the YAML args passed to `senior-engineer`:

```yaml
# prepend these fields to the existing YAML payload:
previous_attempt_review: |
  [paste relevant DONE.md, SPEC_REVIEW.md, QUALITY_REVIEW.md, or REVIEW.md section]
issues_found:
  - "[specific failure]"
fix_required:
  - "[specific correction — do not change anything outside assigned tasks]"
```
