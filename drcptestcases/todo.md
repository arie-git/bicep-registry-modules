# DRCP Test Cases — Task Tracker

## Purpose

These test cases validate that AMAVM Bicep modules deploy correctly to the hardened DRCP platform. Each scenario combines multiple modules into a realistic architecture, deploys via scheduled pipeline, and tears down afterwards to save costs. They serve as integration tests — catching issues that per-module e2e tests miss (cross-module wiring, private endpoint connectivity, identity/RBAC chains, naming conventions).

---

## Scenario Status Overview

| Scenario | Architecture | AMAVM Status | Local refs remaining |
|---|---|---|---|
| 1 | Function App + KV + SQL | **Fully AMAVM** | `naming.bicep` only |
| 2 | Function App + KV + Cosmos DB | **Fully AMAVM** | `naming.bicep` only (migrated) |
| 3 | Function App + Logic App + Storage | **Fully AMAVM** | `naming.bicep` + scenario helper |
| 4 | Function App + Event Hub | **Fully AMAVM** | `naming.bicep` + `roleAssignment.bicep` (circular dep helper) |
| 5 | App Gateway + Web Apps + Function App | **Nearly AMAVM** | 1 local (Public IP) |
| 7 | Docker App Service + ACR + Logic App | **Nearly AMAVM** | 2 local (ACR task + RBAC) |
| 8 | Function Apps + Cosmos DB + APIM | **Partial** | 9 local (worst offender) |
| 9 | AKS + ACR + Storage | **Fully AMAVM** | `naming.bicep` only |
| 10 | Data Factory + Databricks | **Partial** | 4 local (ADF + PE + RBAC) |
| 11 | Web Apps + SQL | **Fully AMAVM** | `naming.bicep` only |
| 12 | N-Tier SQL (pattern module) | **Fully AMAVM** | `naming.bicep` only |

**Note:** Scenario 6 does not exist (removed or never created).

---

## P0 — AMAVM Module Migration (HIGH PRIORITY)

Replace local `../../modules/infra/` references with AMAVM registry modules. This eliminates maintaining duplicate implementations and validates AMAVM modules in real integration scenarios.

### Parameter Change Awareness

AMAVM modules have been through significant upstream syncs. Key differences from local modules:

| Pattern | Local module | AMAVM module |
|---|---|---|
| Private Endpoint | Separate PE module call with `privateLinkResource`, `subnet`, `targetSubResource` | Inline `privateEndpoints` array param on parent module |
| Role Assignments | Separate `role-assignment.bicep` module call | Inline `roleAssignments` array param on parent module |
| Cosmos DB secrets | `secureKeys.bicep` → stores keys in KV | Not needed — `disableLocalAuth: true` means no keys (use RBAC) |
| Diagnostics | Inline `diagnosticSettings` resource | Inline `diagnosticSettings` param on parent module |
| Cosmos DB databases | Separate `sqldatabase.bicep` + `container.bicep` calls | Inline `sqlDatabases` param with nested `containers` |

### Scenario 2 — Cosmos DB migration (5 local refs → 0)

**Migration plan:**
1. Replace `cosmos-db/main.bicep` → `br/amavm:res/document-db/database-account` with `sqlDatabases` param (inline DB + containers)
2. Remove `secureKeys.bicep` call — AMAVM Cosmos uses `disableLocalAuth: true`, no keys to store
3. Remove separate `sqldatabase.bicep` and `container.bicep` calls — folded into `sqlDatabases` param
4. Remove `private-endpoint/main.bicep` call — use AMAVM module's `privateEndpoints` param
5. Add `diagnosticSettings` param to Cosmos module (replaces inline diagnostic resource)

| Local module | AMAVM replacement | Approach |
|---|---|---|
| `storage/cosmos-db/main.bicep` | `br/amavm:res/document-db/database-account` | Replace with inline params |
| `storage/cosmos-db/secureKeys.bicep` | **Remove** | No keys with `disableLocalAuth: true` |
| `storage/cosmos-db/apis/sql/sqldatabase.bicep` | `sqlDatabases` param on database-account | Inline as param |
| `storage/cosmos-db/apis/sql/container.bicep` | `containers` in `sqlDatabases` param | Inline as param |
| `network/private-endpoint/main.bicep` | `privateEndpoints` param on database-account | Inline as param |

- [x] Migrate Cosmos DB to AMAVM `document-db/database-account`
- [ ] Validate `bicep build` passes (requires ACR access or local PE path swap via `swapPeReferences.ps1`)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check after build passes
- [x] Update README

### Scenario 4 — Event Hub migration (6 local refs → 0)

**Migration plan:**
1. Replace `event-hub/namespace.bicep` → `br/amavm:res/event-hub/namespace` with `eventhubs` param (inline hubs + consumer groups)
2. Remove separate `event-hub/main.bicep` and `consumer-group.bicep` calls — folded into `eventhubs` param
3. Remove `private-endpoint/main.bicep` — use AMAVM module's `privateEndpoints` param
4. Remove `role-assignment.bicep` calls — use AMAVM module's `roleAssignments` param

| Local module | AMAVM replacement | Approach |
|---|---|---|
| `integration/event-hub/namespace.bicep` | `br/amavm:res/event-hub/namespace` | Replace |
| `integration/event-hub/main.bicep` | `eventhubs` param on namespace | Inline |
| `integration/event-hub/consumer-group.bicep` | `consumerGroups` in eventhubs | Inline |
| `network/private-endpoint/main.bicep` | `privateEndpoints` param | Inline |
| `integration/event-hub/modules/role-assignment.bicep` | `roleAssignments` param | Inline |
| `storage/storage-account/modules/role-assignment.bicep` | `roleAssignments` param on storage-account | Inline |

- [x] Migrate Event Hub to AMAVM `event-hub/namespace`
- [x] Replace role-assignment helpers with inline `roleAssignments` (Event Hub + Storage; 1 kept as helper for circular dep)
- [ ] Validate `bicep build` passes (requires ACR access or local PE path swap via `swapPeReferences.ps1`)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check after build passes
- [x] Update README

### Scenario 10 — Data Factory migration (4 local refs → 0)

**Migration plan:**
1. Replace `data-factory/main.bicep` → `br/amavm:res/data-factory/factory`
2. Pass `integrationRuntimes` and `linkedServices` as params (AMAVM has child modules)
3. Remove `private-endpoint/main.bicep` — use `privateEndpoints` param
4. Remove `role-assignment.bicep` — use `roleAssignments` param

| Local module | AMAVM replacement | Approach |
|---|---|---|
| `integration/data-factory/main.bicep` | `br/amavm:res/data-factory/factory` | Replace |
| `integration/data-factory/integrationRuntime.bicep` | `integrationRuntimes` param | Inline |
| `integration/data-factory/modules/role-assignment.bicep` | `roleAssignments` param | Inline |
| `network/private-endpoint/main.bicep` | `privateEndpoints` param | Inline |

- [ ] Migrate Data Factory to AMAVM `data-factory/factory`
- [ ] Validate `bicep build` passes (requires ACR access or local PE path swap via `swapPeReferences.ps1`)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check after build passes
- [ ] Update README

### Scenario 8 — Cosmos DB + helpers (9 local refs → 2 blocked)

Same Cosmos DB pattern as scenario 2, plus role-assignments and function.bicep. APIM and Public IP remain local (no AMAVM equivalent).

- [ ] Migrate Cosmos DB to AMAVM (same pattern as scenario 2)
- [ ] Replace PE and role-assignment helpers with inline params — use `/azure:azure-rbac` to verify role definitions
- [ ] Evaluate `function.bicep` — app-code deploy helper, keep local
- [ ] APIM stays local (not a DRCP-whitelisted component)
- [ ] Public IP stays local (no AMAVM equivalent yet — blocked on GAP-5 in tasks/todo.md)
- [ ] Validate `bicep build` passes
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] Update README

### Scenario 7 — ACR helpers (2 local refs → 1)

- [ ] Replace ACR `role-assignment.bicep` with AMAVM `roleAssignments` param
- [ ] Keep `task.bicep` local (ACR Tasks not in AMAVM)
- [ ] Validate `bicep build` passes

### Scenario 5 — Public IP (1 local ref — blocked)

- [ ] Blocked until AMAVM `network/public-ip-address` module is created (GAP-5 in tasks/todo.md)

---

## P1 — README Standardization

All scenario READMEs need a consistent format. Current state is inconsistent — some have wrong titles (scenario 4 says "Scenario 1", scenario 11 says "Scenario 1"), scenario 3 is empty, some lack component lists.

### Standard README Template

```markdown
# Scenario N — <Short Title>

<1-2 sentence description of the architecture pattern being validated.>

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| ... | `br/amavm:res/...` | ... |

## Architecture

<Brief description of how components connect: data flow, network topology, identity chain.>

## Deployment

### Prerequisites
- Azure subscription with DRCP guardrails
- VNet with available address space (`/27` minimum)
- ServiceNow environment ID

### Deploy
```
az deployment sub create --location swedencentral \
  -f scenarioN/infra/main.bicep \
  --name=<deployment-name> \
  --parameters environmentId=<ENV_ID>
```

### Remove
```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter <deployment-name>
```
```

### README Status

| Scenario | Current | Issues | Action |
|---|---|---|---|
| 1 | 30 lines | OK structure | Minor: add components table |
| 2 | Updated | Rewritten with Cosmos migration | Done |
| 3 | Updated | Was empty, now written | Done |
| 4 | Updated | Title fixed, components added | Done |
| 5 | 54 lines | Good quality | Minor formatting |
| 7 | 63 lines | Good quality | Minor: add components table |
| 8 | 61 lines | Good quality | Update after APIM removal |
| 9 | 78 lines | Good quality | Minor formatting |
| 10 | 83 lines | Good quality, typos | Fix typos |
| 11 | Updated | Title fixed | Done |
| 12 | 21 lines | Minimal | Expand with pattern explanation |

- [x] Fix wrong titles (scenarios 4, 11)
- [x] Write scenario 3 README
- [ ] Standardize all READMEs to template format (after P0 migrations)
- [ ] Update top-level README with scenario inventory
- [ ] Use `/azure:azure-resource-visualizer` to generate architecture diagrams for each scenario README (requires deployed resource group)

---

## P2 — AMAVM Module Coverage

After P0 migrations complete, these modules gain integration test coverage:

| Module | Covered by |
|---|---|
| `document-db/database-account` | Scenarios 2, 8 |
| `event-hub/namespace` | Scenario 4 |
| `data-factory/factory` | Scenario 10 |
| `network/private-endpoint` | Scenarios 2, 4, 8, 10 |

Still uncovered (no test case): `cache/redis`, `search/search-service`, `cognitive-services/account`, `app-configuration/configuration-store`, `service-bus/namespace`, `db-for-postgre-sql/flexible-server`

**Interim validation for uncovered modules:**
- Use `/azure:azure-validate` to run pre-deployment checks on module Bicep without a full test scenario
- Use `/azure:azure-compliance` to audit deployed instances against DRCP policies
- Use `/azure:azure-diagnostics` to troubleshoot deployment failures when creating new test scenarios

---

## P3 — Version Bumps

All scenarios use AMAVM module versions 0.1.0–0.3.0. After P0 migrations, bump to latest published versions.

- [ ] Inventory current vs latest versions
- [ ] Bump all scenarios
- [ ] Validate builds — use `bicep build` then `/azure:azure-validate` for deployment readiness

---

## P4 — Cleanup

After P0 migrations complete:

- [ ] Remove `modules/infra/storage/cosmos-db/` (after scenarios 2, 8 migrated)
- [ ] Remove `modules/infra/integration/event-hub/` (after scenario 4 migrated)
- [ ] Remove `modules/infra/integration/data-factory/` (after scenario 10 migrated)
- [ ] Remove `modules/infra/network/private-endpoint/` (after all PE refs migrated)
- [ ] Audit remaining `modules/infra/` for other removable modules
- [ ] Keep: `naming.bicep`, scenario-specific helpers, deployment scripts, `public-ip-address`, `api-management`
