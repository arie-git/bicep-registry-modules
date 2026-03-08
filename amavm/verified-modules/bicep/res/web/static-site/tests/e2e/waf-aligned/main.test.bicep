targetScope = 'subscription'

metadata name = '(Not working) WAF-aligned'
metadata description = 'This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-storage.storageaccounts-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'wafwss'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

@description('Required. The name of the Virtual Network to create.')
param virtualNetworkName string

@description('Required. The name of the Function App to create.')
param siteName string

@description('Required. The name of the Server Farm to create.')
param serverFarmName string

// var addressPrefix = '10.0.0.0/16'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    serverFarmName: serverFarmName
    siteName: siteName
    virtualNetworkName: virtualNetworkName
    location: resourceLocation
  }
}

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    name: '${namePrefix}${serviceShort}01'
    location: resourceLocation
    buildProperties: {
      appLocation: '/'
    }
    privateEndpoints: [
      {
        subnetResourceId: nestedDependencies.outputs.subnetResourceId
      }
    ]
    //TODO: WAF
  }
}
