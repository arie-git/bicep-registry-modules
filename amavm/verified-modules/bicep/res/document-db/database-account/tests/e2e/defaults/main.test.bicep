targetScope = 'subscription'

metadata name = 'Cosmos DB - Defaults'
metadata description = 'This test deploys a Cosmos DB account with default (NoSQL) configuration and private endpoint (public network access denied by policy).'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-cosmosdb-defaults-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'cdbdef'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies '../waf-aligned/dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    virtualNetworkName: 'dep-${namePrefix}-vnet-${serviceShort}'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: 'cosmos-${serviceShort}-${substring(uniqueString(deployment().name), 0, 4)}'
      location: resourceLocation
      networkRestrictions: {
        publicNetworkAccess: 'Disabled'
      }
      privateEndpoints: [
        {
          service: 'Sql'
          subnetResourceId: nestedDependencies.outputs.subnetResourceId
          privateDnsZoneResourceIds: [
            nestedDependencies.outputs.privateDNSZoneResourceId
          ]
        }
      ]
      sqlDatabases: [
        {
          name: 'testdb'
        }
      ]
    }
  }
]
