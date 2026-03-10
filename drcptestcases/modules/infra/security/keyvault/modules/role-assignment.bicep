@description('The name of the KeyVault.')
param resourceName string

@description(''' An array of AAD principals to be assigned to a role. Fields:
    objectId: <oject Id from the AAD>
    principalType: <one of: 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'>
''')
param principals array

@description('A GUID of the role to be assigned. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#key-vault-administrator')
param rbacRole string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: resourceName
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principal in principals: {
  name: guid(rbacRole, resourceName, principal.objectId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacRole)
    principalId: principal.objectId
    principalType: principal.principalType
  }
}]
