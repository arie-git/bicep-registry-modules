# Scenario 10 — Data Factory + Databricks + Unity Catalog

## Current State

Scenario 10 has a two-tier Bicep structure:
- `main.bicep` — 6 active local refs + 11 AMAVM refs (Databricks, ADF, networking, storage)
- `central.bicep` — 11 active local refs + 0 AMAVM refs (100% local, shared/central ADF infra)
- `src/DataPipeline*.bicep` — 3 ADF pipelines (SQL→ADLS, FileShare→ADLS, SQL→ADLS staged)

---

## DRCP Policy Compliance Checklist

### Databricks Policies (8 policies)

| Policy | Control | Requirement | Status |
|---|---|---|---|
| DatabricksPublicNetworkMustBeDisabled | drcp-adb-r01 | `publicNetworkAccess: 'Disabled'` | [ ] Verify |
| DatabricksSupportedSKUs | drcp-adb-r02 | Only `premium` SKU allowed (denies standard/trial) | [ ] Verify |
| DatabricksVirtualNetworkInjection | drcp-adb-r03 | Must use VNet injection (custom VNet params) | [ ] Verify |
| DatabricksPublicIPMustBeDisabled | drcp-adb-r04 | `enableNoPublicIp: true` on cluster configs | [ ] Verify |
| DatabricksPrivateDNSZones | drcp-adb-r05 | Automated private link DNS for UI API endpoint | [ ] Verify |
| DatabricksInfrastructureEncryptionMustBeEnabled | drcp-adb-w10 | DBFS infrastructure encryption enabled | [ ] Verify |
| DatabricksManagedResourceGroupName | drcp-adb-w22 | Managed RG name must end with `-adbmanaged-rg` | [ ] Verify |
| DatabricksPEPLServiceConnections_Inbound | drcp-sub-07 | No cross-subscription private links | [ ] Verify |

### Data Factory Policies (10 policies)

| Policy | Control | Requirement | Status |
|---|---|---|---|
| DataFactoryPublicNetworkAccessMustbeDisabled | drcp-adf-02 | `publicNetworkAccess: 'Disabled'` | [ ] Verify |
| DataFactoryOnlySelfHostedIRisAllowed | drcp-adf-01 | Only Self-Hosted IR type allowed | [ ] Verify |
| DataFactoryLinkedServicesMustStoreSecretsInKeyVault | drcp-adf-04 | No inline secrets — use KV references | [ ] Verify |
| DataFactoryLinkedServicesDontStoreSecretsConString | drcp-adf-04 | No secrets in connection strings | [ ] Verify |
| DataFactoryLinkedServicesWhitelist | drcp-adf-05 | Only approved linked service types | [ ] Verify |
| DataFactoryRepoNotAllowed | drcp-adf-06 | No code repositories with ADF | [ ] Verify |
| DataFactoryNonOrgRepoNotAllowed | drcp-adf-06 | No external Azure DevOps repos | [ ] Verify |
| DataFactoryPurviewIntegrationNotAllowed | drcp-adf-07 | No Purview integration | [ ] Verify |
| DataFactoryPrivateDNSZones | drcp-sub-08 | Automated private link DNS for ADF PE | [ ] Verify |
| DataFactoryPEPLServiceConnections_Inbound | drcp-sub-07 | No cross-subscription private links | [ ] Verify |

---

## P0 — Unity Catalog Example (NEW)

Add a Unity Catalog (UC) configuration to the Databricks workspace. This helps teams understand how to set up UC with DRCP-compliant infrastructure. Unity Catalog is the recommended governance layer for Databricks — it replaces legacy Hive metastore with centralized data governance, access control, and lineage.

### What Unity Catalog Provides

- **Centralized governance**: Single place to manage data access across workspaces
- **Fine-grained access control**: Table/column-level permissions via Databricks SQL
- **Data lineage**: Automatic tracking of data flow across notebooks and jobs
- **Cross-workspace sharing**: Share data between workspaces without copying

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

### Implementation Tasks — Deployable Infrastructure

The goal is a fully deployable Unity Catalog setup that can be validated via `bicep build` and `az deployment sub create`. All Bicep resources below should be added to `main.bicep`.

#### Step 1: UC Storage Account (Bicep — deploy + validate)

- [x] **Add ADLS Gen2 storage account for Unity Catalog managed data** — `storageAccountUc` module in main.bicep
  ```bicep
  // Unity Catalog managed storage — separate from ADF operational storage
  module storageAccountUc 'br/amavm:res/storage/storage-account:0.2.0' = {
    scope: resourceGroup
    name: '${deployment().name}-adls-uc'
    params: {
      name: '${take(storageAccountName,23)}3'  // 3rd storage account in scenario
      location: location
      skuName: 'Standard_LRS'
      accessTier: 'Hot'
      allowSharedKeyAccess: false              // DRCP: RBAC only, no shared keys
      enableHierarchicalNamespace: true         // Required for Delta Lake / UC
      publicNetworkAccess: 'Disabled'           // DRCP: no public access
      privateEndpoints: [
        {
          subnetResourceId: subnetIn.outputs.resourceId
          service: 'dfs'                        // Data Lake endpoint for UC
        }
      ]
      blobServices: {
        containers: [
          { name: 'unity-catalog' }             // UC metastore root container
          { name: 'bronze' }                    // Medallion: raw landing zone
          { name: 'silver' }                    // Medallion: cleansed/conformed
          { name: 'gold' }                      // Medallion: business-level aggregates
        ]
        diagnosticSettings: [
          { workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId }
        ]
      }
      diagnosticSettings: [
        { workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId }
      ]
      // Access Connector MI gets Storage Blob Data Contributor
      // ADF MI also gets Storage Blob Data Contributor (for pipeline writes)
      roleAssignments: [
        {
          principalId: accessConnectorMod.outputs.systemAssignedMIPrincipalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        }
        {
          principalId: adf.outputs.principalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        }
      ]
      tags: tags
    }
  }
  ```
  - Validates: PE, no public access, HNS, RBAC-only auth, diagnostics
  - Access Connector MI gets `Storage Blob Data Contributor` — this is the identity UC uses to read/write managed tables
  - ADF MI also gets access so pipelines can write to medallion containers

#### Step 2: Access Connector RBAC (Bicep — deploy + validate)

- [x] **Verify Access Connector has system-assigned MI** — confirmed
  - AMAVM module creates system-assigned MI by default
  - `Storage Blob Data Contributor` assigned on UC storage via inline `roleAssignments` (Step 1)
  - ADF MI also assigned on UC storage for pipeline writes

#### Step 3: Databricks Workspace Policy Compliance (Bicep — verify)

- [x] **Verify workspace params against all 8 DRCP policies**
  - `customPrivateSubnetName` + `customPublicSubnetName` + `customVirtualNetworkResourceId` → VNet injection (drcp-adb-r03) ✓
  - `privateEndpoints` → PE for UI API (drcp-adb-r05) ✓
  - `defaultStorageFirewall: 'Enabled'` → DBFS firewall ✓
  - `publicNetworkAccess: 'Disabled'` → AMAVM default (drcp-adb-r01) ✓
  - `requireInfrastructureEncryption: true` → AMAVM default (drcp-adb-w10) ✓
  - `skuName: 'premium'` → AMAVM default (drcp-adb-r02) ✓
  - [x] `managedResourceGroupResourceId` added with `-adbmanaged-rg` suffix (drcp-adb-w22)
  - [ ] Cluster policies to enforce `enableNoPublicIp: true` (drcp-adb-r04) — workspace-level config, not Bicep param

#### Step 4: UC Setup Script (post-deployment — for teams)

- [ ] **Create `scenario10/src/setup-unity-catalog.py`** — Databricks notebook/script that teams run after infrastructure deploys
  ```python
  # Run in Databricks workspace after deployment
  # Requires: workspace admin + Access Connector configured as metastore credential

  # 1. Create metastore (account-level — one per region, done once)
  # This is typically done by the platform team via Databricks account console or API:
  #   POST /api/2.1/unity-catalog/metastores
  #   { "name": "drcp-swedencentral", "storage_root": "abfss://unity-catalog@<uc-storage>.dfs.core.windows.net/" }

  # 2. Create catalog + schemas (workspace-level)
  spark.sql("CREATE CATALOG IF NOT EXISTS drcp_data")
  spark.sql("CREATE SCHEMA IF NOT EXISTS drcp_data.bronze")
  spark.sql("CREATE SCHEMA IF NOT EXISTS drcp_data.silver")
  spark.sql("CREATE SCHEMA IF NOT EXISTS drcp_data.gold")

  # 3. Create external location (maps ADLS path to UC)
  # Requires the Access Connector as storage credential:
  #   POST /api/2.1/unity-catalog/storage-credentials
  #   { "name": "drcp-access-connector", "azure_managed_identity": { "access_connector_id": "<access-connector-resource-id>" } }
  #
  #   POST /api/2.1/unity-catalog/external-locations
  #   { "name": "drcp-bronze", "url": "abfss://bronze@<uc-storage>.dfs.core.windows.net/", "credential_name": "drcp-access-connector" }

  # 4. Create managed table (stored in metastore root)
  spark.sql("""
    CREATE TABLE IF NOT EXISTS drcp_data.bronze.employees (
      id INT, name STRING, age INT, place STRING
    ) USING DELTA
  """)

  # 5. Create external table (stored in bronze container via external location)
  spark.sql("""
    CREATE TABLE IF NOT EXISTS drcp_data.bronze.events (
      event_id STRING, timestamp TIMESTAMP, payload STRING
    ) USING DELTA
    LOCATION 'abfss://bronze@<uc-storage>.dfs.core.windows.net/events'
  """)

  # 6. Verify
  display(spark.sql("SHOW CATALOGS"))
  display(spark.sql("SHOW SCHEMAS IN drcp_data"))
  display(spark.sql("SHOW TABLES IN drcp_data.bronze"))
  ```
  - This script validates that the deployed infrastructure (storage + RBAC + PE) is correctly wired
  - Teams run it as a Databricks notebook after `az deployment sub create` completes
  - If UC queries fail, it means infrastructure deployment has gaps (wrong RBAC, PE not working, etc.)

#### Step 5: ADF Pipeline for UC Validation (Bicep — deploy + validate)

- [ ] **Add DataPipeline4.bicep** — ADF Databricks notebook activity that runs UC setup + validation
  - Linked service: AzureDatabricks (with Access Token from Key Vault, or MI-based)
  - Activity: Notebook activity pointing to `setup-unity-catalog.py`
  - Validates end-to-end: ADF → Databricks → UC → ADLS (via Access Connector MI)
  - DRCP policy: drcp-adf-04 (secrets in KV), drcp-adf-05 (AzureDatabricks is whitelisted linked service type)

- [ ] **Add DataPipeline5.bicep** — Medallion architecture: bronze → silver → gold
  - ADF orchestrates Databricks notebook activities for each layer
  - bronze: raw ingestion (existing DataPipeline1 writes here)
  - silver: cleansed/typed (Databricks notebook with Delta merge)
  - gold: business aggregates (Databricks notebook with Delta CTAS)
  - Validates UC table writes across the full medallion chain

#### Step 6: Validation

- [ ] `bicep build` on main.bicep with UC storage + RBAC additions
- [ ] `az deployment sub create --what-if` to validate all resources resolve
- [ ] Deploy and run `setup-unity-catalog.py` notebook — confirms RBAC, PE, UC wiring
- [ ] Run DataPipeline4 (ADF → Databricks → UC) — confirms end-to-end integration
- [ ] Check DRCP policy compliance via `/azure:azure-compliance` after deployment

---

## P1 — AMAVM Module Migration

### main.bicep — 6 local refs to migrate

| Local module | AMAVM replacement | Approach |
|---|---|---|
| `data-factory/main.bicep` | `br/amavm:res/data-factory/factory` | Replace |
| `data-factory/integrationRuntime.bicep` | `integrationRuntimes` param | Inline |
| `data-factory/modules/role-assignment.bicep` | `roleAssignments` param | Inline |
| `network/private-endpoint/main.bicep` (x3) | `privateEndpoints` param on parent | Inline |

- [ ] Migrate Data Factory to AMAVM `data-factory/factory`
- [ ] Replace PE helpers with inline `privateEndpoints` param
- [ ] Replace role-assignment helpers with inline `roleAssignments` param
- [ ] Validate `bicep build` passes

### central.bicep — 11 local refs to migrate

| Local module | AMAVM replacement | Status |
|---|---|---|
| `naming.bicep` | `br/amavm:utl/amavm/naming` | Migrate |
| NSG | `br/amavm:res/network/network-security-group` | Migrate |
| Route Table | `br/amavm:res/network/route-table` | Migrate |
| Subnet | `br/amavm:res/network/virtual-network/subnet` | Migrate |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Migrate |
| Key Vault | `br/amavm:res/key-vault/vault` | Migrate |
| Data Factory | `br/amavm:res/data-factory/factory` | Migrate |
| PE (x3) | `privateEndpoints` param | Inline |
| SHIR | Keep local (`shir-auth.bicep`) | N/A |

- [ ] Audit central.bicep local modules
- [ ] Migrate applicable modules to AMAVM
- [ ] Validate `bicep build` passes

---

## P2 — README Update

- [ ] Update README with Unity Catalog architecture
- [ ] Add DRCP policy compliance table
- [ ] Standardize to template format (components table, deploy/remove)

---

## P3 — Pipeline Updates

- [ ] Update DataPipeline1 to write to UC bronze table (not raw ADLS)
- [ ] Add DataPipeline4: bronze → silver transformation via Databricks notebook
- [ ] Add DataPipeline5: silver → gold aggregation
- [ ] Document medallion architecture pattern in README
