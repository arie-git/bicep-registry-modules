metadata name = 'Log Analytics Workspace Data Exports'
metadata description = 'This module deploys a Log Analytics Workspace Data Export.'
metadata owner = 'AMCCC'

// ============== //
//   Parameters   //
// ============== //

@description('Required. The data export rule name.')
@minLength(4)
@maxLength(63)
param name string

@description('Required. The name of the parent workspaces.')
param logAnalyticsWorkspaceName string

@description('Optional. Destination properties.')
param destination object = {}

@description('Optional. Active when enabled.')
param enable bool = false

@description('Optional. An array of tables to export, for example: [\'Heartbeat\', \'SecurityEvent\'].')
param tableNames array = []

// =============== //
//   Deployments   //
// =============== //

resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource dataExport 'Microsoft.OperationalInsights/workspaces/dataExports@2025-02-01' = {
  parent: workspace
  name: name
  properties: {
    destination: destination
    enable: enable
    tableNames: tableNames
  }
}

// =========== //
//   Outputs   //
// =========== //

@description('The name of the data export.')
output name string = dataExport.name

@description('The resource ID of the data export.')
output resourceId string = dataExport.id

@description('The name of the resource group the data export was created in.')
output resourceGroupName string = resourceGroup().name
