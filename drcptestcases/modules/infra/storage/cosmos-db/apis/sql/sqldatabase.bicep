param cosmosDbAccountName string

param cosmosSqlDatabaseName string

param throughput int = 0

param enableThroughputAutoscale bool = true

param autoscaleMaxThroughput int = 10000

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosDbAccountName
}

var options = (throughput > 0) ? {
  throughput: throughput
  autoscaleSettings: (enableThroughputAutoscale) ? {
    maxThroughput: autoscaleMaxThroughput
  } : {}
} : (enableThroughputAutoscale) ? {
  autoscaleSettings: {
    maxThroughput: autoscaleMaxThroughput
  }
} : {}

resource cosmosSqlDb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  name: cosmosSqlDatabaseName
  parent: cosmosDbAccount
  properties: {
    resource: {
      id: cosmosSqlDatabaseName
    }
    options: options
  }
}

output id string = cosmosSqlDb.id
output name string = cosmosSqlDb.name
