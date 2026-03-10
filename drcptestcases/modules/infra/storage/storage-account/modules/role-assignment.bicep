param description string = ''

@sys.description('''Required. An array of AAD principals to be assigned to a role. Fields:
objectId: \<oject Id from the AAD\>
principalType: \<one of: 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'\>
''')
param principals array

@sys.description('Required. Either the display name of the role definition, or the GUID ID of the role (See See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles')
param roleDefinitionIdOrName string

@sys.description('Resourcer Id of the Container Registry.')
param resourceId string = ''

@sys.description('Name of the Container Registry.')
param resourceName string = last(split(resourceId, '/'))

var builtInRoleNames = {
  Owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  Contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  Reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  'Storage Blob Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  'Storage Blob Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  'Storage Blob Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  'Storage File Data Privileged Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , '69566ab7-960f-475b-8e7c-b3118f30c6bd')
  'Storage File Data Privileged Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , 'b8eda974-7b85-4f76-af95-65846b26df6d')
  'Storage File Data SMB Share Contributor':  subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb')
  'Storage File Data SMB Share Elevated Contributor':  subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , 'a7264617-510b-434b-a828-9731dc254ea7')
  'Storage File Data SMB Share Reader':  subscriptionResourceId('Microsoft.Authorization/roleDefinitions' , 'aba4ae5f-2193-4029-9191-0cb91df5e314')
  'Storage Table Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: resourceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principal in principals: {
  name: guid(storageAccount.name, principal.objectId, roleDefinitionIdOrName)
  properties: {
    description: description
    roleDefinitionId: contains(builtInRoleNames, roleDefinitionIdOrName) ? builtInRoleNames[roleDefinitionIdOrName] : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionIdOrName)
    principalId: principal.objectId
    principalType: !empty(principal.principalType) ? principal.principalType : null
  }
  scope: storageAccount
}]
