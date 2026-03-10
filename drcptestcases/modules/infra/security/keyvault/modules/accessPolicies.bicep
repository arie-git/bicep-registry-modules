@description('Name of the key vault.')
@maxLength(24)
param keyVaultName string
@allowed([
  'add'
  'replace'
  'remove'
])
@description('Operation to be done. One of: add, replace, remove.')
param kvAccessPolicyOperation string = 'add'
@description('Array of access policies')
param accessPolicies array

resource existingKeyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: keyVaultName
}

resource kvAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: kvAccessPolicyOperation
  parent: existingKeyVault
  properties: {
    accessPolicies: accessPolicies
  }
}
