// bicep code to create infra for scenario 4

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
param applicationInstanceCode string = '0401' // in case if there are more than 1 application deployments (for example, in multiple environments)
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

// System-specific parameters
@description('CIDR prefix for the virtual network. Needs a /27 prefix')
param networkAddressSpace string = ''
@description('AAD group object id for the engineering group')
param engineersGroupObjectId string = ''
// #disable-next-line no-unused-params
param engineersContactEmail string = ''

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

// To be used in naming private endpoints
var privateEndpointsNameRoot = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

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

module subnetIn 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet0'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-In'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

module subnetOut 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet1'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-frontendOut'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
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
    }
  }
  dependsOn: [ subnetIn ]
}


// --------------------------------------------------
//
// Logging
//  - LogAnalytics workspace
//  - Application Insights
//
// --------------------------------------------------
var logAnalyticsWorkspaceName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-laworkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tags
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
    tags: tags
  }
}

// --------------------------------------------------
//
// KeyVault
//  - Use by Function in configuration
//
// --------------------------------------------------

// create keyvault and assign RBAC to engineering group
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
        subnetResourceId: subnetIn.outputs.resourceId
        tags: tags
      }
    ]
    diagnosticSettings: [
      {
        name: '${keyVaultName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    roleAssignments: isDevEnvironment ? [
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
      ] : []
  }
}

// --------------------------------------------------
//
// Scenario resources
//  - Storage Account (File share)
//  - Event Hub (Namespace, Event Hub)
//  - Azure Function (App service plan, Function App, Function)
//
// --------------------------------------------------

// ----------------------------------------------
//  Storage account with fileshare
// ----------------------------------------------

// create storage account
var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccount 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    accessTier: 'Hot'
    networkAcls:{
      bypass: 'None'
    }
    roleAssignments: isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: 'Storage Blob Data Contributor'
        }
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: 'Storage File Data Privileged Contributor'
        }
      ] : []
    privateEndpoints:[
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'blob'
        name: '${privateEndpointsNameRoot}-sta-${storageAccountName}-blob'
      }
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'file'
        name: '${privateEndpointsNameRoot}-sta-${storageAccountName}-file'
      }
    ]
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
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: tags
  }
}
// create container (for EventHub capture)
var storageContainerName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts/blobServices/containers']
module blobContainer 'br/amavm:res/storage/storage-account/blob-service/container:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-container'
  params: {
    name: storageContainerName
    storageAccountName: storageAccount.outputs.name
  }
}
// create container (for FunctionApp functions)
var storageContainer2Name = 'dest'
module blobContainer2 'br/amavm:res/storage/storage-account/blob-service/container:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-container2'
  params: {
    name: storageContainer2Name
    storageAccountName: storageAccount.outputs.name
  }
}

// create file share (for Azure Function triggers)
var storageShareName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts/fileServices/shares']
module fileShare 'br/amavm:res/storage/storage-account/file-service/share:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-fileshare'
  params: {
    name: storageShareName
    storageAccountName: storageAccount.outputs.name
    accessTier: 'TransactionOptimized'
    shareQuota: 100
  }
}


// ----------------------------------------------
// Event Hub
// ----------------------------------------------

// Event Hub (AMAVM module — replaces local namespace, eventhub, consumer-group, PE, and RBAC modules)
var eventHubNamespaceName = names.outputs.namingConvention['Microsoft.EventHub/namespaces']
var eventHubName = 'dest'
module eventHubNamespace 'br/amavm:res/event-hub/namespace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-evhns'
  params: {
    name: eventHubNamespaceName
    location: vNet.location
    tags: mytags
    skuName: 'Standard'
    skuCapacity: 1
    isAutoInflateEnabled: true
    maximumThroughputUnits: 10
    managedIdentities: {
      systemAssigned: true
    }
    eventhubs: [
      {
        name: eventHubName
        partitionCount: 1
        messageRetentionInDays: 1
        consumergroups: [
          {
            name: 'drcptesting'
          }
        ]
      }
    ]
    privateEndpoints: [
      {
        name: '${privateEndpointsNameRoot}-evhns'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'namespace'
        tags: mytags
      }
    ]
    roleAssignments: isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: 'Azure Event Hubs Data Owner'
        }
      ] : []
    diagnosticSettings: [
      {
        name: 'allMetricsAndLogs'
        logAnalyticsDestinationType: 'AzureDiagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
  dependsOn: [
    subnetOut
  ]
}

// ----------------------------------------------
// Function App
// ----------------------------------------------

// create a hosting plan (app service plan) for the function app
var hostingPlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlan 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan'
  params: {
    name: hostingPlanName
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
module functionApp 'br/amavm:res/web/site:0.1.0' = { //'../../modules/infra/compute/function-app/main.bicep'
  scope: resourceGroup
  name: '${deployment().name}-fa'
  params: {
      name: functionAppName
      location: vNet.location
      kind: 'functionapp'
      serverFarmResourceId: appServicePlan.outputs.resourceId
      storageAccountResourceId: storageAccount.outputs.resourceId
      privateEndpoints: [
        {
          subnetResourceId: subnetIn.outputs.resourceId
        }
      ]
      virtualNetworkSubnetId: subnetOut.outputs.resourceId
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
      netFrameworkVersion:'v8.0'
      webSiteConfigurationAdditional: {
        use32BitWorkerProcess: true
      }
      siteConfigurationAdditional: {
        detailedErrorLoggingEnabled: true
        cors: (isDevEnvironment) ? {
          allowedOrigins: [ // to test functions from the azure portal
            'https://functions-next.azure.com'
            'https://functions-staging.azure.com'
            'https://functions.azure.com'
            'https://portal.azure.com'
          ]
          supportCredentials: false
          } : {}
      }
      appSettingsKeyValuePairs: {
        FUNCTIONS_EXTENSION_VERSION: '~4'
        FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
        WEBSITE_RUN_FROM_PACKAGE: 1
        EventHubConnection__fullyQualifiedNamespace: '${eventHubNamespaceName}.servicebus.windows.net'
      }
      msDeployConfiguration: {
        packageUri: ''
      }
      tags:tags
  }
}
// --------------------------------------------------
// Separate RBAC assignments (break circular dependency:
//   storageAccount → eventHubNamespace → functionApp → storageAccount)
// --------------------------------------------------

// Function App MI → Storage Blob Data Owner
module storageBlobByFuncAppRbac 'roleAssignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-sta-funcapp-rbac'
  params: {
    storageAccountName: storageAccount.outputs.name
    principalId: functionApp.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner
  }
}

// Event Hub NS MI → Storage Blob Data Owner
module storageBlobByEvhRbac 'roleAssignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-sta-evh-rbac'
  params: {
    storageAccountName: storageAccount.outputs.name
    principalId: eventHubNamespace.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner
  }
}

// Function App MI → Event Hubs Data Owner
module evhByFuncAppRbac 'evhRoleAssignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-evh-funcapp-rbac'
  params: {
    eventHubNamespaceName: eventHubNamespace.outputs.name
    principalId: functionApp.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: 'f526a384-b230-433a-b45c-95f59c4a2dec' // Azure Event Hubs Data Owner
  }
}

// Function App MI → Key Vault Secrets User
module kvByFuncAppRbac 'kvRoleAssignment.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-kv-funcapp-rbac'
  params: {
    keyVaultName: keyVault.outputs.name
    principalId: functionApp.outputs.systemAssignedMIPrincipalId
    roleDefinitionId: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
  }
}

output keyvaultName string = keyVault.outputs.name
output functionAppName string = functionApp.outputs.name
output functionAppPlanName string = appServicePlan.outputs.name
output eventHubNamespaceName string = eventHubNamespace.outputs.name
output eventHubName string = eventHubName
output storageAccountName string = storageAccount.outputs.name
