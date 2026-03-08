metadata name = 'Log Analytics Workspace'
metadata description = 'This module deploys a Log Analytics Workspace.'
metadata owner = 'AMCCC'
metadata compliance = 'Ensure that local authentication and data export are disabled, no linked storage accounts, and that resource permissions are used for access.'
metadata complianceVersion = '20240626'

@description('Required. Name of the Log Analytics workspace.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. The name of the SKU.')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param skuName string = 'PerGB2018'

@minValue(100)
@maxValue(5000)
@description('Optional. The capacity reservation level in GB for this workspace, when CapacityReservation sku is selected. Must be in increments of 100 between 100 and 5000.')
param skuCapacityReservationLevel int = 100

@description('Optional. List of storage accounts to be read by the workspace.')
param storageInsightsConfigs array = []

@description('Optional. List of services to be linked.')
param linkedServices array = []

@description('''Conditional. List of Storage Accounts to be linked.
Required if \'forceCmkForQuery\' is set to \'true\' and \'savedSearches\' is not empty.

Setting this parameter to any value other than empty array (or null), will make the resource non-compliant.''')
param linkedStorageAccounts array = []

@description('Optional. Kusto Query Language searches to save.')
param savedSearches array = []

@description('''Optional. Data export instances to be deployed.

Setting this parameter to any value other than empty array (or null), will make the resource non-compliant.''')
param dataExports array = []

@description('Optional. Data sources to configure.')
param dataSources array = []

@description('Optional. Custom tables to be deployed.')
param tables array = []

@description('Optional. Number of days data will be retained for.')
@minValue(0)
@maxValue(730)
param dataRetention int = 365

@description('Optional. The workspace daily quota for ingestion.')
@minValue(-1)
param dailyQuotaGb int = -1

@description('''Optional. The network access type for accessing Log Analytics ingestion.
When set to 'Enabled' the public access is allowed. Default: Enabled''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('''Optional. The network access type for accessing Log Analytics query.
When set to 'Enabled' the public access is allowed. Default: Enabled''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('''Optional. The managed identity definition for this resource. Default: { systemAssigned: true }.

!!! Only one type of identity is supported by this resource: system-assigned or user-assigned, but not both.

To disable creating a system-assigned identity, provide an empty object {} or null.
''')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('''Optional. Set to \'true\' to use resource or workspace permissions. and \'false\' (or leave empty) to require workspace permissions. Default: true

Setting this parameter to 'false' will make the resource non-compliant.
''')
param useResourcePermissions bool = true

@description('''Optional. Disable non Entra ID authentication, such as secret key access. Default: true


Setting this parameter to 'false' will make the resource non-compliant.
''')
param disableLocalAuth bool = true

@description('''Optional. Set to 'true' to allow exporting data. Default: false

Setting this parameter to 'true' will make the resource non-compliant.
''')
param enableDataExport bool = false

@description('Optional. Set to \'true\' to purge data immediately on 30 days. Default: false.')
param immediatePurgeDataOn30Days bool = false

@metadata({
  example: 'Available log categories: \'Audit\', \'SummaryLogs\''
})
@description('''Optional. The diagnostic settings of the service.

Known log categories: 'Audit', 'SummaryLogs'.

Known metrics categories: 'AllMetrics'.
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. Indicates whether customer managed storage is mandatory for query management.')
param forceCmkForQuery bool = true

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? 'SystemAssigned'
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'Log Analytics Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','92aaf0da-9dab-42b6-94a3-d43ce8d16293')
  'Log Analytics Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','73c42c96-874c-492b-b04d-ab87d138a893')
  'Monitoring Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','749f88d5-cbae-40b8-bcfc-e573ddc772fa')
  'Monitoring Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','43d0d8ad-25c7-4714-9337-8ba259a9fe05')
  'Security Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','fb1c8493-542b-48eb-b624-b4c8fea62acd')
  'Security Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','39bc4728-0917-49c7-9d2c-d95423bc2eb4')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

// When a diagnostic setting is provided without the log category, this array will be used to define defaults
var defaultLogCategoryNames = [
  'Audit'
  'SummaryLogs'
  'AllMetrics'
]
var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]



#disable-next-line prefer-interpolation
var concatUniqueIds = concat(location, name)
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.operationalinsights-workspace.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, concatUniqueIds), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  location: location
  name: name
  tags: finalTags
  properties: {
    features: {
      searchVersion: 1
      enableLogAccessUsingOnlyResourcePermissions: useResourcePermissions
      disableLocalAuth: disableLocalAuth
      enableDataExport: enableDataExport
      immediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    }
    sku: {
      name: skuName
      capacityReservationLevel: skuName == 'CapacityReservation' ? skuCapacityReservationLevel : null
    }
    retentionInDays: dataRetention
    workspaceCapping: {
      dailyQuotaGb: dailyQuotaGb
    }
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    forceCmkForQuery: forceCmkForQuery
  }
  identity: identity
}

#disable-next-line use-recent-api-versions
resource logAnalyticsWorkspace_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: logAnalyticsWorkspace
  }
]

module logAnalyticsWorkspace_storageInsightConfigs 'storage-insight-config/main.bicep' = [
  for (storageInsightsConfig, index) in storageInsightsConfigs: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-storageinsightsconfig-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      containers: storageInsightsConfig.?containers ?? []
      tables: storageInsightsConfig.?tables ?? []
      storageAccountResourceId: storageInsightsConfig.storageAccountResourceId
    }
  }
]

module logAnalyticsWorkspace_linkedServices 'linked-service/main.bicep' = [
  for (linkedService, index) in linkedServices: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-linkedservice-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      name: linkedService.name
      resourceId: linkedService.?resourceId ?? ''
      writeAccessResourceId: linkedService.?writeAccessResourceId ?? ''
    }
  }
]

module logAnalyticsWorkspace_linkedStorageAccounts 'linked-storage-account/main.bicep' = [
  for (linkedStorageAccount, index) in linkedStorageAccounts: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-linkedstorageaccount-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      name: linkedStorageAccount.name
      resourceId: linkedStorageAccount.resourceId
    }
  }
]

module logAnalyticsWorkspace_savedSearches 'saved-search/main.bicep' = [
  for (savedSearch, index) in savedSearches: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-savedsearch-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      name: '${savedSearch.name}${uniqueString(deployment().name)}'
      etag: savedSearch.?etag
      displayName: savedSearch.displayName
      category: savedSearch.category
      query: savedSearch.query
      functionAlias: savedSearch.?functionAlias
      functionParameters: savedSearch.?functionParameters
      version: savedSearch.?version
    }
    dependsOn: [
      logAnalyticsWorkspace_linkedStorageAccounts
    ]
  }
]

module logAnalyticsWorkspace_dataExports 'data-export/main.bicep' = [
  for (dataExport, index) in dataExports: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-dataexport-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      name: dataExport.name
      destination: dataExport.?destination ?? {}
      enable: dataExport.?enable ?? false
      tableNames: dataExport.?tableNames ?? []
    }
  }
]

module logAnalyticsWorkspace_dataSources 'data-source/main.bicep' = [
  for (dataSource, index) in dataSources: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-datasource-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      name: dataSource.name
      kind: dataSource.kind
      linkedResourceId: dataSource.?linkedResourceId ?? ''
      eventLogName: dataSource.?eventLogName ?? ''
      eventTypes: dataSource.?eventTypes ?? []
      objectName: dataSource.?objectName ?? ''
      instanceName: dataSource.?instanceName ?? ''
      intervalSeconds: dataSource.?intervalSeconds ?? 60
      counterName: dataSource.?counterName ?? ''
      state: dataSource.?state ?? ''
      syslogName: dataSource.?syslogName ?? ''
      syslogSeverities: dataSource.?syslogSeverities ?? []
      performanceCounters: dataSource.?performanceCounters ?? []
    }
  }
]

module logAnalyticsWorkspace_tables 'table/main.bicep' = [
  for (table, index) in tables: {
    name: '${uniqueString(deployment().name, location)}-loganalytics-table-${index}'
    params: {
      logAnalyticsWorkspaceName: logAnalyticsWorkspace.name
      name: table.name
      plan: table.?plan
      schema: table.?schema
      retentionInDays: table.?retentionInDays
      totalRetentionInDays: table.?totalRetentionInDays
      restoredLogs: table.?restoredLogs
      searchResults: table.?searchResults
      roleAssignments: table.?roleAssignments
    }
  }
]

resource logAnalyticsWorkspace_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: logAnalyticsWorkspace
}

resource logAnalyticsWorkspace_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(logAnalyticsWorkspace.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      #disable-next-line use-safe-access
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: logAnalyticsWorkspace
  }
]

@description('The resource ID of the deployed log analytics workspace.')
output resourceId string = logAnalyticsWorkspace.id

@description('The resource group of the deployed log analytics workspace.')
output resourceGroupName string = resourceGroup().name

@description('The name of the deployed log analytics workspace.')
output name string = logAnalyticsWorkspace.name

@description('The ID associated with the workspace.')
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.properties.customerId

@description('The location the resource was deployed into.')
output location string = logAnalyticsWorkspace.location

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = logAnalyticsWorkspace.?identity.?principalId ?? ''

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !useResourcePermissions || !disableLocalAuth || enableDataExport || !empty(linkedStorageAccounts)

// =============== //
//   Definitions   //
// =============== //

import {diagnosticSettingType, lockType, managedIdentitiesType, roleAssignmentType} from '../../../../bicep-shared/types.bicep'
