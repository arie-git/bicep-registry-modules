@description('Name of the storage account under which the Tabe will be created.')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Name of the storage account table.')
@minLength(3)
@maxLength(63)
param name string

@description('Log Analytics workspace resource id.')
param logAnalyticsWorkspaceId string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: name
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

// https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/resource-manager-diagnostic-settings?tabs=bicep#diagnostic-setting-for-azure-storage
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'blobdiag'
  scope: blobService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: null
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
  }
}

output name string = blobContainer.name
output id string = blobContainer.id
