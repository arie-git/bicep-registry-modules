metadata name = 'Site Config'
metadata description = 'This module deploys a Site Configuration.'
metadata owner = 'AMCCC'

@description('Required. The name of the parent site resource.')
param appName string

@description('Optional. The web settings configuration.')
param siteConfiguration object?

resource app 'Microsoft.Web/sites@2025-03-01' existing = {
  name: appName
}

resource webSettings 'Microsoft.Web/sites/config@2025-03-01' = {
  name: 'web'
  kind: 'string'
  parent: app
  properties: siteConfiguration
}

@description('The name of the site config.')
output name string = webSettings.name

@description('The resource ID of the site config.')
output resourceId string = webSettings.id

@description('The resource group the site config was deployed into.')
output resourceGroupName string = resourceGroup().name
