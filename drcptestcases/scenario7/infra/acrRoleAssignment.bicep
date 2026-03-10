@description('Name of the Container Registry to scope the role assignment to.')
param containerRegistryName string

@description('Principal ID to assign the role to.')
param principalId string

@description('Principal type (e.g., ServicePrincipal, Group, User).')
param principalType string = 'ServicePrincipal'

@description('Built-in role definition ID (GUID only).')
param roleDefinitionId string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: containerRegistryName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, principalId, roleDefinitionId)
  scope: containerRegistry
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
