// bicep code to create infra for scenario 15 -- Cosmos DB (NoSQL) standalone
// Demonstrates: Cosmos DB with inline databases/containers, Entra ID auth, PE, diagnostics

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
param applicationInstanceCode string = '1501'
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

@description('Name of the Cosmos DB SQL database')
param cosmosSqlDatabaseName string = 'appdata'

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
//  - NSG, Route Table, Subnet (PE only)
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

// --------------------------------------------------
//
// Logging
//  - Log Analytics workspace
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

// --------------------------------------------------
//
// Cosmos DB (NoSQL API)
//  - Entra ID auth only (local auth + key metadata writes disabled)
//  - Inline SQL database with two containers
//  - Private endpoint, no public access
//  - TLS 1.2, zone redundant
//  - Detailed diagnostic categories
//
// DRCP policies enforced:
//  - drcp-cosmos-01: publicNetworkAccess disabled
//  - drcp-cosmos-02: disableLocalAuthentication = true
//  - drcp-cosmos-03: disableKeyBasedMetadataWriteAccess = true
//  - drcp-cosmos-04: private endpoint configured
//  - drcp-cosmos-05: minimumTlsVersion = Tls12
//  - drcp-cosmos-06: NoSQL API only (no Cassandra/Gremlin/Table/Mongo)
//  - drcp-cosmos-10: zoneRedundant = true
//
// --------------------------------------------------

var cosmosDbName = names.outputs.namingConvention['Microsoft.DocumentDB/databaseAccounts']
module cosmosDb 'br/amavm:res/document-db/database-account:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-cosmosDb'
  params: {
    name: cosmosDbName
    location: location
    tags: mytags
    backupStorageRedundancy: isDevEnvironment ? 'Local' : 'Zone'
    sqlDatabases: [
      {
        name: cosmosSqlDatabaseName
        containers: [
          {
            name: 'items'
            paths: ['/partitionKey']
          }
          {
            name: 'events'
            paths: ['/eventType']
          }
        ]
      }
    ]
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-cosmos'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'Sql'
        tags: mytags
      }
    ]
    diagnosticSettings: [
      {
        name: '${cosmosDbName}_diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        logCategoriesAndGroups: [
          { category: 'ControlPlaneRequests' }
          { category: 'DataPlaneRequests' }
          { category: 'PartitionKeyStatistics' }
          { category: 'PartitionKeyRUConsumption' }
          { category: 'QueryRuntimeStatistics' }
        ]
        metricCategories: [
          { category: 'AllMetrics' }
        ]
      }
    ]
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'DocumentDB Account Contributor'
      }
    ] : []
  }
}

output cosmosDbName string = cosmosDb.outputs.name
output cosmosDbEndpoint string = cosmosDb.outputs.endpoint
