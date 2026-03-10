@description('Name of the Event Hub namespace to scope the role assignment to.')
param eventHubNamespaceName string

@description('Principal ID to assign the role to.')
param principalId string

@description('Principal type (e.g., ServicePrincipal, Group, User).')
param principalType string = 'ServicePrincipal'

@description('Built-in role definition ID (GUID only).')
param roleDefinitionId string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: eventHubNamespaceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(eventHubNamespace.id, principalId, roleDefinitionId)
  scope: eventHubNamespace
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
