# Scenario 10 — Data Factory + Databricks + Unity Catalog

Azure Data Factory as data orchestrator with Databricks workspace for compute, ADLS Gen2 for data lake storage, and Unity Catalog for data governance. Includes 3 data pipelines (SQL-to-ADLS, FileShare-to-ADLS, staged copy) and Self-Hosted Integration Runtime for on-premises connectivity. Full DRCP compliance with private endpoints, managed identity, VNet injection, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x3) | `br/amavm:res/network/virtual-network/subnet` | PE, Databricks public, Databricks private |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Key Vault | `br/amavm:res/key-vault/vault` | Secrets + SHIR auth keys |
| ADLS Gen2 | `br/amavm:res/storage/storage-account` | Data lake (HNS enabled) |
| Storage Account | `br/amavm:res/storage/storage-account` | Blob + file share for pipelines |
| Databricks Workspace | `br/amavm:res/databricks/workspace` | Premium, VNet-injected compute |
| Databricks Access Connector | `br/amavm:res/databricks/access-connector` | MI bridge for UC storage access |

### Local modules (pending AMAVM migration)

| Module | Purpose |
|---|---|
| Data Factory | ADF with SHIR, git integration, PE |
| ADF Integration Runtime | Self-Hosted IR linked to central shared IR |
| ADF Role Assignment | RBAC for SHIR access cross-subscription |
| ADF Private Endpoint | PE for Data Factory |

### Data Pipelines (`src/`)

| Pipeline | Pattern |
|---|---|
| DataPipeline1 | SQL Server → ADLS (JSON) |
| DataPipeline2 | File Share → ADLS (binary) |
| DataPipeline3 | SQL Server → ADLS with blob staging |

## DRCP Policy Compliance

| Policy Group | Controls | Key Requirements |
|---|---|---|
| Databricks (8 policies) | drcp-adb-r01 to r05, w10, w22 | Premium SKU, VNet injection, no public IP, PE, infra encryption, managed RG naming |
| Data Factory (10 policies) | drcp-adf-01 to 07 | Self-hosted IR only, secrets in KV, whitelisted linked services, no public access, no repos |

See `scenario10/todo.md` for the full policy checklist and Unity Catalog implementation plan.

## Deployment

### Infrastructure

```
az deployment sub create --location swedencentral \
  -f scenario10/infra/main.bicep \
  --name=drcpdev1002 \
  --parameters @scenario10/infra/parameters.json \
  --parameters location=swedencentral
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
