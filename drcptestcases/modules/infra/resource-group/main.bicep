targetScope = 'subscription'

// Resource Group general parameters
@description('Name of the resource group. Required.')
param rgName string
@description('Location of the resource group. Required.')
param location string
param tags object = {}

//RG
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
  tags: tags
  properties:{
  }
}
