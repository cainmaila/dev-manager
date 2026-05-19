---
name: dev-doc-cleaner
description: Use when the user explicitly asks to clean up dev-manager project documents, archive stale change artifacts, or compact outdated task records for a specific project root.
argument-hint: <project root path>
user-invocable: true
---

# Dev Doc Cleaner

**Initial request:** $ARGUMENTS

Audit and clean `dev-manager` and `dev-change-manager` documents inside one project root. Only run when explicitly invoked. Never modify files until the user approves the cleanup plan.

---

## Phase 0 — Load Project Context

1. Resolve the project root path from `$ARGUMENTS`. If absent, ask once. Do not proceed without it.
2. Verify the path exists.
3. Scan all managed document types in `references/cleanup-rules.md`. Exclude `.archive/`.
4. Report:
   - Project root
   - Document counts by type
   - Found CR ids
   - Task module count

---

## Phase 1 — Audit

Perform a read-only analysis of all discovered documents. Classify each into one of four states:

| State        | Meaning                                                                                      |
| ------------ | -------------------------------------------------------------------------------------------- |
| **Current**  | Matches current project state; keep                                                          |
| **Stale**    | Superseded but still referenced; follow the per-type action in `references/cleanup-rules.md` |
| **Obsolete** | Superseded and unreferenced; archive by default                                              |
| **Conflict** | Contradicts a newer authoritative artifact                                                   |

Apply the classification rules in `references/cleanup-rules.md` for each document type.

Produce a read-only **Audit Report** grouped as:

- `Current (keep)`
- `Stale (action needed)`
- `Obsolete (archive candidate)`
- `Conflict (needs resolution)`

Each entry should name the artifact and give one short reason.

---

## Phase 2 — Cleanup Plan

Turn the audit report into an explicit action list. Include:

- `Archive` — destination under `[project-root]/.archive/`
- `Compact` — in-place compaction actions such as moving superseded rows in `TASKS.md` to `## Change History`
- `Fix conflicts` — precise live-document updates
- `Keep unchanged` — artifacts intentionally left alone

Show this plan to the user. Then ask:

> "Review the cleanup plan above. Type **confirm** to proceed, or describe any changes to the plan."

Do not touch any file until the user confirms.

---

## Phase 3 — Execute (only after user confirms)

Execute each action in the cleanup plan in this order:

1. **Fixes first** — resolve conflicts in MANAGER_STATE.md and other live docs
2. **Compact second** — move superseded rows in TASKS.md to `## Change History`; append one `<!-- Moved to Change History by dev-doc-cleaner on [YYYY-MM-DD] -->` comment at the end of the section per `references/cleanup-rules.md`
3. **Archive third** — move obsolete files and modules to `.archive/` (create directory if absent)
4. **Delete last** — only delete files the user explicitly approved for deletion in the plan (rare; default is archive)

Rules:

- Report each completed action in one line
- If an action fails, report it and continue
- Never upgrade archive to delete without explicit per-file approval

---

## Phase 4 — Summary

After all actions complete, report:

- Project root
- Files archived
- Documents compacted
- Conflicts resolved
- Files deleted with explicit approval
- Errors skipped
- Remaining live documents

If any conflicts were unresolvable without user input, list them and ask for guidance.

---

## Decision Protocol

At each ambiguous or mutating step, state:

- `Found: [what was discovered]`
- `Proposed: [specific action]`
- `Reason: [one sentence]`

Escalate to user when:

- A file's state is ambiguous (cannot determine if current or stale without domain knowledge)
- A merge would lose information that may still be needed
- An archive/delete targets a file larger than expected scope

---

## Additional Resources

- **`references/cleanup-rules.md`** — Document inventory, classification rules per document type, archive vs delete decision matrix, TASKS.md compaction format
