// bicep code to create infra for scenario 17 — Static Web App + Function API
// Demonstrates: Static Web App (Standard) with linked Function App API backend,
// private endpoints, managed identity, VNet integration, diagnostics

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
param applicationInstanceCode string = '1701'
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
@description('CIDR prefix for the virtual network. Needs a /27 prefix (2 x /28 subnets: PE + app egress)')
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
//  - Subnet 0: Private endpoints
//  - Subnet 1: Function App egress (delegated to Microsoft.Web/serverFarms)
//
// --------------------------------------------------

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

module nsg 'dummy_skip' = {
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

module udr 'dummy_skip' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: names.outputs.namingConvention['Microsoft.Network/routeTables']
    location: vNet.location
    tags: mytags
  }
}

var subnetsConfig = [
  {
    // subnet for all components via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'In'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    serviceEndpoints: []
    delegations: []
  }
  {
    // subnet for outgoing traffic from the Function App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
    nameIndex: 'appOut'
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

@batchSize(1) // sequential to prevent VNet conflicts
module subnets 'dummy_skip' = [for index in range(0, 2): {
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
//  - Log Analytics workspace
//  - Application Insights
//
// --------------------------------------------------

var logAnalyticsWorkspaceName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-laworkspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: mytags
  }
}

var applicationInsightsName = names.outputs.namingConvention['Microsoft.Insights/components']
module applicationInsights 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    name: applicationInsightsName
    location: location
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    tags: mytags
  }
}

// --------------------------------------------------
//
// Storage account (Function App backing storage)
//
// --------------------------------------------------

var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccount 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-storage'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    allowSharedKeyAccess: false
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
    tableServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    queueServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    roleAssignments: isDevEnvironment
      ? [
          {
            principalId: engineersGroupObjectId
            principalType: 'Group'
            roleDefinitionIdOrName: 'Storage Blob Data Contributor'
          }
        ]
      : []
    privateEndpoints: [
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
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: mytags
  }
  dependsOn: subnets
}

// --------------------------------------------------
//
// Key Vault (API configuration secrets)
//
// --------------------------------------------------

var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: keyVaultName
    enablePurgeProtection: !isDevEnvironment
    softDeleteRetentionInDays: 7
    networkAcls: {
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
      isDevEnvironment
        ? [
            {
              principalId: engineersGroupObjectId
              roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // Key Vault Admin
              principalType: 'Group'
            }
          ]
        : [],
      [
        {
          principalId: functionApp.outputs.systemAssignedMIPrincipalId
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' // Key Vault Secrets User
          principalType: 'ServicePrincipal'
        }
      ]
    )
    tags: mytags
  }
}

// --------------------------------------------------
//
// Function App (API backend for Static Web App)
//  - Linux Node.js, system-assigned MI
//  - Private endpoint, VNet integration
//  - Connected to Key Vault and Storage via MI
//
// --------------------------------------------------

var hostingPlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlan 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan'
  params: {
    name: hostingPlanName
    location: vNet.location
    kind: 'Linux'
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

var functionAppName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionApp 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-funcapp'
  params: {
    name: functionAppName
    location: vNet.location
    kind: 'functionapp,linux'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
    storageAccountUseIdentityAuthentication: true
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
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'node'
      WEBSITE_NODE_DEFAULT_VERSION: '~20'
    }
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    tags: mytags
  }
}

// --------------------------------------------------
//
// Static Web App (SPA frontend)
//  - Standard SKU (required for PE)
//  - Private endpoint, no public access
//  - Linked backend to Function App API
//  - No source control integration (provider: 'None')
//
// DRCP policies enforced:
//  - drcp-swa-network: publicNetworkAccess = 'Disabled'
//  - drcp-swa-sku: sku = 'Standard'
//  - drcp-swa-pe: PE in same subscription
//  - drcp-swa-dns: private DNS zone (auto-deployed by policy)
//
// --------------------------------------------------

var staticWebAppName = '${namePrefix}${applicationCode}${applicationInstanceCode}-swa-${environmentType}'
module staticWebApp 'dummy_skip' = {
  scope: resourceGroup
  name: '${deployment().name}-swa'
  params: {
    name: staticWebAppName
    location: location
    sku: 'Standard'
    publicNetworkAccess: 'Disabled'
    provider: 'None'
    buildProperties: {
      appLocation: '/'
      outputLocation: 'dist'
      apiLocation: 'api'
    }
    linkedBackend: {
      backendResourceId: functionApp.outputs.resourceId
    }
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-swa'
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        tags: mytags
      }
    ]
    roleAssignments: isDevEnvironment
      ? [
          {
            principalId: engineersGroupObjectId
            principalType: 'Group'
            roleDefinitionIdOrName: 'Contributor'
          }
        ]
      : []
    tags: mytags
  }
}

// --------------------------------------------------
// Outputs
// --------------------------------------------------

output staticWebAppName string = staticWebApp.outputs.name
output staticWebAppHostname string = staticWebApp.outputs.defaultHostname
output functionAppName string = functionApp.outputs.name
output keyVaultName string = keyVault.outputs.name
