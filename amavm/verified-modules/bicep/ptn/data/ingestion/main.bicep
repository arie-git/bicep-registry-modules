metadata name = 'Data Ingestion pattern'
metadata description = 'This module implements a pattern of typical data ingestion with Azure Data Factory and Azure Databricks'
metadata owner = 'AMCCC'
metadata compliance = 'There are no special requirements. The pattern implements a compliant-by-default environment.'
metadata complianceVersion = '20240703'
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

@description('Optional. Set to to Enable Azure Data Factory deployment. Default is true.')
param isDataFactoryEnabled bool = true

@description('Optional. Set to enable Azure Databricks deployment. Default is true.')
param isDatabricksEnabled bool = true

@description('Optional. Set to Enable log Analytics deployment. Default is true.')
param isLogAnalyticsEnabled bool = true

@description('Optional. Repo for adf')
param adfRepoConfig object = {
  gitRepoType: 'FactoryVSTSConfiguration'
  gitAccountName: 'connectdrcpapg1'
  gitProjectName: 'exampleProject'
  gitRepositoryName: 'exampleRepo'
  gitCollaborationBranch: 'main'
  gitDisablePublish: true
  gitRootFolder: '/'
  gitTenantId: 'c1f94f0d-9a3d-4854-9288-bb90dcf2a90d'
}

var locationShort = locationDict[location]

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

var rootName = '${namePrefix}${organizationCode}${department}${applicationCode}${applicationInstanceCode}${environmentType}${locationShort}'
var keyvaultSharedName = take('${rootName}kv01',20)

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')
var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'
var subnetsName = '${rootName}-sn'
var adfName = '${rootName}adf'

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}


// -------------------------------------------------------------------------------------------------------------

#disable-next-line no-deployments-resources

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

// Nsg
var nsgName = '${rootName}-nsg'
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-nsg'
  params: {
    name: nsgName
    location: vNet.location
    tags: mytags
    // Required when re-running: https://github.com/Azure/azure-quickstart-templates/issues/6670
    securityRules: [
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-inbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-databricks-webapp'
        properties: {
          description: 'Required for workers communication with Databricks Webapp.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'AzureDatabricks'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-sql'
        properties: {
          description: 'Required for workers communication with Azure SQL services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3306'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Sql'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-storage'
        properties: {
          description: 'Required for workers communication with Azure Storage services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 102
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-worker-outbound'
        properties: {
          description: 'Required for worker nodes communication within a cluster.'
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
        }
      }
      {
        name: 'Microsoft.Databricks-workspaces_UseOnly_databricks-worker-to-eventhub'
        properties: {
          description: 'Required for worker communication with Azure Eventhub services.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '9093'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'EventHub'
          access: 'Allow'
          priority: 104
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Create Route table
var udrname = '${rootName}-rt'
module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: udrname
    location: vNet.location
    tags: mytags
  }
}

// Log Analytcis
var laName = '${rootName}-la'
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = if (isLogAnalyticsEnabled) {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    location: resourceGroup.location
    name: laName
    tags: mytags
  }
}

// Subnet for private endpoints
var subnet1Name = '${subnetsName}-01'
module subnetIn 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet1'
  params: {
    virtualNetworkName: vNet.name
    subnet: {
      name: subnet1Name
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      
    }
  }
}

module publicSubnet 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet2'
  params: {
    virtualNetworkName: vNet.name
    subnet: {
      name: '${subnetsName}-02'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'databricksDelegation'
          properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
          }
        }
      ]
    }
  }
  dependsOn: [
    subnetIn
  ]
}
module privateSubnet 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet3'
  params: {
    virtualNetworkName: vNet.name
    subnet: {
      name: '${subnetsName}-03'
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      delegations: [
        {
          name: 'databricksDelegation'
          properties: {
          serviceName: 'Microsoft.Databricks/workspaces'
          }
        }
      ]
    }
  }
  dependsOn: [
  publicSubnet
  ]
}

// -------------------------------------------------------------------------------------------------------------
//
// Storage account for Databricks Unity Catalog and external locations.
//
// -------------------------------------------------------------------------------------------------------------
var storageAccountName = toLower('${rootName}sa')

module storageAccountUcMod 'br/amavm:res/storage/storage-account:0.2.0' = if (isDatabricksEnabled) {
  scope: resourceGroup
  name: '${deployment().name}-${storageAccountName}'
  params:{
    name: take(storageAccountName,23)
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
      }
    ]
    location: location
    enableHierarchicalNamespace: true
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        logCategoriesAndGroups:[
          {
            category: 'Transaction'
          }
        ]
      }
    ]
    roleAssignments:union([
        {
          principalId: accessConnectorMod.outputs.systemAssignedMIPrincipalId
          roleDefinitionIdOrName: 'Storage Blob Delegator'
          principalType: 'ServicePrincipal'
        }
      ],
      (engineersGroupObjectId != '' && isDevEnvironment) ? [
        {
          roleDefinitionIdOrName: 'Storage Blob Data Reader'
          principalId: engineersGroupObjectId
          principalType: 'Group'
        }
      ] : []
    )
    blobServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
      corsRules:[ // https://learn.microsoft.com/en-us/azure/databricks/data-governance/unity-catalog/storage-cors
        {
          allowedHeaders: [
            'x-ms-blob-type'
          ]
          allowedMethods: [
            'PUT'
          ]
          allowedOrigins: [
            'https://*.azuredatabricks.net'
          ]
          exposedHeaders: [
            ''
          ]
          maxAgeInSeconds: 1800
        }
      ]
    }
    tags: mytags
  }
  dependsOn: [
    workspaceMod
  ]
}

var containers = isDatabricksEnabled ? [
  'unitycatalog' // Unity Catalog
  'externallocation1' // External location 1
  'externallocation2' // External location 2
  'libraries'
  'initscripts'
] : []

var roleStorageAccountAssignments = union(
  (engineersGroupObjectId != '' && isDevEnvironment) ? [
    {
      roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      principalId: engineersGroupObjectId
      principalType: 'Group'
    }
  ] : [],
  [
    {
      roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      principalId: accessConnectorMod.outputs.systemAssignedMIPrincipalId
      principalType: 'ServicePrincipal'
    }
  ]
)

module containerMod 'br/amavm:res/storage/storage-account/blob-service/container:0.1.0' = [for (container,index) in containers: {
  scope: resourceGroup
  name: take('${uniqueString(deployment().name, location, rootName)}-${storageAccountName}-container-${index}-${container}',64)
  params: {
    storageAccountName: isDatabricksEnabled ? storageAccountUcMod.outputs.name : ''
    name: container
    roleAssignments: roleStorageAccountAssignments
  }
}]

// -------------------------------------------------------------------------------------------------------------
//
// Azure Data Factory
//
// -------------------------------------------------------------------------------------------------------------
module azureDataFactoryMod 'br/amavm:res/data-factory/factory:0.2.0' = if (isDataFactoryEnabled) {
  scope: resourceGroup
  name: '${adfName}-mod'
  params: {
    name: adfName
    managedIdentities: {
      systemAssigned: true
    }
    gitConfigureLater: !isDevEnvironment
    gitconfiguration: isDevEnvironment ? adfRepoConfig : null
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
        name: adfName
        service: 'dataFactory'
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        logAnalyticsDestinationType: 'Dedicated'
      }
    ]
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: 'Data Factory Contributor'
        principalType: 'Group'
        description: 'Access to shared integration runtime'
      }
    ] : []
    tags: mytags
  }
}

//Create a self-hosted integration runtime for the Azure Data Factory
module adfIntegrationRuntimeMod 'br/amavm:res/data-factory/factory/integration-runtime:0.1.0' = if (isDataFactoryEnabled) {
  scope: resourceGroup
  name: '${deployment().name}-adf-shir-mod'
  params:{
    name: '${rootName}-adf-shir-01'
    dataFactoryName: azureDataFactoryMod.outputs.name
    type: 'SelfHosted'
  }
}

module adfLinkedServiceAkvMod 'br/amavm:res/data-factory/factory/linked-service:0.2.0' = if (isDataFactoryEnabled){
  scope: resourceGroup
  name: '${adfName}-lskv-mod'
  params:{
    name: 'akv-${keyvaultSharedMod.outputs.name}'
    dataFactoryName: azureDataFactoryMod.outputs.name
    type: 'AzureKeyVault'
    typeProperties: {
      azureKeyVaultLinkedServiceConfig:{
        baseUrl: keyvaultSharedMod.outputs.uri
      }
    }
  }
}

module adfLinkedServiceAdlsMod 'br/amavm:res/data-factory/factory/linked-service:0.2.0' = if (isDataFactoryEnabled && isDatabricksEnabled){
  scope: resourceGroup
  name: '${adfName}-lsadls-mod'
  dependsOn: [
    adfIntegrationRuntimeMod
  ]
  params:{
    name: 'adls-${storageAccountUcMod.outputs.name}'
    dataFactoryName: azureDataFactoryMod.outputs.name
    type: 'AzureBlobFS'
    typeProperties: {
      azureBlobFSLinkedServiceConfig: {
        url: storageAccountUcMod.outputs.primaryDfsEndpoint
      }
    }
  }
}

// Deploy Databricks Workspace
var workspaceName = '${rootName}-ws'
module workspaceMod 'br/amavm:res/databricks/workspace:0.3.0' = if (isDatabricksEnabled) {
  scope: resourceGroup
  name: '${deployment().name}-databricks-ws'
  params: {
    customPrivateSubnetName: privateSubnet.outputs.name
    customPublicSubnetName: publicSubnet.outputs.name
    customVirtualNetworkResourceId: vNet.id
    defaultStorageFirewall: 'Enabled'
    accessConnectorResourceId:accessConnectorMod.outputs.resourceId
    name: workspaceName
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
      }
    ]
    location: location
    tags: mytags
  }
  dependsOn: [ keyvaultSharedMod ]
}

module accessConnectorMod 'br/amavm:res/databricks/access-connector:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-databricks-ac'
  params: {
    name: '${workspaceName}-ac'
    location: location
    tags: mytags
  }
}

// -------------------------------------------------------------------------------------------------------------
//
// Shared services
//
// Creates following shared services:
//    Azure Key Vault
//
// -------------------------------------------------------------------------------------------------------------

module keyvaultSharedMod 'br/amavm:res/key-vault/vault:0.3.0' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location, rootName)}-${keyvaultSharedName}'
  params: {
    location: location
    name: keyvaultSharedName
    enablePurgeProtection: !isDevEnvironment
    networkAcls: {
      bypass: 'AzureServices'
    }
    privateEndpoints:[
      {
        subnetResourceId: subnetIn.outputs.resourceId
        name: keyvaultSharedName
        service: 'vault'
      }
    ]
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    roleAssignments: union(
      (engineersGroupObjectId != '' && isDevEnvironment) ? [
        {
          roleDefinitionIdOrName: 'Key Vault Secrets Officer'
          principalId: engineersGroupObjectId
          principalType: 'Group'
        }
        {
          roleDefinitionIdOrName: 'Key Vault Certificates Officer'
          principalId: engineersGroupObjectId
          principalType: 'Group'
        }
      ] : [],
      (isDataFactoryEnabled) ? [
        {
          roleDefinitionIdOrName: 'Key Vault Secrets User'
          principalId: isDataFactoryEnabled ? azureDataFactoryMod.outputs.systemAssignedMIPrincipalId : ''
          principalType: 'ServicePrincipal'
        }
      ] : []
    )
  tags: mytags
  }
}
