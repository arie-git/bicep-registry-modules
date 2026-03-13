# Scenario 2 -- Function App + Cosmos DB (NoSQL)

Function App + Key Vault + Cosmos DB (Core/NoSQL API) + Storage Account, deployed with VNet integration and private endpoints.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Subnets (x3) | `br/amavm:res/network/virtual-network/subnet` | PE (x2), Function egress |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret storage |
| Cosmos DB | `br/amavm:res/document-db/database-account` | NoSQL database (SQL API) with inline DB + container |
| Application Insights | `br/amavm:res/insights/component` | Application monitoring |
| App Service Plan | `br/amavm:res/web/serverfarm` | Hosting for Function App |
| Function App | `br/amavm:res/web/site` (kind: functionapp) | Application compute |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing storage |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario2/infra/main.bicep \
  --name=drcptst0201 \
  --parameters environmentId=<ENV_ID>
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0201
```
