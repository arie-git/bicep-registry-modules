# Scenario 14 — Event Hub + App Configuration + Function App (Event-Driven)

Event Hub namespace with inline hub and consumer group, consumed by a Function App via managed identity. App Configuration provides feature flags for toggling event processing without redeployment. Full DRCP compliance with private endpoints, Entra-only auth, and VNet integration.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| Event Hub Namespace | `br/amavm:res/event-hub/namespace` | Event streaming with inline hub + consumer group |
| App Configuration | `br/amavm:res/app-configuration/configuration-store` | Feature flags + config values, PE, Entra-only auth |
| Function App | `br/amavm:res/web/site` (kind: functionapp) | Event Hub consumer with App Config integration |
| App Service Plan | `br/amavm:res/web/serverfarm` | Linux hosting for Function App |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing storage |
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnets (x2) | `br/amavm:res/network/virtual-network/subnet` | PE subnet + Function egress |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application monitoring |

## Architecture

- Function App receives events from Event Hub using identity-based connection (`__fullyQualifiedNamespace`)
- App Configuration stores feature flags (`EnableEventProcessing`, `EnableDetailedLogging`) and config values (`EventProcessing:BatchSize`)
- Function App reads App Configuration via `AppConfigEndpoint` with `App Configuration Data Reader` RBAC
- Event Hub: `disableLocalAuth: true`, inline `eventhubs` with consumer group, PE on namespace
- App Configuration: `disableLocalAuth: true`, Standard SKU, PE on configuration store

## DRCP Compliance

| Policy | Property | Value |
|---|---|---|
| drcp-evh-01 | `publicNetworkAccess` | `'Disabled'` |
| drcp-evh-04 | `minimumTlsVersion` | `'1.2'` |
| drcp-evh-05 | `disableLocalAuth` | `true` |
| drcp-appconfig-auth | `disableLocalAuth` | `true` |
| drcp-appconfig-network | `publicNetworkAccess` | `'Disabled'` |
| drcp-appconfig-pe | Private endpoint | Same subscription |

## Deployment

### Prerequisites
- Azure subscription with DRCP guardrails
- VNet with available address space (`/27` minimum)
- ServiceNow environment ID

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario14/infra/main.bicep \
  --name=drcptst1401 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1401
```
