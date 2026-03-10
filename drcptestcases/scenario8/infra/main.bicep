// bicep code to create infra for scenario 1

targetScope = 'subscription'

// general parameters
param location string = deployment().location
param tags object = {}
param deploymentId string = ''
#disable-next-line no-unused-params
param whatIf string = ''

// APG ServiceNow registrations
param applicationId string = 'AM-CCC'
param environmentId string

// Parts used in naming convention
param namePrefix string = ''
@maxLength(2)
param organizationCode string = 's2' //TODO: split the defaults it into a central module ?
@maxLength(3)
param departmentCode string = 'c3'
param applicationCode string = 'drcptst' // short application code we use in naming (not the one in Snow, that one is applicationId)
@maxLength(4)
param applicationInstanceCode string = '0801' // in case if there are more than 1 application deployments (for example, in multiple environments)
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
param networkAddressSpace string = ''
param engineersGroupObjectId string = ''
#disable-next-line no-unused-params
param engineersGroupName string = 'F-DRCP-${applicationId}-${environmentId}-Engineer-001-ASG'
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

param deployAPIM bool = false

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

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

module names '../../modules/infra/naming.bicep' = {
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

var uamiName = names.outputs.namingConvention['Microsoft.ManagedIdentity/userAssignedIdentities']
module uamiMod 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami'
  params:{
    name: uamiName
  }
}
// --------------------------------------------------
//
// Networking
//  - NSG
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

// create NSG
var nsgRules = [// https://learn.microsoft.com/en-us/azure/api-management/virtual-network-reference?tabs=stv2
  {
    name: 'Management_endpoint_for_Azure_portal_and_Powershell'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3443'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  {
    name: 'Azure_Infrastructure_Load_Balancer'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6390'
      sourceAddressPrefix: 'AzureLoadBalancer'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 130
      direction: 'Inbound'
    }
  }
  {
    name: 'Dependency_to_sync_Rate_Limit_Inbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '4290'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 140
      direction: 'Inbound'
    }
  }
  // OUTBOUND
  {
    name: 'Dependency_on_Azure_Storage'
    properties: {
      description: 'APIM service dependency on Azure blob and Azure table storage'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 120
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_on_Azure_SQL'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '1433'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Sql'
      access: 'Allow'
      priority: 130
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_for_Log_to_event_Hub_policy_and_monitoring_agent'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRanges: [
        '5671'
        '5672'
        '443'
      ]
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'EventHub'
      access: 'Allow'
      priority: 150
      direction: 'Outbound'
    }
  }
  {
    name: 'Dependency_To_sync_RateLimit_Outbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '4290'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 165
      direction: 'Outbound'
    }
  }
  {
    name: 'Publish_DiagnosticLogs_And_Metrics'
    properties: {
      description: 'API Management logs and metrics for consumption by admins and your IT team are all part of the management plane'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureMonitor'
      access: 'Allow'
      priority: 185
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
        '12000'
        '1886'
      ]
    }
  }
  {
    name: 'Connect_To_SMTP_Relay_For_SendingEmails'
    properties: {
      description: 'APIM features the ability to generate email traffic as part of the data plane and the management plane'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Internet'
      access: 'Allow'
      priority: 190
      direction: 'Outbound'
      destinationPortRanges: [
        '25'
        '587'
        '25028'
      ]
    }
  }
  {
    name: 'Authenticate_To_Azure_Active_Directory'
    properties: {
      description: 'Connect to Azure Active Directory for developer portal authentication or for OAuth 2 flow during any proxy authentication'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureActiveDirectory'
      access: 'Allow'
      priority: 200
      direction: 'Outbound'
      destinationPortRanges: [
        '80'
        '443'
      ]
    }
  }
  {
    name: 'Publish_Monitoring_Logs'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureCloud'
      access: 'Allow'
      priority: 300
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
        '12000'
      ]
    }
  }
  {
    name: 'Access_KeyVault'
    properties: {
      description: 'Allow API Management service control plane access to Azure Key Vault to refresh secrets'
      protocol: 'Tcp'
      sourcePortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'AzureKeyVault'
      access: 'Allow'
      priority: 350
      direction: 'Outbound'
      destinationPortRanges: [
        '443'
      ]
    }
  }
  // additional
  {
    name: 'Dependency_on_Azure_File_Share_for_GIT'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '445'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'Storage'
      access: 'Allow'
      priority: 170
      direction: 'Outbound'
    }
  }
  // Default
  {
    name: 'Deny_APIM_Internet_Outbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: 'Internet'
      access: 'Deny'
      priority: 999
      direction: 'Outbound'
    }
  }
]
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    location: vNet.location
    securityRules: nsgRules
    tags: mytags
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

// Create Route table
module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/routeTables']
    location: vNet.location
    routes: []
    tags: mytags
  }
}

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

// create subnets
var subnetsConfig = [
  {
    // subnet for all frontend  inbound via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0) //https://gist.github.com/majastrz/bdd776addfa72c0719334996c0aa78f5
    nameIndex: 'frontendIn'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    delegations: [] // no delegations
    serviceEndpoints: [// for APIM
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
      {
        service: 'Microsoft.EventHub'
      }
      {
        service: 'Microsoft.KeyVault'
      }
      {
        service: 'Microsoft.ServiceBus'
      }
      {
        service: 'Microsoft.AzureActiveDirectory'
      }
    ]
  }
  {
    // subnet for outgoing traffic from the Function App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
    nameIndex: 'frontendOut'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    serviceEndpoints: [] // no service endpoints
  }
  {
    // subnet for all frontend  inbound via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
    nameIndex: 'backendIn'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    delegations: [] // no delegations
    serviceEndpoints: [] // no service endpoints
  }
  {
    // subnet for outgoing traffic from the Function App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 3)
    nameIndex: 'backendOut'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
    serviceEndpoints: [] // no service endpoints
  }
]

@batchSize(1) // makes it run in sequence
module subnets 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [ for index in range(0,4) : {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet${index}'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-${subnetsConfig[index].nameIndex}'
      addressPrefix: subnetsConfig[index].addressPrefix
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: subnetsConfig[index].privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: subnetsConfig[index].privateLinkServiceNetworkPolicies
      delegations: subnetsConfig[index].delegations
      serviceEndpoints: subnetsConfig[index].serviceEndpoints
    }
  }
}]

// --------------------------------------------------
//
// Logging
//  - LogAnalytics workspace
//  - Application Insights
//
// --------------------------------------------------
var logAnalyticsWorspaceName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-loganalytics'
  params: {
    location: location
    name: logAnalyticsWorspaceName
    tags: mytags
  }
}

var applicationInsightsName = names.outputs.namingConvention['Microsoft.Insights/components']
module applicationInsights 'br/amavm:res/insights/component:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'docker'
    tags: tags
  }
}

// --------------------------------------------------
//
// KeyVault
//  - (potentially) used by app service in configuration
//
// --------------------------------------------------

// create keyvault and assign RBAC to engineering group
var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault 'br/amavm:res/key-vault/vault:0.3.0' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: keyVaultName
    enablePurgeProtection: !isDevEnvironment
    softDeleteRetentionInDays: 7
    networkAcls:{
      bypass: 'AzureServices'
    }
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-kv'
        location: vNet.location
        service: 'vault'
        subnetResourceId: subnets[2].outputs.resourceId
        tags: tags
      }
    ]
    diagnosticSettings: [
      {
        name: '${keyVaultName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    roleAssignments: union(
      isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'a4417e6f-fecd-4de8-b567-7b0420556985' // KeyVault Certificate Officer
          principalType: 'Group'
        }
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // KeyVault Admin
          principalType: 'Group'
        }
      ] : [],
      [
        {
          principalId: functionAppIdentityfe
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User
          principalType: 'ServicePrincipal'
        }
        {
          principalId: uamiMod.outputs.principalId
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User
          principalType: 'ServicePrincipal'
        }
      ]
    )
    tags: mytags
  }
  dependsOn: subnets // wait for all subnets to get created, otherwise there is a Put operation conflict
}

// ----------------------------------------------
//
// API Management
//
// ----------------------------------------------
var publicIpAddressName = names.outputs.namingConvention['Microsoft.Network/publicIPAddresses']
module publicIpAddress '../../modules/infra/network/public-ip-address/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-publicip'
  params: {
    name: publicIpAddressName // '${publicIpAddressName}-apim'
    sku: 'Standard'
    tier: 'Regional'
    publicIPAllocationMethod: 'Static'
    //zones: ['1','2','3']
    domainNameLabel: publicIpAddressName
    idleTimeoutInMinutes: 30
    location: location
    tags: mytags
  }
}

var apiManagementName = names.outputs.namingConvention['Microsoft.ApiManagement/service']

module apiManagement '../../modules/infra/integration/api-management/main.bicep' = if (deployAPIM) {
  scope: resourceGroup
  name: '${deployment().name}-apim'
  params: {
    name: apiManagementName
    location: location
    contactEmail: engineersContactEmail
    contactName: engineersGroupName
    sku: 'Developer'
    subnetResourceId: subnets[0].outputs.resourceId
    publicIpAddressId: publicIpAddress.outputs.id
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.resourceId
    tags: mytags
  }
}

// ----------------------------------------------
//
// Azure Function App (front end)
//
// ----------------------------------------------

// create function app
var hostingPlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServiceFrontend 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-asp-fe'
  params: {
    name: '${hostingPlanName}-fe'
    location: vNet.location
    kind: 'Windows'
    skuName: 'B1'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

// create function app
var functionAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionAppFrontend 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-functionapp-fe'
  params: {
    name: '${functionAppName}-fe'
    location: vNet.location
    kind: 'functionapp'
    serverFarmResourceId: appServiceFrontend.outputs.resourceId
    storageAccountResourceId: storageAccountBackend.outputs.resourceId
    privateEndpoints: [
      {
        subnetResourceId: subnets[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnets[1].outputs.resourceId

    diagnosticSettings: [
      {
        name: 'customSetting'
        logCategoriesAndGroups: [
          {
            category: 'FunctionAppLogs'
          }
          {
            category: 'AppServiceAuthenticationLogs'
          }
        ]
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsights.outputs.resourceId
    siteConfigurationAdditional: {
      cors: (isDevEnvironment) ? {
        allowedOrigins: [
          // to test functions from the azure portal
          'https://functions-next.azure.com'
          'https://functions-staging.azure.com'
          'https://functions.azure.com'
          'https://portal.azure.com'
          ]
          supportCredentials: false
        } : {}
    }
    // msDeployConfiguration: {
    //   packageUri: ''
    // }
    netFrameworkVersion:'v8.0'
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      // xxx value used in function, xxx__accountEndpoint (with two underscores) notation will use managed identity
      CosmosDbConnection__accountEndpoint: cosmosDbAccount.outputs.documentEndpoint
      SCM_DO_BUILD_DURING_DEPLOYMENT: true
    }
    tags: mytags
  }
}
// use app identity to grant access to read from the KeyVault
var functionAppIdentityfe = functionAppFrontend.outputs.systemAssignedMIPrincipalId

// grant function App write access to Cosmos DB
module cosmosDbAccountFuncFErbac '../../modules/infra/storage/cosmos-db/modules/role-assignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-account-funcfe-rbac'
  params: {
    resourceName: cosmosDbAccount.outputs.name
    principals: [
      {
        objectId: functionAppIdentityfe
      }
    ]
    rbacRole: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor // TODO: create a dictionary module
  }
}


// https://learn.microsoft.com/en-us/azure/azure-functions/functions-infrastructure-as-code?tabs=bicep
//

module functionAppFrontendFunctions '../../modules/infra/compute/function-app/function.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-functionapp-functions-fe'
  params: {
    functionAppName: functionAppFrontend.outputs.name
    functions: [
      {
        language: 'CSharp'
        name: 'HttpTrigger1'
        enabled: true
        files: {
          'frontend-dotnet.csproj': loadTextContent('../src/frontend-dotnet/frontend-dotnet.csproj')
          'host.json': loadTextContent('../src/frontend-dotnet/host.json')
          'HttpTrigger1.cs': loadTextContent('../src/frontend-dotnet/HttpTrigger1.cs')
        }
        config: {
          bindings: [
            {
              authLevel: 'anonymous'
              type: 'httpTrigger'
              direction: 'in'
              name: 'req'
            }
            {
              type: 'http'
              direction: 'out'
              name: '$return'
            }
          ]
          disabled: false
        }
      }
    ]
  }
}

// ----------------------------------------------
//
// Cosmos DB (backend end)
//
// ----------------------------------------------

// Cosmos DB
var cosmosDbAccountName = names.outputs.namingConvention['Microsoft.DocumentDB/databaseAccounts']
module cosmosDbAccount '../../modules/infra/storage/cosmos-db/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-account'
  params: {
    location: location
    name: cosmosDbAccountName
    periodicBackupStorageRedundancy: 'Local'
    backupPolicyType: 'Periodic'
    disableLocalAuthentication: true
    defaultConsistencyLevel: 'Session'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.resourceId
    objectId: (isDevEnvironment) ? engineersGroupObjectId : '' // engineers group has write access to the Cosmos DB in dev environment
    tags: mytags
  }
}

// CosmosDb Database and container
module cosmosSqlDb '../../modules/infra/storage/cosmos-db/apis/sql/sqldatabase.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-sqlapidb'
  params: {
    cosmosDbAccountName: cosmosDbAccount.outputs.name
    cosmosSqlDatabaseName: 'testdb'
  }
}
module cosmosSqlDbcontainer '../../modules/infra/storage/cosmos-db/apis/sql/container.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-container'
  params: {
    cosmosDbAccountName: cosmosDbAccount.outputs.name
    cosmosSqlDatabaseName: cosmosSqlDb.outputs.name
    containerName: 'testcnt'
    partitionKey: 'id'
  }
}

module cosmosSqlDbcontainer2 '../../modules/infra/storage/cosmos-db/apis/sql/container.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-container2'
  params: {
    cosmosDbAccountName: cosmosDbAccount.outputs.name
    cosmosSqlDatabaseName: cosmosSqlDb.outputs.name
    containerName: 'leases'
    partitionKey: 'id'
  }
}

// Cosmos DB private endpoint
module privateEndpointCosmosDb '../../modules/infra/network/private-endpoint/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-pep'
  params: {
    privateEndpointName: '${privateEndpointsName}-cosmos'
    location: location
    privateLinkResource: cosmosDbAccount.outputs.id
    subnet: subnets[2].outputs.resourceId
    targetSubResource: 'Sql'
    tags: tags
  }
  dependsOn: subnets
}

// ----------------------------------------------
//
// Azure Function App (backend end)
//
// ----------------------------------------------

// create function app plan
module appServicePlanBackend 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-asp-be'
  params: {
    name: '${hostingPlanName}-be'
    location: vNet.location
    kind: 'Linux'
    skuName: 'B1'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

// create function app
module functionAppBackend 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-functionapp-be'
  params: {
    name: '${functionAppName}-be'
    location: vNet.location
    kind: 'functionapp,linux'
    serverFarmResourceId: appServicePlanBackend.outputs.resourceId
    storageAccountResourceId: storageAccountBackend.outputs.resourceId
    // use uami to grant access to read from the KeyVault, this seems required when using keyvault reference in appsettings below
    keyVaultAccessIdentityResourceId: uamiMod.outputs.resourceId
    managedIdentities: {
      userAssignedResourceIds: [
        uamiMod.outputs.resourceId
        ]
    }
    privateEndpoints: [
      {
        subnetResourceId: subnets[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnets[3].outputs.resourceId

    diagnosticSettings: [
      {
        name: 'customSetting'
        logCategoriesAndGroups: [
          {
            category: 'FunctionAppLogs'
          }
          {
            category: 'AppServiceAuthenticationLogs'
          }
        ]
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsights.outputs.resourceId
    siteConfigurationAdditional: {
      cors: (isDevEnvironment) ? {
        allowedOrigins: [
          // to test functions from the azure portal
          'https://functions-next.azure.com'
          'https://functions-staging.azure.com'
          'https://functions.azure.com'
          'https://portal.azure.com'
          ]
          supportCredentials: false
        } : {}
    }
    netFrameworkVersion:'v8.0'
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      // xxx value used in function, xxx__accountEndpoint (with two underscores) notation will use managed identity
      CosmosDbConnection__accountEndpoint: cosmosDbAccount.outputs.documentEndpoint
      //SCM_DO_BUILD_DURING_DEPLOYMENT: true
      AzureWebJobsFeatureFlags: 'EnableWorkerIndexing' // this enables python v2 azure functions model
      AzureFiles_accountName: storageAccountBackend.outputs.name
      // TODO: check if KeyVault can be ditched.
      AzureFiles_accountKey: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.name};SecretName=${copyStorageKeyToKeyvault.outputs.keyVaultSecretName})'
      AzureFiles_shareName: storageBackendShareName
      SCM_DO_BUILD_DURING_DEPLOYMENT: true
      //PIP_EXTRA_INDEX_URL: 'https://nexus3.office01.internalcorp.net:8444/repository/pypi-proxy/packages/'
      //ENABLE_ORYX_BUILD: false
      //ORYX_SDK_STORAGE_BASE_URL: 'https://oryx-cdn.microsoft.io'
      //WEBSITE_DNS_SERVER: '10.250.2.134'
    }
    tags: mytags
    }
      dependsOn: [
      privateEndpointCosmosDb
    ]
}

// RBAC to Cosmos DB to create triggers
module cosmosDbAccountFuncBErbac '../../modules/infra/storage/cosmos-db/modules/role-assignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmosdb-funcbe-rbac'
  params: {
    resourceName: cosmosDbAccount.outputs.name
    principals: [
      {
        objectId: uamiMod.outputs.principalId
      }
    ]
    rbacRole: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor // TODO: create a dictionary module
  }
}
// RBAC to storage account share to store content

module staFuncAppRbac '../../modules/infra/storage/storage-account/modules/role-assignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-storage-funcappbe-1-rbac'
  params: {
    resourceName: storageAccountBackend.outputs.name
    principals: [
      {
        objectId: uamiMod.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ]
    roleDefinitionIdOrName: 'Storage Blob Data Contributor'
  }
}


module copyStorageKeyToKeyvault 'modules/copyStorageKeysToKeyvault.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-copy-stakey2keyvault'
  params: {
    keyVaultName: keyVault.outputs.name
    keyVaultSecretName: 'stakey1'
    storageAccountName: storageAccountBackend.outputs.name
  }
}

// ----------------------------------------------
//
//  Storage account with blob container and fileshare (backend)
//
// ----------------------------------------------

// create storage account
var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
var storageAccountBackendRoles = [
  'Storage Blob Data Contributor'
  'Storage File Data SMB Share Contributor'
  'Storage File Data Privileged Contributor'
]
var storageBackendShareName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts/fileServices/shares']
var storageBlobContainerName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts/blobServices/containers']
module storageAccountBackend 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    roleAssignments: [ for role in ((isDevEnvironment) ? storageAccountBackendRoles : [] ): {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: role
    }]
    privateEndpoints:[
      {
        subnetResourceId: subnets[0].outputs.resourceId
        service: 'file'
      }
    ]
    blobServices:{
      containers:[
        {
          name: storageBlobContainerName
        }
      ]
    }
    fileServices:{
      shares:[
        {
          name: storageBackendShareName
          shareQuota: 100
          accessTier: 'TransactionOptimized'
        }
      ]
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: tags
  }
  dependsOn: subnets
}


output keyvaultName string = keyVault.outputs.name
output apiManagementName string = (deployAPIM) ? apiManagement.outputs.name : ''
output functionAppFrontendName string = functionAppFrontend.outputs.name
output cosmosDbAccountName string = cosmosDbAccount.outputs.name
output functionAppBackendName string = functionAppBackend.outputs.name
output storageAccountName string = storageAccountBackend.outputs.name
