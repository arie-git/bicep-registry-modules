metadata name = 'Storage Account Table Services'
metadata description = 'This module deploys a Storage Account Table Service.'
metadata owner = 'Azure/module-maintainers'
metadata compliance = 'inherited from parent'
metadata complianceVersion = '20260309'

@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('''Optional. Specifies CORS rules for the File service. You can include up to five CorsRule elements in the request.
If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the File service.''')
param corsRules corsRuleType[]?

@description('Optional. tables to create.')
param tables tableServiceType[]?

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

// The name of the table service
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

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2025-01-01' = {
  name: name
  parent: storageAccount
  properties: {
    cors: !empty(corsRules ?? []) ? {
      corsRules: corsRules
    } : null
  }
}

#disable-next-line use-recent-api-versions
resource tableServices_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: tableServices
  }
]

module tableServices_tables 'table/main.bicep' = [
  for (table, index) in (tables ?? []): {
    name: take('${deployment().name}-table-${index}-${table.name}',64)
    params: {
      name: table.name
      storageAccountName: storageAccount.name
      signedIdentifiers: table.?signedIdentifiers
      roleAssignments: table.?roleAssignments
      enableTelemetry: false
    }
  }
]

@description('The name of the deployed table service.')
output name string = tableServices.name

@description('The resource ID of the deployed table service.')
output resourceId string = tableServices.id

@description('The resource group of the deployed table service.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  corsRuleType
} from '../../../../../bicep-shared/types.bicep'

import { tableServiceTableType } from 'table/main.bicep'

@export()
type tableServiceType = {
  @description('''Optional. Specifies CORS rules for the Table service. You can include up to five CorsRule elements in the request.
  If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the Table service.''')
  corsRules: corsRuleType[]?

  @description('''Optional. The diagnostic settings of the service.

  Available options for log categories are: 'StorageRead', 'StorageWrite', 'StorageDelete'
  ''')
  diagnosticSettings: diagnosticSettingType?

  @description('Optional. Tables to create.')
  tables: tableServiceTableType[]?
}

@description('Evidence of non-compliance (inherited from parent).')
output evidenceOfNonCompliance bool = false
