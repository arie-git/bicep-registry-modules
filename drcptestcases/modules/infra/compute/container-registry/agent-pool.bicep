@minLength(5)
@maxLength(50)
@description('The name of the Azure Container Registry.')
param acrName string

param name string = 'defaultpool'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tags for all resource(s).')
param tags object = {}

param virtualNetworkSubnetResourceId string = ''

param poolCount int = 1

@allowed([
  'Linux'
  //'Windows'
])
param OS string = 'Linux'

@allowed([
  'S1'
  'S2'
  'S3'
])
param poolTier string = 'S2'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: acrName
}

resource acrAgentPool 'Microsoft.ContainerRegistry/registries/agentPools@2025-03-01-preview' = {
  name: name
  parent: containerRegistry
  location: location
  tags: tags
  properties: {
    os: OS
    count: poolCount
    tier: poolTier
    virtualNetworkSubnetResourceId: !empty(virtualNetworkSubnetResourceId) ? virtualNetworkSubnetResourceId : null
  }
}

output name string = acrAgentPool.name
