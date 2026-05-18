# Review Gates

Phase 4 has two independent review gates after delivery evidence passes.

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

## Re-Spawn Rule

If either review says `CHANGES_REQUIRED`, copy the relevant review excerpts into the next implementation payload under `previous_attempt_review`, `issues_found`, and `fix_required`.
