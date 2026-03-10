@description('The name of the eventHub.')
param resourceName string

@description(''' An array of AAD principals to be assigned to a role. Fields:
    objectId: <oject Id from the AAD>
    principalType: <one of: 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'>
''')
param principals array

@description('A GUID or Name of the role to be assigned. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles for a list of built-in roles.')
param rbacRole string

var builtInRoleNames = {
  'Azure Event Hubs Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f526a384-b230-433a-b45c-95f59c4a2dec')
  'Azure Event Hubs Data Receiver': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a638d3c7-ab3a-418d-83e6-5f17a39d4fde')
  'Azure Event Hubs Data Sender': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '2b629674-e913-4c01-ae53-ef4638d8f975')
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Role Based Access Control Administrator (Preview)': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f58310d9-a9f6-439a-9e8d-f62e7b41a168')
  'User Access Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9')
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2023-01-01-preview' existing = {
  name: resourceName
}

resource rbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principal in principals: {
  name: guid(rbacRole, resourceName, principal.objectId)
  scope: eventHubNamespace
  properties: {
    roleDefinitionId: contains(builtInRoleNames, rbacRole) ? builtInRoleNames[rbacRole] : contains(rbacRole, '/providers/Microsoft.Authorization/roleDefinitions/') ? rbacRole : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacRole)
    principalId: principal.objectId
    principalType: principal.principalType
  }
}]
