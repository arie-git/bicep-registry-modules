# Scenario 10 -- Data Factory + Databricks + Unity Catalog

Azure Data Factory as data orchestrator with Databricks workspace for compute, ADLS Gen2 for data lake storage, and Unity Catalog for data governance. Includes 3 data pipelines (SQL-to-ADLS, FileShare-to-ADLS, staged copy) and Self-Hosted Integration Runtime for on-premises connectivity. Full DRCP compliance with private endpoints, managed identity, VNet injection, and diagnostics.

## Architecture

Two-tier deployment:

- **`main.bicep`** -- Application-level infrastructure: Databricks workspace (VNet-injected), ADF with linked services, ADLS data lake, UC storage, Access Connector, Key Vault, networking, diagnostics.
- **`central.bicep`** -- Central/shared infrastructure: ADF with Self-Hosted IR, Key Vault (SHIR auth keys), networking, Log Analytics. Deployed once per environment for shared IR access.
- **`src/DataPipeline*.bicep`** -- 3 ADF pipelines deployed as resource-group-scoped templates after infrastructure is in place.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Databricks NSG rules (worker-to-worker, webapp, SQL, storage, EventHub) |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x3) | `br/amavm:res/network/virtual-network/subnet` | PE, Databricks public, Databricks private |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Key Vault | `br/amavm:res/key-vault/vault` | Secrets, RBAC auth, PE, diagnostics |
| ADLS Gen2 | `br/amavm:res/storage/storage-account` | Primary data lake (HNS enabled, ADF MI RBAC) |
| Storage Account | `br/amavm:res/storage/storage-account` | Blob container + file share for ADF pipelines |
| UC Storage (ADLS Gen2) | `br/amavm:res/storage/storage-account` | Unity Catalog managed storage -- medallion containers |
| Databricks Workspace | `br/amavm:res/databricks/workspace` | Premium, VNet-injected, infrastructure encryption |
| Databricks Access Connector | `br/amavm:res/databricks/access-connector` | System-assigned MI for UC credential |
| Data Factory | `br/amavm:res/data-factory/factory` | ADF with SHIR, linked services, PE, diagnostics |

### Local modules (pending AMAVM migration)

| Module | Purpose |
|---|---|
| `role-assignment.bicep` | Cross-subscription RBAC for shared SHIR access |
| `integrationRuntime.bicep` | Linked Self-Hosted IR (non-dev environments) |

### Central infrastructure (`central.bicep`) -- AMAVM modules

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group:0.1.0` | Network security rules |
| Route Table | `br/amavm:res/network/route-table:0.1.0` | Custom routing |
| Subnet | `br/amavm:res/network/virtual-network/subnet:0.2.0` | PE subnet |
| Log Analytics | `br/amavm:res/operational-insights/workspace:0.1.0` | Centralized logging |
| Key Vault | `br/amavm:res/key-vault/vault:0.3.0` | SHIR auth keys, inline PE/RBAC/diagnostics |
| Data Factory | `br/amavm:res/data-factory/factory:0.2.0` | Central ADF with SHIR, inline PE/diagnostics |

### Central local modules

| Module | Purpose |
|---|---|
| `naming.bicep` | DRCP naming conventions (pending AMAVM migration) |
| `role-assignment.bicep` | RBAC for ADO service principals |
| `shir-auth.bicep` | Save SHIR authentication keys to Key Vault |

### Data Pipelines (`src/`)

| Pipeline | Pattern |
|---|---|
| DataPipeline1 | SQL Server to ADLS (JSON format) |
| DataPipeline2 | File Share to ADLS (binary copy) |
| DataPipeline3 | SQL Server to ADLS with blob staging |

## Unity Catalog Architecture

Unity Catalog (UC) is the recommended governance layer for Databricks. It replaces the legacy Hive metastore with centralized data governance, access control, and lineage tracking across workspaces.

### Infrastructure Components

```
Databricks Workspace (Premium, VNet-injected)
  |-- Unity Catalog Metastore
  |     \-- External Location --> ADLS Gen2
  |-- Access Connector (system-assigned MI)
  |     \-- RBAC: Storage Blob Data Contributor on UC storage
  \-- Private Endpoints (UI API + browser_auth)

ADLS Gen2 Storage Account (Unity Catalog data)
  |-- Private endpoint (dfs)
  |-- Hierarchical namespace enabled
  |-- allowSharedKeyAccess: false (RBAC only)
  \-- Containers: unity-catalog, bronze, silver, gold

RBAC Assignments on UC Storage
  |-- Access Connector MI --> Storage Blob Data Contributor
  \-- ADF MI --> Storage Blob Data Contributor
```

### Access Connector

The Databricks Access Connector (`res/databricks/access-connector`) provides a system-assigned managed identity that acts as the UC storage credential. This MI is the identity Unity Catalog uses to read and write managed tables and external locations in the UC storage account. No service keys or shared access signatures are involved -- all access is RBAC-based.

### UC Storage Account (Medallion Pattern)

A dedicated ADLS Gen2 storage account with hierarchical namespace, separate from the primary ADF data lake. Contains four containers:

| Container | Purpose |
|---|---|
| `unity-catalog` | UC metastore root -- managed tables stored here by default |
| `bronze` | Raw landing zone -- ingested data from source systems |
| `silver` | Cleansed and conformed -- typed, deduplicated, validated |
| `gold` | Business-level aggregates -- consumption-ready tables |

Configuration: `publicNetworkAccess: 'Disabled'`, `allowSharedKeyAccess: false`, private endpoint on `dfs` service, diagnostics to Log Analytics.

### RBAC Assignments

| Principal | Role | Target | Purpose |
|---|---|---|---|
| Access Connector MI | Storage Blob Data Contributor | UC Storage Account | UC reads/writes managed tables and external locations |
| ADF MI | Storage Blob Data Contributor | UC Storage Account | ADF pipelines write to medallion containers |
| ADF MI | Storage Blob Data Contributor | Primary ADLS | ADF pipelines read/write data lake |
| ADF MI | Storage Blob Data Contributor + File SMB Share Contributor | Backend Storage | ADF blob and file share operations |

### Managed Resource Group

The Databricks workspace uses a managed resource group with the naming convention `<resource-group-name>-adbmanaged-rg`, enforced by DRCP policy `drcp-adb-w22`. This is set via the `managedResourceGroupResourceId` parameter on the workspace module.

### ADF Linked Services

Five pre-configured linked services support pure Bicep pipeline deployment without Git integration:

| Linked Service | Type | Target |
|---|---|---|
| `ls_keyvault` | AzureKeyVault | Key Vault (secret references) |
| `ls_adls` | AzureBlobFS | Primary ADLS Gen2 data lake |
| `ls_blob` | AzureBlobStorage | Backend blob/file storage |
| `ls_adls_uc` | AzureBlobFS | UC ADLS Gen2 (medallion layers) |
| `ls_databricks` | AzureDatabricks | Databricks workspace (MSI auth) |

All linked services use managed identity authentication. No inline secrets or connection string credentials.

## DRCP Policy Compliance

### Databricks Policies (8 policies)

| Policy | Control | Requirement | Status |
|---|---|---|---|
| DatabricksPublicNetworkMustBeDisabled | drcp-adb-r01 | `publicNetworkAccess: 'Disabled'` | PASS (AMAVM default) |
| DatabricksSupportedSKUs | drcp-adb-r02 | Only `premium` SKU allowed | PASS (AMAVM default) |
| DatabricksVirtualNetworkInjection | drcp-adb-r03 | Must use VNet injection (custom VNet params) | PASS |
| DatabricksPublicIPMustBeDisabled | drcp-adb-r04 | `enableNoPublicIp: true` on cluster configs | N/A (workspace-level cluster policy, not a Bicep param) |
| DatabricksPrivateDNSZones | drcp-adb-r05 | Automated private link DNS for UI API endpoint | PASS (PE configured) |
| DatabricksInfrastructureEncryptionMustBeEnabled | drcp-adb-w10 | DBFS infrastructure encryption enabled | PASS (AMAVM default) |
| DatabricksManagedResourceGroupName | drcp-adb-w22 | Managed RG name must end with `-adbmanaged-rg` | PASS |
| DatabricksPEPLServiceConnections_Inbound | drcp-sub-07 | No cross-subscription private links | PASS |

### Data Factory Policies (10 policies)

| Policy | Control | Requirement | Status |
|---|---|---|---|
| DataFactoryPublicNetworkAccessMustbeDisabled | drcp-adf-02 | `publicNetworkAccess: 'Disabled'` | PASS |
| DataFactoryOnlySelfHostedIRisAllowed | drcp-adf-01 | Only Self-Hosted IR type allowed | PASS |
| DataFactoryLinkedServicesMustStoreSecretsInKeyVault | drcp-adf-04 | No inline secrets -- use KV references | PASS (MI auth on all linked services) |
| DataFactoryLinkedServicesDontStoreSecretsConString | drcp-adf-04 | No secrets in connection strings | PASS (MI auth, no connection strings) |
| DataFactoryLinkedServicesWhitelist | drcp-adf-05 | Only approved linked service types | PASS (AzureKeyVault, AzureBlobFS, AzureBlobStorage, AzureDatabricks) |
| DataFactoryRepoNotAllowed | drcp-adf-06 | No code repositories with ADF | PASS (gitConfigureLater: true in non-dev) |
| DataFactoryNonOrgRepoNotAllowed | drcp-adf-06 | No external Azure DevOps repos | PASS |
| DataFactoryPurviewIntegrationNotAllowed | drcp-adf-07 | No Purview integration | PASS |
| DataFactoryPrivateDNSZones | drcp-sub-08 | Automated private link DNS for ADF PE | PASS (PE configured) |
| DataFactoryPEPLServiceConnections_Inbound | drcp-sub-07 | No cross-subscription private links | PASS |

## Deployment

### Infrastructure (main.bicep)

```
az deployment sub create --location swedencentral \
  -f scenario10/infra/main.bicep \
  --name=drcpdev1002 \
  --parameters @scenario10/infra/parameters.json \
  --parameters location=swedencentral
```

### Central Infrastructure (central.bicep)

```
az deployment sub create --location swedencentral \
  -f scenario10/infra/central.bicep \
  --name=drcptst1001 \
  --parameters environmentId=<ENV_ID> \
  --parameters adfRepoConfig='{}'
```

### Data Pipelines

```
az deployment group create \
  --resource-group <rg> \
  --name drcpdev1002 \
  --template-file scenario10/src/DataPipeline1.bicep \
  --parameters adfName='<adf>' kvName='<kv>' adlsName='<adls>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcpdev1002
```

### Notes

- The Databricks workspace requires 3 subnets: PE, public (delegated), and private (delegated). Subnets are deployed sequentially due to Azure VNet locking.
- Unity Catalog metastore creation and catalog/schema setup are post-deployment steps. See `todo.md` Step 4 for the `setup-unity-catalog.py` notebook reference.
- The `drcp-adb-r04` policy (no public IP on clusters) is enforced via Databricks workspace cluster policies, not Bicep infrastructure params.
- Central ADF (`central.bicep`) deploys shared SHIR infrastructure. Application ADF (`main.bicep`) links to it in non-dev environments via `linkedIntegrationRuntime` and `masterAdfIr` params.
