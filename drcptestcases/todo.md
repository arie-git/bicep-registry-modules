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
| 7 | Docker App Service + ACR + Logic App | **Nearly AMAVM** | 1 (`naming.bicep`) + 1 (ACR task) + 1 (`acrRoleAssignment.bicep`) | 13 |
| 8 | **PostgreSQL + Service Bus** (repurposed) | **Fully AMAVM** | 1 (`naming.bicep`) | 11 |
| 9 | AKS + ACR + Storage | **Fully AMAVM** | 1 (`naming.bicep`) | 16 |
| 10 | Data Factory + Databricks | **Nearly AMAVM** | main.bicep: 3 local (naming, IR, role-assignment) + central.bicep: 11 local | main: 12 |
| 11 | Web Apps + SQL | **Fully AMAVM** | 1 (`naming.bicep`) | 15 |
| 12 | N-Tier SQL (pattern module) | **Complete** | 0 (only scenario with zero local refs) | 2 |
| **13** | **Redis Cache (standalone)** | **Implemented** | 1 (`naming.bicep`) | 5 |
| **14** | **Event Hub + Function App** | **Implemented** | 1 (`naming.bicep`) | 11 |
| **15** | **Cosmos DB NoSQL (standalone)** | **Implemented** | 1 (`naming.bicep`) | 5 |
| **16** | **AI Chatbot: OpenAI + AI Search** | **Planned** (from chatbot-poc) | — | — |

| **17** | **Static Web App + Function API** | **Planned** | — | — |

**Note:** Scenario 6 does not exist (removed or never created). Local ref counts exclude commented-out references. `naming.bicep` is a utility module that will remain local (not an AMAVM candidate). Scenarios 13-15 implemented, scenario 16 migrated from chatbot-poc (needs cleanup). Scenario 8 being repurposed from APIM to PostgreSQL + Service Bus. Scenario 17 is new (Static Web App).

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
- [ ] Migrate central.bicep local modules to AMAVM where equivalents exist
- [ ] Validate against all 18 DRCP policies (8 Databricks + 10 Data Factory)
- [ ] Update README with UC architecture and policy compliance table

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
- [ ] Remove Logic App module, second App Service Plan, and Logic App subnet — simplify to ACR + Docker only
- [ ] Keep `task.bicep` local (ACR Tasks not in AMAVM)
- [ ] Validate `bicep build` passes
- [ ] Update README to reflect simplified architecture

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
- [ ] Create `drcptestcases/scenario13/pipelines/` with deploy + teardown
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
- [ ] **Add App Configuration module** — PE, disableLocalAuth, inline keyValues for feature flags
- [ ] Wire App Configuration RBAC (Data Reader) + Function App endpoint setting
- [ ] Use `/azure:azure-rbac` to confirm Data Sender / Data Receiver / App Configuration Data Reader roles
- [ ] Create `drcptestcases/scenario14/pipelines/` with deploy + teardown
- [x] Validate `bicep build` passes (via localBuildHelper.ps1, warnings only — all from upstream modules)
- [ ] Re-validate `bicep build` after adding App Configuration
- [ ] Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] Update README with App Configuration component

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
- [ ] Create `drcptestcases/scenario15/pipelines/` with deploy + teardown
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
- [ ] Replace `rbac.bicep` with inline `roleAssignments` where possible — use `/azure:azure-rbac` to verify roles
- [x] Fix deprecated VNet routing params → `outboundVnetRouting` (both web apps)
- [ ] Parameterize hardcoded values (engineer object IDs, subscription IDs)
- [ ] Use `/azure:entra-app-registration` to validate the app registration pattern
- [ ] Create `drcptestcases/scenario16/pipelines/` with deploy + teardown
- [x] Create `drcptestcases/scenario16/README.md` using standard template
- [ ] Validate `bicep build` passes (note: `microsoftGraphV1` extension may require special bicepconfig)
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
- [ ] Create `drcptestcases/scenario17/infra/main.bicep` — Static Web App + Function API
- [ ] Static Web App: Standard SKU, PE (staticSites), linked backend, Entra auth
- [ ] Function App API: PE, MI, VNet integration, linked to SWA
- [ ] Create `drcptestcases/scenario17/README.md`
- [ ] Validate `bicep build` passes
- [ ] Create pipeline YAML

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

### Environment Mapping for New Scenarios (13-16)

New scenarios need DEV and TST network allocations in Sweden Central that don't overlap with existing ranges.

**Current DEV allocations (10.238.18.0/24 + 10.238.19.0/24):**

| Scenario | CIDR | Range | Size |
|---|---|---|---|
| 1 | 10.238.18.0/27 | .0-.31 | /27 |
| 2 | 10.238.18.32/27 | .32-.63 | /27 |
| 3 | 10.238.18.64/27 | .64-.95 | /27 |
| 4 | 10.238.18.96/27 | .96-.127 | /27 |
| 7 | 10.238.18.128/26 | .128-.191 | /26 |
| 5 | 10.238.18.192/26 | .192-.255 | /26 |
| 8 | 10.238.19.0/26 | .0-.63 | /26 |
| 10 | 10.238.19.64/27 | .64-.95 | /27 |
| 9 | 10.238.19.128/26 | .128-.191 | /26 |
| 11 | 10.238.19.192/26 | .192-.255 | /26 |

**Free DEV ranges:**
- `10.238.19.96/27` (.96-.127) — between scenario 10 and 9

That's only 1 free /27 in the existing /24 blocks. New scenarios need additional address space or a new /24 block.

**Proposed DEV allocations for new scenarios (ENV23968/ENV23969):**

| Scenario | CIDR | Size | Justification |
|---|---|---|---|
| 12 | (uses ntier pattern, may not need VNet) | /27 | Verify if VNet is abstracted |
| 13 | 10.238.19.96/27 | /27 | 1 subnet (PE only) |
| 14 | needs new /24 block or reuse freed WE space | /27 | 2 subnets (PE + egress) |
| 15 | needs new /24 block | /27 | 1 subnet (PE only) |
| 16 | needs new /24 block | /26 | 3 subnets (PE + 2 egress) |

**Current TST allocations (10.238.64.0/24 + 10.238.65.0/24):**

| Scenario | CIDR | Range | Size |
|---|---|---|---|
| 1 | 10.238.64.0/27 | .0-.31 | /27 |
| 2 | 10.238.64.32/27 | .32-.63 | /27 |
| 3 | 10.238.64.64/27 | .64-.95 | /27 |
| 4 | 10.238.64.96/27 | .96-.127 | /27 |
| 7 | 10.238.64.128/26 | .128-.191 | /26 |
| 5 | 10.238.64.192/26 | .192-.255 | /26 |
| 8 | 10.238.65.0/26 | .0-.63 | /26 |
| 10 | 10.238.65.64/27 | .64-.95 | /27 |
| 11 | 10.238.65.192/26 | .192-.255 | /26 |

**Free TST ranges:**
- `10.238.65.96/27` (.96-.127)
- `10.238.65.128/26` (.128-.191)

**Proposed TST allocations:**

| Scenario | CIDR | Size |
|---|---|---|
| 13 | 10.238.65.96/27 | /27 |
| 14 | 10.238.65.128/27 | /27 |
| 15 | 10.238.65.160/27 | /27 |
| 16 | 10.238.65.192/26 | /26 (conflicts with S11 — needs resolution) |

**Action items:**
- [ ] Confirm with platform team: available address space for DEV scenarios 14-16 (need new /24 block or freed West Europe space)
- [ ] Confirm TST scenario 11 actual start address (.192 or .196 — README says .196 which is not /26-aligned)
- [ ] Assign DEV CIDR for scenario 13: `10.238.19.96/27`
- [ ] Assign TST CIDRs for scenarios 13-15 in free TST range `10.238.65.96/26`
- [ ] Request new address space for scenario 16 (DEV + TST) — needs /26 for 3 subnets
- [ ] Update scenario `main.bicep` defaults with assigned `networkAddressSpace` values
- [ ] Create pipeline YAML for scenarios 13, 14, 15 (deploy + teardown, nightly schedule)
- [ ] Add nightly schedule slots: scenario 12 at 12am, 13 at 1:13am (offset to avoid collision), etc.
- [ ] Ensure all pipelines include teardown stage so environments stay clean

### Environment Strategy

| Environment | Purpose | Policy Strictness | Used By |
|---|---|---|---|
| DEV (ENV23968/ENV23969) | Development + initial validation | Less restrictive — allows engineer RBAC, conditional dev features | All scenarios (primary) |
| TST (ENV23978/ENV23979) | Policy compliance validation | Strict — mirrors production policies, no dev shortcuts | Scenarios with nightly pipeline |

**Principle:** Every scenario should deploy to DEV first (less restrictive, faster iteration). Once stable, add TST pipeline to validate under strict policies. Teardown must always run — no leftover resources.

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
- [ ] Migrate `naming.bicep` references → `br/amavm:utl/amavm/naming:0.1.0` in all scenarios (scenario 16 already uses AMAVM naming; scenarios 1-12 still use local `../../modules/infra/naming.bicep`)
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
