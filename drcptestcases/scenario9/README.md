# Scenario 9 -- AKS + ACR + Application Gateway + Cosmos DB

Azure Kubernetes Service with Container Registry, Application Gateway ingress, and Cosmos DB backend. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| NSG (x4) | `br/amavm:res/network/network-security-group` | PE, AKS inbound, node pool, API subnets |
| Route Table (x4) | `br/amavm:res/network/route-table` | PE, AKS inbound, node pool, API routing |
| Subnet (x4) | `br/amavm:res/network/virtual-network/subnet` | PE, AKS inbound, node pool, API subnets |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Key Vault | `br/amavm:res/key-vault/vault` | AKS KMS encryption (optional) |
| Key Vault Key | `br/amavm:res/key-vault/vault/key` | AKS KMS key (optional) |
| Storage Account | `br/amavm:res/storage/storage-account` | Persistent storage |
| User-Assigned MI | `br/amavm:res/managed-identity/user-assigned-identity` | AKS control plane identity |
| AKS | `br/amavm:res/container-service/managed-cluster` | Kubernetes cluster |
| Container Registry | `br/amavm:res/container-registry/registry` | Docker image hosting |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario9/infra/main.bicep \
  --name=drcptst0901 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst0901
```
