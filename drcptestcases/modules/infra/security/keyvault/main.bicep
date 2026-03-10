@description('Deployment Location')
param location string

param tags object = {}

@description('Suffix of Azure Key Vault Resource name. Default: kv')
@maxLength(4)
param suffix string = 'kv'

@description('Name of the Key Vault')
@minLength(3)
@maxLength(24)
param name string = '${take(uniqueString(resourceGroup().id), 20)}${suffix}'

@description('The tenant ID where the Key Vault is deployed')
param tenantId string = subscription().tenantId

@description('Deploy Key Vault into existing Virtual Network. Enabling this setting also requires subnetID. Default: false.')
param enableVNet bool = false

@description('Subnet ID for the Key Vault')
param subnetID string = ''

@description('''Array of AAD objects/principals to assign roles on the Key Vault.
Fields:
objectId: <oject Id from the AAD>
principalType: one of: 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'
''')
param rbacPrincipals array = []

@description('RBAC roles to apply to each principal.')
param rbacRoles array = [
  '4633458b-17de-408a-b874-0445c86b69e6' // rbacSecretsReaderRole
  //'a4417e6f-fecd-4de8-b567-7b0420556985' // rbacCertificateOfficerRole
]

@allowed([ 'new', 'existing' ])
@description('Whether to create a new Key Vault or use an existing one. Default: new')
param newOrExisting string = 'new'

@description('Name of Secret to add to Key Vault. Required when provided a secretValue.')
param secretName string = ''

@secure()
@description('Value of Secret to add to Key Vault. The secretName parameter must also be provided when adding a secret.')
param secretValue string = ''

@description('Specifies whether purge protection should be enabled for the Key Vault.')
param enablePurgeProtection bool = true

@description('Specifies whether soft delete should be enabled for the Key Vault. Default: true.')
param enableSoftDelete bool = true

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enableForTemplateDeployment bool = false

@description('The number of days to retain deleted data in the Key Vault.')
param softDeleteRetentionInDays int = 7

@allowed(['standard', 'premium'])
@description('The SKU name of the Key Vault.')
param skuName string = 'standard'

@allowed(['A', 'B'])
@description('The SKU family of the Key Vault.')
param skuFamily string = 'A'

@description('Specifies if the trusted Azure services are allowed to bypass the firewall.')
param allowAzureServices bool = false

@description('Optional. Id of the log analytics workspace to send diagnostics data into. Default: empty.')
param logAnalyticsWorkspaceId string = ''

module keyVault 'modules/vaults.bicep' = {
  name: '${deployment().name}-kv'
  params: {
    location: location
    name: name
    newOrExisting: newOrExisting
    enableSoftDelete: enableSoftDelete
    enableForTemplateDeployment: enableForTemplateDeployment
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    skuFamily: skuFamily
    skuName: skuName
    tenantId: tenantId
    subnetID: subnetID
    enableVNet: enableVNet
    allowAzureServices: allowAzureServices
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    tags: tags
  }
}

module rbacRoleAssignments 'modules/role-assignment.bicep' = [for rbacRole in rbacRoles: if (length(rbacPrincipals) > 0) {
  name: take('${deployment().name}-rbac-${rbacRole}',64)
  params: {
    resourceName: keyVault.outputs.name
    principals: rbacPrincipals
    rbacRole: rbacRole
  }
}]

var createSecret = secretValue != ''

module secret 'modules/secrets.bicep' = if (createSecret) {
  name: '${deployment().name}-secret'
  params: {
    keyVaultName: keyVault.outputs.name
    secretName: secretName
    secretValue: secretValue
  }
}

@description('Key Vault Id')
output id string = keyVault.outputs.id

@description('Key Vault Name')
output name string = name

@description('Key Vault Seceret Id')
output secretId string = createSecret ? secret.outputs.id : ''

@description('Key Vault Secert Name')
output secretName string = secretName

@description('Secret URI')
output secretUri string = createSecret ? secret.outputs.secretUri : ''

@description('Secret URI with version')
output secretUriWithVersion string = createSecret ? secret.outputs.secretUriWithVersion : ''
