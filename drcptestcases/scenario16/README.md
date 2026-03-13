# Scenario 16 -- AI Chatbot: Azure OpenAI + AI Search

RAG (Retrieval-Augmented Generation) chatbot with Streamlit frontend and Flask backend API. Uses Azure OpenAI (GPT-4o) for chat completions and AI Search for knowledge base retrieval. Entra ID Easy Auth with federated identity credentials (FIC) and On-Behalf-Of (OBO) token exchange. Full DRCP compliance with private endpoints, UAMI auth, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| Naming | `br/amavm:utl/amavm/naming` | DRCP naming conventions |
| NSG | `br/amavm:res/network/network-security-group` | Network security rules |
| Route Table | `br/amavm:res/network/route-table` | Custom routing |
| Subnet (x3) | `br/amavm:res/network/virtual-network/subnet` | PE + 2 app egress subnets |
| Log Analytics | `br/amavm:res/operational-insights/workspace` | Centralized logging |
| Application Insights | `br/amavm:res/insights/component` | Application telemetry |
| Azure OpenAI | `br/amavm:res/cognitive-services/account` | GPT-4o deployment (kind: OpenAI) |
| AI Search | `br/amavm:res/search/search-service` | Knowledge base index + shared private links |
| Storage Account | `br/amavm:res/storage/storage-account` | Blob + table for AI Search data source |
| User-Assigned MI (x2) | `br/amavm:res/managed-identity/user-assigned-identity` | Front + back UAMI |
| App Service Plan (x2) | `br/amavm:res/web/serverfarm` | Separate plans for front + back |
| Web App (frontend) | `br/amavm:res/web/site` | Streamlit UI with Entra ID Easy Auth |
| Web App (backend) | `br/amavm:res/web/site` | Flask API with OBO token exchange |

### Local modules (no AMAVM equivalent)

| Module | Purpose |
|---|---|
| `modules/appregistration.bicep` | Entra ID app registrations via `microsoftGraphV1` extension |
| `modules/rbac.bicep` | Multi-principal storage role assignments |

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario16/infra/main.bicep \
  --name=drcptst1601 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcptst1601
```

### Notes

- AI Search shared private links (to Storage + OpenAI) require manual approval in the DRCP portal after deployment.
- App registrations use the `microsoftGraphV1` Bicep extension -- may require special bicepconfig settings.
