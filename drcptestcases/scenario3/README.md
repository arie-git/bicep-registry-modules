# Scenario 3 -- Event-Driven Function App + Logic App

Function App + Logic App (Standard) + Storage Account + Key Vault, deployed with VNet integration and private endpoints.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| Managed Identity | `br/amavm:res/managed-identity/user-assigned-identity` | Shared identity for Function App and Logic App |
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Subnets (x3) | `br/amavm:res/network/virtual-network/subnet` | PE, Function egress, Logic App egress |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret storage (storage keys) |
| Application Insights | `br/amavm:res/insights/component` | Application monitoring |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Hosting for Function App and Logic App |
| Function App | `br/amavm:res/web/site` (kind: functionapp) | Event processing |
| Logic App | `br/amavm:res/web/site` (kind: functionapp,workflowapp) | Workflow orchestration |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App and Logic App backing storage |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario3/infra/main.bicep \
  --name=drcptst0301 \
  --parameters environmentId=<ENV_ID>
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0301
```
