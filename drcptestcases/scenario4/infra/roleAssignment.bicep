@description('Name of the storage account to scope the role assignment to.')
param storageAccountName string

@description('Principal ID to assign the role to.')
param principalId string

@description('Principal type (e.g., ServicePrincipal, Group, User).')
param principalType string = 'ServicePrincipal'

@description('Built-in role definition ID (GUID only).')
param roleDefinitionId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, roleDefinitionId)
  scope: storageAccount
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
