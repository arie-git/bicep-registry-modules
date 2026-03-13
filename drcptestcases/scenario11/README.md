# Scenario 11 -- Multi-Tier Web Application

Web App (ASP.NET UI) + Web App (ASP.NET API) + Key Vault + SQL Database. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| Naming | `br/amavm:utl/amavm/naming` | DRCP naming conventions |
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet | `br/amavm:res/network/virtual-network/subnet` | PE + egress subnets |
| Log Analytics (x2) | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret management |
| Key Vault Secret | `br/amavm:res/key-vault/vault/secret` | SQL connection string |
| Storage Account | `br/amavm:res/storage/storage-account` | Backing storage |
| User-Assigned MI | `br/amavm:res/managed-identity/user-assigned-identity` | Managed identity for SQL |
| SQL Server | `br/amavm:res/sql/server` | Azure SQL with PE + Entra auth |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Hosting for UI + API web apps |
| Web App (UI) | `br/amavm:res/web/site` | ASP.NET frontend |
| Web App (API) | `br/amavm:res/web/site` | ASP.NET backend API |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario11/infra/main.bicep \
  --name=drcptst1101 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1101
```
