# DRCP Test Cases -- Completed Work Archive

> This file preserves historical details from [`todo.md`](todo.md): completed migration plans, component tables, DRCP policy configs, and design documents. The active task tracker is in `todo.md`.

---

## P0 -- Completed AMAVM Migrations

### Scenario 2 -- Cosmos DB migration (5 local refs → 0)

**Migration plan:**
1. Replace `cosmos-db/main.bicep` → `br/amavm:res/document-db/database-account` with `sqlDatabases` param (inline DB + containers)
2. Remove `secureKeys.bicep` call -- AMAVM Cosmos uses `disableLocalAuth: true`, no keys to store
3. Remove separate `sqldatabase.bicep` and `container.bicep` calls -- folded into `sqlDatabases` param
4. Remove `private-endpoint/main.bicep` call -- use AMAVM module's `privateEndpoints` param
5. Add `diagnosticSettings` param to Cosmos module (replaces inline diagnostic resource)

| Local module | AMAVM replacement | Approach |
|---|---|---|
| `storage/cosmos-db/main.bicep` | `br/amavm:res/document-db/database-account` | Replace with inline params |
| `storage/cosmos-db/secureKeys.bicep` | **Remove** | No keys with `disableLocalAuth: true` |
| `storage/cosmos-db/apis/sql/sqldatabase.bicep` | `sqlDatabases` param on database-account | Inline as param |
| `storage/cosmos-db/apis/sql/container.bicep` | `containers` in `sqlDatabases` param | Inline as param |
| `network/private-endpoint/main.bicep` | `privateEndpoints` param on database-account | Inline as param |

**Validation results:**
- `bicep build` passes (1 warning: `no-unnecessary-dependson` on subnetOut)
- DRCP policy audit: 8 PASS, 6 FAIL, 4 N/A (policy-remediated). Failures are AMAVM module defaults that already enforce the policies at module level:
  - KV/Storage `publicNetworkAccess` -- AMAVM defaults to `'Disabled'` when PE configured
  - TLS 1.2 -- AMAVM defaults `minimumTlsVersion: 'TLS1_2'` for storage and `'1.2'` for web/site
  - VNet route all -- AMAVM web/site already migrated to `outboundVnetRouting` (S2 needs this param added)
  - Cosmos DB zone redundancy -- not exposed by AMAVM module v0.1.0

### Scenario 4 -- Event Hub migration (6 local refs → 0)

**Migration plan:**
1. Replace `event-hub/namespace.bicep` → `br/amavm:res/event-hub/namespace` with `eventhubs` param (inline hubs + consumer groups)
2. Remove separate `event-hub/main.bicep` and `consumer-group.bicep` calls -- folded into `eventhubs` param
3. Remove `private-endpoint/main.bicep` -- use AMAVM module's `privateEndpoints` param
4. Remove `role-assignment.bicep` calls -- use AMAVM module's `roleAssignments` param

| Local module | AMAVM replacement | Approach |
|---|---|---|
| `integration/event-hub/namespace.bicep` | `br/amavm:res/event-hub/namespace` | Replace |
| `integration/event-hub/main.bicep` | `eventhubs` param on namespace | Inline |
| `integration/event-hub/consumer-group.bicep` | `consumerGroups` in eventhubs | Inline |
| `network/private-endpoint/main.bicep` | `privateEndpoints` param | Inline |
| `integration/event-hub/modules/role-assignment.bicep` | `roleAssignments` param | Inline |
| `storage/storage-account/modules/role-assignment.bicep` | `roleAssignments` param on storage-account | Inline |

**Key decision:** Extracted 3 cross-resource RBAC assignments into separate modules (`roleAssignment.bicep`, `evhRoleAssignment.bicep`, `kvRoleAssignment.bicep`) to break circular dependencies.

**Validation results:**
- `bicep build` passes for both main.bicep and central.bicep (warnings only: `use-safe-access` in local role-assignment modules + `prefer-unquoted-property-names` in legacy rbac module)
- DRCP policy audit: 15 PASS, 1 FAIL (ADF Git config in dev -- acceptable if policy exempted), 2 N/A

### Scenario 10 -- Data Factory + Databricks + Unity Catalog (17 local refs across 2 files)

**Architecture:** Two-tier Bicep structure:
- `main.bicep` -- 6 active local refs + 11 AMAVM refs
- `central.bicep` -- 11 active local refs + **0 AMAVM refs** (100% local, worst file in all scenarios)

**See `scenario10/todo.md` for detailed plan** -- includes Unity Catalog example, full DRCP policy checklist (8 Databricks + 10 Data Factory policies), AMAVM migration plan, and medallion architecture pipeline updates.

**Completed:**
- Unity Catalog infra (ADLS Gen2 + Access Connector RBAC + managed RG name)
- Data Factory in main.bicep migrated to AMAVM `data-factory/factory` (inline PE, diagnostics, linked services, IR)
- Linked services (ls_keyvault, ls_adls, ls_blob, ls_adls_uc, ls_databricks) -- MI auth, no hardcoded URLs
- Pure Bicep deployment support (gitConfigureLater, adfRepoConfig optional)
- central.bicep migration (6 migrated, 3 eliminated via inlining, 3 kept local)
- All 18 DRCP policies validated: **15 PASS, 1 FAIL** (ADF Git repo in dev), **2 N/A**
- README updated with UC architecture and policy compliance table

### Scenario 8 -- Repurposed from APIM to PostgreSQL + Service Bus

**Decision:** APIM is NOT a whitelisted DRCP component and Cosmos DB is already covered by S2 + S15. Repurposed to provide new AMAVM module coverage for `db-for-postgre-sql/flexible-server` and `service-bus/namespace`.

**Architecture:** Message-driven processing -- Function App receives messages from Service Bus queue, processes them, writes results to PostgreSQL. Both services use Managed Identity exclusively.

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

### Scenario 7 -- ACR + Docker Web App (simplified)

Removed Logic App (already covered by S3). Kept `task.bicep` local (ACR Tasks not in AMAVM).
- Removed: Logic App module, appServicePlan2, logicAppOut subnet, UAMI, copyStorageKeysToKeyvault helper, fileShare
- Fixed: `allowSharedKeyAccess: false` (was `true` for Logic App), removed `UsedBy: 'LogicApp'` tag
- Subnet count: 3 → 2 (PE + web egress)

---

## P0 -- Parameter Change Awareness (reference)

AMAVM modules have been through significant upstream syncs. Key differences from local modules:

| Pattern | Local module | AMAVM module |
|---|---|---|
| Private Endpoint | Separate PE module call with `privateLinkResource`, `subnet`, `targetSubResource` | Inline `privateEndpoints` array param on parent module |
| Role Assignments | Separate `role-assignment.bicep` module call | Inline `roleAssignments` array param on parent module |
| Cosmos DB secrets | `secureKeys.bicep` → stores keys in KV | Not needed -- `disableLocalAuth: true` means no keys (use RBAC) |
| Diagnostics | Inline `diagnosticSettings` resource | Inline `diagnosticSettings` param on parent module |
| Cosmos DB databases | Separate `sqldatabase.bicep` + `container.bicep` calls | Inline `sqlDatabases` param with nested `containers` |

---

## P1 -- README Standardization (completed)

### Standard README Template

```markdown
# Scenario N -- <Short Title>

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

### README Completion Status

| Scenario | Status |
|---|---|
| 1-5, 7-12 | Updated to standard template |

---

## P1.5 -- New Scenario Details (reference)

### Scenario 13 -- Redis Cache + Web App

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Redis Cache | `br/amavm:res/cache/redis` | Premium P1, PE, Entra auth, TLS 1.2 |
| Web App | `br/amavm:res/web/site` | Consumes Redis via managed identity |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux, S1 |
| Key Vault | `br/amavm:res/key-vault/vault` | Stores Redis hostname (not keys -- Entra auth) |
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

### Scenario 14 -- Event Hub + App Configuration + Function App

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
- Function App settings: `EventHubConnection__fullyQualifiedNamespace: '<ns>.servicebus.windows.net'` (identity-based)
- `diagnosticSettings: [{ workspaceResourceId: logAnalytics }]`

**DRCP-specific config (App Configuration -- 4 policies):**

| Policy | Property | Required Value |
|---|---|---|
| drcp-appconfig-auth | `disableLocalAuth` | `true` |
| drcp-appconfig-network | `publicNetworkAccess` | `'Disabled'` |
| drcp-appconfig-pe | PE must be same subscription | Enforced by policy |
| drcp-appconfig-dns | Private DNS zone | Auto-deployed by policy |

### Scenario 15 -- Cosmos DB NoSQL CRUD API

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
- `privateEndpoints: [{ service: 'Sql', subnetResourceId: peSubnet }]`
- `sqlDatabases: [{ name: 'tododb', containers: [{ name: 'items', paths: ['/id'] }] }]`
- `sqlRoleAssignments: [{ principalId: funcApp.MI, roleDefinitionId: '00000000-0000-0000-0000-000000000002' }]` (Cosmos DB Built-in Data Contributor)
- `backupStorageRedundancy: 'Local'` (dev/test cost savings)
- `diagnosticSettings: [{ workspaceResourceId: logAnalytics }]`

### Scenario 16 -- AI Chatbot: OpenAI + AI Search + Web Apps

**Architecture:** Streamlit frontend + Flask backend API. RAG pattern: AI Search → Storage → OpenAI (GPT-4o). Entra ID Easy Auth + FIC, On-Behalf-Of token exchange, shared private links.

**Components:**

| Component | AMAVM Module | Purpose |
|---|---|---|
| Azure OpenAI | `br/amavm:res/cognitive-services/account` | GPT-4o deployment, kind: OpenAI, S0 SKU |
| AI Search | `br/amavm:res/search/search-service` | Knowledge base index, shared private links |
| Web App (frontend) | `br/amavm:res/web/site` | Streamlit UI, Entra ID Easy Auth, UAMI |
| Web App (backend) | `br/amavm:res/web/site` | Flask API, OBO token exchange, UAMI |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Linux, P1V3 (separate for front/back) |
| Storage Account | `br/amavm:res/storage/storage-account` | Blob + Table, AI Search data source |
| Managed Identity (x2) | `br/amavm:res/managed-identity/user-assigned-identity` | Front UAMI + Back UAMI |
| VNet + Subnets (x3) | `br/amavm:res/network/virtual-network/subnet` | PE + 2 app egress subnets |
| NSG + Route Table | `br/amavm:res/network/network-security-group` + `route-table` | Network controls |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Central logging |
| App Insights | `br/amavm:res/insights/component` | APM telemetry |
| App Registration (x2) | `modules/appregistration.bicep` (local) | Entra ID app registrations + FIC |
| Storage RBAC | `modules/rbac.bicep` (local) | Cross-service role assignments on storage |

**Key architectural patterns validated:**
- RAG pattern: AI Search → Storage (blob/table) → OpenAI (chat completions with context)
- Entra ID Easy Auth + FIC: Frontend uses federated identity credentials
- On-Behalf-Of flow: Backend exchanges user token for ARM/service tokens
- Shared Private Links: AI Search connects to Storage and OpenAI (requires manual approval)
- Microsoft Graph Bicep: `extension microsoftGraphV1` for declarative Entra ID resources
- Multi-UAMI: Separate managed identities for frontend and backend

**Local modules that remain (cannot migrate to AMAVM):**
- `modules/appregistration.bicep` -- uses `microsoftGraphV1` Bicep extension; no AMAVM equivalent
- `modules/rbac.bicep` -- circular dependency prevents inlining (see lessons.md rule 22)

**Migration notes:**
- Naming module: uses `br/amavm:utl/amavm/naming:0.1.0` (preferred approach -- older scenarios use local `../../modules/infra/naming.bicep`)
- Fixed deprecated VNet routing params → `outboundVnetRouting` (both web apps)
- Parameterized hardcoded values (owner OIDs, department, environmentId, applicationId)

### Scenario 17 -- Static Web App + Function API Backend

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

---

## P2 -- AMAVM Module Coverage Matrix

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

**Still indirectly covered only (consumed as child modules):**
- `insights/*` monitoring utilities (action-group, metric-alert, webtest, etc.)
- `network/private-endpoint` -- consumed inline by parent modules
- `network/virtual-network` -- scenarios reference existing VNets

---

## P2.5 -- RBAC Enforcement Audit (completed scenarios)

| Scenario | Resource | Auth Method | Status |
|---|---|---|---|
| 1 | SQL, KV, Storage | MI RBAC | Compliant -- system MI + UAMI for SQL, no keys |
| 2 | Cosmos DB, KV, Storage | MI RBAC (`disableLocalAuth: true`) | Fixed -- added disableLocalAuth + disableKeyBasedMetadataWriteAccess + roleAssignments |
| 3 | Logic App, Storage | Connection string (Logic App exception) | Verified -- keys in KV, UAMI for KV access, documented exception |
| 4 | Event Hub, KV, Storage | MI RBAC (`disableLocalAuth: true`) | Confirmed -- separate RBAC modules |
| 5 | App Gateway, Web Apps, Storage | MI RBAC | Mostly compliant -- FuncApp MI → KV, Storage `allowSharedKeyAccess: false` |
| 7 | ACR, Logic App, Storage | Mixed (Logic App exception) | Verified -- ACR RBAC via helper, Logic App exception same as S3 |
| 9 | AKS, ACR, Storage | MI RBAC | Fixed -- uncommented `allowSharedKeyAccess: false` on storage |
| 10 | Data Factory, Databricks, Storage | MI RBAC | Verified -- ADF MI + RBAC on storage; SHIR keys in KV (platform exception) |
| 11 | Web Apps, SQL, Storage | MI RBAC | Fixed -- SQL connection string now uses `Authentication=Active Directory Default` |
| 13 | Redis | MI RBAC (`disableAccessKeyAuthentication: true`) | Built with Entra auth |
| 14 | Event Hub, Function App | MI RBAC (`disableLocalAuth: true`) | Built with Entra auth |
| 15 | Cosmos DB | MI RBAC (`disableLocalAuthentication: true`) | Built with Entra auth |
| 16 | OpenAI, AI Search, Storage | UAMI RBAC + FIC | Verified -- full RBAC, federated identity credentials, no keys |

---

## P2.9 -- Test Concurrency & Scheduling (full design)

### Problem

All scenarios deploy subnets into **shared VNets**. Azure Resource Manager serializes operations on a VNet -- if two scenarios create/delete subnets in the same VNet simultaneously, ARM returns conflict errors. Current pipelines rely on 1-hour time staggering with **no concurrency locks**. With 17 scenarios this approach breaks down.

### Current State

**VNet topology** -- 4 shared VNets (2 per env type):

| VNet | Env Type | Env IDs | Address Space | Scenarios |
|---|---|---|---|---|
| VNet-A-DEV | DEV | ENV23968 | `10.238.18.0/24` | 1, 2, 3, 4, 5, 7 |
| VNet-B-DEV | DEV | ENV23969 | `10.238.19.0/24` | 8, 9, 10, 11, 12 |
| VNet-A-TST | TST | ENV23978 | `10.238.64.0/24` | 1, 2, 3, 4, 5, 7 |
| VNet-B-TST | TST | ENV23979 | `10.238.65.0/24` | 8, 9, 10, 11, 12 |

**Concurrency rule**: Scenarios sharing a VNet form a **concurrency group** -- only one can be deploying or tearing down at a time.

**Current scheduling** (bi-weekly, 1st + 15th of month):

| Hour (UTC) | Group A (VNet-A) | Group B (VNet-B) |
|---|---|---|
| 01:00 | S1 | -- |
| 02:00 | S2 | -- |
| 03:00 | S3 | -- |
| 04:00 | S4 | -- |
| 05:00 | S5 | -- |
| 07:00 | S7 | -- |
| 08:00 | -- | S8 |
| 09:00 | -- | S9 |
| 10:00 | -- | S10 |
| 11:00 | -- | S11 |
| 12:00 | -- | S12 |

### Address Space -- Solved by Exclusive Lock + Teardown

Since every pipeline always runs **deploy → teardown** and the exclusive lock ensures only one scenario uses a VNet at a time, subnets are always cleaned up before the next scenario starts. All scenarios in a group **reuse the same address space**.

Each group just needs a shared block large enough for the single largest scenario:
- **Group A**: Largest is S5 (App Gateway, 3 subnets) -- needs /26
- **Group B**: Largest is S9 (AKS, 4 subnets including /25) -- needs /25

### Proposed Approach

#### 1. ADO Exclusive Lock per VNet

```yaml
# Each scenario pipeline uses its VNet's lock environment
- deployment: deployInfra
  environment: 'drcp-vnet-b-dev'     # exclusive lock -- queues if another run is active
  strategy:
    runOnce:
      deploy: ...
```

Create 4 ADO environments with `exclusivelock` check:
- `drcp-vnet-a-dev` (scenarios 1-5, 7)
- `drcp-vnet-b-dev` (scenarios 8-17)
- `drcp-vnet-a-tst` (scenarios 1-5, 7)
- `drcp-vnet-b-tst` (scenarios 8-17)

#### 2. Parallel groups to halve total runtime

Schedule both groups at the same start time. Each scenario takes ~20-30 min. With exclusive locks, the next auto-starts when the previous finishes. Total runtime drops from ~12 hours to ~3 hours per group.

#### 3. Rebalancing groups

Group B currently has 5 scenarios (8-12) plus all new scenarios (13-17) = 10 total. Group A has 6 (1-5, 7).
- Move S13 (Redis) and S15 (Cosmos) to Group A -- simple, fast-deploying scenarios
- Keep S14 (EVH), S16 (AI), S17 (SWA) in Group B
- Result: Group A = 8, Group B = 8 -- balanced ~4h each

### Environment Strategy

| Environment | Purpose | Policy Strictness | Used By |
|---|---|---|---|
| DEV (ENV23968/ENV23969) | Development + initial validation | Less restrictive -- allows engineer RBAC, conditional dev features | All scenarios (primary) |
| TST (ENV23978/ENV23979) | Policy compliance validation | Strict -- mirrors production policies, no dev shortcuts | Scenarios with nightly pipeline |

---

## Brainstorm: Function App Code Deployment via Bicep (full design)

### Problem

Currently all scenarios deploy infrastructure via Bicep and deploy app code separately via CI/CD pipeline. Explore deploying Function App code **during Bicep deployment time** via a dedicated helper module.

### Options Analyzed

| Option | Mechanism | DRCP OK? | Complexity |
|--------|-----------|:--------:|:----------:|
| A. MSDeploy Extension | `msDeployConfiguration.packageUri` on web/site | Yes | Low |
| B. WEBSITE_RUN_FROM_PACKAGE URL | App setting → blob URL, FA pulls at startup | Yes | Low |
| C. Deployment Script (az CLI) | `deploymentScripts` runs `az webapp deploy` | Partial (ACI networking) | Medium |
| D. Dedicated Helper Module | Wraps A or B with storage + RBAC | Yes | Medium |
| **E. Run From Package + MI** | `WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID` + blob URL | **Yes -- no SAS** | Low |

### Recommendation: Option E (Run From Package + MI) wrapped in Option D (Helper Module)

**Why:**
- **DRCP-compliant**: No shared keys, no SAS tokens -- MI-only access to blob
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

---

## Scenario 10 -- Detailed Policy Compliance & Unity Catalog Design

> Previously tracked in `scenario10/todo.md`. Open items moved to main `todo.md`.

### DRCP Policy Compliance Checklist

#### Databricks Policies (8 policies)

| Policy | Control | Requirement | Status |
|---|---|---|---|
| DatabricksPublicNetworkMustBeDisabled | drcp-adb-r01 | `publicNetworkAccess: 'Disabled'` | ✅ AMAVM default |
| DatabricksSupportedSKUs | drcp-adb-r02 | Only `premium` SKU allowed | ✅ AMAVM default |
| DatabricksVirtualNetworkInjection | drcp-adb-r03 | Must use VNet injection | ✅ Custom VNet params |
| DatabricksPublicIPMustBeDisabled | drcp-adb-r04 | `enableNoPublicIp: true` | ⚠️ Cluster-level, not Bicep |
| DatabricksPrivateDNSZones | drcp-adb-r05 | Private link DNS | ✅ PE configured |
| DatabricksInfrastructureEncryptionMustBeEnabled | drcp-adb-w10 | DBFS encryption | ✅ AMAVM default |
| DatabricksManagedResourceGroupName | drcp-adb-w22 | Name ends `-adbmanaged-rg` | ✅ Added |
| DatabricksPEPLServiceConnections_Inbound | drcp-sub-07 | No cross-sub PE | ✅ Same subscription |

#### Data Factory Policies (10 policies)

| Policy | Control | Requirement | Status |
|---|---|---|---|
| DataFactoryPublicNetworkAccessMustbeDisabled | drcp-adf-02 | `publicNetworkAccess: 'Disabled'` | ✅ |
| DataFactoryOnlySelfHostedIRisAllowed | drcp-adf-01 | Self-Hosted IR only | ✅ |
| DataFactoryLinkedServicesMustStoreSecretsInKeyVault | drcp-adf-04 | No inline secrets | ✅ KV-backed |
| DataFactoryLinkedServicesDontStoreSecretsConString | drcp-adf-04 | No secrets in conn strings | ✅ |
| DataFactoryLinkedServicesWhitelist | drcp-adf-05 | Approved types only | ✅ |
| DataFactoryRepoNotAllowed | drcp-adf-06 | No code repos | ⚠️ FAIL in dev (gitConfigureLater) |
| DataFactoryNonOrgRepoNotAllowed | drcp-adf-06 | No external repos | ✅ |
| DataFactoryPurviewIntegrationNotAllowed | drcp-adf-07 | No Purview | ✅ |
| DataFactoryPrivateDNSZones | drcp-sub-08 | Private link DNS | ✅ |
| DataFactoryPEPLServiceConnections_Inbound | drcp-sub-07 | No cross-sub PE | ✅ |

### DRCP-Compliant Unity Catalog Architecture

```
┌─────────────────────────────────────────────────┐
│ Databricks Workspace (Premium, VNet-injected)    │
│   ├── Unity Catalog Metastore                    │
│   │     └── External Location → ADLS Gen2        │
│   ├── Access Connector (system-assigned MI)       │
│   │     └── RBAC: Storage Blob Data Contributor   │
│   └── Private Endpoints (UI API + browser_auth)   │
├─────────────────────────────────────────────────┤
│ ADLS Gen2 Storage Account (Unity Catalog data)   │
│   ├── Private endpoint (dfs)                      │
│   ├── Hierarchical namespace enabled              │
│   ├── allowSharedKeyAccess: false                 │
│   └── RBAC: Access Connector MI → Blob Data Contributor │
├─────────────────────────────────────────────────┤
│ Key Vault (catalog secrets, access keys)          │
│   ├── Private endpoint                            │
│   ├── enableRbacAuthorization: true               │
│   └── RBAC: Access Connector MI → KV Secrets User │
└─────────────────────────────────────────────────┘
```

### UC Storage Account Implementation (completed)

```bicep
module storageAccountUc 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-adls-uc'
  params: {
    name: '${take(storageAccountName,23)}3'
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    enableHierarchicalNamespace: true
    publicNetworkAccess: 'Disabled'
    privateEndpoints: [{ subnetResourceId: subnetIn.outputs.resourceId, service: 'dfs' }]
    blobServices: {
      containers: [
        { name: 'unity-catalog' }
        { name: 'bronze' }
        { name: 'silver' }
        { name: 'gold' }
      ]
      diagnosticSettings: [{ workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId }]
    }
    diagnosticSettings: [{ workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId }]
    roleAssignments: [
      { principalId: accessConnectorMod.outputs.systemAssignedMIPrincipalId, principalType: 'ServicePrincipal', roleDefinitionIdOrName: 'Storage Blob Data Contributor' }
      { principalId: adf.outputs.principalId, principalType: 'ServicePrincipal', roleDefinitionIdOrName: 'Storage Blob Data Contributor' }
    ]
    tags: tags
  }
}
```

### UC Setup Script Design (for future implementation)

Post-deployment Databricks notebook (`setup-unity-catalog.py`):
1. Create metastore (account-level, one per region, platform team)
2. Create catalog + schemas: `drcp_data.{bronze,silver,gold}`
3. Create external location with Access Connector as storage credential
4. Create managed Delta table in bronze
5. Create external Delta table via external location
6. Verify: `SHOW CATALOGS`, `SHOW SCHEMAS`, `SHOW TABLES`

### central.bicep Migration (completed)

| Local module | AMAVM replacement | Status |
|---|---|---|
| `naming.bicep` | Keep local | KEEP |
| NSG | `br/amavm:res/network/network-security-group:0.1.0` | DONE |
| Route Table | `br/amavm:res/network/route-table:0.1.0` | DONE |
| Subnet | `br/amavm:res/network/virtual-network/subnet:0.2.0` | DONE |
| Log Analytics | `br/amavm:res/operational-insights/workspace:0.1.0` | DONE |
| Key Vault | `br/amavm:res/key-vault/vault:0.3.0` (inline PE/RBAC/diag) | DONE |
| Data Factory | `br/amavm:res/data-factory/factory:0.2.0` (inline PE/diag/IR) | DONE |
| KV PE | Inlined on Key Vault module | ELIMINATED |
| ADF PE | Inlined on ADF module | ELIMINATED |
| ADF IR | Inlined as `integrationRuntimes` param | ELIMINATED |
| RBAC | Keep local (`role-assignment.bicep`) | KEEP |
| SHIR | Keep local (`shir-auth.bicep`) | KEEP |
