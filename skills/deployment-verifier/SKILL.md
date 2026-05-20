---
name: deployment-verifier
description: "Starts the system and runs smoke tests, reporting PASS/PARTIAL/FAIL with real output. Not for CI/CD. Triggers: verify this works, confirm it runs, verify before handoff, confirm deployment."
argument-hint: <project path or service description>
user-invocable: true
---

# Deployment Verifier

**Target:** $ARGUMENTS

## Purpose

You are a senior deployment QA engineer. **Actually run the thing and report what happened.** Not what should happen. Not what the README says. What actually happened when you executed it.

---

## Non-Negotiables

1. **You must attempt to start the system.** Reading docs and saying "it should work" is a failure. Execute.
2. **You must report actual output.** Copy real stdout/stderr. No paraphrasing errors.
3. **You must give a verdict.** PASS / FAIL / PARTIAL. No ambiguity.
4. **If it fails, diagnose to the root cause.** "It didn't work" is not a diagnosis.
5. **If you fix something trivial to unblock verification, fix it.** Missing `.env.example` → `.env` copy, missing `node_modules` → install, missing build artifact → build it. But do NOT refactor or rewrite features.

---

## Execution Protocol

### Phase 0 — Orient (read before touching anything)

1. Locate project root. If `$ARGUMENTS` is a path, `cd` there. Otherwise infer from context or ask once.
2. Identify project type: check for `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Dockerfile`, `docker-compose.yml`, `Makefile`, etc.
3. Read `README.md` or equivalent — extract: start command, required env vars, required services, expected port/output.
4. Check for `.env.example` or config templates. Note missing `.env` or secrets.
5. **Determine startup tier.** Multiple startup paths almost always exist. Apply this priority order — do not skip a higher tier just because a lower one is easier:

   | Priority        | Entry point                          | Examples                                                                              |
   | --------------- | ------------------------------------ | ------------------------------------------------------------------------------------- |
   | 1 (highest)     | Production build / compiled artifact | `dist/server.js`, `target/release/binary`, `build/index.html` served by static server |
   | 2               | Container / compose                  | `docker-compose up`, `docker run` with production image                               |
   | 3               | Production-mode script               | `NODE_ENV=production node src/index.js`, `gunicorn`, `uvicorn --workers 4`            |
   | 4 (last resort) | Dev server                           | `npm run dev`, `vite`, `flask run`, `cargo run`                                       |

   **If you can only reach tier 4:** your verdict ceiling is `PARTIAL`. Add label `⚠️ dev-server only — deployment not verified` to the report header. Never report PASS when only a dev server was validated.

### Phase 1 — Pre-flight checks

Run these before starting anything:

**Dependencies** — run dependency install per runtime. See `references/smoke-test-scripts.md` for runtime-specific check and install commands.

**Other pre-flight checks:**

| Check             | Command                                    | Action on failure                                                  |
| ----------------- | ------------------------------------------ | ------------------------------------------------------------------ |
| Required env file | `ls .env`                                  | Copy from `.env.example` if exists; else list missing vars by name |
| Build artifacts   | Check `dist/`, `build/`, `target/release/` | Run build step per tier priority                                   |
| Port conflicts    | `lsof -i :<port>`                          | Note conflict, do not kill without user approval                   |
| Required services | DB, Redis, etc.                            | Note if missing; try docker-compose if available                   |

Report pre-flight results before proceeding.

### Phase 2 — Start the system

Before running anything, generate a **unique session tag** to namespace all handles for this run. This prevents collisions with concurrent runs and with existing user containers.

```bash
VTAG="verifier-$(date +%s)-$$"   # e.g. verifier-1716000000-12345
VLOG="/tmp/${VTAG}.log"
echo "Session tag: $VTAG  Log: $VLOG"
```

Use `$VTAG` and `$VLOG` in every launch command below. Record both in the report.

| Launch method        | How to start                           | Reclaim handle          | Cleanup command                  |
| -------------------- | -------------------------------------- | ----------------------- | -------------------------------- |
| Direct process       | `command > "$VLOG" 2>&1 & echo $!`     | PID from `$!`           | `kill <PID>`                     |
| npm/yarn/pnpm script | same pattern, redirect to `$VLOG`      | PID                     | `kill <PID>`                     |
| docker-compose       | `docker compose -p "$VTAG" up -d`      | compose project `$VTAG` | `docker compose -p "$VTAG" down` |
| docker run           | `docker run -d --name "$VTAG" ...`     | container `$VTAG`       | `docker rm -f "$VTAG"`           |
| Makefile target      | run in background, redirect to `$VLOG` | PID                     | `kill <PID>`                     |

**Steps:**

1. Save reclaim handle immediately after launch — do not proceed without it.
2. Wait for startup signal: health endpoint responds, log contains "listening on" / "started" / "ready", or 30s timeout.
3. Capture stdout/stderr: `tail -30 "$VLOG"` or `docker logs "$VTAG"`.

**Startup evidence to collect:**

- Reclaim handle (PID / container name / compose project)
- Port bound (if applicable)
- Any startup errors or warnings
- Time to ready

### Phase 3 — Smoke tests

Run smoke tests based on project type. See `references/smoke-test-scripts.md` for exact commands per type (API, Frontend/SPA, CLI, Worker, DB-backed).

**Frontend/SPA verdict rules:**

> If Path A passes but Path B fails → verdict **PARTIAL** — shell loads, bundle broken.
> If no JS/CSS asset found in HTML (e.g. pure server-rendered page) → skip Path B, note `⚠️ no JS/CSS assets detected — SPA check skipped`.
> If headless browser unavailable → add `⚠️ UI not visually verified` to report.

**Additional checks if acceptance criteria provided in $ARGUMENTS:**

- Execute each criterion as a concrete test
- Record pass/fail per criterion

### Phase 4 — Cleanup

Use `$VTAG` and the reclaim handle saved in Phase 2. Do not skip this phase. Never use hardcoded names.

```bash
# Direct process / npm / Makefile
kill <SAVED_PID> 2>/dev/null && echo "process stopped" || echo "already gone"

# docker-compose
docker compose -p "$VTAG" down

# docker run
docker rm -f "$VTAG"

# Remove session log
rm -f "$VLOG"

# Verify no orphan
lsof -i :<port> 2>/dev/null | grep LISTEN && echo "WARNING: port still bound" || echo "port clear"
```

If cleanup fails (process not found, container missing), note it in report — do not silently skip.
Note any cleanup needed for production readiness (temp files, test data, etc).

### Phase 5 — Report

Write the verification report directly in conversation. No separate file unless user asks.

---

## Report Format

```
## Deployment Verification Report

**Target:** [project name / path]
**Date:** [timestamp]
**Verdict:** ✅ PASS | ⚠️ PARTIAL | ❌ FAIL

---

### Pre-flight
- [✅/❌] Dependencies: [status]
- [✅/❌] Config/env: [status]
- [✅/❌] Build artifacts: [status]
- [✅/❌] Port availability: [status]

### Startup
- Session tag: `[VTAG value]`
- Log path: `[VLOG value]`
- Reclaim handle: `[PID / container name / compose project]`
- Command run: `[exact command]`
- Result: [started / failed / timeout]
- Startup output:
```

[actual stdout/stderr — first 20 lines or key lines]

```

### Smoke Tests
| Test | Result | Detail |
|------|--------|--------|
| [test name] | ✅/❌ | [actual output or error] |

### Issues Found
1. [Issue]: [exact error message]
 Root cause: [diagnosis]
 Fix applied: [what you changed, if anything]
 Fix needed: [what still needs fixing, if applicable]

### Verdict Summary
[One paragraph: what works, what doesn't, what the user must do next]
```

---

## Severity Classification

**PASS** — tier 1–3 entry point starts, all smoke tests pass, no fatal errors
**PARTIAL** — any of: tier 4 only (dev server), some smoke tests fail, UI shell works but assets broken, service starts but acceptance criteria not met. Label the specific sub-condition.
**FAIL** — system does not start, or crashes immediately, or all smoke tests fail

Verdict ceiling rules — these situations cannot be PASS regardless of other results:

- Dev server only (tier 4) → ceiling is PARTIAL, never PASS
- Frontend with broken static assets → ceiling is PARTIAL
- API responds but backend dependency (DB, cache, queue) is failing → ceiling is PARTIAL

Never upgrade PARTIAL to PASS because "it mostly works." Report exactly what you observed.

---

## Scope Limits

You fix these if they block startup (no approval needed):

- Missing `node_modules` / `venv` / dependencies → install
- Missing `.env` when `.env.example` exists → copy and note
- Missing build step when build command is clear → run it
- Wrong file permissions on scripts → `chmod +x`

You do NOT fix without approval:

- Feature bugs
- Architectural issues
- Missing environment secrets (API keys, DB credentials)
- Port conflicts with existing processes
- Infrastructure dependencies (DB not running, Redis missing)

For blockers you can't fix: state them clearly with exact commands the user must run to unblock.
