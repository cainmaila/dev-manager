# Interview Phases Reference

## Not Applicable Rules

A phase is **N/A** if either condition is true:

1. **Spec already answers it** — the requirements document explicitly states the decision. Pre-fill the decision log from the spec; do not ask.
2. **System doesn't need it** — the phase is structurally irrelevant (e.g., Phase 5 Auth for a CLI tool with no user login; Phase 6 Integrations for a self-contained local script; Phase 2 Frontend for a pure API service).

Mark the phase as `N/A` in the decision log with a one-line reason. Treat N/A phases as "resolved" for the purposes of the completion signal. Do not ask questions about N/A phases.

---

## Phase Checklist

Work through phases in order. Mark N/A (see rules above) rather than asking unnecessary questions.

### Phase 1: Runtime & Language

Questions to resolve:

- What programming language(s)?
- What language version constraints?
- Monorepo or separate repos?

### Phase 2: Framework & Libraries

Questions to resolve:

- Backend framework (if applicable)?
- Frontend framework (if applicable)?
- Any mandatory libraries or SDKs?
- Any libraries explicitly forbidden?

### Phase 3: Data Layer

Questions to resolve:

- Database type (relational / document / key-value / time-series)?
- Specific database product?
- ORM or raw queries?
- Migration strategy (schema-first or code-first)?
- Caching layer needed?

### Phase 4: Infrastructure & Deployment

Questions to resolve:

- Where does this run? (local / VPS / cloud provider / container platform)
- Containerized? (Docker, Kubernetes?)
- CI/CD pipeline requirements?
- Environments needed? (dev / staging / prod)

### Phase 5: Auth & Security

Questions to resolve:

- Authentication method? (session, JWT, OAuth2, SSO, none)
- Authorization model? (RBAC, ABAC, flat, none)
- Any compliance requirements? (GDPR, HIPAA, PCI, etc.)
- Any security-mandated tooling that must be used? (e.g., specific IdP, KMS, secret manager, audit logging service, WAF)

### Phase 6: Integrations & External APIs

Questions to resolve:

- Any third-party services to integrate?
- Are API keys/credentials already available or to be provisioned?
- Any webhooks? If yes: inbound (external → this system), outbound (this system → external), or both?

### Phase 7: Non-Functional Requirements

Questions to resolve:

- Expected concurrent users or request volume?
- Response time targets?
- Availability SLA?
- Observability requirements? (logging, metrics, tracing)

### Phase 8: Team & Dev Constraints

Questions to resolve:

- Team size and roles?
- Any deadline (time constraints)?
- Any budget constraints? (e.g., cloud spend cap, licensing limits)
- How many developers are expected to work in parallel on this project?
- Preferred split strategy for parallel work? (by layer, by domain, by user journey, or no preference)
- Existing codebase to integrate with?
- Any technologies forbidden at any layer (database engines, cloud platforms, deployment methods, vendors)? (Libraries are covered in Phase 2 — this phase catches everything else.)
- Any must-use technologies mandated by the business or organization (beyond libraries)?
- Which contracts or boundaries should be frozen first so multiple developers can work independently? (e.g., API schema, DB migration plan, event payloads, shared component props)
- Are mocks/stubs acceptable so dependent tasks can proceed before the real implementation is finished?
- Any required integration checkpoints or merge milestones? (e.g., daily contract sync, end-of-sprint integration branch)

---

## Decision Log Format

Every field in this log maps to a named field in the SPEC.md template. No field is orphaned. Maintain in conversation after each answer.

**SPEC mapping key** — shown as `→ SPEC §section.field` on each line below.

```
## Technical Decisions Log

### Runtime & Language         [Phase 1]
- Language: [value]                              → SPEC §2 Language
- Version: [value]                               → SPEC §2 Language / Notes
- Repo structure: [monorepo / separate repos / N/A]  → SPEC §5 Repo structure

### Framework                  [Phase 2]
- Backend: [value | N/A]                         → SPEC §2 Backend Framework
- Frontend: [value | N/A]                        → SPEC §2 Frontend Framework
- Must-use libraries: [list | none]              → merged into SPEC §5 Must-use tech
- Forbidden libraries: [list | none]             → merged into SPEC §5 Forbidden tech

### Data Layer                 [Phase 3]
- DB: [value | N/A]                              → SPEC §2 Database
- ORM: [value | none | N/A]                      → SPEC §2 Database / Notes
- Cache: [value | none | N/A]                    → SPEC §2 Cache
- Migration strategy: [value | N/A]              → SPEC §2 Migration strategy

### Infrastructure             [Phase 4]
- Platform: [value | N/A]                        → SPEC §2 Infrastructure
- Containers: [yes/no | N/A]                     → SPEC §2 Infrastructure / Notes
- CI/CD: [value | none | N/A]                    → SPEC §2 CI/CD
- Environments: [list | N/A]                     → SPEC §2 Environments

### Auth & Security            [Phase 5]
- Auth method: [value | none | N/A]              → SPEC §2 Auth method
- Authorization model: [value | none | N/A]      → SPEC §2 Authorization model
- Compliance: [list | none]                      → SPEC §5 Compliance
- Must-use tech (security): [list | none]        → merged into SPEC §5 Must-use tech

### Integrations               [Phase 6]
- [service]: purpose=[value], credentials=[available/needed/N/A], webhooks=[inbound/outbound/both/none]  → SPEC §4 row
- (mark entire section N/A if no integrations)

### NFR                        [Phase 7]
- Scale target: [value | not specified]          → SPEC §6 Scale target
- Response time: [value | not specified]         → SPEC §6 Response time target
- Availability SLA: [value | not specified]      → SPEC §6 Availability SLA
- Observability: [list | none]                   → SPEC §6 Observability

### Team & Constraints         [Phase 8]
- Team: [size and roles]                         → SPEC §5 Team
- Deadline: [date | none stated]                 → SPEC §5 Deadline
- Budget: [description | none stated]            → SPEC §5 Budget
- Must-use tech (business): [list | none]        → merged into SPEC §5 Must-use tech
- Forbidden tech (any layer): [list | none]      → merged into SPEC §5 Forbidden tech
- Existing codebase: [yes: description | no]     → SPEC §5 Existing codebase

### Parallelization            [Phase 8]
- Parallel developers: [value | not specified]   → SPEC §8 Expected parallel developers
- Split strategy: [value | not specified]        → SPEC §8 Split strategy
- Contract-first boundaries: [list | none]       → SPEC §8 Contract-first boundaries
- Mock/stub policy: [allowed / not allowed / limited / not specified]  → SPEC §8 Mock/stub policy
- Integration checkpoints: [value | none stated] → SPEC §8 Integration checkpoints

### Scope                      [Workflow Phase 2]
- MVP features: [list from spec]                 → SPEC §7 MVP features
- Deferred features: [list: feature — reason | none]  → SPEC §7 Deferred
- Known risks: [list entries use format below]   → SPEC §9 Open Risks rows
  - Risk: [description] | Impact: [H/M/L] | Mitigation: [plan or "none"]

### Open Questions
- [question]: unresolved
```

**Merge rules for SPEC §5:**

- `Must-use tech` = Phase 2 must-use libraries + Phase 5 must-use tech (security) + Phase 8 must-use tech (business), deduplicated
- `Forbidden tech` = Phase 2 forbidden libraries + Phase 8 forbidden tech (any layer), deduplicated

**Rules:**

- Every field must have a value or explicit `N/A` / `none` / `not specified` before tasks are generated.
- "Open Questions" must be empty at completion.
- Fields pre-filled from the spec are still recorded — mark them `(from spec)`.

---

## Contradiction Detection Checklist

After every answer, scan for these contradiction patterns:

| Pattern                                | Example                                           |
| -------------------------------------- | ------------------------------------------------- |
| Tech A incompatible with Tech B        | "Serverless" + "WebSocket persistent connections" |
| Constraint conflicts with scale        | "Solo dev" + "99.99% SLA"                         |
| Framework conflicts with language      | PHP framework + Python language                   |
| DB choice conflicts with data shape    | Relational DB + "flexible schema"                 |
| Auth method conflicts with integration | "No server" + "Session-based auth"                |
| Deadline conflicts with scope          | "2 weeks" + 40 tasks                              |

When a contradiction is found, surface it:

> "我注意到一個可能的矛盾：你選了 [A]，但也提到 [B]，這兩個可能衝突，因為 [reason]。你想怎麼解決？"

Do not proceed to the next question until the contradiction is resolved.

---

## Completion Signal

Interview is complete when:

- Every decision log field has a value, `N/A`, `none`, or `not specified` — no blanks
- "Open Questions" section is empty
- No unresolved contradictions
- Scope Validation (Workflow Phase 2) is done

Final confirmation message — adapt to user's language:

> ZH: "技術決策已全部確認，無矛盾。MVP 範圍：[summary]. 準備拆解開發任務。"
> EN: "All technical decisions confirmed, no contradictions. MVP scope: [summary]. Ready to generate tasks."

Then proceed to ask for output path (Workflow Phase 3).
