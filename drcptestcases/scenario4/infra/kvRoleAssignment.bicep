@description('Name of the Key Vault to scope the role assignment to.')
param keyVaultName string

@description('Principal ID to assign the role to.')
param principalId string

@description('Principal type (e.g., ServicePrincipal, Group, User).')
param principalType string = 'ServicePrincipal'

@description('Built-in role definition ID (GUID only).')
param roleDefinitionId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, principalId, roleDefinitionId)
  scope: keyVault
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
