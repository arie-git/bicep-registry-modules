metadata name = 'N tier application pattern'
metadata description = 'This module implements a pattern with a sql database'
metadata owner = 'AMCCC'
metadata compliance = 'There are no special requirements. The pattern implements a compliant-by-default environment.'
metadata complianceVersion = '20250304'

targetScope = 'subscription'

// general parameters
@description('Required. The location where the resources will be deployed.')
param location string = deployment().location

@description('Optional. Tags to apply to resources for categorization and management.')
param tags object = {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}'
  environmentType: environmentType
  contactEmail: engineersContactEmail
  deploymentPipelineId: deploymentId
}

@description('Optional. The deployment ID to uniquely identify the deployment process.')
param deploymentId string = ''

// APG ServiceNow registrations
@description('Required. The unique application ID used for APG ServiceNow registration.')
param applicationId string = 'AM-CCC'

@description('Required. The environment ID for the deployment.')
param environmentId string = 'ENV24643'

// Parts used in naming convention
@description('Optional. A prefix to use in naming resources.')
param namePrefix string = ''

@description('Required. The organization code used in naming conventions.')
@maxLength(2)
param organizationCode string = 's2'

@description('Required. The application code used in naming conventions.')
param applicationCode string = 'drcp'

@maxLength(3)
@description('Optional. Code of the department within a business unit.')
param department string = ''

@description('Required. The application instance code used in naming conventions.')
@maxLength(4)
param applicationInstanceCode string = '0101'

@description('Optional. The system code used in naming conventions.')
param systemCode string = ''

@description('Optional. The system instance code used in naming conventions.')
@maxLength(2)
param systemInstanceCode string = ''


@description('Required. The environment type such as sbx, dev, tst, acc, or prd.')
@allowed([
  'sbx'
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentType string = 'dev'

// System-specific parameters
@description('Required. Network space for the subnets. Needs a /27 prefix.')
param networkAddressSpace string = ''

@description('Required. The Object ID of the group that will be assigned higher privileges in DEV.')
param engineersGroupObjectId string = '9c1f0c78-5ed0-4a97-aecd-4ec20336f626'

@description('Optional. The contact email address for engineers involved in the project.')
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var mytags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'ptn', telemetryAVMversion: moduleVersion})


import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'


// var privateEndpointStorageIntermediateName = '${patternName}pep-st01'
var locationDict = {
  westeurope: 'we'
  northeurope: 'ne'
  swedencentral: 'sec'
}

var locationShort = locationDict[location]
var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'
var rootName = '${namePrefix}${organizationCode}${department}${applicationCode}${applicationInstanceCode}${environmentType}${locationShort}'
var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'
var subnetsName = '${rootName}-sn'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

// Logging resources
var logAnalyticsWorkspaceName = '${rootName}-la'
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: mytags
  }
}

var applicationInsightsName = '${rootName}-appinsights'
module applicationInsights 'br/amavm:res/insights/component:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-insights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    tags: mytags
  }
}

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${rootName}-nsg'
    diagnosticSettings: [ {
      name: 'allCategories'
      workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    }]
    location: vNet.location
    tags: mytags
  }
}

module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${rootName}-rt'
    location: vNet.location
    tags: mytags
  }
}

// Subnets
var subnetsConfig = [
  {
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'In'
    delegations: []
  }
  {
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

@batchSize(1)
module subnets 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [for index in range(0, 2): {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-sn-${index}'
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
}]

// Shared resources

// create storage account
var storageAccountName = toLower('${rootName}sa')
module storageAccountMod 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-sa'
  params: {
    name: take(storageAccountName,23)
    location: location
    skuName: 'Standard_ZRS'
    accessTier: 'Hot'
    enableHierarchicalNamespace: false
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'None'
    }
    blobServices: {
      diagnosticSettings: [
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    privateEndpoints: [
      {
        name: '${rootName}-pep-stg'
        location: vNet.location
        service: 'blob'
        subnetResourceId: subnets[0].outputs.resourceId
        tags: mytags
      }
    ]
    tags: mytags
  }
  dependsOn: subnets
}

// Scenario resources
var sqlServerName = toLower('${rootName}-sql')
var sqlDatabaseName = '${rootName}-sqldb'
module sqlServerMod 'br/amavm:res/sql/server:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-sqlsrv'
  params: {
    name: sqlServerName
    administrators: {
      principalType: 'Group'
      sid: engineersGroupObjectId
    }
    privateEndpoints: [
      {
        subnetResourceId: subnets[0].outputs.resourceId
        name: '${rootName}-pep-sql'
        location: vNet.location
        tags: mytags
      }
    ]
    outboundFirewallRules: [
      {
        name: replace(replace(storageAccountMod.outputs.primaryBlobEndpoint,'https://',''),'/','')
      }
    ]
    databases: [
      {
        name: sqlDatabaseName
        skuName: 'GP_Gen5_2'
        zoneRedundant: true
        diagnosticSettings: [
          {
            workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
          }
        ]
        backupLongTermRetentionPolicy: {
          monthlyRetention: ''
          weeklyRetention: ''
        }
        tags: mytags
      }
    ]
    securityAlertPolicy: {
      emailAddresses: [engineersContactEmail]
    }
    auditSettings: {
      state: 'Enabled'
      //storageAccountResourceId: storageAccountMod.outputs.resourceId // requires outbound firewall rules
      isAzureMonitorTargetEnabled: true
      workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    }
    tags: mytags
  }
}

output storageAccountName string = storageAccountMod.outputs.name
output sqlServerName string = sqlServerMod.outputs.name
output sqlDatabaseName string = sqlServerMod.outputs.databases[0].name
