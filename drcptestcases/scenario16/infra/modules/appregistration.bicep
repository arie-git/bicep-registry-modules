
extension microsoftGraphV1

@description('Specifies the name of cloud environment to run this deployment in.')
param cloudEnvironment string = environment().name

@description('Audience URIs for public and national clouds')
param audiences object = {
  AzureCloud: {
    uri: 'api://AzureADTokenExchange'
  }
  AzureUSGovernment: {
    uri: 'api://AzureADTokenExchangeUSGov'
  }
  USNat: {
    uri: 'api://AzureADTokenExchangeUSNat'
  }
  USSec: {
    uri: 'api://AzureADTokenExchangeUSSec'
  }
  AzureChinaCloud: {
    uri: 'api://AzureADTokenExchangeChina'
  }
}

@description('Specifies the ID of the user-assigned managed identity.')
param webAppIdentityId string

@description('Specifies the unique name for the client application.')
param clientAppName string

@description('Specifies the display name for the client application.')
param clientAppDisplayName string

@description('Specifies the web app name for redirect URIs.')
param webAppName string

@description('Issuer for federated identity credentials.')
param issuer string

@description('Optional service management reference.')
param serviceManagementReference string = ''

@description('Array of required resource access objects (resourceAppId + resourceAccess[]).')
param resourceAccessConfiguration array = []

@description('Array of OAuth2 permission scopes this app exposes.')
param oauth2PermissionScopesConfiguration array = []

param knownClientApplicationsConfiguration array = []

@description('Owners to assign (AAD object IDs of users or service principals).')
param ownerObjectIds array = []

resource clientApp 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: clientAppName
  displayName: clientAppDisplayName
  signInAudience: 'AzureADMyOrg'
  serviceManagementReference: empty(serviceManagementReference) ? null : serviceManagementReference

  web: {
    redirectUris: [
      'http://localhost:50505/.auth/login/aad/callback'
      'https://${webAppName}.azurewebsites.net/.auth/login/aad/callback'
    ]
    implicitGrantSettings: {
      enableIdTokenIssuance: true
    }
  }

  api: {
    oauth2PermissionScopes: oauth2PermissionScopesConfiguration
    knownClientApplications: knownClientApplicationsConfiguration
  }

  requiredResourceAccess: resourceAccessConfiguration

  resource federatedIdentity 'federatedIdentityCredentials@v1.0' = {
    name: '${clientApp.uniqueName}/miAsFic'
    audiences: [
      audiences[cloudEnvironment].uri
    ]
    issuer: issuer
    subject: webAppIdentityId
  }
}

resource appOwnersUpdate 'Microsoft.Graph/applications@v1.0' = {
  uniqueName: clientAppName
  displayName: clientAppDisplayName
  owners: {
    relationships: ownerObjectIds
    // Optional:
    // relationshipSemantics: 'Reference'
  }

  dependsOn: [
    clientApp
  ]
}

resource clientAppUpdate 'Microsoft.Graph/applications@v1.0' = {
  displayName: clientAppDisplayName
  uniqueName: clientAppName
  signInAudience: 'AzureADMyOrg'
  identifierUris: [
    'api://${clientApp.appId}'
  ]
  api: clientApp.api
}

resource clientSp 'Microsoft.Graph/servicePrincipals@v1.0' = {
  appId: clientApp.appId
}

output clientAppId string = clientApp.appId
output clientSpId string = clientSp.id
