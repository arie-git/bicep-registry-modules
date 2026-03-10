param workspaceName string

param location string = resourceGroup().location

@description('CapacityReservation | LACluster | PerGB2018')
@allowed([
  'CapacityReservation'
  'LACluster'
  'PerGB2018'
])
param sku string = 'PerGB2018'

param disableLocalAuth bool = true
param enableDataExport bool = false
param enableLogAccessUsingOnlyResourcePermissions bool = true
param retentionInDays int = 30
param immediatePurgeDataOn30Days bool = true

param publicNetworkAccessForQuery string = 'Enabled'
param publicNetworkAccessForIngestion string = 'Enabled'

param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    features: {
      disableLocalAuth: disableLocalAuth
      enableDataExport: enableDataExport
      enableLogAccessUsingOnlyResourcePermissions: enableLogAccessUsingOnlyResourcePermissions
      immediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    }
  }
  tags: tags
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
