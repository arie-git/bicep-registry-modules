// bicep code to create infra for scenario 2
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
param applicationCode string = 'scn'
@maxLength(4)
param applicationInstanceCode string = '1001'
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

@description('CIDR prefix for the virtual network. Needs a /28 prefix')
param networkAddressSpace string = ''

param engineersGroupObjectId string = ''

param tags object = {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${systemCode}'
  environmentType: environmentType
  deploymentId: deploymentId
}

param adfRepoConfig object = {}

@description('Does the ADF use linked IR? Required.')
param linkedIntegrationRuntime bool = false

@description('Dictionary of Resource id of the linked IR per environment type (dev,tst,acc,prd).')
param masterAdfIr object = {}

#disable-next-line no-unused-params
param clientsEnvironmentsAdoPrincipalIds object = {}
#disable-next-line no-unused-params
param clientsEnvironmentsAdoRoleDefinitions object = {}

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

// Resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
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

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

// Nsg
var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-nsg'
  params: {
    name: nsgName
    location: vNet.location
    tags: tags
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
var udrname = names.outputs.namingConvention['Microsoft.Network/routeTables']
module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: udrname
    location: vNet.location
    tags: tags
  }
}

// Log Analytcis
var laName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    location: resourceGroup.location
    name: laName
    tags: tags
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
        subnetResourceId: subnetIn.outputs.resourceId
        tags: tags
      }
    ]
    publicNetworkAccess: 'Disabled'
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

//----------------------------------------------------------------------------
//  Create ADF (AMAVM module — replaces local data-factory, PE, diagnostics)
//  Supports pure Bicep deployment (no Git) — set adfRepoConfig = {} or omit
//----------------------------------------------------------------------------
var adfName = names.outputs.namingConvention['Microsoft.DataFactory/factories']
var enableGitConfig = isDevEnvironment && !empty(adfRepoConfig) && contains(adfRepoConfig, 'repoEnabled') && bool(adfRepoConfig.repoEnabled)

// Storage account name vars (for linked service URL construction)
var adlsName = '${take(storageAccountName, 23)}1'
var storageBackendName = '${take(storageAccountName, 23)}2'
var adlsUcName = '${take(storageAccountName, 23)}3'

module adf 'br/amavm:res/data-factory/factory:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-adf'
  params: {
    name: adfName
    location: location
    tags: tags
    publicNetworkAccess: 'Disabled'

    // Git — only in dev with explicit opt-in; otherwise pure Bicep deployment
    gitConfigureLater: !enableGitConfig
    gitconfiguration: enableGitConfig ? {
      gitRepoType: 'FactoryVSTSConfiguration'
      gitAccountName: 'connectdrcpapg1'
      gitProjectName: adfRepoConfig.repoProjectName
      gitRepositoryName: adfRepoConfig.repositoryName
      gitCollaborationBranch: contains(adfRepoConfig, 'repoCollaborationBranch') ? adfRepoConfig.repoCollaborationBranch : 'main'
      gitRootFolder: contains(adfRepoConfig, 'repoRootFolder') ? adfRepoConfig.repoRootFolder : '/'
      gitDisablePublish: false
      gitTenantId: 'c1f94f0d-9a3d-4854-9288-bb90dcf2a90d'
    } : null

    // Private endpoint (replaces separate adfPe module)
    privateEndpoints: [
      {
        name: '${adfName}-pep'
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'dataFactory'
        tags: tags
      }
    ]

    // Diagnostics
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]

    // Self-hosted IR for dev (standalone); non-dev uses linked IR below
    integrationRuntimes: isDevEnvironment ? [
      {
        name: 'SelfHostedIR'
        type: 'SelfHosted'
      }
    ] : []

    //--------------------------------------------------------------------------
    //  Linked Services — pre-configured for pure Bicep pipeline deployment
    //  All use Managed Identity auth (DRCP: no keys, no secrets in config)
    //--------------------------------------------------------------------------
    linkedServices: [
      // Key Vault — secret store for pipeline credentials
      {
        name: 'ls_keyvault'
        type: 'AzureKeyVault'
        typeProperties: {
          azureKeyVaultLinkedServiceConfig: {
            baseUrl: 'https://${keyVaultName}${environment().suffixes.keyvaultDns}/'
          }
        }
        description: 'Key Vault for pipeline secret references'
      }
      // ADLS Gen2 — primary data lake (landing/staging)
      {
        name: 'ls_adls'
        type: 'AzureBlobFS'
        typeProperties: {
          azureBlobFSLinkedServiceConfig: {
            url: 'https://${adlsName}.dfs.${environment().suffixes.storage}/'
          }
        }
        description: 'ADLS Gen2 data lake'
      }
      // Blob Storage — file share & container backend
      {
        name: 'ls_blob'
        type: 'AzureBlobStorage'
        typeProperties: {
          azureBlobStorageLinkedServiceConfig: {
            serviceEndpoint: 'https://${storageBackendName}.blob.${environment().suffixes.storage}/'
            accountKind: 'StorageV2'
          }
        }
        description: 'Blob storage for ADF staging and file operations'
      }
      // ADLS Gen2 Unity Catalog — medallion architecture
      {
        name: 'ls_adls_uc'
        type: 'AzureBlobFS'
        typeProperties: {
          azureBlobFSLinkedServiceConfig: {
            url: 'https://${adlsUcName}.dfs.${environment().suffixes.storage}/'
          }
        }
        description: 'Unity Catalog ADLS — bronze/silver/gold medallion layers'
      }
      // Databricks — compute for data transformations
      {
        name: 'ls_databricks'
        type: 'AzureDatabricks'
        typeProperties: {
          azureDatabricksLinkedServiceConfig: {
            domain: 'https://${workspaceMod.outputs.workspaceUrl}'
            authentication: 'MSI'
            workspaceResourceId: workspaceMod.outputs.resourceId
            newClusterVersion: '14.3.x-scala2.12'
            newClusterNodeType: 'Standard_DS3_v2'
            clusterOption: 'Fixed'
            newClusterNumOfWorker: '1'
          }
        }
        description: 'Databricks workspace for data transformations'
      }
    ]
  }
}

var masterAdfIrId = (!empty(masterAdfIr)) ? masterAdfIr[environmentType] : '' // /subscriptions/.../resourcegroups/.../providers/Microsoft.DataFactory/factories/.../integrationruntimes/...
var masterAdfSubscriptionId = split(masterAdfIrId, '/')[2]
var masterAdfResourceGroupName = split(masterAdfIrId, '/')[4]
var masterAdfName = split(masterAdfIrId, '/')[8]
var masterAdfIrName = split(masterAdfIrId, '/')[10]

// Cross-subscription RBAC for shared IR access (non-dev only — linked IR pattern)
module roleAssignment '../../modules/infra/integration/data-factory/modules/role-assignment.bicep' = if (!isDevEnvironment) {
  name: '${deployment().name}-shir-rbac'
  scope: az.resourceGroup(masterAdfSubscriptionId, masterAdfResourceGroupName)
  params: {
    resourceName: '${masterAdfName}/${masterAdfIrName}'
    resourceType: 'integrationRuntimes'
    principalIds: [adf.outputs.systemAssignedMIPrincipalId]
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Data Factory Contributor'
  }
}
// After the role assignment, create the linked self-hosted IR (non-dev only)
module adfIntegrationRuntime '../../modules/infra/integration/data-factory/integrationRuntime.bicep' = if (!isDevEnvironment) {
  scope: resourceGroup
  name: '${deployment().name}-selfhostedIR'
  params: {
    adfName: adf.outputs.name
    linkedIntegrationRuntime: linkedIntegrationRuntime
    masterAdfIrId: masterAdfIrId
  }
  dependsOn: [
    roleAssignment
  ]
}

//----------------------------------------------------------------------------
//  Create ADLS
//----------------------------------------------------------------------------
var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']

var adlsRoles = [
  'Storage Blob Data Contributor'
]
module storageAccountAdls 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-adls'
  params: {
    location: location
    #disable-next-line BCP334
    name: adlsName
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    enableHierarchicalNamespace: true
    publicNetworkAccess: 'Disabled'
    roleAssignments: [for role in adlsRoles: {
      principalId: adf.outputs.systemAssignedMIPrincipalId
      principalType: 'ServicePrincipal'
      roleDefinitionIdOrName: role
    }]
    privateEndpoints:[
      {
        subnetResourceId: subnetIn.outputs.resourceId
      }
    ]
    blobServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    tags: tags
  }
}
//----------------------------------------------------------------------------
//  Create Storage account, File share
//----------------------------------------------------------------------------

var storageAccountBackendRoles = [
  'Storage Blob Data Contributor'
  'Storage File Data SMB Share Contributor'
]
var fileShareName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts/fileServices/shares']
var containerName = 'adf'

module storageAccount2 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-sa'
  params: {
    location: location
    #disable-next-line BCP334
    name: storageBackendName
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    // keyVaultName: keyVault.outputs.name
    blobServices:{
      containers:[
        {
          name: containerName
        }
      ]
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    fileServices:{
      shares:[
        {
          name: fileShareName
          shareQuota: 50
        }
      ]
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
    roleAssignments: [for role in storageAccountBackendRoles: {
      principalId: adf.outputs.systemAssignedMIPrincipalId
      principalType: 'ServicePrincipal'
      roleDefinitionIdOrName: role
    }]
    privateEndpoints:[
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'blob'
      }
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'file'
      }
    ]
    tags: tags
  }
}

// Deploy Databricks Workspace
var workspaceName = names.outputs.namingConvention['Microsoft.Databricks/workspaces']
module workspaceMod 'br/amavm:res/databricks/workspace:0.3.0' = {
  scope: resourceGroup
  name: '${deployment().name}-databricks-ws'
  params: {
    customPrivateSubnetName: privateSubnet.outputs.name
    customPublicSubnetName: publicSubnet.outputs.name
    customVirtualNetworkResourceId: vNet.id
    defaultStorageFirewall: 'Enabled'
    accessConnectorResourceId: accessConnectorMod.outputs.resourceId
    managedResourceGroupResourceId: '${subscription().id}/resourceGroups/${resourceGroupName}-adbmanaged-rg'  // drcp-adb-w22: managed RG name suffix
    name: workspaceName
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
      }
    ]
    location: location
    tags: tags
  }
}
module accessConnectorMod 'br/amavm:res/databricks/access-connector:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-databricks-ac'
  params: {
    name: '${workspaceName}-ac'
    location: location
    tags: tags
  }
}

//----------------------------------------------------------------------------
//  Unity Catalog — ADLS Gen2 storage for managed tables + external locations
//  Access Connector MI gets Storage Blob Data Contributor for UC data access
//  ADF MI also gets access for pipeline writes to medallion containers
//----------------------------------------------------------------------------
module storageAccountUc 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-adls-uc'
  params: {
    #disable-next-line BCP334
    name: adlsUcName
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false                   // DRCP: RBAC only
    enableHierarchicalNamespace: true              // Required for Delta Lake / Unity Catalog
    publicNetworkAccess: 'Disabled'                // DRCP: no public access
    privateEndpoints: [
      {
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'dfs'                             // Data Lake endpoint for UC
      }
    ]
    blobServices: {
      containers: [
        { name: 'unity-catalog' }                  // UC metastore root container
        { name: 'bronze' }                         // Medallion: raw landing zone
        { name: 'silver' }                         // Medallion: cleansed/conformed
        { name: 'gold' }                           // Medallion: business-level aggregates
      ]
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
    roleAssignments: [
      {
        principalId: accessConnectorMod.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'  // UC data access via Access Connector MI
      }
      {
        principalId: adf.outputs.systemAssignedMIPrincipalId
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'  // ADF pipeline writes to medallion
      }
    ]
    tags: tags
  }
}

