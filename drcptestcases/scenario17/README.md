# Scenario 17 -- Static Web App + Function API

SPA frontend on Azure Static Web Apps (Standard SKU) with a linked Function App API backend. Validates the AMAVM `web/static-site` module's private endpoint, linked backend, and DRCP compliance.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| Static Web App | `br/amavm:res/web/static-site` | Standard SKU, PE, linked backend, no source control |
| Function App (API) | `br/amavm:res/web/site` | Linux Node.js API backend, MI, VNet integration |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux, S1 |
| Storage Account | `br/amavm:res/storage/storage-account` | Function backing storage (shared key disabled) |
| Key Vault | `br/amavm:res/key-vault/vault` | API config secrets |
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x2) | `br/amavm:res/network/virtual-network/subnet` | PE subnet + app egress subnet |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | APM telemetry |

## Architecture

- Static Web App serves the SPA frontend with `provider: 'None'` (pure Bicep deployment, no GitHub integration)
- Function App is linked as the API backend via the `linkedBackend` param
- Function App uses system-assigned MI for Key Vault access (Secrets User) and identity-based storage
- All PaaS resources use private endpoints on a dedicated PE subnet
- Function App routes all outbound traffic through VNet (`outboundVnetRouting`)

## DRCP Compliance

| Policy | Property | Value |
|---|---|---|
| drcp-swa-network | `publicNetworkAccess` | `'Disabled'` |
| drcp-swa-sku | `sku` | `'Standard'` (required for PE) |
| drcp-swa-pe | Private endpoint | Same subscription, `staticSites` service |
| drcp-swa-dns | Private DNS zone | Auto-deployed by DRCP policy |

## Deployment

### Prerequisites
- Azure subscription with DRCP guardrails
- VNet with available address space (`/27` minimum -- 2 x /28 subnets)
- ServiceNow environment ID

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario17/infra/main.bicep \
  --name=drcptst1701 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1701
```
