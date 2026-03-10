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

// Resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Nsg
var nsgName =  names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
module nsg '../../modules/infra/network/network-security-group/main.bicep' = {
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
module udr '../../modules/infra/network/route-table/main.bicep' = {
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
module subnetIn '../../modules/infra/network/virtual-network-subnet/main.bicep' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet1'
  params: {
    name: subnet1Name
    vnetName: vNet.name
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    networkSecurityGroupId: nsg.outputs.id
    routeTableId: udr.outputs.id
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}


// ---------------------------------------------------------
// Shared resources
// ---------------------------------------------------------
// Log Analytics
var laName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logWorkspace '../../modules/infra/observability/logging/loganalytics.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    workspaceName: laName
    location: resourceGroup.location
    tags: tags
  }
}

// Key-vault
var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault '../../modules/infra/security/keyvault/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: keyVaultName
    location: location
    tags: tags
    skuFamily: 'A'
    skuName: 'standard'
    enableForTemplateDeployment: true
    enablePurgeProtection: !isDevEnvironment
    allowAzureServices: true
    rbacPrincipals: union([
      {
        objectId: adf.outputs.principalId
        principalType: 'ServicePrincipal'
      }
    ], (engineersGroupObjectId!='')? [
      {
        objectId: engineersGroupObjectId
        principalType: 'Group'
      }
    ]: [])
    rbacRoles: isDevEnvironment ? [
      'a4417e6f-fecd-4de8-b567-7b0420556985' // KeyVault Certificate Officer
      '00482a5a-887f-4fb3-b363-3b7fe8e74483' // KeyVault Admin
    ] : [
      '4633458b-17de-408a-b874-0445c86b69e6' // KeyVault Secrets User
    ]
    logAnalyticsWorkspaceId: logWorkspace.outputs.id
  }
}

// Key-vault private endpoint
module keyvaultPep '../../modules/infra/network/private-endpoint/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault-pep'
  params: {
    privateEndpointName: '${keyVaultName}pep'
    location: vNet.location
    privateLinkResource: keyVault.outputs.id
    subnet: subnetIn.outputs.id
    targetSubResource: 'vault'
    tags: tags
  }
}

//----------------------------------------------------------------------------
//  Create ADF
//----------------------------------------------------------------------------

var adfName = names.outputs.namingConvention['Microsoft.DataFactory/factories']
module adf '../../modules/infra/integration/data-factory/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-adf'
  params: {
    name: adfName
    publicNetworkAccess: 'Disabled'
    enableRepo: (isDevEnvironment) ? adfRepoConfig.repoEnabled : false
    location: location
    repoAccountName: (isDevEnvironment) ? adfRepoConfig.repoAccountName : null
    repoCollaborationBranch: (isDevEnvironment) ? adfRepoConfig.repoCollaborationBranch : null
    repoProjectName: (isDevEnvironment) ? adfRepoConfig.repoProjectName : null
    repoRootFolder: (isDevEnvironment) ? adfRepoConfig.repoRootFolder : null
    repositoryName: (isDevEnvironment) ? adfRepoConfig.repositoryName : null
    repoType: 'FactoryVSTSConfiguration'
    tags: tags
    logAnalyticsWorkspaceId: logWorkspace.outputs.id
  }
}

module adfIntegrationRuntime '../../modules/infra/integration/data-factory/integrationRuntime.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-selfhostedIR'
  params: {
    adfName: adf.outputs.name
    linkedIntegrationRuntime: false
  }
}

module adfPe '../../modules/infra/network/private-endpoint/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-adf-pe'
  params: {
    location: vNet.location
    privateEndpointName: '${adf.outputs.name}-pep'
    privateLinkResource: adf.outputs.id
    subnet: subnetIn.outputs.id
    targetSubResource: 'dataFactory'
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
    shIrName: adfIntegrationRuntime.outputs.name
    keyVaultName: keyVault.outputs.name
  }
}
