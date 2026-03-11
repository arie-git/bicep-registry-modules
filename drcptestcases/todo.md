# DRCP Test Cases — Task Tracker

## Purpose

These test cases validate that AMAVM Bicep modules deploy correctly to the hardened DRCP platform. Each scenario combines multiple modules into a realistic architecture, deploys via scheduled pipeline, and tears down afterwards to save costs. They serve as integration tests — catching issues that per-module e2e tests miss (cross-module wiring, private endpoint connectivity, identity/RBAC chains, naming conventions).

---

## Scenario Status Overview

| Scenario | Architecture | AMAVM Status | Active local refs | AMAVM refs |
|---|---|---|---|---|
| 1 | Function App + KV + SQL | **Fully AMAVM** | 0 | 13 |
| 2 | Function App + KV + Cosmos DB | **Fully AMAVM** | 0 | 13 |
| 3 | Function App + Logic App + Storage | **Fully AMAVM** | 0 | 13 |
| 4 | Function App + Event Hub | **Fully AMAVM** | `roleAssignment.bicep` (x3) | 15 |
| 5 | App Gateway + Web Apps + Function App | **Nearly AMAVM** | 1 (public-ip-address) | 16 |
| 7 | Docker App Service + ACR | **Nearly AMAVM** | 1 (ACR task) + 1 (`acrRoleAssignment.bicep`) | 11 |
| 8 | **PostgreSQL + Service Bus** (repurposed) | **Fully AMAVM** | 0 | 12 |
| 9 | AKS + ACR + Storage | **Fully AMAVM** | 0 | 17 |
| 10 | Data Factory + Databricks | **Nearly AMAVM** | main.bicep: 2 local (IR, role-assignment) + central.bicep: 2 local (rbac, shir-auth) | main: 13, central: 7 |
| 11 | Web Apps + SQL | **Fully AMAVM** | 0 | 16 |
| 12 | N-Tier SQL (pattern module) | **Complete** | 0 | 2 |
| **13** | **Redis Cache (standalone)** | **Fully AMAVM** | 0 | 6 |
| **14** | **Event Hub + App Config + Function App** | **Fully AMAVM** | 0 | 13 |
| **15** | **Cosmos DB NoSQL (standalone)** | **Fully AMAVM** | 0 | 6 |
| **16** | **AI Chatbot: OpenAI + AI Search** | **Planned** (from chatbot-poc) | 2 (appregistration, rbac) | ~15 |
| **17** | **Static Web App + Function API** | **Fully AMAVM** | 0 | 11 |

**Note:** Scenario 6 does not exist (removed or never created). All scenarios now use `br/amavm:utl/amavm/naming:0.1.0` (naming migration complete). Scenarios 13-15 implemented, scenario 16 migrated from chatbot-poc (needs cleanup). Scenario 8 repurposed from APIM to PostgreSQL + Service Bus. Scenario 17 implemented (Static Web App + Function API).

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
- [x] Validate `bicep build` passes (via localBuildHelper.ps1, warnings only — all from upstream modules)
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
- [x] Replace role-assignment helpers with inline `roleAssignments` (Event Hub + Storage; separate helpers for cross-deps)
- [x] Fix circular dependency: extracted 3 cross-resource RBAC assignments into separate modules (`roleAssignment.bicep`, `evhRoleAssignment.bicep`, `kvRoleAssignment.bicep`)
- [x] Validate `bicep build` passes (via localBuildHelper.ps1, warnings only — all from upstream modules)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check after build passes
- [x] Update README

### Scenario 10 — Data Factory + Databricks + Unity Catalog (17 local refs across 2 files)

**Architecture note:** Scenario 10 has a two-tier Bicep structure:
- `main.bicep` — 6 active local refs + 11 AMAVM refs
- `central.bicep` — 11 active local refs + **0 AMAVM refs** (100% local, worst file in all scenarios)

**See `scenario10/todo.md` for detailed plan** — includes Unity Catalog example, full DRCP policy checklist (8 Databricks + 10 Data Factory policies), AMAVM migration plan, and medallion architecture pipeline updates.

- [x] Add Unity Catalog infra (ADLS Gen2 + Access Connector RBAC + managed RG name)
- [x] Migrate Data Factory in main.bicep to AMAVM `data-factory/factory` (inline PE, diagnostics, linked services, IR)
- [x] Add linked services (ls_keyvault, ls_adls, ls_blob, ls_adls_uc, ls_databricks) — MI auth, no hardcoded URLs
- [x] Support pure Bicep deployment (gitConfigureLater, adfRepoConfig optional)
- [x] Validate `bicep build` passes (warnings only, no errors)
- [x] Migrate central.bicep local modules to AMAVM (6 migrated, 3 eliminated via inlining, 3 kept local)
- [ ] Validate against all 18 DRCP policies (8 Databricks + 10 Data Factory)
- [x] Update README with UC architecture and policy compliance table

### Scenario 8 — **REPURPOSED:** PostgreSQL + Service Bus (message-driven processing)

**Decision:** APIM is NOT a whitelisted DRCP component and Cosmos DB is already covered by S2 + S15. Scenario 8 is repurposed to provide **new AMAVM module coverage** for `db-for-postgre-sql/flexible-server` and `service-bus/namespace`.

**Architecture:** Message-driven processing with relational persistence. A Function App receives messages from a Service Bus queue (trigger), processes them, and writes results to PostgreSQL. Both services use Managed Identity authentication exclusively.

```
Service Bus Namespace (Premium, zone-redundant)
  └── Queue: "orders" (dead-letter enabled)
  └── Topic: "events" + Subscription: "processor"
Function App (Service Bus trigger → PostgreSQL writer)
PostgreSQL Flexible Server (v17, Entra-only, VNet-integrated)
Key Vault (connection config)
Log Analytics + Diagnostics
```

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Service Bus Namespace | `br/amavm:res/service-bus/namespace:0.1.0` | Premium, PE, queue + topic, disableLocalAuth |
| PostgreSQL Flexible Server | `br/amavm:res/db-for-postgre-sql/flexible-server:0.1.0` | v17, Entra-only, VNet-delegated subnet |
| Function App | `br/amavm:res/web/site:0.1.0` | Service Bus trigger, writes to PostgreSQL |
| App Service Plan | `br/amavm:res/web/serverfarm:0.1.0` | Linux, S1 |
| Key Vault | `br/amavm:res/key-vault/vault:0.3.0` | PostgreSQL FQDN, Service Bus namespace |
| Storage Account | `br/amavm:res/storage/storage-account:0.2.0` | Function App backing storage |
| VNet + Subnets (x3) | `br/amavm:res/network/virtual-network/subnet:0.2.0` | PE, app egress, PostgreSQL delegated |
| NSG + Route Table | `br/amavm:res/network/network-security-group:0.1.0` + `route-table:0.1.0` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace:0.1.0` | Central logging |
| App Insights | `br/amavm:res/insights/component:0.1.0` | APM telemetry |

**DRCP policies (11 PostgreSQL + 5 Service Bus):**

| Policy | Property | Required Value |
|---|---|---|
| drcp-pgsql-auth | `authConfig.activeDirectoryAuth` | `'Enabled'` |
| drcp-pgsql-auth | `authConfig.passwordAuth` | `'Disabled'` |
| drcp-pgsql-network | `network.publicNetworkAccess` | `'Disabled'` |
| drcp-pgsql-network | `network.delegatedSubnetResourceId` | Must exist |
| drcp-pgsql-network | `network.privateDnsZoneArmResourceId` | Must exist |
| drcp-pgsql-tls | `configurations` (ssl_min_protocol_version) | `'TLSv1.2'` |
| drcp-pgsql-ssl | `configurations` (require_secure_transport) | `'ON'` |
| drcp-pgsql-version | `version` | `>= 16` |
| drcp-pgsql-ha | `highAvailability.mode` | `'ZoneRedundant'` |
| drcp-pgsql-encryption | `dataEncryption.type` | NOT `'AzureKeyVault'` (service-managed) |
| drcp-pgsql-defender | `serverThreatProtection` | `'Enabled'` |
| drcp-sb-auth | `disableLocalAuth` | `true` |
| drcp-sb-network | `publicNetworkAccess` | `'Disabled'` |
| drcp-sb-tls | `minimumTlsVersion` | `'1.2'` |
| drcp-sb-pe | PE must be same subscription | Enforced by policy |
| drcp-sb-dns | Private DNS zone | Auto-deployed by policy |

**AMAVM module defaults already enforce:** authConfig (Entra-only), publicNetworkAccess=Disabled, version=17, highAvailability=ZoneRedundant, serverThreatProtection=Enabled, disableLocalAuth=true, minimumTlsVersion=1.2

**RBAC roles:**
- Function App MI → `Azure Service Bus Data Receiver` (queue trigger)
- Function App MI → PostgreSQL Entra admin (via `administrators` param)

**Tasks:**
- [x] Delete existing scenario 8 content (APIM-based) — removed `modules/`, `parameters.json`
- [x] Create `drcptestcases/scenario8/infra/main.bicep` — PostgreSQL + Service Bus, all AMAVM
- [x] PostgreSQL: Entra-only auth, VNet-delegated subnet, private DNS zone, v17, zone redundant
- [x] Service Bus: Premium, PE, queue + topic, disableLocalAuth, inline roleAssignments
- [x] Function App: Service Bus trigger with `__fullyQualifiedNamespace` (identity-based), PostgreSQL Entra token
- [x] Validate against all 16 DRCP policies listed above
- [x] Validate `bicep build` passes — 0 errors, 0 warnings in S8 code (only AMAVM-internal warnings)
- [x] Update README with new architecture
- [ ] Create pipeline YAML
- [ ] Update `src/` directory for new architecture (old frontend/backend code references APIM)

### Scenario 7 — ACR + Docker Web App (simplify — remove Logic App)

**Change:** Remove Logic App from scenario 7. Logic App is already fully covered by S3. Scenario 7's unique value is ACR + Docker + ACR Build Task.

- [x] Replace ACR `role-assignment.bicep` with local helper (`acrRoleAssignment.bicep`) — cycle `acr ↔ webApp` prevents inline
- [x] Remove Logic App module, second App Service Plan, and Logic App subnet — simplify to ACR + Docker only
  - Removed: Logic App module, appServicePlan2, logicAppOut subnet, UAMI, copyStorageKeysToKeyvault helper, fileShare
  - Fixed: `allowSharedKeyAccess: false` (was `true` for Logic App), removed `UsedBy: 'LogicApp'` tag
  - Subnet count: 3 → 2 (PE + web egress)
- [x] Keep `task.bicep` local (ACR Tasks not in AMAVM)
- [x] Validate `bicep build` passes — 0 scenario7 errors, 43 warnings (all from upstream AMAVM modules)
- [x] Update README to reflect simplified architecture

### Cross-Scenario — Role Assignment Migration (GAP-6 in tasks/todo.md)

**Prerequisite:** Sync `authorization/role-assignment` from upstream AVM into AMAVM fork (see GAP-6).

5 scenarios use local role-assignment helpers for circular dependency breaking or cross-subscription RBAC. Once the AMAVM `authorization/role-assignment/rg-scope` module is available, replace them all.

| Scenario | Local module(s) | Pattern | Refs |
|---|---|---|---|
| 4 | `roleAssignment.bicep`, `evhRoleAssignment.bicep`, `kvRoleAssignment.bicep` | Circular dep: FuncApp↔Storage, FuncApp↔EVH, FuncApp↔KV | 4 |
| 7 | `acrRoleAssignment.bicep` | Circular dep: WebApp↔ACR | 1 |
| 10 central | `security/rbac/role-assignment.bicep` | ADO RBAC (multi-principal batch) | 1 |
| 10 main | `data-factory/modules/role-assignment.bicep` | Cross-subscription shared IR RBAC | 1 |
| 16 | `modules/rbac.bicep` | AI Search MI → Storage (multi-principal) | 2 |

**Migration approach:** AMAVM module takes single `principalId`, so batch patterns become caller-level `for` loops. Role GUIDs already used directly in most scenarios (no dependency on the 309-role name mapping).

- [ ] Blocked until GAP-6 AMAVM module is created
- [ ] Migrate scenario 4 (3 local helpers → AMAVM)
- [ ] Migrate scenario 7 (1 local helper → AMAVM)
- [ ] Migrate scenario 10 central + main (2 local helpers → AMAVM)
- [ ] Migrate scenario 16 (1 local helper → AMAVM or inline on storage)
- [ ] Remove replaced local modules
- [ ] Validate `bicep build` on all affected scenarios

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
| 1 | Updated | Components table + standard format | Done |
| 2 | Updated | Rewritten with Cosmos migration | Done |
| 3 | Updated | Was empty, now written | Done |
| 4 | Updated | Title fixed, components added | Done |
| 5 | Updated | Components table + standard format | Done |
| 7 | Updated | Components table + circular dep notes | Done |
| 8 | Updated | Components table + standard format | Done |
| 9 | Updated | Components table + standard format | Done |
| 10 | Updated | Components + UC + policy table | Done |
| 11 | Updated | Title fixed | Done |
| 12 | Updated | Pattern module + standard format | Done |

- [x] Fix wrong titles (scenarios 4, 11)
- [x] Write scenario 3 README
- [x] Standardize all READMEs to template format (scenarios 1, 5, 7, 9, 12)
- [x] Update top-level README with scenario inventory table
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
- [x] Create `drcptestcases/scenario13/infra/main.bicep` — Redis Premium, PE, Entra auth, zone redundant, diagnostics
- [x] Wire private endpoint, RBAC (Redis Cache Contributor for dev), diagnostic settings
- [x] Create `drcptestcases/scenario13/README.md` using standard template
- [ ] Use `/azure:azure-rbac` to confirm least-privilege role for Redis data access
- [x] Create `drcptestcases/scenario13/pipeline/` with deploy + teardown — dev (appCode 1395, cron 13:00) + tst (appCode 1394). EnvSnowId + networkAddressSpace TODOs need filling.
- [x] Validate `bicep build` passes (via localBuildHelper.ps1, warnings only — all from upstream modules)
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check

### Scenario 14 — Event Hub + App Configuration + Function App (event-hub/namespace + app-configuration/configuration-store)

**Existing coverage:** Scenario 4 already exercises `event-hub/namespace`, but was migrated from local modules. This dedicated scenario provides a clean AMAVM-native test with a simpler architecture focused on validating the module's inline `eventhubs`, `consumerGroups`, and `roleAssignments` params. **App Configuration added** to provide feature flag support for event consumer enable/disable — realistic pattern for toggling event processing without redeployment.

**Architecture:** A Function App sends events to an Event Hub (HTTP trigger → producer) and a second Function App reads events (Event Hub trigger → consumer → writes to Storage blob). Both connect via managed identity using the `__fullyQualifiedNamespace` pattern (no SAS keys). App Configuration provides feature flags to toggle consumers and configuration values for processing behavior. Validates namespace-level private endpoint, `disableLocalAuth`, and consumer group wiring.

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Event Hub Namespace | `br/amavm:res/event-hub/namespace` | Standard SKU, PE, inline eventhub + consumer group |
| App Configuration | `br/amavm:res/app-configuration/configuration-store` | Feature flags, PE, Entra-only auth |
| Function App (producer) | `br/amavm:res/web/site` | HTTP-triggered, sends events |
| Function App (consumer) | `br/amavm:res/web/site` | Event Hub-triggered, writes to blob |
| App Service Plan | `br/amavm:res/web/serverfarm` | Shared plan, Linux |
| Storage Account | `br/amavm:res/storage/storage-account` | Function backing + blob output |
| Key Vault | `br/amavm:res/key-vault/vault` | App config secrets |
| VNet + Subnets | `br/amavm:res/network/virtual-network/subnet` | PE + app egress |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |
| App Insights | `br/amavm:res/insights/component` | APM telemetry |

**DRCP-specific config (Event Hub):**
- `disableLocalAuth: true` (Entra-only, per drcp-evh-05)
- `publicNetworkAccess: 'Disabled'` (per drcp-evh-01)
- `minimumTlsVersion: '1.2'` (per drcp-evh-04)
- `privateEndpoints: [{ service: 'namespace', subnetResourceId: peSubnet }]`
- `eventhubs: [{ name: 'events', messageRetentionInDays: 1, partitionCount: 2, consumerGroups: [{ name: 'consumer-func' }] }]`
- `roleAssignments:` producer MI gets `Azure Event Hubs Data Sender`, consumer MI gets `Azure Event Hubs Data Receiver`
- Function App settings: `EventHubConnection__fullyQualifiedNamespace: '<ns>.servicebus.windows.net'` (identity-based, no connection string)
- `diagnosticSettings: [{ workspaceResourceId: logAnalytics }]`

**DRCP-specific config (App Configuration — 4 policies):**

| Policy | Property | Required Value |
|---|---|---|
| drcp-appconfig-auth | `disableLocalAuth` | `true` |
| drcp-appconfig-network | `publicNetworkAccess` | `'Disabled'` |
| drcp-appconfig-pe | PE must be same subscription | Enforced by policy |
| drcp-appconfig-dns | Private DNS zone | Auto-deployed by policy |

**AMAVM module defaults already enforce:** `disableLocalAuth = true`, `publicNetworkAccess = 'Disabled'` (when PE set), `sku = 'Standard'` (Free tier has no PE support)

**App Configuration setup:**
- `privateEndpoints: [{ service: 'configurationStores', subnetResourceId: peSubnet }]`
- `keyValues: [{ name: 'FeatureFlags:ConsumerEnabled', value: 'true' }, { name: 'Processing:BatchSize', value: '100' }]`
- `roleAssignments:` Function App MI gets `App Configuration Data Reader`
- Function App settings: `AppConfigEndpoint: appConfig.outputs.endpoint` (identity-based)

**Tasks:**
- [x] Create `drcptestcases/scenario14/infra/main.bicep` — Event Hub + Function App, inline hubs/consumer groups, PE, Entra auth
- [x] Wire inline eventhubs, consumer groups, private endpoint, RBAC (Data Receiver for Function App)
- [x] Create `drcptestcases/scenario14/README.md` using standard template
- [x] **Add App Configuration module** — PE, disableLocalAuth, inline keyValues for feature flags
- [x] Wire App Configuration RBAC (Data Reader) + Function App endpoint setting
- [ ] Use `/azure:azure-rbac` to confirm Data Sender / Data Receiver / App Configuration Data Reader roles
- [x] Create `drcptestcases/scenario14/pipeline/` with deploy + teardown — dev (appCode 1495, cron 14:00) + tst (appCode 1494). EnvSnowId + networkAddressSpace TODOs need filling.
- [x] Validate `bicep build` passes (via localBuildHelper.ps1, warnings only — all from upstream modules)
- [x] Re-validate `bicep build` after adding App Configuration
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check
- [x] Update README with App Configuration component

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
- [x] Create `drcptestcases/scenario15/infra/main.bicep` — Cosmos DB NoSQL, inline DB + 2 containers, PE, Entra auth, diagnostics
- [x] Wire inline sqlDatabases, private endpoint, RBAC (DocumentDB Account Contributor for dev)
- [x] Create `drcptestcases/scenario15/README.md` using standard template
- [ ] Use `/azure:azure-rbac` to confirm Cosmos DB SQL role definitions for data-plane access
- [x] Create `drcptestcases/scenario15/pipeline/` with deploy + teardown — dev (appCode 1595, cron 15:00) + tst (appCode 1594). EnvSnowId + networkAddressSpace TODOs need filling.
- [x] Validate `bicep build` passes (via localBuildHelper.ps1, warnings only — all from upstream modules)
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
1. ~~Copy `chatbot-poc/infra/main.bicep` → `drcptestcases/scenario16/infra/main.bicep`~~ DONE
2. ~~Copy `chatbot-poc/infra/modules/` → `drcptestcases/scenario16/infra/modules/`~~ DONE
3. Keep `br/amavm:utl/amavm/naming:0.1.0` — this is the AMAVM naming module (already correct, unlike older scenarios that use local `../../modules/infra/naming.bicep`)
4. Replace `modules/rbac.bicep` calls → inline `roleAssignments` on storage module where possible
5. Fix deprecated params: `vnetRouteAllEnabled`, `vnetContentShareEnabled`, `vnetImagePullEnabled` → `outboundVnetRouting` (per TD-15/FEAT-1)
6. Remove hardcoded subscription IDs, object IDs, and resource names from readme
7. ~~Add `bicepconfig.json`, pipelines~~ DONE — add README

**Note on naming module:** Scenario 16 uses `br/amavm:utl/amavm/naming:0.1.0` (the AMAVM registry naming utility). This is the preferred approach — older scenarios (1-12) use the local `../../modules/infra/naming.bicep` and should be migrated to AMAVM naming in a future pass.

**Tasks:**
- [x] Copy chatbot-poc infra to `drcptestcases/scenario16/infra/`
- [x] Copy pipelines, bicepconfig.json, src/ (backend + frontend)
- [x] ~~Replace `rbac.bicep` with inline `roleAssignments`~~ — **kept** — circular dependency between storage ↔ search/openai prevents inlining (search MI needs blob contributor, openai MI needs blob contributor, but storage module creates before search/openai exist). See lessons.md rule 22.
- [x] Fix deprecated VNet routing params → `outboundVnetRouting` (both web apps)
- [x] Parameterize hardcoded values — moved owner OIDs to `appOwnerObjectIds` param, added `department` to naming module (fixes unused `departmentCode` warning), removed unused `dockerImage` var, added `environmentId`/`applicationId` to `mytags`
- [ ] Use `/azure:entra-app-registration` to validate the app registration pattern
- [x] Create `drcptestcases/scenario16/pipelines/` with deploy + teardown — added `scenario16-scheduled-sec-dev.yaml` (cron 16:00 UTC, 1st+15th) alongside existing manual `main.yaml` + `deploy-app.yaml`
- [x] Create `drcptestcases/scenario16/README.md` using standard template
- [x] Validate `bicep build` passes — only BCP192 (expected, no ACR login) and pre-existing warnings (no-hardcoded-env-urls, use-safe-access in rbac.bicep). No real errors.
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] Use `/azure:azure-ai` for AI Search and OpenAI configuration best practices
- [ ] Document shared private link approval process in README (DRCP portal + manual curl approval)

### Scenario 17 — Static Web App + Function API Backend (web/static-site)

**Architecture:** SPA frontend deployed to Azure Static Web Apps (Standard SKU — required for private endpoints) with a linked Function App API backend. Validates the AMAVM `web/static-site` module's private endpoint, linked backend, and app settings support.

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Static Web App | `br/amavm:res/web/static-site` | Standard SKU, PE, linked backend |
| Function App (API) | `br/amavm:res/web/site` | API backend, linked to SWA |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux, S1 |
| Storage Account | `br/amavm:res/storage/storage-account` | Function backing storage |
| Key Vault | `br/amavm:res/key-vault/vault` | API config secrets |
| VNet + Subnets | `br/amavm:res/network/virtual-network/subnet` | PE + app egress |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |

**DRCP policies (4 Static Web App):**

| Policy | Property | Required Value |
|---|---|---|
| drcp-swa-network | `publicNetworkAccess` | `'Disabled'` |
| drcp-swa-sku | `sku.name` / `sku.tier` | `'Standard'` (only tier with PE) |
| drcp-swa-pe | PE must be same subscription | Enforced by policy |
| drcp-swa-dns | Private DNS zone | Auto-deployed by policy (partitioned DNS) |

**AMAVM module defaults already enforce:** `publicNetworkAccess = 'Disabled'`, `sku = 'Standard'`

**Key configuration:**
- `buildProperties: { appLocation: '/', outputLocation: 'dist', apiLocation: 'api' }`
- `linkedBackend: { resourceId: functionApp.outputs.resourceId }` — links SWA to Function API
- `privateEndpoints: [{ service: 'staticSites', subnetResourceId: peSubnet }]`
- Entra ID auth via `staticwebapp.config.json` routes
- `provider: 'None'` — no source control integration (pure Bicep deployment)

**Tasks:**
- [x] Create `drcptestcases/scenario17/infra/main.bicep` — Static Web App + Function API
  - SWA: Standard SKU, PE (staticSites), publicNetworkAccess=Disabled, provider=None, linkedBackend
  - Function App: Linux Node.js, PE, MI, VNet integration, identity-based storage
  - Storage: shared key disabled, 4x PE (blob/file/table/queue), diagnostics
  - Key Vault: PE, Function App MI → Secrets User
  - 10 AMAVM module refs, 1 local ref (naming.bicep)
- [x] Static Web App: Standard SKU, PE (staticSites), linked backend, Entra auth
- [x] Function App API: PE, MI, VNet integration, linked to SWA
- [x] Create `drcptestcases/scenario17/README.md`
- [x] Validate `bicep build` passes — 0 scenario17 errors
- [x] Create pipeline YAML — `pipeline/scenario17-scheduled-sec-dev.yaml` (ENV23969, appCode 1795) + `pipeline/scenario17-scheduled-sec-tst.yaml` (ENV_TODO, appCode 1794). Cron: 17:00 UTC, 1st+15th. TST envSnowId needs to be filled in.

---

## P2 — AMAVM Module Coverage

After P0 migrations, P1.5 new scenarios, and restructuring, these modules have integration test coverage:

| Module | Covered by |
|---|---|
| `cognitive-services/account` | **Scenario 16** |
| `search/search-service` | **Scenario 16** |
| `document-db/database-account` | Scenarios 2, **15** |
| `event-hub/namespace` | Scenarios 4, **14** |
| `cache/redis` | **Scenario 13** |
| `data-factory/factory` | Scenario 10 |
| `db-for-postgre-sql/flexible-server` | **Scenario 8** (repurposed) |
| `service-bus/namespace` | **Scenario 8** (repurposed) |
| `app-configuration/configuration-store` | **Scenario 14** (added) |
| `web/static-site` | **Scenario 17** (new) |
| `databricks/workspace` | Scenario 10 |
| `databricks/access-connector` | Scenario 10 |
| `container-registry/registry` | Scenario 7, 9 |
| `container-service/managed-cluster` | Scenario 9 |
| `sql/server` | Scenarios 1, 11, 12 |
| `web/site` | Scenarios 1, 2, 3, 4, 5, 7, 8, 11, 13, 14, 15, 16, **17** |
| `key-vault/vault` | Scenarios 1, 2, 3, 4, 5, 8, 11, 13, 14, 15, **17** |
| `storage/storage-account` | Scenarios 1, 2, 3, 4, 9, 10, 13, 14, 15, 16, **17** |
| `network/application-gateway` | Scenario 5 |

**Full coverage achieved!** All 36 AMAVM `res/` modules are now covered by at least one scenario after S8 repurpose, S14 enhancement, and S17 addition.

**Still indirectly covered only (consumed as child modules):**
- `insights/*` monitoring utilities (action-group, metric-alert, webtest, etc.) — used within modules, not standalone
- `network/private-endpoint` — consumed inline by parent modules
- `network/virtual-network` — scenarios reference existing VNets

**Interim validation for monitoring modules:**
- Use `/azure:azure-validate` to run pre-deployment checks on module Bicep without a full test scenario
- Use `/azure:azure-compliance` to audit deployed instances against DRCP policies

---

## P2.5 — RBAC Enforcement Across All Scenarios

All scenarios should use Entra ID RBAC (managed identity + role assignments) instead of connection strings or access keys. This is a DRCP requirement: no local auth, no shared keys, no SAS tokens.

**Exception:** Logic App connections (scenario 3) require a connection string due to Logic App connector limitations — this is the only acceptable exception.

**Audit checklist:**

| Scenario | Resource | Auth Method | Status |
|---|---|---|---|
| 1 | SQL, KV, Storage | MI RBAC | [x] Compliant — system MI + UAMI for SQL, no keys |
| 2 | Cosmos DB, KV, Storage | MI RBAC (`disableLocalAuth: true`) | [x] Fixed — added disableLocalAuth + disableKeyBasedMetadataWriteAccess + roleAssignments |
| 3 | Logic App, Storage | Connection string (Logic App exception) | [x] Verified — keys in KV, UAMI for KV access, documented exception |
| 4 | Event Hub, KV, Storage | MI RBAC (`disableLocalAuth: true`) | [x] Confirmed — separate RBAC modules |
| 5 | App Gateway, Web Apps, Storage | MI RBAC | [x] Mostly compliant — FuncApp MI → KV, Storage `allowSharedKeyAccess: false` |
| 7 | ACR, Logic App, Storage | Mixed (Logic App exception) | [x] Verified — ACR RBAC via helper, Logic App exception same as S3 |
| 8 | PostgreSQL, Service Bus | MI RBAC (Entra-only for both) | [ ] Implement with repurpose |
| 9 | AKS, ACR, Storage | MI RBAC | [x] Fixed — uncommented `allowSharedKeyAccess: false` on storage |
| 10 | Data Factory, Databricks, Storage | MI RBAC | [x] Verified — ADF MI + RBAC on storage; SHIR keys in KV (platform exception) |
| 11 | Web Apps, SQL, Storage | MI RBAC | [x] Fixed — SQL connection string now uses `Authentication=Active Directory Default` |
| 13 | Redis | MI RBAC (`disableAccessKeyAuthentication: true`) | [x] Built with Entra auth |
| 14 | Event Hub, Function App | MI RBAC (`disableLocalAuth: true`) | [x] Built with Entra auth |
| 15 | Cosmos DB | MI RBAC (`disableLocalAuthentication: true`) | [x] Built with Entra auth |
| 16 | OpenAI, AI Search, Storage | UAMI RBAC + FIC | [x] Verified — full RBAC, federated identity credentials, no keys |

- [x] Audit scenarios 1, 2, 5, 7, 9, 10, 11, 16 for RBAC compliance
- [x] Document Logic App exception in scenario 3 (verified: keys in KV, UAMI for access)
- [ ] Audit scenario 8 for RBAC compliance (blocked on P0 migration)
- [ ] Use `/azure:azure-rbac` to verify least-privilege roles per scenario

---

## P2.7 — Region Cleanup + Environment Mapping

### West Europe Deprecation

West Europe is no longer used for deployments. All references should be cleaned up.

- [x] Remove West Europe network space from top-level `drcptestcases/README.md`
- [x] Remove West Europe environments (ENV23148, ENV23684) from top-level README
- [ ] Update files that reference `westeurope`:
  - [ ] `scenario5/infra/main.bicep` — line 94: location mapping (keep — used as abbreviation lookup)
  - [ ] `scenario7/README.md` — deploy command uses `westeurope` location
  - [ ] `scenario8/README.md` — deploy command uses `westeurope` location
  - [ ] `scenario10/README.md` — deploy command uses `westeurope` location
  - [ ] `scenario10/pipeline/scenario10-DataPipelines.yaml` — pipeline references
  - [ ] `scenario16/pipelines/main.yaml` — pipeline references
  - [ ] `scenario16/pipelines/deploy-app.yaml` — pipeline references
  - [ ] `pipelines/universalPipeline.yaml` — shared pipeline template
  - [ ] `modules/pipelines/tpl/variables/commonVariables.yaml` — shared variables
  - [ ] `modules/pipelines/tpl/tasks/*.yaml` (5 files) — shared task templates
  - [ ] `modules/infra/naming.bicep` — location abbreviation mapping
  - [ ] `modules/infra/network/virtual-network/README.md` — documentation

### Environment Mapping for New Scenarios (13-17)

**Address space is no longer a constraint.** With ADO exclusive locks (see P2.9), scenarios run sequentially within their concurrency group and always tear down. All scenarios in a group reuse the same CIDR block — no per-scenario allocation needed.

Each scenario's `networkAddressSpace` param should be set to the group's shared CIDR:
- **Group A** (VNet-A, ENV23968/23978): shared `/25` from the VNet's address space
- **Group B** (VNet-B, ENV23969/23979): shared `/24` from the VNet's address space (S9/AKS needs the largest block)

**Action items:**
- [ ] Standardize `networkAddressSpace` defaults to use shared group CIDRs
- [ ] Assign new scenarios to groups (see P2.9 for rebalancing proposal)
- [ ] Create pipeline YAML for scenarios 13-17 (deploy + teardown, exclusive lock environment)

### Environment Strategy

| Environment | Purpose | Policy Strictness | Used By |
|---|---|---|---|
| DEV (ENV23968/ENV23969) | Development + initial validation | Less restrictive — allows engineer RBAC, conditional dev features | All scenarios (primary) |
| TST (ENV23978/ENV23979) | Policy compliance validation | Strict — mirrors production policies, no dev shortcuts | Scenarios with nightly pipeline |

**Principle:** Every scenario should deploy to DEV first (less restrictive, faster iteration). Once stable, add TST pipeline to validate under strict policies. Teardown must always run — no leftover resources.

---

## P2.9 — Test Concurrency & Scheduling

### Problem

All scenarios deploy subnets into **shared VNets**. Azure Resource Manager serializes operations on a VNet — if two scenarios create/delete subnets in the same VNet simultaneously, ARM returns conflict errors. Current pipelines rely on 1-hour time staggering with **no concurrency locks**. With 17 scenarios this approach breaks down.

### Current State

**VNet topology** — 4 shared VNets (2 per env type):

| VNet | Env Type | Env IDs | Address Space | Scenarios |
|---|---|---|---|---|
| VNet-A-DEV | DEV | ENV23968 | `10.238.18.0/24` | 1, 2, 3, 4, 5, 7 |
| VNet-B-DEV | DEV | ENV23969 | `10.238.19.0/24` | 8, 9, 10, 11, 12 |
| VNet-A-TST | TST | ENV23978 | `10.238.64.0/24` | 1, 2, 3, 4, 5, 7 |
| VNet-B-TST | TST | ENV23979 | `10.238.65.0/24` | 8, 9, 10, 11, 12 |

**Concurrency rule**: Scenarios sharing a VNet form a **concurrency group** — only one can be deploying or tearing down at a time.

**Current scheduling** (bi-weekly, 1st + 15th of month):

| Hour (UTC) | Group A (VNet-A) | Group B (VNet-B) |
|---|---|---|
| 01:00 | S1 | — |
| 02:00 | S2 | — |
| 03:00 | S3 | — |
| 04:00 | S4 | — |
| 05:00 | S5 | — |
| 07:00 | S7 | — |
| 08:00 | — | S8 |
| 09:00 | — | S9 |
| 10:00 | — | S10 |
| 11:00 | — | S11 |
| 12:00 | — | S12 |

**Problems:**
1. Groups run sequentially today (A finishes, then B starts) — wastes 6 hours
2. No concurrency lock — if S1 takes >60 min, it overlaps with S2 (same VNet = ARM conflict)
3. New scenarios 13-17 have no schedule slots or address space
4. `ptn/data/ingestion` commented out in S12 — when enabled adds subnet pressure

### Address Space — Solved by Exclusive Lock + Teardown

Since every pipeline always runs **deploy → teardown** and the exclusive lock ensures only one scenario uses a VNet at a time, subnets are always cleaned up before the next scenario starts. All scenarios in a group **reuse the same address space** — they don't need unique, non-overlapping CIDRs.

**Implication**: Each group just needs a shared block large enough for the single largest scenario:
- **Group A**: Largest is S5 (App Gateway, 3 subnets) — needs /26
- **Group B**: Largest is S9 (AKS, 4 subnets including /25) — needs /25

Both groups' existing `/24` blocks are more than sufficient. New scenarios 13-17 fit into existing VNets with zero changes — they just need a `networkAddressSpace` param that's large enough for their subnets.

**Each scenario should use the same shared CIDR** (e.g., the first available /25 or /26 in the VNet's address space). No per-scenario CIDR allocation table needed.

**Scenario 12 `ptn/data/ingestion`**: When enabled, it deploys ~3 subnets. With exclusive lock + teardown, it simply reuses the same shared block as every other Group B scenario. No subnet budget concern.

### Proposed Approach

#### 1. ADO Exclusive Lock per VNet (prevents ARM conflicts)

Use Azure DevOps **environment exclusive locks** to guarantee only one scenario deploys to a VNet at a time:

```yaml
# Each scenario pipeline uses its VNet's lock environment
- deployment: deployInfra
  environment: 'drcp-vnet-b-dev'     # exclusive lock — queues if another run is active
  strategy:
    runOnce:
      deploy: ...
```

Create 4 ADO environments with `exclusivelock` check:
- `drcp-vnet-a-dev` (scenarios 1-5, 7)
- `drcp-vnet-b-dev` (scenarios 8-17)
- `drcp-vnet-a-tst` (scenarios 1-5, 7)
- `drcp-vnet-b-tst` (scenarios 8-17)

**Effect**: Scenarios auto-queue if their VNet is in use. No manual stagger needed. Group A and Group B run fully in parallel (different VNets). Address space reused by every scenario through deploy+teardown.

#### 2. Parallel groups to halve total runtime

Today groups run sequentially (A then B) taking ~12 hours. With exclusive locks, schedule both groups at the same start time:

| Hour (UTC) | Group A (VNet-A) | Group B (VNet-B) |
|---|---|---|
| 01:00 | S1 | S8 |
| ~01:30 | S2 (auto-queued) | S9 (auto-queued) |
| ~02:00 | S3 | S10 |
| ... | ... | ... |

Each scenario takes ~20-30 min. With exclusive locks, the next auto-starts when the previous finishes. Total runtime drops from ~12 hours to ~3 hours per group.

#### 3. Shared CIDR per group

All scenarios in a group use the **same `networkAddressSpace`** — large enough for the biggest consumer:
- Group A: `/25` (covers S5's 3 subnets with room to spare)
- Group B: `/24` (covers S9's AKS multi-pool layout)

New scenarios just pass this shared CIDR. No per-scenario allocation needed.

#### 4. Rebalancing groups

Group B currently has 5 scenarios (8-12) plus all new scenarios (13-17) = 10 total. Group A has 6 (1-5, 7). Consider moving some new scenarios to Group A for balance:
- Move S13 (Redis) and S15 (Cosmos) to Group A — simple, fast-deploying scenarios
- Keep S14 (EVH), S16 (AI), S17 (SWA) in Group B
- Result: Group A = 8, Group B = 8 — balanced ~4h each

### Tasks

- [ ] Create 4 ADO environments with exclusive lock: `drcp-vnet-{a,b}-{dev,tst}`
- [ ] Update all scenario pipeline YAMLs to use environment-based deployment (replaces time stagger)
- [ ] Standardize `networkAddressSpace` param: one shared CIDR per group (remove per-scenario allocations)
- [ ] Schedule Group A and Group B at the same start time (01:00 UTC)
- [ ] Decide group assignment for scenarios 13-17 (balance runtime across groups)
- [x] Create pipeline YAMLs for scenarios 13-17 — all created with ENV_TODO placeholders for envSnowId + networkAddressSpace
- [ ] Verify S12 `ptn/data/ingestion` works with the shared CIDR when uncommented
- [ ] Document concurrency groups in top-level `drcptestcases/README.md`

---

## Pipeline Audit (2026-03-11)

### Current State

| Scenario | Pipeline Dir | Files | Schedule (UTC) | Status |
|----------|:--------:|-------|----------|--------|
| 1 | `pipeline/` | dev + tst | 01:00 | OK |
| 2 | `pipelines/` | dev + tst | 02:00 | OK |
| 3 | `pipelines/` | dev + tst | 03:00 | OK |
| 4 | `pipelines/` | dev + tst | 04:00 | OK |
| 5 | `pipeline/` | dev + tst | 05:00 | OK |
| 7 | `pipeline/` | dev + tst | 07:00 | OK |
| 8 | `pipeline/` | dev + tst | 08:00 | OK |
| 9 | `pipeline/` | tst only | 09:00 | **Missing DEV pipeline** |
| 10 | `pipeline/` | dev + tst + DataPipelines | 10:00 | OK |
| 11 | `pipeline/` | dev + tst + env-init | 11:00 | OK |
| 12 | `pipeline/` | dev + tst | 12:00 | OK |
| 13 | `pipeline/` | dev + tst | 13:00 | OK (created, ENV_TODO) |
| 14 | `pipeline/` | dev + tst | 14:00 | OK (created, ENV_TODO) |
| 15 | `pipeline/` | dev + tst | 15:00 | OK (created, ENV_TODO) |
| 16 | `pipelines/` | main + deploy-app + **scheduled-dev** | 16:00 | OK (scheduled added) |
| 17 | `pipeline/` | **dev + tst** | 17:00 | OK (created) |

### Open Issues

- [ ] **Scenario 9**: Only has TST pipeline, missing DEV — needs `scenario9-scheduled-sec-dev.yaml`
- [ ] **Scenarios 13, 14, 15**: No pipeline YAMLs at all — deferred to future session
- **Directory naming inconsistency**: Some use `pipeline/` (singular), others `pipelines/` (plural) — cosmetic, not breaking. Not worth renaming.
- **Application instance code pattern**: S10-12 use `{nn}94`/`{nn}93` instead of `{nn}95`/`{nn}94` — legacy, not worth changing

---

## Brainstorm: Function App Code Deployment via Bicep

### Problem

Currently all scenarios deploy infrastructure via Bicep and deploy app code separately via CI/CD pipeline. Explore deploying Function App code **during Bicep deployment time** via a dedicated helper module.

### Options Analyzed

| Option | Mechanism | DRCP OK? | Complexity |
|--------|-----------|:--------:|:----------:|
| A. MSDeploy Extension | `msDeployConfiguration.packageUri` on web/site | Yes | Low |
| B. WEBSITE_RUN_FROM_PACKAGE URL | App setting → blob URL, FA pulls at startup | Yes | Low |
| C. Deployment Script (az CLI) | `deploymentScripts` runs `az webapp deploy` | Partial (ACI networking) | Medium |
| D. Dedicated Helper Module | Wraps A or B with storage + RBAC | Yes | Medium |
| **E. Run From Package + MI** | `WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID` + blob URL | **Yes — no SAS** | Low |

### Recommendation: Option E (Run From Package + MI) wrapped in Option D (Helper Module)

**Why:**
- **DRCP-compliant**: No shared keys, no SAS tokens — MI-only access to blob
- **No ACI dependency**: Avoids deployment script networking issues
- **Clean separation**: Package upload stays in pipeline, Bicep handles wiring
- **Reusable**: Helper module parameterizes the pattern for all Function App scenarios

**Helper Module Design** (`modules/infra/function-app-package/main.bicep`):
```
Inputs:  functionAppName, storageAccountName, containerName, packageBlobName, functionAppPrincipalId
Does:    1) Creates blob container  2) Assigns Storage Blob Data Reader to FA MI  3) Outputs blob URL + app settings
Outputs: packageUrl, appSettings object
```

**Workflow:**
1. Bicep deploys infra (storage + function app + helper module)
2. Pipeline builds FA code → uploads zip to blob container
3. Function App reads package at startup via MI (no redeployment needed)

### Next Steps

- [ ] Prototype helper module in a new scenario (S18?) or integrate into S14 (Event Hub + Function App)
- [ ] Validate that `WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID` works with system-assigned MI on DRCP
- [ ] Test blob container creation via storage account module's `blobServices.containers` param (avoid separate module)

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
- [ ] Remove `modules/infra/integration/data-factory/` (after scenario 10 migrated — keep `integrationRuntime.bicep` + `role-assignment.bicep` for linked IR pattern)
- [ ] Remove `modules/infra/network/private-endpoint/` (after all PE refs migrated)
- [ ] Audit remaining `modules/infra/` for other removable modules
- [x] Migrate `naming.bicep` references → `br/amavm:utl/amavm/naming:0.1.0` in all 16 scenario files (params + outputs identical, drop-in replacement)
- [ ] Keep: scenario-specific helpers, deployment scripts, `public-ip-address`
- [ ] Remove `modules/infra/integration/api-management/` (no longer needed — S8 repurposed)

### Scenario 7 — ACR Task Module Update (LOW PRIORITY)

The ACR task module at `modules/infra/compute/container-registry/task.bicep` uses preview APIs:
- `Microsoft.ContainerRegistry/registries@2023-01-01-preview` (existing ref)
- `Microsoft.ContainerRegistry/registries/tasks@2019-06-01-preview` (6+ years old)
- `Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview`

ACR Tasks are not available as an AMAVM module, so this stays local. But the API versions should be updated.

- [ ] Update ACR task API version from `2019-06-01-preview` to latest GA (`2019-04-01` or check for newer)
- [ ] Check if `taskRuns` resource type has a GA API version
- [ ] Validate `bicep build` after update
- [ ] Consider if ACR Tasks can be replaced by GitHub Actions or ADO pipeline tasks (simpler, no preview API dependency)
