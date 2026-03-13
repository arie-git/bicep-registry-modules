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
param departmentCode string = 'c3'
param applicationCode string = 'drcptst'
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
param environmentType string = 'tst'

@description('CIDR prefix for the virtual network. Needs a /28 prefix')
param networkAddressSpace string = ''

param tags object = {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${systemCode}'
  environmentType: environmentType
  deploymentId: deploymentId
}

param adfRepoConfig object

#disable-next-line no-unused-params
param engineersGroupObjectId string = ''
#disable-next-line no-unused-params
param linkedIntegrationRuntime bool = false
#disable-next-line no-unused-params
param masterAdfIr object = {}

param clientsEnvironmentsAdoPrincipalIds object = {}
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

// Resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Nsg
var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-nsg'
  params: {
    name: nsgName
    location: vNet.location
    tags: tags
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

// Subnet for private endpoints
var subnet1Name = 'central-adf-related-peps'
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


// ---------------------------------------------------------
// Shared resources
// ---------------------------------------------------------
// Log Analytics
var laName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    name: laName
    location: resourceGroup.location
    tags: tags
  }
}

// Key-vault (AMAVM — inline PE, RBAC, diagnostics)
var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault 'br/amavm:res/key-vault/vault:0.3.0' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    enableForTemplateDeployment: true
    enablePurgeProtection: !isDevEnvironment
    networkAcls: {
      bypass: 'AzureServices'
    }
    privateEndpoints: [
      {
        name: '${keyVaultName}pep'
        location: vNet.location
        service: 'vault'
        subnetResourceId: subnetIn.outputs.resourceId
        tags: tags
      }
    ]
    diagnosticSettings: [
      {
        name: '${keyVaultName}-diagnostics'
        workspaceResourceId: logWorkspace.outputs.resourceId
      }
    ]
    roleAssignments: union(
      // ADF MI roles
      isDevEnvironment ? [
        {
          principalId: adf.outputs.systemAssignedMIPrincipalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: 'a4417e6f-fecd-4de8-b567-7b0420556985' // KeyVault Certificate Officer
        }
        {
          principalId: adf.outputs.systemAssignedMIPrincipalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // KeyVault Admin
        }
      ] : [
        {
          principalId: adf.outputs.systemAssignedMIPrincipalId
          principalType: 'ServicePrincipal'
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' // KeyVault Secrets User
        }
      ],
      // Engineers group roles (if provided)
      (engineersGroupObjectId != '') ? (isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: 'a4417e6f-fecd-4de8-b567-7b0420556985' // KeyVault Certificate Officer
        }
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // KeyVault Admin
        }
      ] : [
        {
          principalId: engineersGroupObjectId
          principalType: 'Group'
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' // KeyVault Secrets User
        }
      ]) : []
    )
  }
}

//----------------------------------------------------------------------------
//  Create ADF (AMAVM — inline PE, diagnostics, self-hosted IR)
//----------------------------------------------------------------------------

var adfName = names.outputs.namingConvention['Microsoft.DataFactory/factories']
var enableGitConfig = isDevEnvironment && !empty(adfRepoConfig) && contains(adfRepoConfig, 'repoEnabled') && bool(adfRepoConfig.repoEnabled)
var shirName = 'selfhosted'

module adf 'br/amavm:res/data-factory/factory:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-adf'
  params: {
    name: adfName
    location: location
    tags: tags
    publicNetworkAccess: 'Disabled'

    // Git — only in dev with explicit opt-in
    gitConfigureLater: !enableGitConfig
    gitconfiguration: enableGitConfig ? {
      gitRepoType: 'FactoryVSTSConfiguration'
      gitAccountName: adfRepoConfig.repoAccountName
      gitProjectName: adfRepoConfig.repoProjectName
      gitRepositoryName: adfRepoConfig.repositoryName
      gitCollaborationBranch: contains(adfRepoConfig, 'repoCollaborationBranch') ? adfRepoConfig.repoCollaborationBranch : 'main'
      gitRootFolder: contains(adfRepoConfig, 'repoRootFolder') ? adfRepoConfig.repoRootFolder : '/'
      gitDisablePublish: false
    } : null

    // Private endpoint (replaces separate adfPe module)
    privateEndpoints: [
      {
        name: '${adfName}-pep'
        location: vNet.location
        subnetResourceId: subnetIn.outputs.resourceId
        service: 'dataFactory'
        tags: tags
      }
    ]

    // Diagnostics
    diagnosticSettings: [
      {
        workspaceResourceId: logWorkspace.outputs.resourceId
      }
    ]

    // Self-hosted IR (replaces separate integrationRuntime module)
    integrationRuntimes: [
      {
        name: shirName
        type: 'SelfHosted'
      }
    ]
  }
}

var assignRoles = !empty(clientsEnvironmentsAdoPrincipalIds) && contains(clientsEnvironmentsAdoPrincipalIds, environmentType) && !empty(clientsEnvironmentsAdoRoleDefinitions) && contains(clientsEnvironmentsAdoRoleDefinitions, environmentType)
module roleAssignment '../../modules/infra/security/rbac/role-assignment.bicep' = if (assignRoles) {
  name: '${deployment().name}-shir-rbac'
  scope: resourceGroup
  params: {
    principalIds: clientsEnvironmentsAdoPrincipalIds[environmentType]
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: clientsEnvironmentsAdoRoleDefinitions[environmentType]
  }
}

// Save SHIR auth info to keyvault
module shirAuth 'modules/shir-auth.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-shir-kv'
  params: {
    adfName: adf.outputs.name
    shIrName: shirName
    keyVaultName: keyVault.outputs.name
  }
}
