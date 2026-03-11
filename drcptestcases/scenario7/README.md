# Scenario 7 — App Service (Docker) + ACR

App Service running a Docker container from Azure Container Registry, with ACR Build Task for CI. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x2) | `br/amavm:res/network/virtual-network/subnet` | PE subnet + web egress subnet |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| Storage Account | `br/amavm:res/storage/storage-account` | General storage (shared key disabled) |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret management |
| Container Registry | `br/amavm:res/container-registry/registry` | Docker image hosting with cache rules |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux hosting for Web App |
| Web App | `br/amavm:res/web/site` | Docker container app (linux,container) |
| ACR Build Task | Local `task.bicep` | Builds Docker image from GitHub source |
| ACR Role Assignment | Local `acrRoleAssignment.bicep` | Breaks ACR ↔ Web App circular dependency |

## Architecture

- Web App pulls a Docker image from ACR (`AcrPull` RBAC via system-assigned MI)
- ACR Build Task (optional) builds the image from a GitHub repo on a schedule
- ACR ↔ Web App has a circular dependency: Web App needs ACR login server for the Docker image config, ACR needs Web App MI for AcrPull. Resolved via a separate `acrRoleAssignment.bicep` helper module.
- All resources use private endpoints on a dedicated PE subnet
- Web App routes all outbound traffic through VNet (`outboundVnetRouting`)

## Deployment

### Prerequisites
- Azure subscription with DRCP guardrails
- VNet with available address space (`/27` minimum — 2 x /28 subnets)
- ServiceNow environment ID

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
