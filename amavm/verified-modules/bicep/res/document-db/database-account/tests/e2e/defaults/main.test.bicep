targetScope = 'subscription'

metadata name = 'Cosmos DB - Defaults'
metadata description = 'This test deploys a Cosmos DB account with default (NoSQL) configuration.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-cosmosdb-defaults-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'cdbdef'

// ============ //
// Dependencies //
// ============ //

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// ============== //
// Test Execution //
// ============== //

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    name: 'cosmos-${serviceShort}-${substring(uniqueString(deployment().name), 0, 4)}'
    location: resourceLocation
    sqlDatabases: [
      {
        name: 'testdb'
      }
    ]
  }
}
