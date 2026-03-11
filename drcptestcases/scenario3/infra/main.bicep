// bicep code to create infra for scenario 3
targetScope = 'subscription'

param location string = deployment().location

param deploymentId string = ''
#disable-next-line no-unused-params
param whatIf string = ''

// APG ServiceNow registrations
param applicationId string = 'AM-CCC'
param environmentId string

// Parts used in naming convention
param namePrefix string = ''
@maxLength(2)
param organizationCode string = 's2'
@maxLength(3)
param departmentCode string = 'ccc'
param applicationCode string = 'scne3'
@maxLength(4)
param applicationInstanceCode string = '21'
param systemCode string = ''
@maxLength(2)
param systemInstanceCode string = ''
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentType string = 'dev'

@description('CIDR prefix for the virtual network. Needs a /27 prefix')
param networkAddressSpace string = ''

param engineersGroupObjectId string = ''

param tags object = {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${systemCode}'
  environmentType: environmentType
  deploymentPipelineId: deploymentId
}

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

// To be used in naming private endpoints
var privateEndpointsNameRoot = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

// Resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
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

// Nsg
var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-nsg'
  params: {
    name: nsgName
    location: location
    tags: tags
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

// Create Route table
var udrname = names.outputs.namingConvention['Microsoft.Network/routeTables']
module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: udrname
    location: location
    tags: tags
  }
}

// Log Analytcis
var logAnalyticsName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-laworkspace'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

// Subnet for private endpoints
var subnetsConfig = [
  {
    // subnet for incoming traffic via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'In'
    delegations: []
    serviceEndpoints: []
  }
  {
    // subnet for outgoing traffic from App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 29, 2)
    nameIndex: 'frontendOut'
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
    // subnet for outgoing traffic from App 2
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 29, 3)
    nameIndex: 'frontend2Out'
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
        networkSecurityGroupResourceId: nsg.outputs.resourceId
        routeTableResourceId: udr.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegations: subnetsConfig[index].delegations
        serviceEndpoints: subnetsConfig[index].serviceEndpoints
      }
    }
  }
]
var subnetPrivateEndpoints = subnetsMod[0]
// Key-vault
var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault 'br/amavm:res/key-vault/vault:0.3.0' = {  //'../../modules/infra/security/keyvault/main.bicep'
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
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
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
          principalId: functionApp.outputs.systemAssignedMIPrincipalId
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
  }
}

// Application insights
var appInsightsName = names.outputs.namingConvention['Microsoft.Insights/components']
module appInsight 'br/amavm:res/insights/component:0.1.0' = { //'../../modules/infra/observability/application-insights/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: appInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    tags: tags
  }
}

//-----------------------------------------------------------------------
//  Create App plan and Function app
//-----------------------------------------------------------------------

// Server farm
var appServicePlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module aspFunction 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-asp'
  params: {
    name: appServicePlanName
    location: vNet.location
    kind: 'Windows'
    skuName: 'S1'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: tags
  }
}

// Function app
var functionAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionApp 'br/amavm:res/web/site:0.1.0' = { //'../../modules/infra/compute/function-app/main.bicep'
  scope: resourceGroup
  name: '${deployment().name}-fa'
  params: {
  name: functionAppName
      location: vNet.location
      kind: 'functionapp'
      serverFarmResourceId: aspFunction.outputs.resourceId
      storageAccountResourceId: storageAccountMod.outputs.resourceId
      storageAccountUseIdentityAuthentication: false
      privateEndpoints: [
        {
          subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        }
      ]
      virtualNetworkSubnetId: subnetsMod[1].outputs.resourceId
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
      appInsightResourceId: appInsight.outputs.resourceId
      netFrameworkVersion:'v8.0'
      appSettingsKeyValuePairs: {
        FUNCTIONS_EXTENSION_VERSION: '~4'
        FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      }
      tags:tags
  }
}

//----------------------------------------------------------------------------
//  Create Storage account, File share and Table for logic app functionality
//----------------------------------------------------------------------------

var storageAccountBackendRoles = [
  'Storage Blob Data Owner'
  'Storage File Data SMB Share Contributor'
  'Storage File Data Privileged Contributor'
]
var fileShare2Name = 'fshare'

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
        name: fileShare2Name
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
    roleAssignments: [
      for role in ((isDevEnvironment) ? storageAccountBackendRoles : [] ): {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: role
      }
    ]
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
     usedBy: 'LogicApp' //DRCP policy compliance
    }
  }
  dependsOn: subnetsMod // This prevents conflicting parallel operations on subnets and VNet
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

//-----------------------------------------------------------------------
//  Create App plan and Logic app
//-----------------------------------------------------------------------

// Server farm
module aspLogic 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-asp-logic'
  params: {
    name: '${appServicePlanName}-logic'
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
    tags: tags
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
      serverFarmResourceId: aspLogic.outputs.resourceId
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
      virtualNetworkSubnetId: subnetsMod[2].outputs.resourceId
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
      appInsightResourceId: appInsight.outputs.resourceId
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
        WEBSITE_CONTENTSHARE: fileShare2Name
        APP_KIND: 'workflowApp'
        AzureFunctionsJobHost__extensionBundle__id: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        AzureFunctionsJobHost__extensionBundle__version: '[1.*, 2.0.0)'
      }
    tags: tags
  }
}
