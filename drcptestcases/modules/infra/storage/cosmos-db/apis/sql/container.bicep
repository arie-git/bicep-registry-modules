param cosmosDbAccountName string

param cosmosSqlDatabaseName string

param containerName string

param partitionKey string

@allowed([
  'Hash'
  'MultiHash'
  'Range'
])
param partitionKeyKind string = 'Hash'

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosDbAccountName
}

resource cosmosSqlDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' existing = {
  name: cosmosSqlDatabaseName
  parent: cosmosDbAccount
}

resource cosmosSqlDbContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  name: containerName
  parent: cosmosSqlDb
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        kind: partitionKeyKind
        paths: [
          '/${partitionKey}'
        ]
      }
    }
  }
}

output id string = cosmosSqlDbContainer.id

output nme string = cosmosSqlDbContainer.name
