
param storageAccountName string

param name string

@description('Access tier for specific share. GpV2 account can choose between TransactionOptimized (default), Hot, and Cool. FileStorage account can choose Premium.')
@allowed([
  'TransactionOptimized'
  'Hot'
  'Cool'
  'Premium'
])
param accessTier string = 'TransactionOptimized'

@description('The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5TB (5120). For Large File Shares, the maximum size is 102400')
param shareQuota int = 100

param logAnalyticsWorkspaceId string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource share 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-05-01' = {
  name: name
  parent: fileService
  properties: {
    enabledProtocols: 'SMB'
    shareQuota: shareQuota
    accessTier: accessTier
  }
}


// https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/resource-manager-diagnostic-settings?tabs=bicep#diagnostic-setting-for-azure-storage
var diagnosticsCategories = [
  'StorageRead'
  'StorageWrite'
  'StorageDelete'
]
resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'blobdiag'
  scope: fileService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logAnalyticsDestinationType: null
    logs: [for category in diagnosticsCategories: {
        category: category
        enabled: true
    }]
  }
}


output name string = share.name
output id string = share.id
