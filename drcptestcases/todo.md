# DRCP Test Cases — Task Tracker

## Purpose

These test cases validate that AMAVM Bicep modules deploy correctly to the hardened DRCP platform. Each scenario combines multiple modules into a realistic architecture, deploys via scheduled pipeline, and tears down afterwards to save costs. They serve as integration tests — catching issues that per-module e2e tests miss (cross-module wiring, private endpoint connectivity, identity/RBAC chains, naming conventions).

---

## Legend

- **Fully AMAVM**: All resource modules use `br/amavm:` registry references (only `naming.bicep` is local)
- **Partial**: Mix of AMAVM and local `../../modules/infra/` references
- **Local count**: Number of `../../modules/infra/` references that have an AMAVM equivalent

---

## P0 — Module Migration (replace local modules with AMAVM)

Replace local `../../modules/infra/` references with AMAVM registry modules where equivalents exist. This is the core tech debt — maintaining two implementations of the same resource.

### Scenario 2 — Cosmos DB migration (5 local refs)

| Local module | AMAVM replacement |
|---|---|
| `modules/infra/storage/cosmos-db/main.bicep` | `br/amavm:res/document-db/database-account` |
| `modules/infra/storage/cosmos-db/secureKeys.bicep` | Absorbed into database-account module |
| `modules/infra/storage/cosmos-db/apis/sql/sqldatabase.bicep` | `document-db/database-account/sql-database` child |
| `modules/infra/storage/cosmos-db/apis/sql/container.bicep` | `document-db/database-account/sql-database/container` child |
| `modules/infra/network/private-endpoint/main.bicep` | `br/amavm:res/network/private-endpoint` |

- [ ] Migrate Cosmos DB to AMAVM `document-db/database-account`
- [ ] Replace local PE with AMAVM PE module
- [ ] Validate deployment + teardown

### Scenario 4 — Event Hub migration (6 local refs)

| Local module | AMAVM replacement |
|---|---|
| `modules/infra/integration/event-hub/namespace.bicep` | `br/amavm:res/event-hub/namespace` |
| `modules/infra/integration/event-hub/main.bicep` | `event-hub/namespace/eventhub` child |
| `modules/infra/integration/event-hub/consumer-group.bicep` | `event-hub/namespace/eventhub/consumergroup` child |
| `modules/infra/network/private-endpoint/main.bicep` | `br/amavm:res/network/private-endpoint` |
| `modules/infra/integration/event-hub/modules/role-assignment.bicep` | Use AMAVM `roleAssignments` param |
| `modules/infra/storage/storage-account/modules/role-assignment.bicep` | Use AMAVM `roleAssignments` param |

- [ ] Migrate Event Hub to AMAVM `event-hub/namespace` (pass eventhubs + consumergroups as params)
- [ ] Replace local PE with AMAVM PE module
- [ ] Replace local role-assignment helpers with AMAVM `roleAssignments` param
- [ ] Validate deployment + teardown

### Scenario 8 — Cosmos DB + helpers (9 local refs, worst offender)

| Local module | AMAVM replacement |
|---|---|
| `modules/infra/storage/cosmos-db/main.bicep` | `br/amavm:res/document-db/database-account` |
| `modules/infra/storage/cosmos-db/apis/sql/sqldatabase.bicep` | `document-db/database-account/sql-database` child |
| `modules/infra/storage/cosmos-db/apis/sql/container.bicep` (x2) | `document-db/database-account/sql-database/container` child |
| `modules/infra/network/private-endpoint/main.bicep` | `br/amavm:res/network/private-endpoint` |
| `modules/infra/storage/cosmos-db/modules/role-assignment.bicep` (x2) | Use AMAVM `roleAssignments` param |
| `modules/infra/storage/storage-account/modules/role-assignment.bicep` | Use AMAVM `roleAssignments` param |
| `modules/infra/compute/function-app/function.bicep` | Evaluate: may be app-code deploy helper, not infra |
| `modules/infra/integration/api-management/main.bicep` | **No AMAVM equivalent** — see P1 |
| `modules/infra/network/public-ip-address/main.bicep` | **No AMAVM equivalent** — see P1 |

- [ ] Migrate Cosmos DB to AMAVM (same pattern as scenario 2)
- [ ] Replace local PE and role-assignment helpers
- [ ] Evaluate `function.bicep` — if it's app deployment logic, keep local; if infra, migrate
- [ ] API Management and Public IP blocked on P1
- [ ] Validate deployment + teardown

### Scenario 10 — Data Factory migration (4 local refs)

| Local module | AMAVM replacement |
|---|---|
| `modules/infra/integration/data-factory/main.bicep` | `br/amavm:res/data-factory/factory` |
| `modules/infra/integration/data-factory/modules/role-assignment.bicep` | Use AMAVM `roleAssignments` param |
| `modules/infra/integration/data-factory/integrationRuntime.bicep` | `data-factory/factory/managed-virtual-network` child or inline |
| `modules/infra/network/private-endpoint/main.bicep` | `br/amavm:res/network/private-endpoint` |

- [ ] Migrate Data Factory to AMAVM `data-factory/factory`
- [ ] Verify integration runtime support in AMAVM module (managed VNet IR)
- [ ] Replace local PE with AMAVM PE module
- [ ] Validate deployment + teardown

### Scenario 7 — ACR helpers (2 local refs)

| Local module | AMAVM replacement |
|---|---|
| `modules/infra/compute/container-registry/modules/role-assignment.bicep` | Use AMAVM `roleAssignments` param on `container-registry/registry` |
| `modules/infra/compute/container-registry/task.bicep` | Evaluate: ACR Tasks may need to stay local (not in AMAVM) |

- [ ] Replace ACR role-assignment with AMAVM `roleAssignments` param
- [ ] Evaluate ACR task.bicep — keep local if AMAVM doesn't cover tasks
- [ ] Validate deployment + teardown

### Scenario 5 — Public IP (1 local ref)

| Local module | AMAVM replacement |
|---|---|
| `modules/infra/network/public-ip-address/main.bicep` | **No AMAVM equivalent** — see P1 |

- [ ] Blocked on P1 (Public IP module)

---

## P1 — New AMAVM Modules Needed

### API Management — NOT APPLICABLE

API Management is **not a whitelisted DRCP component**. Scenario 8's APIM usage (conditional deployment) should be removed or flagged as non-DRCP. No AMAVM module needed.

- [ ] Remove or disable APIM deployment from scenario 8
- [ ] Update scenario 8 README to reflect APIM is out of scope

### Public IP Address

- Used by: Scenarios 5, 8 (Application Gateway requires public IP)
- Complexity: Low — simple resource, few properties
- Tracked in main task tracker (`tasks/todo.md`) as a new AMAVM module candidate
- [ ] Create AMAVM module `network/public-ip-address`

---

## P2 — AMAVM Module Coverage by Test Cases

Audit which AMAVM modules are exercised by at least one test case scenario. Gaps represent modules that only have per-module e2e tests but no integration-level validation on the DRCP platform.

### Currently covered by test cases

| AMAVM Module | Scenarios |
|---|---|
| `operational-insights/workspace` | 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 |
| `insights/component` | 1, 2, 3, 4, 5, 7, 8, 9, 11 |
| `network/network-security-group` | 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 |
| `network/route-table` | 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 |
| `network/virtual-network` (subnet) | 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 |
| `key-vault/vault` | 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 |
| `storage/storage-account` | 1, 2, 3, 4, 5, 7, 8, 9, 10, 11 |
| `web/serverfarm` | 1, 2, 3, 4, 5, 7, 8, 11 |
| `web/site` | 1, 2, 3, 4, 5, 7, 8, 11 |
| `managed-identity/user-assigned-identity` | 1, 3, 7, 8, 11 |
| `sql/server` | 1, 11 |
| `container-registry/registry` | 7, 9 |
| `container-service/managed-cluster` | 9 |
| `network/application-gateway` | 5, 9 |
| `databricks/workspace` | 10 |
| `databricks/access-connector` | 10 |

### NOT covered — no test case exercises these AMAVM modules

| AMAVM Module | Notes |
|---|---|
| `document-db/database-account` | Scenarios 2, 8 USE Cosmos DB but via local modules — migration (P0) would fix |
| `event-hub/namespace` | Scenario 4 USES Event Hub but via local modules — migration (P0) would fix |
| `data-factory/factory` | Scenario 10 USES ADF but via local modules — migration (P0) would fix |
| `cache/redis` | **No scenario covers Redis** |
| `search/search-service` | **No scenario covers AI Search** |
| `cognitive-services/account` | **No scenario covers AI Services / OpenAI** |
| `app-configuration/configuration-store` | **No scenario covers App Configuration** |
| `service-bus/namespace` | **No scenario covers Service Bus** |
| `db-for-postgre-sql/flexible-server` | **No scenario covers PostgreSQL** |
| `network/private-endpoint` | Scenarios use PE but via local modules — migration (P0) would fix |
| `insights/webtest` | **No scenario covers Web Tests** |
| `insights/action-group` | **No scenario covers Action Groups** |
| `insights/activity-log-alert` | **No scenario covers Activity Log Alerts** |
| `insights/data-collection-rule` | **No scenario covers Data Collection Rules** |
| `insights/data-collection-endpoint` | **No scenario covers Data Collection Endpoints** |
| `insights/metric-alert` | **No scenario covers Metric Alerts** |
| `insights/private-link-scope` | **No scenario covers Private Link Scopes** |
| `insights/scheduled-query-rule` | **No scenario covers Scheduled Query Rules** |
| `insights/diagnostic-setting` | **No scenario covers Diagnostic Settings (subscription-level)** |
| `web/static-site` | **No scenario covers Static Web Apps** |
| `network/virtual-network` (full module) | Scenarios only use subnet child module |

- [ ] After P0 migrations, re-assess coverage — Cosmos DB, Event Hub, Data Factory, PE will be covered
- [ ] Evaluate new scenarios for uncovered high-value modules (Redis, AI Search, PostgreSQL, Service Bus)
- [ ] Low-priority utility modules (action-group, metric-alert, etc.) may not need dedicated scenarios

---

## P3 — Version Bumps

All scenarios currently reference old AMAVM module versions (0.1.0–0.3.0). The registry has been updated significantly. After P0 migrations are done, bump all module references to latest versions.

| Module | Current version in test cases | Latest in registry |
|---|---|---|
| All modules | 0.1.0 – 0.3.0 | TBD — check registry |

- [ ] Inventory current vs latest versions for all referenced modules
- [ ] Bump all scenarios to latest versions
- [ ] Validate all scenarios still build
- [ ] Validate deployment + teardown after version bumps

---

## P4 — Documentation & Consistency

### README gaps

| Scenario | Status | Action |
|---|---|---|
| 3 | **Empty** (0 lines) | Write README: Function App + Event Hub + Logic App + Storage |
| 2 | Minimal (22 lines) | Expand with architecture description |
| 12 | Minimal (21 lines) | Expand with pattern module explanation |
| Top-level `doc/` | Stale (lists only 4 components) | Update to reflect all 11 scenarios |

- [ ] Write scenario 3 README
- [ ] Review and update all scenario READMEs to consistent format
- [ ] Update top-level README with current scenario inventory
- [ ] Update `doc/README.md` or remove if redundant

### Scenario relevance review

| Scenario | Architecture | Still relevant? |
|---|---|---|
| 1 | Function App + KV + SQL | Yes — basic pattern, validates core modules |
| 2 | Function App + KV + Cosmos DB | Yes — validates NoSQL pattern |
| 3 | Function App + Event Hub + Logic App + Storage | Yes — validates event-driven pattern |
| 4 | Dual Function Apps + Event Hub broker | Review — overlaps with scenario 3 |
| 5 | Application Gateway + Web Apps + Function App | Yes — validates WAF/ingress pattern |
| 6 | **Missing** | Determine: was it removed intentionally or lost? |
| 7 | Docker App Service + ACR + Logic App | Yes — validates container pattern |
| 8 | Dual Function Apps + Cosmos DB + APIM | Review — overlaps with scenario 2; APIM adds value |
| 9 | AKS + ACR + App Gateway + Cosmos DB | Yes — validates Kubernetes pattern |
| 10 | Data Factory + Data Lake + Databricks | Yes — validates data platform pattern |
| 11 | Web App (UI) + Web App (API) + SQL | Review — similar to scenario 1 but multi-tier |
| 12 | N-Tier SQL pattern module | Yes — validates pattern-level abstraction |

- [ ] Decide on scenario 4 vs 3 overlap (keep both or merge?)
- [ ] Decide on scenario 8 vs 2 overlap (APIM justifies keeping?)
- [ ] Decide on scenario 11 vs 1 overlap (multi-tier justifies keeping?)
- [ ] Investigate missing scenario 6

---

## P5 — Pipeline & Operational

### Pipeline consistency

- [ ] Verify all scenarios have both DEV and TST pipeline variants
- [ ] Verify scheduled triggers are still correct (1st/15th of month)
- [ ] Verify environment Snow IDs are current
- [ ] Verify CIDR allocations don't conflict

### Local modules cleanup

After P0 migrations, the `modules/infra/` folder will have unused modules. Clean up:

- [ ] Remove `modules/infra/storage/cosmos-db/` after scenarios 2, 8 migrated
- [ ] Remove `modules/infra/integration/event-hub/` after scenario 4 migrated
- [ ] Remove `modules/infra/integration/data-factory/` after scenario 10 migrated
- [ ] Remove `modules/infra/network/private-endpoint/` after all PE refs migrated
- [ ] Keep `modules/infra/naming.bicep` (naming convention, no AMAVM equivalent)
- [ ] Keep scenario-specific helpers (e.g., `copyStorageKeysToKeyvault.bicep`)
- [ ] Audit remaining `modules/infra/` for anything else that can be removed
