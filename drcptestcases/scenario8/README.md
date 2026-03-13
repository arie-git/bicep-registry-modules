# Scenario 8 -- PostgreSQL + Service Bus (message-driven processing)

Function App with Service Bus trigger writing to PostgreSQL via managed identity. Demonstrates VNet-delegated PostgreSQL (not PE), Premium Service Bus with private endpoint, and identity-based connections throughout.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG | `br/amavm:res/network/network-security-group:0.1.0` | Network security rules |
| Route Table | `br/amavm:res/network/route-table:0.1.0` | Custom routing |
| Subnet (x3) | `br/amavm:res/network/virtual-network/subnet:0.2.0` | PE, Function App egress, PostgreSQL delegated |
| Log Analytics | `br/amavm:res/operational-insights/workspace:0.1.0` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component:0.1.0` | Application telemetry |
| Key Vault | `br/amavm:res/key-vault/vault:0.3.0` | Secret management |
| Storage Account | `br/amavm:res/storage/storage-account:0.2.0` | Function App backing storage |
| App Service Plan | `br/amavm:res/web/serverfarm:0.1.0` | Function App hosting |
| Function App | `br/amavm:res/web/site:0.1.0` | Service Bus trigger → PostgreSQL writer |
| PostgreSQL Flexible Server | `br/amavm:res/db-for-postgre-sql/flexible-server:0.1.0` | Relational data store (Entra-only, VNet-delegated) |
| Service Bus Namespace | `br/amavm:res/service-bus/namespace:0.1.0` | Message broker (Premium, PE, queue + topic) |

## DRCP Policy Compliance

### PostgreSQL (11 policies)

- Entra-only auth (`passwordAuth: Disabled`, `activeDirectoryAuth: Enabled`)
- VNet-delegated subnet with private DNS zone (not PE)
- Public network access disabled
- TLS 1.2+ enforced (`ssl_min_protocol_version: TLSv1.2`)
- SSL required (`require_secure_transport: ON`)
- Version 17 (policy requires >= 16)
- Zone-redundant HA
- Service-managed encryption (not CMK)
- Defender enabled

### Service Bus (5 policies)

- Local auth disabled (`disableLocalAuth: true`)
- Public network access disabled
- TLS 1.2 minimum
- Private endpoint in same subscription
- Auto DNS zone registration

## Architecture

```
Service Bus (Premium, PE)
    ↓ queue trigger (identity-based)
Function App (VNet-integrated)
    ↓ Entra token auth
PostgreSQL Flexible Server (VNet-delegated)
```

- **No shared keys or SAS tokens** -- all connections use managed identity
- **Service Bus trigger**: `ServiceBusConnection__fullyQualifiedNamespace` (identity-based)
- **PostgreSQL**: Entra AD administrator with token-based authentication

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
