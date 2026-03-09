metadata name = 'Storage Account Queue Services'
metadata description = 'This module deploys a Storage Account Queue Service.'
metadata owner = 'AMCCC'

@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('''Optional. Specifies CORS rules for the File service. You can include up to five CorsRule elements in the request.
If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the File service.''')
param corsRules corsRuleType[]?

@description('Optional. Queues to create.')
param queues array?

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

// The name of the queue services
var name = 'default'

// When a diagnostic setting is provided without the log category, this array will be used to define defaults
var defaultLogCategoryNames = [
  'StorageRead'
  'StorageWrite'
  'StorageDelete'
]
var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2025-01-01' = {
  name: name
  parent: storageAccount
  properties: {
    cors: !empty(corsRules ?? []) ? {
      corsRules: corsRules
    } : null
  }
}

#disable-next-line use-recent-api-versions
resource queueServices_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? defaultLogCategories): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: queueServices
  }
]

module queueServices_queues 'queue/main.bicep' = [
  for (queue, index) in (queues ?? []): {
    name: take('${deployment().name}-queue-${index}-${queue.name}',64)
    params: {
      storageAccountName: storageAccount.name
      name: queue.name
      metadata: queue.?metadata
      roleAssignments: queue.?roleAssignments
      enableTelemetry: false
    }
  }
]

@description('The name of the deployed file share service.')
output name string = queueServices.name

@description('The resource ID of the deployed file share service.')
output resourceId string = queueServices.id

@description('The resource group of the deployed file share service.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  corsRuleType
} from '../../../../../bicep-shared/types.bicep'

import { queueServiceQueueType } from 'queue/main.bicep'

@export()
type queueServiceType = {
  @description('''Optional. Specifies CORS rules for the Queue service. You can include up to five CorsRule elements in the request.
  If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the Queue service.''')
  corsRules: corsRuleType[]?

  @description('''Optional. The diagnostic settings of the service.

  Available options for log categories are: 'StorageRead', 'StorageWrite', 'StorageDelete'
  ''')
  diagnosticSettings: diagnosticSettingType?

  @description('Optional. Queues to create.')
  queues: queueServiceQueueType[]?
}
