# Task Tracker

## Legend

- Checklist items reference the Module Customization Checklist in `instructions.md`
- `bicep build` = minimum acceptance gate for any change

---

## GAP: New Modules Needed

### GAP-1: Cosmos-DB (document-db/database-account)

- [ ] Research upstream module (`microsoft-avm/avm/res/document-db/database-account/`, v0.19)
  - 9 child modules: cassandra-keyspace, cassandra-role-assignment, cassandra-role-definition, gremlin-database, mongodb-database, sql-database, sql-role-assignment, sql-role-definition, table
- [ ] Azure Policy Expert: identify Cosmos-DB policies from `policy/Generic/` and `policy/knowledge_base/Azure-Components/Cosmos-DB/Security-Baseline.rst`
- [ ] Plan: decide which child modules to include (not all may be needed)
- [ ] Fork upstream `main.bicep` → `amavm/verified-modules/bicep/res/document-db/database-account/`
- [ ] Apply full Module Customization Checklist (metadata, evidenceOfNonCompliance, versionInfo, shared types, telemetry with take(64), role defs, finalTags, explicit diagnostic categories)
- [ ] Create `upstream.json` (v0.19), `version.json` (v0.1)
- [ ] Create `tests/e2e/defaults/`, `tests/e2e/max/`, `tests/e2e/waf-aligned/`
- [ ] Create `README.md`
- [ ] Karen: `bicep build` passes, all checklist items verified

### GAP-2: Event-Hubs (event-hub/namespace)

- [ ] Research upstream (`microsoft-avm/avm/res/event-hub/namespace/`, v0.14)
- [ ] Assess `ORPHANED.md` — determine if upstream is deprecated or just unmaintained
- [ ] Azure Policy Expert: identify Event-Hub policies
- [ ] Fork upstream `main.bicep` → `amavm/verified-modules/bicep/res/event-hub/namespace/`
  - Child modules: authorization-rule, disaster-recovery-config, eventhub, network-rule-set
- [ ] Apply full Module Customization Checklist
- [ ] Create `upstream.json`, `version.json`, tests, `README.md`
- [ ] Karen: validate

### GAP-3: Redis (cache/redis)

- [ ] Research upstream (`microsoft-avm/avm/res/cache/redis/`, v0.16)
  - Child modules: access-policy, access-policy-assignment, firewall-rule, linked-servers
- [ ] Azure Policy Expert: identify Redis policies
- [ ] Fork upstream `main.bicep` → `amavm/verified-modules/bicep/res/cache/redis/`
- [ ] Apply full Module Customization Checklist
- [ ] Create `upstream.json`, `version.json`, tests, `README.md`
- [ ] Karen: validate

### GAP-4: Notification-Hubs

- [ ] No upstream AVM module exists — decision required: build custom or defer?
- [ ] Azure Policy Expert: identify applicable policies from `policy/Generic/` and `policy/knowledge_base/Azure-Components/Notification-Hubs/Security-Baseline.rst`
- [ ] If building: determine ARM resource type (`Microsoft.NotificationHubs/namespaces`), plan parameters
- [ ] Implement at `amavm/verified-modules/bicep/res/notification-hubs/namespace/`
- [ ] Apply full Module Customization Checklist
- [ ] Create version files, tests, `README.md`
- [ ] Karen: validate

---

## TECH-DEBT: Per-Module Fixes

Findings from full audit of all existing whitelisted modules. Modules are ordered by severity (most failures first).

### TD-01: app-configuration/configuration-store — 5 failures

| # | Issue | Fix |
|---|---|---|
| 6 | `versionInfo` variable missing | Add `var versionInfo = loadJsonContent('version.json')` |
| 7 | `moduleVersion` variable missing | Add `var moduleVersion = versionInfo.version` |
| 10 | Telemetry name not truncated to 64 chars | Wrap telemetry name with `take(..., 64)` |
| 14 | Uses `tags` directly instead of `finalTags` | Add `var finalTags = union(tags ?? {}, {...})` and replace `tags` usage |
| 15 | Has `{ categoryGroup: 'allLogs' }` | Replace with explicit list of supported log categories |

- [ ] Fix all 5 issues
- [ ] `bicep build` passes
- [ ] Karen: re-audit all 18 checklist items

### TD-02: service-bus/namespace — 5 failures

| # | Issue | Fix |
|---|---|---|
| 6 | `versionInfo` variable missing | Add `var versionInfo = loadJsonContent('version.json')` |
| 7 | `moduleVersion` variable missing | Add `var moduleVersion = versionInfo.version` |
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |
| 14 | Uses `tags` directly instead of `finalTags` | Add `finalTags` variable and replace usage |
| 15 | Has `{ categoryGroup: 'allLogs' }` | Replace with explicit log categories |

- [ ] Fix all 5 issues
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-03: container-service/managed-cluster — 3 failures

| # | Issue | Fix |
|---|---|---|
| 6 | `versionInfo` variable missing | Add variable |
| 7 | `moduleVersion` variable missing | Add variable |
| 16 | Non-standard test folder names (`1defaults`, `2priv`, `3azure`, `4waf-aligned`, `5automatic`) | Ensure `defaults/`, `max/`, `waf-aligned/` exist (may be aliased by numbered prefixes — verify if build tooling handles this) |

- [ ] Fix issues (test folder naming may be intentional — confirm before changing)
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-04: web/site — 2 failures

| # | Issue | Fix |
|---|---|---|
| 4 | Some `@description()` decorators don't start with `Required.`/`Optional.`/`Conditional.`/`Generated.` | Audit all parameter descriptions and fix prefixes |
| 16 | Non-standard test folder names (`1webAppLinux.defaults`, `5waf-aligned`, etc.) | Ensure standard `defaults/`, `max/`, `waf-aligned/` naming (or confirm build tooling handles prefixed names) |

- [ ] Fix description prefixes
- [ ] Resolve test folder naming
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-05: storage/storage-account — 1 failure

| # | Issue | Fix |
|---|---|---|
| 4 | 13 output descriptions lack `Required.`/`Optional.` etc. prefix | Add appropriate prefix to all output `@description()` decorators |

- [ ] Fix output description prefixes
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-06: search/search-service — 1 failure

| # | Issue | Fix |
|---|---|---|
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |

- [ ] Fix telemetry truncation
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-07: network/application-gateway — 1 failure

| # | Issue | Fix |
|---|---|---|
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |

- [ ] Fix telemetry truncation
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-08: insights/component (Application-Insights) — 1 failure

| # | Issue | Fix |
|---|---|---|
| 5 | `evidenceOfNonCompliance` output is commented out | Uncomment or re-implement the output |

- [ ] Fix commented-out output
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-09: db-for-postgre-sql/flexible-server — 1 failure

| # | Issue | Fix |
|---|---|---|
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |

Note: `evidenceOfNonCompliance` output exists but is hardcoded to `false` — review if this should check actual compliance state.

- [ ] Fix telemetry truncation
- [ ] Review `evidenceOfNonCompliance` logic
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-10: sql/server — 1 failure

| # | Issue | Fix |
|---|---|---|
| 4 | One description has typo "Deafult:" instead of proper prefix | Fix typo and add correct `Optional.` prefix |

- [ ] Fix description typo
- [ ] `bicep build` passes
- [ ] Karen: re-audit

### TD-11: Fully Compliant Modules (no fixes needed)

These modules passed all 18 checklist items. No action required unless upstream drift audit reveals changes.

- [x] key-vault/vault — 18/18 PASS
- [x] cognitive-services/account — 18/18 PASS
- [x] data-factory/factory — 18/18 PASS
- [x] databricks/workspace — 18/18 PASS
- [x] operational-insights/workspace — 18/18 PASS
- [x] web/serverfarm — 18/18 PASS

### TD-12: Remaining Module Audits (not yet analyzed)

These modules need their first audit by the Bicep Tech Debt Analyst:

- [ ] databricks/access-connector
- [ ] web/static-site
- [ ] managed-identity/user-assigned-identity
- [ ] insights/action-group
- [ ] insights/activity-log-alert
- [ ] insights/data-collection-endpoint
- [ ] insights/data-collection-rule
- [ ] insights/diagnostic-setting
- [ ] insights/metric-alert
- [ ] insights/private-link-scope
- [ ] insights/scheduled-query-rule
- [ ] insights/webtest
- [ ] network/application-gateway-web-application-firewall-policy
- [ ] network/network-security-group
- [ ] network/private-endpoint
- [ ] network/route-table
- [ ] network/virtual-network

---

## POLICY: Compliance Audits

Each whitelisted module audited by Azure Policy Expert against `policy/Generic/*.json` and `policy/knowledge_base/`. Not yet started.

- [ ] AI-Search (search/search-service)
- [ ] AI-services (cognitive-services/account)
- [ ] App-Configuration (app-configuration/configuration-store)
- [ ] Application-Gateway (network/application-gateway)
- [ ] Application-Insights (insights/component)
- [ ] App-Service (web/site, web/serverfarm)
- [ ] Container-Registry (container-registry/registry)
- [ ] Databricks (databricks/*)
- [ ] Data-Factory (data-factory/factory)
- [ ] Key-Vault (key-vault/vault)
- [ ] Kubernetes-Service (container-service/managed-cluster)
- [ ] Log-Analytics-Workspace (operational-insights/workspace)
- [ ] Monitor (insights/*)
- [ ] PostgreSQL (db-for-postgre-sql/flexible-server)
- [ ] Service-Bus (service-bus/namespace)
- [ ] SQL-Database (sql/server)
- [ ] Storage-Account (storage/storage-account)

---

## Completed Tasks

- [x] Set up multi-agent task management structure
- [x] Document three-project architecture
- [x] Narrow scope to 22 whitelisted components
- [x] Gap analysis: identify 4 missing modules
- [x] Map all existing modules with upstream version tracking
- [x] Define Module Customization Checklist from amavm README
- [x] Define 3 specialized agents (Bicep Tech Debt Analyst, Azure Policy Expert, Karen)
- [x] Full audit of all 17 whitelisted modules against 18-point checklist
- [x] Create granular per-module task backlog with specific findings
