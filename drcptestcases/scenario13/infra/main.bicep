// bicep code to create infra for scenario 13 — Azure Cache for Redis
// Demonstrates: Redis Premium with PE, Entra ID auth, zone redundancy, diagnostics

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
param applicationInstanceCode string = '1301'
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
//  - NSG, Route Table, Subnet (PE only — no app egress needed)
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
// Azure Cache for Redis (Premium)
//  - Entra ID auth only (access keys disabled)
//  - Private endpoint, no public access
//  - TLS 1.2, zone redundant
//  - Diagnostics to Log Analytics
//
// DRCP policies enforced:
//  - drcp-redis-02: publicNetworkAccess disabled
//  - drcp-redis-04: private endpoint configured
//  - drcp-redis-05: disableAccessKeyAuthentication = true
//  - drcp-redis-07: enableNonSslPort = false
//  - drcp-redis-08: minimumTlsVersion = 1.2
//  - drcp-redis-09: zoneRedundant = true
//
// --------------------------------------------------

var redisName = names.outputs.namingConvention['Microsoft.Cache/redis']
module redis 'br/amavm:res/cache/redis:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-redis'
  params: {
    name: redisName
    location: location
    tags: mytags
    skuName: 'Premium'
    capacity: 1
    disableAccessKeyAuthentication: true
    enableNonSslPort: false
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    zoneRedundant: true
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-redis'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'redisCache'
        tags: mytags
      }
    ]
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Redis Cache Contributor'
      }
    ] : []
    diagnosticSettings: [
      {
        name: '${redisName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

output redisName string = redis.outputs.name
output redisHostName string = redis.outputs.hostName
