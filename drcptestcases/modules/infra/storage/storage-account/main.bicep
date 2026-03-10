@description('Deployment Location')
param location string

@description('Required. Name of Storage Account. Must be unique within Azure.')
@maxLength(24)
@minLength(3)
param name string

@description('ID of the subnet where the Storage Account will be deployed, if virtual network access is enabled.')
param subnetId string = ''

@description('Enable access for the Storage Account for whiteliested Vnets via public endpoint firewall. Default: false')
param enableVnet bool = false

@description('Optional. Data Lake enabled? Default: false.')
param isHnsEnabled bool = false

@description('Storage Account Access Tier. Default: Hot')
@allowed([
  'Cool'
  'Hot'
  'Premium'
])
param accessTier string = 'Hot'

@description('Storage Account Type. Use Zonal Redundant Storage when able.')
@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Premium_LRS'
])
param skuName string = 'Standard_LRS'

@description('Required. If to allow access with a shared key. Dafault: false.')
param allowSharedKeyAccess bool = false

@description('Optional. If to use AAD in the portal by default. Used only when allowSharedKeyAccess is true. Dafault: false.')
param defaultToOAuthAuthentication bool = true

@description('Optional. Resource Id of Log Analytics workspace to send diagnostics/logs to.')
param logAnalyticsWorkspaceId string = ''

@description('''
Array of role assignment objects that contain the \'roleDefinitionIdOrName\', and an inside array of 'principals' (with fields \'principalType\' and \'objectId\'), to define RBAC role assignments on this resource.
In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or the GUID ID of the role (See See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles').
roleDefinitionIdOrName : value
principals : [
  objectId: \<object Id from the AAD\>
  principalType: \<one of: 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'\>
]
''')
param roleAssignments array = []

param keyVaultName string = ''

@allowed(['None','AzureServices'])
param networkAclsBypass string = 'AzureServices'

var networkAcls = enableVnet ? {
  defaultAction: 'Deny'
  bypass: networkAclsBypass
  virtualNetworkRules: [
    {
      action: 'Allow'
      id: subnetId
    }
  ]
} : {
  defaultAction: 'Deny'
  bypass: networkAclsBypass
}

@description('Public network access to the storage account. Default: Disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: name
  location: location
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: accessTier
    isHnsEnabled: isHnsEnabled
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: allowSharedKeyAccess ? defaultToOAuthAuthentication : true
    encryption: {
      requireInfrastructureEncryption: true
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    publicNetworkAccess: publicNetworkAccess
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    networkAcls: networkAcls
    minimumTlsVersion: 'TLS1_2'
    allowCrossTenantReplication: false
  }
  tags: tags
}

var diagName = '${storageAccount.name}diag'

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: diagName
  scope: storageAccount
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: null
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

module RBAC 'modules/role-assignment.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-sta-rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principals: roleAssignment.principals
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: storageAccount.id
  }
}]

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = if (!empty(keyVaultName)) {
  name: keyVaultName
}

module secret1 '../../security/keyvault/modules/secrets.bicep' = if (!empty(keyVaultName)) {
  name: '${deployment().name}-secret1'
  params: {
    keyVaultName: keyVault.name
    secretName: '${storageAccount.name}-primary-key'
    secretValue: storageAccount.listKeys().keys[0].value
  }
}

module secret2 '../../security/keyvault/modules/secrets.bicep' = if (!empty(keyVaultName)) {
  name: '${deployment().name}-secret2'
  params: {
    keyVaultName: keyVault.name
    secretName: '${storageAccount.name}-secondary-key'
    secretValue: storageAccount.listKeys().keys[1].value
  }
}


@description('The name of the Storage Account resource')
output name string = name

@description('The ID of the Storage Account. Use this ID to reference the Storage Account in other Azure resource deployments.')
output id string = storageAccount.id

output keyVaultKeyNames array = (!empty(keyVaultName)) ? [
  '${storageAccount.name}-primary-key'
  '${storageAccount.name}-secondary-key'
]: []
