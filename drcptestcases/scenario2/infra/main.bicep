// bicep code to create infra for scenario 2
targetScope = 'subscription'

param location string =  deployment().location

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
param applicationCode string = 'scne2'
@maxLength(4)
param applicationInstanceCode string = '03'
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

@description('Network space for the subnets. Needs a /27 prefix.')
param networkAddressSpace string = ''

@description('Object ID of the group that will be assigned higher privileges in DEV.')
param engineersGroupObjectId string = ''

param cosmosSqlDatabaseName string = 'iotdevices'

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

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

// Resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
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
module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/routeTables']
    location: location
    tags: tags
  }
}

// Log Analytcis
var logAnalyticsName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    name: logAnalyticsName
    location: location
    tags: tags
  }
}

// Subnet for private endpoints
module subnetIn 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet1'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-01'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 29, 0)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
}

// Subnet for private endpoints
module subnetIn2 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet2'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-02'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 29, 1)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
  dependsOn: [
    subnetIn
  ]
}

// Subnet for function app egress
module subnetOut 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet3'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsName}-03'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      serviceEndpoints: [ // TODO: intellisence improvements needed
        {
          service: 'Microsoft.Storage'
        }
      ]
      delegations: [  // TODO: intellisence improvements needed
        {
          name: 'Microsoft.Web.serverFarms'
          type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
  dependsOn: [
    subnetIn2
  ]
}

// Key-vault
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
  dependsOn: [
    subnetOut
  ]
}

// Cosmos DB
var cosmosDbName = names.outputs.namingConvention['Microsoft.DocumentDB/databaseAccounts']
module cosmosDb '../../modules/infra/storage/cosmos-db/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmosDb'
  params: {
    location: location
    name: cosmosDbName
    periodicBackupStorageRedundancy: 'Local'
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.resourceId
    tags: tags
  }
}

module storeCosmosDbSecret '../../modules/infra/storage/cosmos-db/secureKeys.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-storeCosmosDbSecret'
  params: {
    cosmosDbName: cosmosDb.outputs.name
    keyVaultName: keyVault.outputs.name
  }
}

// Cosmos DB private endpoint
module cosmosDbPe '../../modules/infra/network/private-endpoint/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmos-pep'
  params: {
    privateEndpointName: '${cosmosDbName}pep'
    location: location
    privateLinkResource: cosmosDb.outputs.id
    subnet: subnetIn.outputs.resourceId
    targetSubResource: 'Sql'
    privateDnsZoneName: 'privatelink.documents.azure.com'
    tags: tags
  }
  dependsOn: [
    subnetOut
  ]
}

// Cosmos DB Database
module cosmosSqlDb '../../modules/infra/storage/cosmos-db/apis/sql/sqldatabase.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmossqlapi'
  params: {
    cosmosDbAccountName: cosmosDb.outputs.name
    cosmosSqlDatabaseName: cosmosSqlDatabaseName
  }
}

module cosmosSqlDbcontainer '../../modules/infra/storage/cosmos-db/apis/sql/container.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmossqlcontainer'
  params: {
    containerName: 'humidity'
    cosmosDbAccountName: cosmosDb.outputs.name
    cosmosSqlDatabaseName: cosmosSqlDb.outputs.name
    partitionKey: 'Eui'
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

// Server farm
var aspName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlan 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-asp'
  params: {
    name: aspName
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
      serverFarmResourceId: appServicePlan.outputs.resourceId
      storageAccountResourceId: storageAccountMod.outputs.resourceId
      privateEndpoints: [
        {
          subnetResourceId: subnetIn2.outputs.resourceId
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
      appInsightResourceId: appInsight.outputs.resourceId
      netFrameworkVersion:'v8.0'
      appSettingsKeyValuePairs: {
        FUNCTIONS_EXTENSION_VERSION: '~4'
        FUNCTIONS_WORKER_RUNTIME: 'dotnet'
      }
      tags:tags
  }
}

// create storage account
var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccountMod 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_ZRS'
    accessTier: 'Hot'
    enableHierarchicalNamespace: false
    allowSharedKeyAccess: false
    networkAcls:{
      bypass: 'None'
    }
    blobServices:{
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
    ] : []
    privateEndpoints:[
      {
        subnetResourceId: subnetIn2.outputs.resourceId
        service: 'blob'
      }
    ]
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: tags
  }
  dependsOn: [subnetIn,subnetOut] // This prevents conflicting parallel operations on subnets and VNet
}
