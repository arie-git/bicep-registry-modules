# Scenario 4 — Event Hub Broker

Function App with two functions: one writes events to Event Hub, the other reads from Event Hub and writes to a Storage Account blob container. Deployed with VNet integration and private endpoints.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Subnets (x2) | `br/amavm:res/network/virtual-network/subnet` | PE, Function egress |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret storage |
| Event Hub Namespace | `br/amavm:res/event-hub/namespace` | Event streaming (inline hub + consumer group) |
| Application Insights | `br/amavm:res/insights/component` | Application monitoring |
| App Service Plan | `br/amavm:res/web/serverfarm` | Hosting for Function App |
| Function App | `br/amavm:res/web/site` (kind: functionapp) | Event processing |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing storage + event destination |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario4/infra/main.bicep \
  --name=drcptst0401 \
  --parameters environmentId=<ENV_ID>
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0401
```

## Application

To deploy the function app code:

```
cd src/eventHubFunctionApp
func azure functionapp publish <funcappname>
```

Test endpoint: `https://<funcappname>.azurewebsites.net/api/generateevents?param=testing21`
