param resourceName string

@description('''The principal ID of the user, service principal or security group to assign the role to.
'00000000-0000-0000-0000-000000000001' - Cosmos DB Built-in Data Reader
'00000000-0000-0000-0000-000000000002' - Cosmos DB Built-in Data Contributor
''')
@allowed([
  '00000000-0000-0000-0000-000000000001' //Cosmos DB Built-in Data Reader
  '00000000-0000-0000-0000-000000000002' //Cosmos DB Built-in Data Contributor
])
param rbacRole string = '00000000-0000-0000-0000-000000000002' //Cosmos DB Built-in Data Contributor

param principals array

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: resourceName
}

resource roleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2023-04-15' existing = {
  name: rbacRole
  parent: cosmosDb
}

resource roleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2023-04-15' = [for principal in principals : {
  name: guid(rbacRole, resourceName, principal.objectId)
  parent: cosmosDb
  properties: {
    principalId: principal.objectId
    roleDefinitionId: roleDefinition.id
    scope: cosmosDb.id
  }
}]
