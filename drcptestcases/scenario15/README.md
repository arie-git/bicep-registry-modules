# Scenario 15 — Cosmos DB (NoSQL) Standalone

Cosmos DB account with inline SQL database and containers, Entra ID authentication, private endpoint, zone redundancy, and detailed diagnostics. Minimal scenario focused on the `document-db/database-account` AMAVM module with full DRCP compliance.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet | `br/amavm:res/network/virtual-network/subnet` | Private endpoint subnet |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Cosmos DB | `br/amavm:res/document-db/database-account` | NoSQL database with inline DB + containers |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario15/infra/main.bicep \
  --name=drcptst1501 \
  --parameters environmentId=<ENV_ID>
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1501
```
