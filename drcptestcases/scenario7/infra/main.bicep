// bicep code to create infra for scenario 7

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
param applicationInstanceCode string = '0701' // in case if there are more than 1 application deployments (for example, in multiple environments)
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
@description('CIDR prefix for the virtual network. Needs a /26 prefix')
param networkAddressSpace string = ''
param engineersGroupObjectId string = ''

#disable-next-line no-unused-params
param engineersGroupName string = 'F-DRCP-${applicationId}-${environmentId}-Engineer-001-ASG'
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

param doDeployApp bool = false

@description('Application (client) ID of the Entra ID app registration for web app authentication.')
param authSettingApplicationId string = ''

@description('Client ID of the managed identity used for FIC assertion (OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID). For system-assigned MI, use the app\'s own client ID after first deployment.')
param authSettingMiClientId string = ''

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

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

module names 'br/amavm:utl/amavm/naming:0.1.0' = {
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
// Networking
//  - NSG
//  - Subnets
//
// --------------------------------------------------

// create NSG
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    location: vNet.location
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
    tags: mytags
  }
}

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

var subnetsConfig = [
  {
    // subnet for all components via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0) //https://gist.github.com/majastrz/bdd776addfa72c0719334996c0aa78f5
    nameIndex: 'In'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: []
    delegations: []
  }

  {
    // subnet for outgoing traffic from the Web App
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
]

@batchSize(1) // makes it run in sequence
module subnets 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [ for index in range(0,2) : {
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

var subnetPrivateEndpoints = subnets[0]

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
module applicationInsights 'br/amavm:res/insights/component:0.1.0' = { //'../../modules/infra/observability/application-insights/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    // diagnosticSettings: [
    //   {
    //     workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    //   }
    // ]
    // appInsightsKind: 'web'
    // appInsightsType: 'web'
    // tagProjectName: applicationInsightsName
    tags: mytags
  }
}


// ----------------------------------------------
//
//  Storage account
//
// ----------------------------------------------
// create storage account
var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccountMod 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    enableHierarchicalNamespace: false
    allowSharedKeyAccess: false
    blobServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    fileServices: {
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    tableServices: {
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    queueServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }

    roleAssignments: (isDevEnvironment) ? [
      {
        principalId:engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage File Data Privileged Contributor'
      }
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage Queue Data Contributor'
      }
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage Table Data Contributor'
      }
    ] : []
    privateEndpoints:[
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'blob'
      }
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'file'
      }
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'table'
      }
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'queue'
      }
    ]
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
  dependsOn: subnets // This prevents conflicting parallel operations on subnets and VNet
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
        subnetResourceId: subnets[0].outputs.resourceId
        tags: mytags
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
          principalId: webApp.outputs.systemAssignedMIPrincipalId
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User
          principalType: 'ServicePrincipal'
        }
      ]
    )
    tags: mytags
  }
}

// --------------------------------------------------
//
// Azure Container Registry
//
// --------------------------------------------------

// create ACR and assign RBAC to engineering group
var acrName = names.outputs.namingConvention['Microsoft.ContainerRegistry/registries']
var acrCacheRuleName = names.outputs.namingConvention['Microsoft.ContainerRegistry/registries/cacheRules']
module acr 'br/amavm:res/container-registry/registry:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-acr'
  params: {
    name: acrName
    location: vNet.location
    sku: 'Premium'
    roleAssignments: (isDevEnvironment) ? [
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: 'AcrDelete'
        principalType: 'Group'
      }
    ]: []
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
      }
    ]
    diagnosticSettings: [
      {
        logAnalyticsDestinationType: 'Dedicated'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    cacheRules: [
      {
        name: acrCacheRuleName
        sourceRepository: 'mcr.microsoft.com/dotnet/samples'
        targetRepository: 'samples'
      }
    ]
    tags: mytags
  }
}

// module agentpools '../../modules/infra/compute/container-registry/agent-pool.bicep' = {
//   scope: resourceGroup
//   name: '${deployment().name}-acr-pools'
//   params: {
//     acrName: acr.outputs.name
//     virtualNetworkSubnetResourceId: subnetPrivateEndpoints.outputs.resourceId
//   }
// }

// --------------------------------------------------
//
// Docker container in App Service
//
// --------------------------------------------------

// create app service plan
var hostingPlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlan 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan'
  params: {
    name: hostingPlanName
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

var dockerImage = 'samples:aspnetapp'

// create docker app on app service
var webAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module webApp 'br/amavm:res/web/site:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-wa'
  params: {
    name: webAppName
    location: vNet.location
    serverFarmResourceId: appServicePlan.outputs.resourceId
    kind: 'app,linux,container'
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnets[1].outputs.resourceId
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsights.outputs.resourceId
    authSettingApplicationId: authSettingApplicationId
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
      OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID: authSettingMiClientId
    }
    siteConfigurationAdditional: {
      linuxFxVersion: 'DOCKER|${acr.outputs.loginServer}/${dockerImage}'
    }
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    tags: mytags
    }
  }

// use app identity to grant access to read from the KeyVault
var appIdentity = webApp.outputs.systemAssignedMIPrincipalId

// use app identity to grant access to read from the ACR
// Separate helper module: acr ↔ webApp cycle prevents inline roleAssignments
// (acr needs webApp.MI for AcrPull, webApp needs acr.loginServer for Docker image)
module acrFuncAppRbac 'acrRoleAssignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-acr-webapp-rbac'
  params: {
    containerRegistryName: acr.outputs.name
    principalId: appIdentity
    principalType: 'ServicePrincipal'
    roleDefinitionId: '7f951dda-4ed3-4680-a7ca-43fe172d538d' // AcrPull
  }
}

// ------------------------
//
// Application deployment part. TODO move to a separate file
//
// ------------------------

// Use ACR to build and host an image
var acrTaskName = 'build-aznamingtool'
module acrDockerBuildTask '../../modules/infra/compute/container-registry/task.bicep' = if (doDeployApp) {
  scope: resourceGroup
  name: '${deployment().name}-acr-task'
  params: {
    acrName: acr.outputs.name
    name: acrTaskName
    location: acr.outputs.location
    dockerContextPath: 'https://github.com/mspnp/AzureNamingTool.git#master:src'
    dockerFilePath: 'Dockerfile'
    dockerImageName: dockerImage
    agentPoolName: ''
    doTaskRun: false
    enableTimeTrigger: true
  }
}

output keyvaultName string = keyVault.outputs.name
output functionAppName string = webApp.outputs.name
output functionAppPlanName string = appServicePlan.outputs.name
//output functions array = webApp.outputs.functions
