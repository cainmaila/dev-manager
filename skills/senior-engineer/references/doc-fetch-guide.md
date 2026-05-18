# Documentation Fetch Guide

## When to Fetch (Decision Rule)

Fetch documentation when any of these are true:

- Uncertain about exact method/function signature
- Library version may have breaking changes
- Configuration options have too many variants to recall precisely
- Authentication or authorization flow is non-trivial
- Output behavior is version-specific (response shape, error codes)
- Library is less common (not Python stdlib, not React core)

**Default stance:** When unsure whether to fetch — fetch. Training data has a cutoff. Libraries ship breaking changes. A 30-second fetch prevents a silent bug.

## Tool Priority

```
1. context7          — best for popular libraries with versioned docs
2. WebFetch          — fallback when context7 has no result, or for specific URLs
```

## context7 Workflow

```
Step 1: resolve-library-id
  Input: library name (e.g. "prisma", "fastapi", "langchain")
  Output: context7 library ID

Step 2: query-docs
  Input: library ID + specific question
  Output: relevant documentation excerpts

Example:
  resolve-library-id("prisma") → /prisma/prisma
  query-docs("/prisma/prisma", "how to use upsert with unique constraints")
```

**Query specificity matters.** "How does prisma work" returns noise. "prisma upsert conflict resolution on unique constraint" returns the exact section needed.

## WebFetch Workflow

Use when:
- context7 has no result for the library
- Need a specific version's changelog
- Need official API reference from a specific URL

```
WebFetch(url) → parse the relevant section → extract exact answer
```

Prefer official docs over community posts. Stack Overflow answers may be outdated. Official migration guides are authoritative.

## Common Fetch Targets by Domain

| Domain | What to verify | Source pattern |
|---|---|---|
| ORM / DB | query builder syntax, migration API, transaction handling | official docs |
| Auth libraries | token format, expiry handling, refresh flow | official docs |
| HTTP clients | timeout config, error handling, retry behavior | official docs |
| Cloud SDKs | credential chain, region config, error codes | official docs + SDK changelog |
| Test frameworks | assertion API, fixture lifecycle, async test support | official docs |
| Frontend | hook dependency rules, event handling, SSR constraints | official docs |

## Logging Fetches in DONE.md

Every fetch must be logged:

```markdown
## Documentation Fetched
- fastapi — dependency injection with async functions — https://fastapi.tiangolo.com/tutorial/dependencies/
- prisma — upsert API in v5 — context7 /prisma/prisma
- boto3 — S3 presigned URL generation — https://boto3.amazonaws.com/v1/documentation/api/latest/...
```

This creates a reproducible record. If a behavior is questioned later, the source is known.

## What Not to Fetch

Do not fetch for:
- Language built-ins (Python list methods, JS array methods)
- Math/logic operations
- Standard library modules used daily (os.path, json, fs)
- Patterns that are clearly stable (HTTP status codes, REST conventions)

Fetching everything wastes time. Fetching nothing ships bugs. The line is: "Would a reasonable senior engineer remember this precisely, or would they double-check?"
