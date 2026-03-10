# Scenario 14 — Event Hub + Function App (Event-Driven)

Event Hub namespace with inline hub and consumer group, consumed by a Function App via managed identity. Demonstrates event-driven architecture with VNet integration and full DRCP compliance.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnets (x2) | `br/amavm:res/network/virtual-network/subnet` | PE subnet + Function egress |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application monitoring |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing storage |
| Event Hub Namespace | `br/amavm:res/event-hub/namespace` | Event streaming with inline hub + consumer group |
| App Service Plan | `br/amavm:res/web/serverfarm` | Hosting for Function App |
| Function App | `br/amavm:res/web/site` (kind: functionapp) | Event Hub consumer |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario14/infra/main.bicep \
  --name=drcptst1401 \
  --parameters environmentId=<ENV_ID>
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1401
```
