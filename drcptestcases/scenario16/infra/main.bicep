// bicep code to create infra for scenario chatbot

targetScope = 'subscription'

// general parameters
param location string = deployment().location
param tags object = {}

param deploymentId string = ''
#disable-next-line no-unused-params
param whatIf string = ''

// APG ServiceNow registrations
param applicationId string = 'AM-CCC'
param environmentId string = 'ENV24083'

// Parts used in naming convention
param namePrefix string = ''
@maxLength(2)
param organizationCode string = 's2' //TODO: split the defaults it into a central module ?
@maxLength(3)
param departmentCode string = 'c3'
param applicationCode string = 'drcpchat' // short application code we use in naming (not the one in Snow, that one is applicationId)
@maxLength(4)
param applicationInstanceCode string = '01' // in case if there are more than 1 application deployments (for example, in multiple environments)
param systemCode string = ''
@maxLength(2)
param systemInstanceCode string = ''
@allowed([
  'sbx'
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentType string = 'dev'

// System-specific parameters
@description('Network space for the subnets. Needs a /26 prefix.')
param networkAddressSpace string = ''
@description('Object ID of the group that will be assigned higher privileges in DEV.')
param engineersGroupObjectId string = '4ac8afa1-dfbc-4096-967c-4b0fba1f37f6'
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

@description('Deploy Azure AI Search service (requires manual approval for shared private links)')
param deploySearchService bool = false

@description('Deploy Entra ID app registrations (requires extra manual steps)')
param deployAppRegistration bool = false

@description('Object IDs of app registration owners (Entra ID users)')
param appOwnerObjectIds array = []

// var engineersGroupName = 'F-DRCP-${applicationId}-${environmentId}-Engineer-001-ASG'
// resource engineersGroup 'Microsoft.Graph/groups@v1.0' existing = {
//   uniqueName: engineersGroupName
// }
// var engineersGroupObjectId2 = engineersGroup.id

var mytags = union(tags, {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}'
  environmentType: environmentType
  contactEmail: engineersContactEmail
  deploymentPipelineId: deploymentId
})

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

// Call naming module
module namesMod 'br/amavm:utl/amavm/naming:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-names'
  params: {
    prefix: namePrefix
    organization: organizationCode
    department: departmentCode
    workload: '${applicationCode}${applicationInstanceCode}'
    role: systemCode
    roleIndex: systemInstanceCode
    environment: environmentType
    location: location
  }
}

// --------------------------------------------------
//
// Logging
//  - LogAnalytics workspace
//  - Application Insights
//
// --------------------------------------------------
var logAnalyticsWorspaceName = namesMod.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspaceMod 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-loganalytics'
  params: {
    name: logAnalyticsWorspaceName
    location: location
    tags: mytags
  }
}

var applicationInsightsName = namesMod.outputs.namingConvention['Microsoft.Insights/components']
module applicationInsightsMod 'br/amavm:res/insights/component:0.1.0' = { //'../../modules/infra/observability/application-insights/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]

    tags: mytags
  }
}

// --------------------------------------------------
//
// Networking
//  - NSG
//  - UDR
//  - Subnets
//
// --------------------------------------------------

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

module nsgMod 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: namesMod.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    diagnosticSettings:[
      {
        name: 'allCategories'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    location: vNet.location
    tags: mytags
  }
}

module udrMod 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: namesMod.outputs.namingConvention['Microsoft.Network/routeTables']
    location: vNet.location
    tags: mytags
  }
}

var subnetsName = namesMod.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var subnetsConfig = [
  {
    // subnet for incoming traffic via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'In'
    delegations: []
  }
 {
    // subnet for outgoing traffic from the Web App Frontend
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
    nameIndex: 'frontendOut'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: []
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
{
    // subnet for outgoing traffic from the Web App Backend
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
    nameIndex: 'frontendOut01'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: []
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
]

@batchSize(1) // makes it run in sequence
module subnetsMod 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [for index in range(0, 3): {
    scope: az.resourceGroup(vnetResourceGroupName)
    name: '${deployment().name}-subnet${index}'
    params: {
      virtualNetworkName: vnetName
      subnet: {
        name: '${subnetsName}-${subnetsConfig[index].nameIndex}'
        addressPrefix: subnetsConfig[index].addressPrefix
        networkSecurityGroupResourceId: nsgMod.outputs.resourceId
        routeTableResourceId: udrMod.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegations: subnetsConfig[index].delegations
      }
    }
  }
]

//required role assignments for foundry: https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/on-your-data-configuration#role-assignments
var subnetPrivateEndpoints = subnetsMod[0]
var cognitiveAccountName = namesMod.outputs.namingConvention['Microsoft.CognitiveServices/accounts']
module accountMod 'br/amavm:res/cognitive-services/account:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-csa'
  params: {
    //Currently allow kinds in DRCP: 'OpenAI' and 'TextAnalytics, the latter requires sku S0'
    kind: 'OpenAI'
    sku: 'S0'
    name: '${cognitiveAccountName}poc02'
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    customSubDomainName: '${cognitiveAccountName}02'
    roleAssignments: union(
    isDevEnvironment && !empty(engineersGroupObjectId) ? [
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: 'Cognitive Services Language Owner'
      }
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: 'Cognitive Services OpenAI Contributor'
      }
    ] : [],
    [
    {
      principalId: uamiModFront.outputs.principalId
      roleDefinitionIdOrName: 'Cognitive Services OpenAI User'
    }
    ])
    deployments: [
      {
        name: 'gpt-4o-dev'
        model: {
          format: 'OpenAI'
          name: 'gpt-4o'
          version: '2024-11-20'
        }
        sku: {
          name: 'Standard'
          capacity: 10
        }
      }
    ]
  tags: mytags
  }
}

var searchName = namesMod.outputs.namingConvention['Microsoft.Search/searchServices']
module searchMod 'br/amavm:res/search/search-service:0.1.0' = if (deploySearchService) {
  scope: resourceGroup
  name: '${deployment().name}-srch'
  params: {
    name: '${searchName}poc01'
    dataExfiltrationProtections: [
      'BlockAll'
    ]
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
      }
    ]
    roleAssignments: [
    {
      roleDefinitionIdOrName: 'Search Index Data Contributor'
      principalId: engineersGroupObjectId
      principalType: 'Group'
    }
    {
      roleDefinitionIdOrName: 'Search Index Data Reader'
      principalId: accountMod.outputs.systemAssignedMIPrincipalId
      principalType: 'ServicePrincipal'
    }
    {
      roleDefinitionIdOrName: 'Search Index Data Reader'
      principalId: uamiModFront.outputs.principalId
      principalType: 'ServicePrincipal'
    }
    {
      roleDefinitionIdOrName: 'Search Service Contributor'
      principalId: accountMod.outputs.systemAssignedMIPrincipalId
      principalType: 'ServicePrincipal'
    }
    ]
    networkRuleSet: {
      bypass: isDevEnvironment ? 'AzureServices' : null
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    sharedPrivateLinkResources: [
      { //just for testing, this one needs manual approval
        name: '${storageAccountName}-shrdplr-01'
        privateLinkResourceId: storageAccountMod.outputs.resourceId
        groupId: 'blob'
        requestMessage: 'Manual approval required'
      }
      { //just for testing, this one needs manual approval
        name: '${storageAccountName}-shrdplr-02'
        privateLinkResourceId: storageAccountMod.outputs.resourceId
        groupId: 'table'
        requestMessage: 'Manual approval required'
      }
      { //just for testing, this one needs manual approval
        name: '${cognitiveAccountName}-shrdplr-03'
        privateLinkResourceId: accountMod.outputs.resourceId
        groupId: 'openai_account'
        requestMessage: 'Manual approval required'
      }
    ]
  tags: mytags
  }
}

// create storage account
var storageAccountName = namesMod.outputs.namingConvention['Microsoft.Storage/storageAccounts']
var storageAccountBackendRoles = [
  'Storage Blob Data Owner'
  'Storage Table Data Contributor'
]
var storageBlobContainerName = namesMod.outputs.namingConvention['Microsoft.Storage/storageAccounts/blobServices/containers']
module storageAccountMod 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    roleAssignments: [ for role in ((isDevEnvironment) ? storageAccountBackendRoles : [] ): {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: role
    }]
    privateEndpoints:[
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'blob'
      }
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'table'
      }
    ]
    blobServices:{
      containers:[
        {
          name: storageBlobContainerName
        }
      ]
    }
    tableServices: {
      tables: [
        {
          name: 'table1'
        }
      ]
    }
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

module storageBlobBySearch 'modules/rbac.bicep' = if (deploySearchService) {
  scope: resourceGroup
  name: '${deployment().name}-sta-search-rbac'
  params: {
    resourceName: storageAccountMod.outputs.name
    principals: [
      {
        objectId: searchMod.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
      {
        objectId: accountMod.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
    roleDefinitionIdOrName: 'Storage Blob Data Contributor'
  }
}

module storageTableBySearch 'modules/rbac.bicep' = if (deploySearchService) {
  scope: resourceGroup
  name: '${deployment().name}-sta-search-table-rbac'
  params: {
    resourceName: storageAccountMod.outputs.name
    principals: [
      {
        objectId: searchMod.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]
    roleDefinitionIdOrName: 'Storage Table Data Contributor'
  }
}

// --------------------------------------------------
//
// Docker container in App Service
//
// --------------------------------------------------

var uamiName = namesMod.outputs.namingConvention['Microsoft.ManagedIdentity/userAssignedIdentities']
module uamiModFront 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami-front'
  params:{
    name: uamiName
  }
}

module uamiModBack 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami-back'
  params:{
    name: '${uamiName}01'
  }
}

// create Web app service plan
var hostingPlanName = namesMod.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlanFront 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan-front'
  params: {
    name: hostingPlanName
    location: vNet.location
    kind: 'Linux'
    skuName: 'P1V3'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

// create Web app service plan
module appServicePlanBack 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan-back'
  params: {
    name: '${hostingPlanName}01'
    location: vNet.location
    kind: 'Linux'
    skuName: 'P1V3'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: mytags
  }
}


var issuer = '${environment().authentication.loginEndpoint}${tenant().tenantId}/v2.0'

module appRegistrationFront 'modules/appregistration.bicep' = if (deployAppRegistration) {
  name: '${deployment().name}-appreg-front'
  scope: resourceGroup
  params: {
    ownerObjectIds: appOwnerObjectIds
    clientAppName: '${webAppFrontName}-entra-client-app'
    clientAppDisplayName: '${webAppFrontName} Front End App Registration'
    webAppName: webAppFrontName
    webAppIdentityId: uamiModFront.outputs.principalId
    issuer: issuer
    resourceAccessConfiguration: [
      {
        resourceAppId: '00000003-0000-0000-c000-000000000000'
        resourceAccess: [
          { id: 'e1fe6dd8-ba31-4d61-89e7-88639da4683d', type: 'Scope' } // User.Read
          { id: '37f7f235-527c-4136-accd-4a02d197296e', type: 'Scope' } // openid
          { id: '14dad69e-099b-42c9-810b-d002981feec1', type: 'Scope' } // profile
          { id: '7427e0e9-2fba-42fe-b0c0-848c9e6a8182', type: 'Scope' } // offline_access
        ]
      }
      {
        resourceAppId: '797f4846-ba00-4fd7-ba43-dac1f8f63013'
        resourceAccess: [
          { id: '41094075-9dad-400e-a0bd-54e686782033', type: 'Scope' } //ASM User_impersonation
        ]
      }
      {
        resourceAppId: appRegistrationBack.outputs.clientAppId
        resourceAccess: [
          { id: guid('${webAppBackName}-access_as_user'), type: 'Scope' }
        ]
      }
    ]
  }
}

module appRegistrationBack 'modules/appregistration.bicep' = if (deployAppRegistration) {
  name: '${deployment().name}-appreg-back'
  scope: resourceGroup
  params: {
    ownerObjectIds: appOwnerObjectIds
    clientAppName: '${webAppBackName}-entra-client-app'
    clientAppDisplayName: '${webAppBackName} Back End App Registration'
    webAppName: webAppBackName
    webAppIdentityId: uamiModBack.outputs.principalId
    issuer: issuer
    resourceAccessConfiguration: [
          {
            resourceAppId: '797f4846-ba00-4fd7-ba43-dac1f8f63013'
            resourceAccess: [
              { id: '41094075-9dad-400e-a0bd-54e686782033', type: 'Scope' } //ASM User_impersonation
            ]
          }
        ]
    // Define the scopes this API exposes
    oauth2PermissionScopesConfiguration: [
      {
        adminConsentDescription: 'Access Azure services on your behalf'
        adminConsentDisplayName: 'Access as user'
        id: guid('${webAppBackName}-access_as_user') // Stable GUID for the scope
        isEnabled: true
        type: 'User'
        userConsentDescription: null
        userConsentDisplayName: null
        value: 'access_as_user'
      }
    ]
  }
}

// create web apps on app service
var webAppName = namesMod.outputs.namingConvention['Microsoft.Web/sites']
var webAppFrontName = '${webAppName}01'
var webAppBackName = '${webAppName}02'

module webAppFront 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-wa-front'
  params: {
    name: webAppFrontName
    location: location
    serverFarmResourceId: appServicePlanFront.outputs.resourceId
    kind: 'app,linux'
    managedIdentities: {
      userAssignedResourceIds: [
        uamiModFront.outputs.resourceId
      ]
    }
    privateEndpoints: [
      {
        subnetResourceId: subnetsMod[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnetsMod[1].outputs.resourceId
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsightsMod.outputs.resourceId
   authSettingV2ConfigurationAdditional: deployAppRegistration ? {
      globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'RedirectToLoginPage'
      redirectToProvider: 'azureactivedirectory'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: appRegistrationFront.outputs.clientAppId
          clientSecretSettingName: 'OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID'
          openIdIssuer: issuer
        }
        validation: {
          allowedAudiences: [
            'api://${appRegistrationFront.outputs.clientAppId}'
          ]
          defaultAuthorizationPolicy: {
            allowedPrincipals: {}
            allowedApplications: [appRegistrationFront.outputs.clientAppId]
          }
          jwtClaimChecks: {}
            }
        login: {
          loginParameters: ['scope=openid email profile https://management.azure.com/user_impersonation']
        }
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
    } : {}
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      WEBSITE_RUN_FROM_PACKAGE: true
      OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID: uamiModFront.outputs.clientId
      AZURE_TENANT_ID: tenant().tenantId
      SCM_DO_BUILD_DURING_DEPLOYMENT: false
      ENABLE_ORYX_BUILD: false
      PYTHONPATH: '/home/site/wwwroot/.python_packages/lib/site-packages'
      AZURE_OPENAI_ENDPOINT: accountMod.outputs.endpoint
      AZURE_OPENAI_DEPLOYMENT: 'gpt-4o-dev'
      AZURE_OPENAI_API_VERSION: '2025-01-01-preview'
      AZURE_CLIENT_ID: uamiModFront.outputs.clientId
    }
    siteConfigurationAdditional: {
      linuxFxVersion: 'PYTHON|3.12'
    }
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    tags: tags
    }
}

module webAppBack 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-wa-back'
  params: {
    name: webAppBackName
    location: location
    serverFarmResourceId: appServicePlanBack.outputs.resourceId
    kind: 'app,linux'
    managedIdentities: {
      userAssignedResourceIds: [
        uamiModBack.outputs.resourceId
      ]
    }
    privateEndpoints: [
      {
        subnetResourceId: subnetsMod[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnetsMod[2].outputs.resourceId
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsightsMod.outputs.resourceId
    authSettingV2Configuration: deployAppRegistration ? {
      globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
      redirectToProvider: 'azureactivedirectory'
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        registration: {
          clientId: appRegistrationBack.outputs.clientAppId
          clientSecretSettingName: 'OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID'
          openIdIssuer: issuer
        }
        login: {
          loginParameters: [
            'scope=openid profile email offline_access'
          ]
        }
        validation: {
           allowedAudiences: [
              'api://${appRegistrationBack.outputs.clientAppId}'
              appRegistrationBack.outputs.clientAppId
            ]
        }
      }
    }
    login: {
      tokenStore: {
        enabled: true
      }
    }
  } : {}
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID: uamiModBack.outputs.clientId
      SCM_DO_BUILD_DURING_DEPLOYMENT: false
      WEBSITE_RUN_FROM_PACKAGE: true
      ENABLE_ORYX_BUILD: false
    }
    siteConfigurationAdditional: {
      linuxFxVersion: 'PYTHON|3.12'
    }
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    tags: tags
    }
  }
