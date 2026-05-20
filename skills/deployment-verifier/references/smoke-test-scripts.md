# Deployment Verifier — Reference Scripts

---

## Pre-flight: Dependency Commands

Use these commands to check and install dependencies. Never guess package names — use manifest/lockfile commands only.

| Runtime         | Installed check                                                                                      | Install command                                      |
| --------------- | ---------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| Node (npm)      | `test -d node_modules && echo ok`                                                                    | `npm ci` (if `package-lock.json`) else `npm install` |
| Node (pnpm)     | `test -d node_modules && echo ok`                                                                    | `pnpm install --frozen-lockfile`                     |
| Node (yarn)     | `test -d node_modules && echo ok`                                                                    | `yarn install --frozen-lockfile`                     |
| Python (pip)    | `pip install -r requirements.txt --dry-run 2>&1 \| grep -c "Would install"` — if 0, deps already met | `pip install -r requirements.txt`                    |
| Python (uv)     | `uv sync --check` (exit 0 = env matches lockfile)                                                    | `uv sync`                                            |
| Python (poetry) | `poetry install --dry-run 2>&1 \| grep -c "Installing"` — if 0, env already complete                 | `poetry install`                                     |
| Rust            | `cargo fetch --locked`                                                                               | `cargo fetch --locked`                               |
| Go              | `go mod verify`                                                                                      | `go mod download`                                    |

Other pre-flight checks:

| Check             | Command                                    | Action on failure                                                  |
| ----------------- | ------------------------------------------ | ------------------------------------------------------------------ |
| Required env file | `ls .env`                                  | Copy from `.env.example` if exists; else list missing vars by name |
| Build artifacts   | Check `dist/`, `build/`, `target/release/` | Run build step per tier priority                                   |
| Port conflicts    | `lsof -i :<port>`                          | Note conflict, do not kill without user approval                   |
| Required services | DB, Redis, etc.                            | Note if missing; try docker-compose if available                   |

---

## Smoke Tests by Project Type

### API / backend service

```bash
# 1. Health endpoint (preferred)
curl -sf http://localhost:<port>/health && echo PASS || echo FAIL
# 2. Root or first real endpoint
curl -s -o /dev/null -w "HTTP %{http_code}" http://localhost:<port>/
# 3. Verify JSON response if applicable
curl -sf http://localhost:<port>/api/v1/status | python3 -m json.tool
```

### Frontend / SPA (two-path check — both required)

```bash
BASE="http://localhost:<port>"

# Path A: HTML shell — must return 2xx and contain at least one script/link tag
STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/")
HTML=$(curl -sf "$BASE/")
echo "HTTP: $STATUS"
echo "$HTML" | grep -cE '<script|<link' # must be > 0

# Path B: fetch one real asset to confirm bundle is actually served
# Handles: relative paths (/assets/main.js), absolute URLs (http://...), href (CSS), src (JS)
# Step 1 — extract candidates: both src and href attributes
CANDIDATES=$(echo "$HTML" | grep -oE '(src|href)="[^"]+"' | sed 's/^[a-z]*="//' | tr -d '"')

# Step 2 — filter to likely JS/CSS assets
# Strategy: keep relative paths + localhost absolute URLs; reject other-domain absolute URLs
# Use awk for the domain test — BSD grep lacks PCRE lookahead, but awk regex is portable
ASSET=$(echo "$CANDIDATES" \
  | grep -E '\.(js|css)(\?|$)' \
  | grep -v '^data:' \
  | grep -v '^mailto:' \
  | grep -v '^#' \
  | awk '!/^https?:\/\// || /^https?:\/\/(localhost|127\.0\.0\.1)/' \
  | head -1)
# awk rule: pass through if NOT an absolute URL, OR if absolute URL points to localhost/127.0.0.1
# This keeps: /assets/main.js, assets/main.js, http://localhost:3000/assets/app.js
# This rejects: https://cdn.example.com/lib.js

# Step 3 — normalize to absolute URL (3 cases)
if echo "$ASSET" | grep -qE '^https?://'; then
  # Case A: already absolute URL (e.g. http://localhost:3000/assets/main.js)
  ASSET_URL="$ASSET"
elif echo "$ASSET" | grep -q '^/'; then
  # Case B: root-relative (e.g. /assets/main.js or /static/app.css)
  ASSET_URL="${BASE}${ASSET}"
else
  # Case C: bare relative or ./ relative (e.g. assets/main.js or ./assets/main.js)
  ASSET_CLEAN=$(echo "$ASSET" | sed 's|^\./||')
  ASSET_URL="${BASE}/${ASSET_CLEAN}"
fi

echo "Testing asset: $ASSET_URL"
curl -sf "$ASSET_URL" -o /dev/null -w "asset HTTP %{http_code}\n" && echo "asset OK" || echo "asset FAIL"
```

### CLI tool

```bash
./binary --help
./binary --version
```

### Worker / background job

```bash
ps aux | grep <process>
tail -20 <logfile>
```

### Database-backed service

```bash
grep -i "connected\|error\|refused" <logfile>
```
