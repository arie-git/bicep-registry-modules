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
param applicationInstanceCode string = '0101' // in case if there are more than 1 application deployments (for example, in multiple environments)
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
@description('Network space for the subnets. Needs a /27 prefix.')
param networkAddressSpace string = ''
@description('Object ID of the group that will be assigned higher privileges in DEV.')
param engineersGroupObjectId string = ''
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

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
// Logging
//  - LogAnalytics workspace
//  - Application Insights
//
// --------------------------------------------------

var logAnalyticsWorkspaceName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-loganalytics'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
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

module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    diagnosticSettings:[
      {
        name: 'allCategories'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    location: vNet.location
    tags: mytags
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
var subnetsConfig = [
  {
    // subnet for incoming traffic via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'In'
    delegations: []
  }
  {
    // subnet for outgoing traffic from Function App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
    nameIndex: 'frontendOut'
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
module subnets 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [for index in range(0, 2): {
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
      }
    }
  }
]

var subnetPrivateEndpoints = subnets[0]
// --------------------------------------------------
//
// Shared resources
//  - Keyvault (Use by Function in configuration)
//  - Storage account (used by SQL server for auditing)
//
// --------------------------------------------------

// create keyvault, private endpoint and assign RBAC to engineering group
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
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
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
          roleDefinitionIdOrName: 'Key Vault Crypto Officer' // KeyVault Crypto Officer
          principalType: 'Group'
        }
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'Key Vault Certificates Officer' // KeyVault Certificate Officer
          principalType: 'Group'
        }
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'Key Vault Secrets Officer' // Key Vault Secrets Officer
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
          roleDefinitionIdOrName:  '4633458b-17de-408a-b874-0445c86b69e6' // 'Key Vault Secrets User'
          principalType: 'ServicePrincipal'
        }
      ]
    )
    keys:[
      {
        name: 'tst1'
        attributes:{
          exp: dateTimeToEpoch('2025-07-01T00:00:00Z') // set it fixed to allow updates
        }
        tags: mytags
      }
    ]
    secrets:[
      {
        name: 'tst2'
        value: uniqueString(resourceGroup.id)
        tags: mytags
      }
    ]
  }
}

module kvSecret1 'br/amavm:res/key-vault/vault/secret:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault-secret1'
  params:{
    name: 'tst3'
    keyVaultName: keyVault.outputs.name
    value: uniqueString(resourceGroup.id)
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: 'Key Vault Secrets User'
        principalType: 'Group'
      }
    ] : []
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
    allowSharedKeyAccess: false // for sql server security alerts
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
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
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
  dependsOn: subnets // This prevents conflicting parallel operations on subnets and VNet
}

// --------------------------------------------------
//
// Scenario resources
//  - SQL database (and its server)
//  - Azure Function (App service plan, Function App, Function)
//
// --------------------------------------------------

// create a managed identity for SQL server
var uamiName = names.outputs.namingConvention['Microsoft.ManagedIdentity/userAssignedIdentities']
module uamiMod 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami'
  params:{
    name: uamiName
  }
}

// create SQL server and a database
var sqlServerName = names.outputs.namingConvention['Microsoft.Sql/servers']
var sqlDatabaseName = names.outputs.namingConvention['Microsoft.Sql/servers/databases']
module sqlServerMod 'br/amavm:res/sql/server:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-sqlsrv'
  params: {
    name: sqlServerName
    administrators:{
      principalType: 'Group'
      sid: engineersGroupObjectId
    }
    privateEndpoints:[
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        name: '${privateEndpointsName}-sql'
        location: vNet.location
        tags: mytags
      }
    ]
    outboundFirewallRules:[
      {
        name: replace(replace(storageAccountMod.outputs.primaryBlobEndpoint,'https://',''),'/','')
      }
    ]
    databases:[
      {
        name: sqlDatabaseName
        skuName: 'GP_Gen5_2'
        //maxSizeBytes: 53687091200
        zoneRedundant: true
        diagnosticSettings:[
          {
            workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
          }
        ]
        backupLongTermRetentionPolicy:{
          monthlyRetention: ''
          weeklyRetention: ''
        }
        tags: mytags
      }
    ]
    securityAlertPolicy: {
      emailAddresses:[
        engineersContactEmail
      ]
    }
    auditSettings:{
      state: 'Enabled'
      //storageAccountResourceId: storageAccountMod.outputs.resourceId // requires outbound firewall rules
      isAzureMonitorTargetEnabled: true
      workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    }
    // vulnerabilityAssessmentsClassic:{ // exclusive: either Express or Classic
    //   storageAccountResourceId: storageAccountMod.outputs.resourceId  // requires outbound firewall rules
    // }
    managedIdentities:{
      userAssignedResourceIds:[
        uamiMod.outputs.resourceId
      ]
    }
    tags: mytags
  }
}



// create a hosting plan (app service plan) for the function app
var hostingPlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']

module appServicePlan 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan'
  params: {
    name: hostingPlanName
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
    tags: mytags
  }
}



// create function app
var functionAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionApp 'br/amavm:res/web/site:0.2.0' = { //'../../modules/infra/compute/function-app/main.bicep'
  scope: resourceGroup
  name: '${deployment().name}-functionapp'
  params: {
    name: functionAppName
    location: vNet.location
    kind: 'functionapp'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    storageAccountResourceId: storageAccountMod.outputs.resourceId
    privateEndpoints: [
      {
        subnetResourceId: subnets[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnets[1].outputs.resourceId
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    diagnosticSettings: [
      {
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
        } : {}
    }
    netFrameworkVersion:'v8.0'
    appSettingsKeyValuePairs: {
      AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
      SqlDbConnection_server: sqlServerMod.outputs.fullyQualifiedDomainName
      SqlDbConnection_database: sqlServerMod.outputs.databases[0].name//sqlDatabase.outputs.name
    }
    tags: mytags
    
  } 
}

output keyvaultName string = keyVault.outputs.name
output functionAppName string = functionApp.outputs.name
output functionAppPlanName string = appServicePlan.outputs.name
