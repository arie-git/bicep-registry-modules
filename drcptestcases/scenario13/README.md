# Scenario 13 — Azure Cache for Redis (Premium)

Redis Premium cache with Entra ID authentication, private endpoint, zone redundancy, and diagnostics. Minimal scenario focused on the `cache/redis` AMAVM module with full DRCP compliance.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet | `br/amavm:res/network/virtual-network/subnet` | Private endpoint subnet |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Redis Cache | `br/amavm:res/cache/redis` | Premium cache with PE + Entra ID auth |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario13/infra/main.bicep \
  --name=drcptst1301 \
  --parameters environmentId=<ENV_ID>
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1301
```
