targetScope = 'subscription'

metadata name = 'Event Hub Namespace - Defaults'
metadata description = 'This test deploys an Event Hub Namespace with default configuration.'

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-eventhub-defaults-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment.')
param serviceShort string = 'ehndef'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies '../waf-aligned/dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    virtualNetworkName: 'dep-vnet-${serviceShort}'
    managedIdentityName: 'dep-ids-${serviceShort}'
    storageAccountName: 'depsa${serviceShort}'
  }
}

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    name: 'evhns-${serviceShort}-${substring(uniqueString(deployment().name), 0, 4)}'
    location: resourceLocation
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          nestedDependencies.outputs.privateDNSZoneResourceId
        ]
        subnetResourceId: nestedDependencies.outputs.subnetResourceId
      }
    ]
  }
}
