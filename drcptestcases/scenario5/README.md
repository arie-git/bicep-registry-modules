# Scenario 5 -- Application Gateway (WAF)

Application Gateway as a Web Application Firewall with App Service and Function App backends. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG (x2) | `br/amavm:res/network/network-security-group` | PE + AppGw network rules |
| Route Table (x2) | `br/amavm:res/network/route-table` | PE + AppGw routing |
| Subnet (x3) | `br/amavm:res/network/virtual-network/subnet` | PE, egress, AppGw subnets |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| Key Vault | `br/amavm:res/key-vault/vault` | Certificate + secret management |
| App Service Plan | `br/amavm:res/web/serverfarm` | Hosting for web + function apps |
| Function App | `br/amavm:res/web/site` | Backend compute |
| Web App | `br/amavm:res/web/site` | Backend web application |
| Application Gateway | `br/amavm:res/network/application-gateway` | WAF + traffic routing |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing storage |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario5/infra/main.bicep \
  --name=drcpdev0501 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcpdev0501
```
