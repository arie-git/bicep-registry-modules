metadata name = 'Application Insights'
metadata description = 'This component deploys an Application Insights instance.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''

Ensure that:
- don't use certain log categories in diagnostic settings ("AppEvents", "AppExceptions", "AppRequests", "AppTraces")
- not tags named 'hidden-link:Insights.Sourcemap.Storage'
'''

@description('Required. Name of the Application Insights.')
param name string

@description('''Optional. The kind of application that this component refers to, used to customize UI.
This value is a freeform string, values should typically be one of the following: web, ios, other, store, java, phone. Default is set to 'web'
''')
param kind string = 'web'

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Application type. Default is set to \'web\'')
@allowed([
  'web'
  'other'
])
param applicationType string = 'web'

@description('Required. Resource ID of the log analytics workspace which the data will be ingested to. This property is required to create an application with this API version. Applications from older versions will not have this property.')
param workspaceResourceId string

@description('Optional. Disable IP masking. Default value is set to true.')
param disableIpMasking bool = true

@description('''Optional. Disable Non-AAD based Auth. Default value is set to true.
''')
param disableLocalAuth bool = true

@description('Optional. Force users to create their own storage account for profiler and debugger. Default is set to false.')
param forceCustomerStorageForProfiler bool = false

@description('Optional. Purge data immediately after 30 days.  Default is set to false.')
param immediatePurgeDataOn30Days bool = false

@description('Optional. Linked storage account resource ID.')
param linkedStorageAccountResourceId string?

@description('Optional. The network access type for accessing Application Insights ingestion. - Enabled or Disabled. Default is Enabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. The network access type for accessing Application Insights query. - Enabled or Disabled. Default is Enabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Optional. Retention period in days. Default is 365.')
@allowed([
  30
  60
  90
  120
  180
  270
  365
  550
  730
])
param retentionInDays int = 365

@description('Optional. Percentage of the data produced by the application being monitored that is being sampled for Application Insights telemetry. Default is 100.')
@minValue(0)
@maxValue(100)
param samplingPercentage int = 100

@description('Optional. Used by the Application Insights system to determine what kind of flow this component was created by. This is to be set to \'Bluefield\' when creating/updating a component via the REST API.')
param flowType string?

@description('Optional. Describes what tool created this Application Insights component. Customers using this API should set this to the default \'rest\'.')
param requestSource string?

@description('Optional. Indicates the flow of the ingestion.')
@allowed([
  'ApplicationInsights'
  'ApplicationInsightsWithDiagnosticSettings'
  'LogAnalytics'
])
param ingestionMode string?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('''Optional. The diagnostic settings of the service.

Use of any of the following categories will make this resource non-compliant: "AppEvents", "AppExceptions", "AppRequests", "AppTraces"
''')
param diagnosticSettings diagnosticSettingType?

@description('Optional. The lock settings of the service.')
param lock lockType

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId as telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'Monitoring Metrics Publisher': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '3913510d-42f4-4e42-8a64-420c390055eb'
  )
  'Application Insights Component Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'ae349356-3a1b-4a5e-921d-050484c6347e'
  )
  'Application Insights Snapshot Debugger': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '08954f03-6346-4c2e-81c0-ec3a5cfae23b'
  )
  'Monitoring Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
  )
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)


var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// When a diagnostic setting is provided without the log category, this array will be used to define defaults
var defaultLogCategoryNames = [
  'AppAvailabilityResults'
  'AppBrowserTimings'
  'AppMetrics'
  'AppDependencies'
  'AppPageViews'
  'AppPerformanceCounters'
  'AppSystemEvents'
  // 'AppEvents'
  // 'AppExceptions'
  // 'AppRequests'
  // 'AppTraces'
]
var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]


#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take('${telemetryId}.res.insights-component.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}',64)
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

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  tags: finalTags
  kind: kind
  properties: {
    Application_Type: applicationType
    DisableIpMasking: disableIpMasking
    DisableLocalAuth: disableLocalAuth
    ForceCustomerStorageForProfiler: forceCustomerStorageForProfiler
    ImmediatePurgeDataOn30Days: immediatePurgeDataOn30Days
    WorkspaceResourceId: workspaceResourceId
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    RetentionInDays: retentionInDays
    SamplingPercentage: samplingPercentage
    Flow_Type: flowType
    Request_Source: requestSource
    IngestionMode: ingestionMode
  }
}

resource appInsights_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: appInsights
}

module linkedStorageAccount 'linkedStorageAccounts/main.bicep' = if (!empty(linkedStorageAccountResourceId)) {
  name: '${uniqueString(deployment().name, location)}-appInsights-linkedstorageaccount'
  params: {
    appInsightsName: appInsights.name
    storageAccountResourceId: linkedStorageAccountResourceId ?? ''
  }
}

resource appInsights_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(appInsights.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: appInsights
  }
]

#disable-next-line use-recent-api-versions
resource appInsights_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: appInsights
  }
]

@description('The name of the application insights component.')
output name string = appInsights.name

@description('The resource ID of the application insights component.')
output resourceId string = appInsights.id

@description('The resource group the application insights component was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The application ID of the application insights component.')
output applicationId string = appInsights.properties.AppId

@description('The location the resource was deployed into.')
output location string = appInsights.location

@description('Application Insights Instrumentation key. A read-only value that applications can use to identify the destination for all telemetry sent to Azure Application Insights. This value will be supplied upon construction of each new Application Insights component.')
output instrumentationKey string = appInsights.properties.InstrumentationKey

@description('Application Insights Connection String.')
output connectionString string = appInsights.properties.ConnectionString

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !disableLocalAuth


// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  roleAssignmentType
  lockType
} from '../../../../bicep-shared/types.bicep'

