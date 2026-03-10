# Simple Azure OpenAI Chatbot - POC

A simplified proof-of-concept chatbot that demonstrates Azure OpenAI integration using Managed Identity and Easy Auth on Azure App Service.

## Architecture

- **Single-file Streamlit application** (`app.py`)
- **No backend API needed** - Streamlit connects directly to Azure OpenAI
- **Managed Identity** for authentication (no secrets in code)
- **Easy Auth** for user authentication (infrastructure-level auth)

## Features

- 🤖 Chat interface with Azure OpenAI
- 🔐 Easy Auth integration (displays authenticated user)
- 🔍 Debug panel showing environment and auth headers
- ✅ Local testing with `az login`
- 🚀 Simple deployment to Azure App Service

## Local Setup

### Prerequisites

- Python 3.9+
- Azure CLI (`az login`)
- Access to Azure OpenAI resource

### Installation

```bash
# Install dependencies
pip install -r requirements.txt

# Copy .env.example to .env and configure
cp .env.example .env

# Edit .env with your Azure OpenAI details
# - AZURE_OPENAI_ENDPOINT
# - AZURE_OPENAI_DEPLOYMENT
# - AZURE_OPENAI_API_VERSION (optional)
```

### Running Locally

```bash
# Make sure you're logged into Azure CLI
az login

# Run Streamlit
streamlit run app.py
```

The app will use your Azure CLI credentials to authenticate with Azure OpenAI.

## Azure Deployment

### 1. Create App Service

```bash
# Create resource group (if needed)
az group create --name my-resource-group --location eastus

# Create App Service plan
az appservice plan create \
  --name my-appservice-plan \
  --resource-group my-resource-group \
  --sku B1 \
  --is-linux

# Create web app (Python)
az webapp create \
  --name my-chatbot-app \
  --resource-group my-resource-group \
  --plan my-appservice-plan \
  --runtime "PYTHON:3.11"
```

### 2. Configure Managed Identity

```bash
# Enable system-assigned managed identity
az webapp identity assign \
  --name my-chatbot-app \
  --resource-group my-resource-group

# Get the identity principal ID
PRINCIPAL_ID=$(az webapp identity show \
  --name my-chatbot-app \
  --resource-group my-resource-group \
  --query principalId \
  -o tsv)

# Assign Azure OpenAI role to the managed identity
# Get your Azure OpenAI resource ID first
OPENAI_RESOURCE_ID="/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.CognitiveServices/accounts/<openai-name>"

# Assign Cognitive Services User role
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Cognitive Services User" \
  --scope $OPENAI_RESOURCE_ID
```

### 3. Configure App Settings

```bash
# Set environment variables
az webapp config appsettings set \
  --name my-chatbot-app \
  --resource-group my-resource-group \
  --settings \
    AZURE_OPENAI_ENDPOINT="https://your-openai-resource.openai.azure.com" \
    AZURE_OPENAI_DEPLOYMENT="gpt-4" \
    AZURE_OPENAI_API_VERSION="2024-02-15-preview"
```

### 4. Deploy Application

Option A: Using Zip Deploy

```bash
# Navigate to simple_chat directory
cd simple_chat

# Create zip file
zip -r app.zip . -x "*.pyc" "__pycache__/*" ".git/*"

# Deploy
az webapp deployment source config-zip \
  --name my-chatbot-app \
  --resource-group my-resource-group \
  --src app.zip
```

Option B: Using Local Git (simpler for development)

```bash
az webapp deployment source config-local-git \
  --name my-chatbot-app \
  --resource-group my-resource-group

# Copy the git URL and push
git remote add azure <git-url-from-previous-command>
git add .
git commit -m "Deploy to Azure"
git push azure main
```

### 5. Configure Streamlit Startup Command

```bash
# Set startup command
az webapp config set \
  --name my-chatbot-app \
  --resource-group my-resource-group \
  --startup-file "streamlit run app.py --server.port 8000"
```

### 6. Enable Easy Auth

```bash
# Enable Easy Auth with Azure AD
az webapp auth update \
  --name my-chatbot-app \
  --resource-group my-resource-group \
  --enabled true \
  --action LoginWithAzureActiveDirectory \
  --aad-client-id <your-frontend-app-client-id> \
  --aad-tenant-id <your-tenant-id>

# Or enable via Azure Portal for easier configuration
# Go to App Service -> Authentication -> Add identity provider
```

**Important for Easy Auth:**

1. In Azure Portal, go to your App Service
2. Navigate to **Authentication** blade
3. Click **Add identity provider**
4. Choose **Microsoft** (Azure Active Directory)
5. Select **Defaults** (creates a new registration automatically) or use existing
6. Set **Unauthenticated requests** to **"Redirect to identity provider"**
7. Save

The Streamlit app will now:
- Require users to authenticate before accessing
- Display authenticated user name from headers
- Use the App Service's Managed Identity for Azure OpenAI access

## Troubleshooting

### "Missing or invalid token" errors

- **Locally**: Run `az login` and verify you have access to the Azure OpenAI resource
- **Azure**: Ensure Managed Identity has Cognitive Services User role on the Azure OpenAI resource

### Easy Auth not working

- Check Authentication settings in Azure Portal
- Verify the token headers are present in the Debug Info panel
- Ensure you're not redirecting through a CDN or proxy that strips headers

### Deployment issues

- Check logs: `az webapp log tail --name my-chatbot-app --resource-group my-resource-group`
- Verify startup command is correct: `streamlit run app.py --server.port 8000`
- Make sure all dependencies are in requirements.txt

### Azure OpenAI not accessible

- Verify AZURE_OPENAI_ENDPOINT is correct
- Check that the deployment name matches exactly
- Ensure the managed identity (or local account) has proper RBAC permissions
- Verify the API version is compatible with your deployment

## Testing

1. Deploy to Azure
2. Access the URL (you should be redirected to login)
3. After login, you should see "Authenticated as: user@domain.com"
4. Open "Debug Info" to verify headers are present
5. Send a message and verify the response works

## Security Notes

- No secrets stored in code or environment variables
- Managed Identity handles authentication automatically
- Easy Auth provides user authentication at the infrastructure level
- The app runs under the App Service's context, not the user's context
- Users can access Azure OpenAI through the app, not directly

## Simplified vs Original Architecture

| Aspect | Original | Simplified (POC) |
|--------|----------|------------------|
| Backend API | Flask with OBO flow | None |
| Frontend | Streamlit with MSAL | Streamlit with Easy Auth |
| Auth Flow | MSAL → OBO → Azure APIs | Easy Auth (infrastructure) |
| Azure Access | User-delegated via OBO | Managed Identity (app-level) |
| Complexity | High (multiple apps, token exchange) | Low (single app, no token exchange) |
| Deployment | 2 separate deployments | 1 deployment |

This POC demonstrates that a chatbot can work with just:
- Managed Identity for Azure resource access
- Easy Auth for user authentication
- No complex token handling code