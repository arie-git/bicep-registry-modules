# Scenario 7 — App Service (Docker) + ACR + Logic App

App Service running a Docker container from Azure Container Registry, with Logic App, Storage Account, and Key Vault. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x3) | `br/amavm:res/network/virtual-network/subnet` | PE, web egress, Logic App subnets |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| User-Assigned MI | `br/amavm:res/managed-identity/user-assigned-identity` | Cross-resource identity |
| Storage Account | `br/amavm:res/storage/storage-account` | Blob + file storage |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret management |
| Container Registry | `br/amavm:res/container-registry/registry` | Docker image hosting with ACR Tasks |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Hosting for Web App + Logic App |
| Web App | `br/amavm:res/web/site` | Docker container app |
| Logic App | `br/amavm:res/web/site` | Workflow automation |

## Notes

- ACR ↔ Web App has a circular dependency (ACR needs Web App MI for AcrPull, Web App needs ACR login server). Cross-resource RBAC uses a separate helper module.
- Logic App uses connection strings (RBAC exception — no MI support for Logic App connectors).

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario7/infra/main.bicep \
  --name=drcptst0701 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0701
```
