// bicep code to create infra for scenario 14 -- Event Hub + Function App + App Configuration (event-driven)
// Demonstrates: Event Hub namespace with inline hubs, App Configuration with feature flags, Function App consumer, VNet integration

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
param organizationCode string = 's2'
@maxLength(3)
param departmentCode string = 'c3'
param applicationCode string = 'drcptst'
@maxLength(4)
param applicationInstanceCode string = '1401'
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
//  - NSG, Route Table
//  - Subnet-In (private endpoints)
//  - Subnet-Out (Function App VNet integration)
//
// --------------------------------------------------

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    location: vNet.location
    tags: mytags
    diagnosticSettings: [
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
      name: '${subnetsName}-Out'
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
//  - Log Analytics workspace
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
    tags: mytags
  }
}

// --------------------------------------------------
//
// Storage Account (Function App backing storage)
//
// --------------------------------------------------

var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccount 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'None'
    }
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ] : []
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'blob'
        name: '${privateEndpointsName}-sta-blob'
      }
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'file'
        name: '${privateEndpointsName}-sta-file'
      }
    ]
    blobServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    fileServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
  dependsOn: [ subnetOut ]
}

// --------------------------------------------------
//
// Event Hub Namespace
//  - Standard SKU with auto-inflate
//  - Inline event hub + consumer group
//  - Entra ID auth only (local auth disabled)
//  - Private endpoint, no public access
//  - TLS 1.2, zone redundant
//
// DRCP policies enforced:
//  - drcp-evh-01: publicNetworkAccess disabled (via PE)
//  - drcp-evh-02: private endpoint configured
//  - drcp-evh-05: disableLocalAuth = true
//  - drcp-evh-07: minimumTlsVersion = 1.2
//  - drcp-evh-09: zoneRedundant = true
//
// --------------------------------------------------

var eventHubNamespaceName = names.outputs.namingConvention['Microsoft.EventHub/namespaces']
var eventHubName = 'telemetry'
module eventHubNamespace 'br/amavm:res/event-hub/namespace:0.2.0' = {
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
        partitionCount: 2
        messageRetentionInDays: 1
        consumergroups: [
          {
            name: 'functionconsumer'
          }
        ]
      }
    ]
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-evhns'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'namespace'
        tags: mytags
      }
    ]
    roleAssignments: union(
      isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: 'Azure Event Hubs Data Owner'
        }
      ] : [],
      [
        {
          principalId: functionApp.outputs.systemAssignedMIPrincipalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'Azure Event Hubs Data Receiver'
        }
      ]
    )
    diagnosticSettings: [
      {
        name: 'allMetricsAndLogs'
        logAnalyticsDestinationType: 'AzureDiagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

// --------------------------------------------------
//
// App Configuration Store
//  - Feature flags and configuration key-values
//  - Entra ID auth only (local auth disabled)
//  - Private endpoint, no public access
//
// DRCP policies enforced:
//  - drcp-appcs-01: publicNetworkAccess disabled (via PE)
//  - drcp-appcs-02: disableLocalAuth = true
//  - drcp-appcs-03: private endpoint configured
//
// --------------------------------------------------

var appConfigName = names.outputs.namingConvention['Microsoft.AppConfiguration/configurationStores']
module appConfig 'br/amavm:res/app-configuration/configuration-store:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appcs'
  params: {
    name: appConfigName
    location: location
    tags: mytags
    sku: 'Standard'
    disableLocalAuth: true
    enablePurgeProtection: false
    softDeleteRetentionInDays: 1
    dataPlaneProxy: {
      authenticationMode: 'Pass-through'
      privateLinkDelegation: 'Enabled'
    }
    managedIdentities: {
      systemAssigned: true
    }
    keyValues: [
      {
        name: '.appconfig.featureflag~2FEnableEventProcessing'
        value: '{"id":"EnableEventProcessing","description":"Enables event processing from Event Hub","enabled":true}'
        contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
      }
      {
        name: '.appconfig.featureflag~2FEnableDetailedLogging'
        value: '{"id":"EnableDetailedLogging","description":"Enables detailed diagnostic logging","enabled":false}'
        contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
      }
      {
        name: 'EventProcessing:BatchSize'
        value: '100'
      }
    ]
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-appcs'
        subnetResourceId: subnetIn.outputs.resourceId
        tags: mytags
      }
    ]
    roleAssignments: union(
      isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: 'App Configuration Data Owner'
        }
      ] : [],
      [
        {
          principalId: functionApp.outputs.systemAssignedMIPrincipalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'App Configuration Data Reader'
        }
      ]
    )
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

// --------------------------------------------------
//
// Function App (Event Hub triggered)
//  - Consumes events from Event Hub
//  - Reads configuration from App Configuration
//  - VNet integrated, PE for inbound
//
// --------------------------------------------------

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

var functionAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionApp 'br/amavm:res/web/site:0.2.0' = {
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
    netFrameworkVersion: 'v8.0'
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
      WEBSITE_RUN_FROM_PACKAGE: 1
      EventHubConnection__fullyQualifiedNamespace: '${eventHubNamespaceName}.servicebus.windows.net'
      AppConfigEndpoint: 'https://${appConfigName}.azconfig.io'
    }
    tags: mytags
  }
}

output eventHubNamespaceName string = eventHubNamespace.outputs.name
output eventHubName string = eventHubName
output functionAppName string = functionApp.outputs.name
output appConfigName string = appConfig.outputs.name
output appConfigEndpoint string = 'https://${appConfigName}.azconfig.io'
