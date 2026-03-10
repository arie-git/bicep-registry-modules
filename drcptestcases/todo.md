# DRCP Test Cases — Task Tracker

## Purpose

These test cases validate that AMAVM Bicep modules deploy correctly to the hardened DRCP platform. Each scenario combines multiple modules into a realistic architecture, deploys via scheduled pipeline, and tears down afterwards to save costs. They serve as integration tests — catching issues that per-module e2e tests miss (cross-module wiring, private endpoint connectivity, identity/RBAC chains, naming conventions).

---

## Scenario Status Overview

| Scenario | Architecture | AMAVM Status | Active local refs | AMAVM refs |
|---|---|---|---|---|
| 1 | Function App + KV + SQL | **Fully AMAVM** | 1 (`naming.bicep`) | 12 |
| 2 | Function App + KV + Cosmos DB | **Fully AMAVM** | 1 (`naming.bicep`) | 12 |
| 3 | Function App + Logic App + Storage | **Fully AMAVM** | 1 (`naming.bicep`) | 12 |
| 4 | Function App + Event Hub | **Fully AMAVM** | 1 (`naming.bicep`) + `roleAssignment.bicep` | 14 |
| 5 | App Gateway + Web Apps + Function App | **Nearly AMAVM** | 1 (`naming.bicep`) + 1 (public-ip-address) | 15 |
| 7 | Docker App Service + ACR + Logic App | **Nearly AMAVM** | 1 (`naming.bicep`) + 2 (ACR task + RBAC) | 13 |
| 8 | Function Apps + Cosmos DB + APIM | **Partial** | 12 active local refs (worst offender) | 12 |
| 9 | AKS + ACR + Storage | **Fully AMAVM** | 1 (`naming.bicep`) | 16 |
| 10 | Data Factory + Databricks | **Partial** | main.bicep: 6 local + central.bicep: 11 local (0 AMAVM) | main: 11 |
| 11 | Web Apps + SQL | **Fully AMAVM** | 1 (`naming.bicep`) | 15 |
| 12 | N-Tier SQL (pattern module) | **Complete** | 0 (only scenario with zero local refs) | 2 |
| **13** | **Redis Cache + Web App** | **Planned** | — | — |
| **14** | **Event Hub Producer/Consumer** | **Planned** | — | — |
| **15** | **Cosmos DB NoSQL CRUD API** | **Planned** | — | — |
| **16** | **AI Chatbot: OpenAI + AI Search** | **Planned** (from chatbot-poc) | — | — |

**Note:** Scenario 6 does not exist (removed or never created). Local ref counts exclude commented-out references. `naming.bicep` is a utility module that will remain local (not an AMAVM candidate). Scenarios 13-16 are new test cases for GAP/uncovered modules.

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

### Scenario 10 — Data Factory + Databricks migration (17 local refs across 2 files)

**Architecture note:** Scenario 10 has a two-tier Bicep structure:
- `main.bicep` — 6 active local refs + 11 AMAVM refs
- `central.bicep` — 11 active local refs + **0 AMAVM refs** (100% local, worst file in all scenarios)

**Migration plan (main.bicep — 6 local refs):**
1. Replace `data-factory/main.bicep` → `br/amavm:res/data-factory/factory`
2. Pass `integrationRuntimes` and `linkedServices` as params (AMAVM has child modules)
3. Remove `private-endpoint/main.bicep` — use `privateEndpoints` param
4. Remove `role-assignment.bicep` — use `roleAssignments` param

| Local module (main.bicep) | AMAVM replacement | Approach |
|---|---|---|
| `integration/data-factory/main.bicep` | `br/amavm:res/data-factory/factory` | Replace |
| `integration/data-factory/integrationRuntime.bicep` | `integrationRuntimes` param | Inline |
| `integration/data-factory/modules/role-assignment.bicep` | `roleAssignments` param | Inline |
| `network/private-endpoint/main.bicep` | `privateEndpoints` param | Inline |

**Migration plan (central.bicep — 11 local refs, 0 AMAVM):**
- [ ] Audit `central.bicep` — identify which local modules have AMAVM equivalents
- [ ] Migrate applicable modules (likely: VNet, NSG, storage, KV, managed identity, private endpoints)
- [ ] Use `/azure:azure-rbac` to verify role assignments in central infrastructure

- [ ] Migrate Data Factory in main.bicep to AMAVM `data-factory/factory`
- [ ] Migrate central.bicep local modules to AMAVM where equivalents exist
- [ ] Validate `bicep build` passes (requires ACR access or local PE path swap via `swapPeReferences.ps1`)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check after build passes
- [ ] Update README

### Scenario 8 — Cosmos DB + APIM + helpers (12 active local refs → 2 blocked)

Same Cosmos DB pattern as scenario 2, plus role-assignments, function.bicep, storage, and private endpoints. APIM and Public IP remain local (no AMAVM equivalent). This is the worst single-file scenario for local ref count.

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

## P1.5 — New Test Scenarios for GAP Modules

Three new scenarios to provide dedicated integration test coverage for the newly built GAP modules. Each follows the established DRCP pattern: VNet + subnets, NSG + route table, private endpoints, managed identity, Log Analytics + App Insights, Key Vault, and diagnostic settings on all resources.

**Reference:** Microsoft Learn quickstarts and existing scenario patterns (scenarios 1, 2, 4, 9).

### Scenario 13 — Redis Cache + Web App (cache/redis)

**Priority: HIGH** — `cache/redis` is the only GAP module with **zero integration test coverage**.

**Architecture:** A Web App uses Azure Cache for Redis (Premium SKU) as a distributed cache/session store. The app connects via private endpoint using Entra ID authentication (no access keys). Validates the AMAVM `cache/redis` module's private endpoint wiring, RBAC, and DRCP-compliant defaults.

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Redis Cache | `br/amavm:res/cache/redis` | Premium P1, PE, Entra auth, TLS 1.2 |
| Web App | `br/amavm:res/web/site` | Consumes Redis via managed identity |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux, S1 |
| Key Vault | `br/amavm:res/key-vault/vault` | Stores Redis hostname (not keys — Entra auth) |
| Storage Account | `br/amavm:res/storage/storage-account` | Web App backing storage |
| Managed Identity | `br/amavm:res/managed-identity/user-assigned-identity` | UAMI for Redis RBAC |
| VNet + Subnets | `br/amavm:res/network/virtual-network/subnet` | PE subnet + app egress subnet |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |
| App Insights | `br/amavm:res/insights/component` | APM telemetry |

**DRCP-specific config:**
- `sku: 'Premium'` with `capacity: 1` (Premium required for private endpoints)
- `publicNetworkAccess: 'Disabled'`
- `minimumTlsVersion: '1.2'`
- `disableAccessKeyAuthentication: true` (Entra-only auth, per drcp-redis-08)
- `enableNonSslPort: false`
- `privateEndpoints: [{ service: 'redisCache', subnetResourceId: peSubnet }]`
- `roleAssignments: [{ principalId: webApp.MI, roleDefinitionIdOrName: 'Redis Cache Contributor' }]`
- `diagnosticSettings: [{ workspaceResourceId: logAnalytics }]`
- `zones: ['1', '2', '3']` (zone redundancy per drcp-redis-05)

**Tasks:**
- [ ] Create `drcptestcases/scenario13/infra/main.bicep` following scenario 1 pattern
- [ ] Use `/azure:azure-rbac` to confirm least-privilege role for Redis data access
- [ ] Wire private endpoint, managed identity auth, diagnostic settings
- [ ] Create `drcptestcases/scenario13/README.md` using standard template
- [ ] Create `drcptestcases/scenario13/pipelines/` with deploy + teardown
- [ ] Validate `bicep build` passes
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check

### Scenario 14 — Event Hub Producer/Consumer (event-hub/namespace)

**Existing coverage:** Scenario 4 already exercises `event-hub/namespace`, but was migrated from local modules. This dedicated scenario provides a clean AMAVM-native test with a simpler architecture focused on validating the module's inline `eventhubs`, `consumerGroups`, and `roleAssignments` params.

**Architecture:** A Function App sends events to an Event Hub (HTTP trigger → producer) and a second Function App reads events (Event Hub trigger → consumer → writes to Storage blob). Both connect via managed identity using the `__fullyQualifiedNamespace` pattern (no SAS keys). Validates namespace-level private endpoint, `disableLocalAuth`, and consumer group wiring.

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Event Hub Namespace | `br/amavm:res/event-hub/namespace` | Standard SKU, PE, inline eventhub + consumer group |
| Function App (producer) | `br/amavm:res/web/site` | HTTP-triggered, sends events |
| Function App (consumer) | `br/amavm:res/web/site` | Event Hub-triggered, writes to blob |
| App Service Plan | `br/amavm:res/web/serverfarm` | Shared plan, Linux |
| Storage Account | `br/amavm:res/storage/storage-account` | Function backing + blob output |
| Key Vault | `br/amavm:res/key-vault/vault` | App config secrets |
| VNet + Subnets | `br/amavm:res/network/virtual-network/subnet` | PE + app egress |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |
| App Insights | `br/amavm:res/insights/component` | APM telemetry |

**DRCP-specific config:**
- `disableLocalAuth: true` (Entra-only, per drcp-evh-05)
- `publicNetworkAccess: 'Disabled'` (per drcp-evh-01)
- `minimumTlsVersion: '1.2'` (per drcp-evh-04)
- `privateEndpoints: [{ service: 'namespace', subnetResourceId: peSubnet }]`
- `eventhubs: [{ name: 'events', messageRetentionInDays: 1, partitionCount: 2, consumerGroups: [{ name: 'consumer-func' }] }]`
- `roleAssignments:` producer MI gets `Azure Event Hubs Data Sender`, consumer MI gets `Azure Event Hubs Data Receiver`
- Function App settings: `EventHubConnection__fullyQualifiedNamespace: '<ns>.servicebus.windows.net'` (identity-based, no connection string)
- `diagnosticSettings: [{ workspaceResourceId: logAnalytics }]`

**Tasks:**
- [ ] Create `drcptestcases/scenario14/infra/main.bicep` following scenario 1 pattern
- [ ] Use `/azure:azure-rbac` to confirm Data Sender / Data Receiver roles
- [ ] Wire inline eventhubs, consumer groups, private endpoint, RBAC
- [ ] Create `drcptestcases/scenario14/README.md` using standard template
- [ ] Create `drcptestcases/scenario14/pipelines/` with deploy + teardown
- [ ] Validate `bicep build` passes
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check

### Scenario 15 — Cosmos DB NoSQL CRUD API (document-db/database-account)

**Existing coverage:** Scenario 2 already exercises `document-db/database-account`, but was migrated from local modules with legacy patterns. This dedicated scenario provides a clean AMAVM-native test focused on validating `sqlDatabases` inline param with nested containers, SQL role definitions/assignments, and `disableLocalAuth`.

**Architecture:** A Function App exposes HTTP CRUD endpoints backed by a Cosmos DB NoSQL database. The app uses the Cosmos DB SDK with Entra ID authentication via the Function App's system-assigned MI. Cosmos DB SQL role assignments grant data-plane access (not Azure RBAC — Cosmos uses its own role model). Validates the module's `sqlDatabases`, `sqlRoleDefinitions`, and `sqlRoleAssignments` child modules.

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Cosmos DB Account | `br/amavm:res/document-db/database-account` | NoSQL, PE, inline DB + containers |
| Function App | `br/amavm:res/web/site` | HTTP CRUD API |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux, S1 |
| Storage Account | `br/amavm:res/storage/storage-account` | Function backing storage |
| Key Vault | `br/amavm:res/key-vault/vault` | Cosmos DB endpoint URI |
| VNet + Subnets | `br/amavm:res/network/virtual-network/subnet` | PE + app egress |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |
| App Insights | `br/amavm:res/insights/component` | APM telemetry |

**DRCP-specific config:**
- `disableLocalAuth: true` (Entra-only, per drcp-cosmos-01)
- `disableKeyBasedMetadataWriteAccess: true` (per drcp-cosmos-02)
- `publicNetworkAccess: 'Disabled'` (per drcp-cosmos-03)
- `networkRestrictions.publicNetworkAccess: 'Disabled'`
- `privateEndpoints: [{ service: 'Sql', subnetResourceId: peSubnet }]`
- `sqlDatabases: [{ name: 'tododb', containers: [{ name: 'items', paths: ['/id'] }] }]`
- `sqlRoleAssignments: [{ principalId: funcApp.MI, roleDefinitionId: '00000000-0000-0000-0000-000000000002' }]` (Cosmos DB Built-in Data Contributor)
- `backupStorageRedundancy: 'Local'` (dev/test cost savings)
- `diagnosticSettings: [{ workspaceResourceId: logAnalytics }]`
- Function App settings: `CosmosDbEndpoint: cosmosDb.outputs.endpoint` (identity-based, no keys)

**Tasks:**
- [ ] Create `drcptestcases/scenario15/infra/main.bicep` following scenario 1 pattern
- [ ] Use `/azure:azure-rbac` to confirm Cosmos DB SQL role definitions for data-plane access
- [ ] Wire inline sqlDatabases, sqlRoleAssignments, private endpoint
- [ ] Create `drcptestcases/scenario15/README.md` using standard template
- [ ] Create `drcptestcases/scenario15/pipelines/` with deploy + teardown
- [ ] Validate `bicep build` passes
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check

### Scenario 16 — AI Chatbot: OpenAI + AI Search + Web Apps (cognitive-services/account + search/search-service)

**Source:** `chatbot-poc/` — existing POC that is already partially AMAVM-migrated. This scenario exercises the two whitelisted modules with **zero integration test coverage**: `cognitive-services/account` (AI Services/OpenAI) and `search/search-service` (AI Search). Migrating the POC into a proper DRCP test case validates these modules in a realistic RAG (Retrieval-Augmented Generation) architecture.

**Architecture:** A Streamlit frontend Web App authenticates users via Entra ID (Easy Auth + FIC), queries Azure Resource Graph for DRCP policy violations, searches an AI Search knowledge base for remediation guidance, and uses Azure OpenAI (GPT-4o) to generate context-aware remediation advice. A Flask backend API handles OBO (On-Behalf-Of) token exchange for cross-service calls. Both apps run on Linux App Service Plans with private endpoints and UAMI-based auth.

**Reference:** `chatbot-poc/infra/main.bicep` (existing, already uses AMAVM module references).

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Azure OpenAI | `br/amavm:res/cognitive-services/account` | GPT-4o deployment, kind: OpenAI, S0 SKU |
| AI Search | `br/amavm:res/search/search-service` | Knowledge base index, shared private links to storage + OpenAI |
| Web App (frontend) | `br/amavm:res/web/site` | Streamlit UI, Entra ID Easy Auth, UAMI |
| Web App (backend) | `br/amavm:res/web/site` | Flask API, OBO token exchange, UAMI |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Linux, P1V3 (separate for front/back) |
| Storage Account | `br/amavm:res/storage/storage-account` | Blob + Table, AI Search data source |
| Managed Identity (x2) | `br/amavm:res/managed-identity/user-assigned-identity` | Front UAMI + Back UAMI |
| VNet + Subnets (x3) | `br/amavm:res/network/virtual-network/subnet` | PE subnet + 2 app egress subnets |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |
| App Insights | `br/amavm:res/insights/component` | APM telemetry |
| App Registration (x2) | `modules/appregistration.bicep` (local, uses `microsoftGraphV1` extension) | Entra ID app registrations + FIC |
| Storage RBAC | `modules/rbac.bicep` (local) | Cross-service role assignments on storage |

**Key architectural patterns validated:**
- **RAG pattern:** AI Search → Storage (blob/table) → OpenAI (chat completions with context)
- **Entra ID Easy Auth + FIC:** Frontend uses federated identity credentials (`OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID`) — same pattern as FEAT-1b's auth settings
- **On-Behalf-Of flow:** Backend exchanges user token for ARM/service tokens via OBO credential
- **Shared Private Links:** AI Search connects to Storage and OpenAI via shared private links (requires manual approval in DRCP portal)
- **Microsoft Graph Bicep:** App registrations use `extension microsoftGraphV1` for declarative Entra ID app + service principal + FIC creation
- **Multi-UAMI:** Separate managed identities for frontend and backend with different role assignments

**DRCP-specific config (from chatbot-poc/infra/main.bicep):**
- OpenAI: `kind: 'OpenAI'`, `sku: 'S0'`, private endpoint, `Cognitive Services OpenAI User` role for UAMI
- AI Search: `dataExfiltrationProtections: ['BlockAll']`, private endpoint, shared private links for blob/table/openai
- Storage: `skuName: 'Standard_LRS'`, blob + table PEs, `Storage Blob Data Owner` + `Storage Table Data Contributor` roles
- Web Apps: Linux Python 3.12, VNet integration, private endpoints, Easy Auth with Entra ID, `vnetRouteAllEnabled: true`
- All resources: diagnostic settings → Log Analytics

**Local modules that remain (cannot migrate to AMAVM):**
- `modules/appregistration.bicep` — uses `microsoftGraphV1` Bicep extension for Entra ID app registrations; no AMAVM equivalent
- `modules/rbac.bicep` — multi-principal storage role assignments; could be replaced with inline `roleAssignments` on storage module

**Migration from chatbot-poc to drcptestcases/scenario16:**
1. Copy `chatbot-poc/infra/main.bicep` → `drcptestcases/scenario16/infra/main.bicep`
2. Copy `chatbot-poc/infra/modules/` → `drcptestcases/scenario16/infra/modules/`
3. Replace `br/amavm:utl/amavm/naming:0.1.0` → `../../modules/infra/naming.bicep` (match scenario convention)
4. Replace `modules/rbac.bicep` calls → inline `roleAssignments` on storage module where possible
5. Fix deprecated params: `vnetRouteAllEnabled`, `vnetContentShareEnabled`, `vnetImagePullEnabled` → `outboundVnetRouting` (per TD-15/FEAT-1)
6. Remove hardcoded subscription IDs, object IDs, and resource names from readme
7. Add `bicepconfig.json`, pipelines, README

**Tasks:**
- [ ] Copy chatbot-poc infra to `drcptestcases/scenario16/infra/`
- [ ] Replace naming module reference with local `../../modules/infra/naming.bicep`
- [ ] Replace `rbac.bicep` with inline `roleAssignments` where possible — use `/azure:azure-rbac` to verify roles
- [ ] Fix deprecated VNet routing params → `outboundVnetRouting`
- [ ] Parameterize hardcoded values (engineer object IDs, subscription IDs)
- [ ] Use `/azure:entra-app-registration` to validate the app registration pattern
- [ ] Create `drcptestcases/scenario16/pipelines/` with deploy + teardown
- [ ] Create `drcptestcases/scenario16/README.md` using standard template
- [ ] Validate `bicep build` passes (note: `microsoftGraphV1` extension may require special bicepconfig)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] Use `/azure:azure-ai` for AI Search and OpenAI configuration best practices
- [ ] Document shared private link approval process in README (DRCP portal + manual curl approval)

---

## P2 — AMAVM Module Coverage

After P0 migrations and P1.5 new scenarios, these modules have integration test coverage:

| Module | Covered by |
|---|---|
| `cognitive-services/account` | **Scenario 16** |
| `search/search-service` | **Scenario 16** |
| `document-db/database-account` | Scenarios 2, 8, **15** |
| `event-hub/namespace` | Scenarios 4, **14** |
| `cache/redis` | **Scenario 13** |
| `data-factory/factory` | Scenario 10 |
| `network/private-endpoint` | Scenarios 2, 4, 8, 10, **13, 14, 15, 16** |
| `web/site` | Scenarios 1, 2, 3, 4, 5, 8, 11, **13, 14, 15, 16** |
| `key-vault/vault` | Scenarios 1, 2, 3, 4, 5, 8, 11, **13, 14, 15** |
| `storage/storage-account` | Scenarios 1, 2, 3, 4, 9, **13, 14, 15, 16** |

Still uncovered (no test case): `app-configuration/configuration-store`, `service-bus/namespace`, `db-for-postgre-sql/flexible-server`

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
