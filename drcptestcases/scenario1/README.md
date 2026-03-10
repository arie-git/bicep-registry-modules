# Scenario 1 — Function App + Key Vault + SQL Database

Function App with Key Vault secret management and Azure SQL backend. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet | `br/amavm:res/network/virtual-network/subnet` | PE + egress subnets |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret management |
| Key Vault Secret | `br/amavm:res/key-vault/vault/secret` | SQL connection string |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing storage |
| User-Assigned MI | `br/amavm:res/managed-identity/user-assigned-identity` | Managed identity for SQL |
| SQL Server | `br/amavm:res/sql/server` | Azure SQL with PE + Entra auth |
| App Service Plan | `br/amavm:res/web/serverfarm` | Function App hosting |
| Function App | `br/amavm:res/web/site` | Application compute |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario1/infra/main.bicep \
  --name=drcptst0113 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0113
```
