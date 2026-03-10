# Scenario 8 — Function Apps + Cosmos DB + APIM

Frontend and backend Function Apps with Cosmos DB data store, APIM gateway, and Storage Account. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| User-Assigned MI | `br/amavm:res/managed-identity/user-assigned-identity` | Cross-resource identity |
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x4) | `br/amavm:res/network/virtual-network/subnet` | PE, frontend egress, backend egress, APIM |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| Key Vault | `br/amavm:res/key-vault/vault` | Secret management |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Frontend + backend hosting |
| Function App (frontend) | `br/amavm:res/web/site` | HTTP API gateway consumer |
| Function App (backend) | `br/amavm:res/web/site` | Cosmos DB data processor |
| Storage Account | `br/amavm:res/storage/storage-account` | Function App backing + blob/file |

### Local modules (no AMAVM equivalent)

| Module | Purpose |
|---|---|
| Cosmos DB + PE + role-assignment | Pending migration to AMAVM `document-db/database-account` |
| APIM | Not a DRCP-whitelisted AMAVM component |
| Public IP | Blocked on AMAVM `network/public-ip-address` module |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario8/infra/main.bicep \
  --name=drcptst0801 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0801
```
