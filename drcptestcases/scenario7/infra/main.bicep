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
var uamiName = names.outputs.namingConvention['Microsoft.ManagedIdentity/userAssignedIdentities']
module uamiMod 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami'
  params:{
    name: uamiName
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
    // subnet for outgoing traffic from the Function App
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
    // subnet for outgoing traffic from the Logic App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
    nameIndex: 'logicAppOut'
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
module subnets 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [ for index in range(0,3) : {
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
//  Storage account with blob container and fileshare
//
// ----------------------------------------------
var fileShareName = 'fshare'

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
    allowSharedKeyAccess: true //required for Logic App
    blobServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    fileServices: {
      shares:[
        {
        name: fileShareName
        shareQuota: 100
        accessTier: 'TransactionOptimized'
        }
      ]
      protocolSettings: {
        smb: {
          versions: 'SMB2.1;SMB3.0;SMB3.1.1'
          authenticationMethods: 'NTLMv2;Kerberos'
          kerberosTicketEncryption: 'RC4-HMAC;AES-256'
          channelEncryption: 'AES-128-CCM;AES-128-GCM;AES-256-GCM'
        }
      }
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
    tags: {
     UsedBy: 'LogicApp' //DRCP policy compliance
    }
  }
  dependsOn: subnets // This prevents conflicting parallel operations on subnets and VNet
}
module copyStorageKeyToKeyvault 'modules/copyStorageKeysToKeyvault.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-copy-stakey2keyvault'
  params: {
    keyVaultName: keyVault.outputs.name
    keyVaultSecretName: 'stakey1'
    storageAccountName: storageAccountMod.outputs.name
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
        {
          principalId: uamiMod.outputs.principalId
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

// create function app service plan
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
module webApp 'br/amavm:res/web/site:0.1.0' = {
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
    authSettingV2Configuration: {}
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: false
    }
    siteConfigurationAdditional: {
      linuxFxVersion: 'DOCKER|${acr.outputs.loginServer}/${dockerImage}'
    }
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    tags: mytags
    }
  }

// use app identity to grant access to read from the KeyVault
var appIdentity = webApp.outputs.systemAssignedMIPrincipalId

// use app identity to grant access to read from the ACR
module acrFuncAppRbac '../../modules/infra/compute/container-registry/modules/role-assignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-acr-webapp-rbac'
  params: {
    resourceName: acr.outputs.name
    principals: [
      {
        objectId: appIdentity
        principalType: 'ServicePrincipal'
      }
    ]
    roleDefinitionIdOrName: 'AcrPull'
  }
}


// ------------------------
//
// Logic app
//
// ------------------------

// create app service plan 2 for logic app
module appServicePlan2 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan2'
  params: {
    name: '${hostingPlanName}-002'
    location: vNet.location
    kind: 'Windows'
    skuName: 'WS1'
    skuCapacity: 1
    zoneRedundant: false
    targetWorkerCount: 3
    maximumElasticWorkerCount: 20
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

var logicAppName = names.outputs.namingConvention['Microsoft.Logic/workflows']
//Logic App
module logicApp 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-logicapp'
  params: {
      name: logicAppName
      location: vNet.location
      kind: 'functionapp,workflowapp'
      serverFarmResourceId: appServicePlan2.outputs.resourceId
      vnetRouteAllEnabled: true
      vnetContentShareEnabled: true
      enabled: true
      storageAccountResourceId: storageAccountMod.outputs.resourceId
      storageAccountUseIdentityAuthentication: false
      keyVaultAccessIdentityResourceId: uamiMod.outputs.resourceId
      logsConfiguration: {}
      managedIdentities: {
        userAssignedResourceIds: [
          uamiMod.outputs.resourceId
        ]
      }
      privateEndpoints: [
        {
          subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        }
      ]
      virtualNetworkSubnetId: subnets[2].outputs.resourceId
      diagnosticSettings: [
        {
          name: 'customSetting'
          logCategoriesAndGroups: [
            {
              category: 'FunctionAppLogs'
            }
            {
              category: 'WorkflowRuntime'
            }
          ]
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
      appInsightResourceId: applicationInsights.outputs.resourceId
      siteConfigurationAdditional: {
        vnetPrivatePortsCount: 2
        detailedErrorLoggingEnabled: true
        cors: (isDevEnvironment) ? {
          allowedOrigins: [
            'https://afd.hosting.portal.azure.net'
            'https://afd.hosting-ms.portal.azure.net'
            'https://hosting.portal.azure.net'
            'https://ms.hosting.portal.azure.net'
            'https://ema-ms.hosting.portal.azure.net'
            'https://ema.hosting.portal.azure.net'
            'https://ema.hosting.portal.azure.net'
            ]
          } : {}
      }
      appSettingsKeyValuePairs: {
        FUNCTIONS_EXTENSION_VERSION: '~4'
        FUNCTIONS_WORKER_RUNTIME: 'dotnet'
        WEBSITE_NODE_DEFAULT_VERSION: '~20'
        //Keyvault Reference requires below /https://learn.microsoft.com/en-us/azure/app-service/reference-app-settings?tabs=kudu%2Cdotnet#key-vault-references
        WEBSITE_SKIP_CONTENTSHARE_VALIDATION: '1'
        WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(VaultName=${keyVault.outputs.name};SecretName=${copyStorageKeyToKeyvault.outputs.keyVaultSecretName})'//'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        WEBSITE_CONTENTSHARE: fileShareName
        APP_KIND: 'workflowApp'
        AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
      }
    tags: tags
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
