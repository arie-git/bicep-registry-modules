@description('Required. Name of the Application Insight.')
param name string

@description('Required. Location of the resource group.')
param location string = resourceGroup().location

@description('Optional. Tags for Application Insight.')
param tags object = {}

@description('Optional. The kind of application that this component refers to, used to customize UI.')
@allowed([
  'azfunc'
  'web'
  'java'
  'ios'
  'docker'
  'store'
  'phone'
  'other'
])
param appInsightsKind string = 'web'

@description('Optional. Application type. Default: web')
@allowed([
  'web'
  'other'
])
param appInsightsType string = 'web'

@description('Optional. Indicates the flow of the ingestion.')
@allowed([
  'ApplicationInsights'
  'ApplicationInsightsWithDiagnosticSettings'
  'LogAnalytics'
])
param ingestionMode string = 'LogAnalytics'

@description('Required. Resource Id of the log analytics workspace which the data will be ingested to.')
param logAnalyticsWorkspaceId string

param logsRetentionInDays int = 30

param tagProjectName string = ''

@description('Optional. The network access type for accessing Application Insights ingestion. - Enabled or Disabled.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Optional. The network access type for accessing Application Insights query. - Enabled or Disabled.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: appInsightsKind
  properties: {
    Application_Type: appInsightsType
    DisableLocalAuth: true
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    IngestionMode: ingestionMode
    WorkspaceResourceId: logAnalyticsWorkspaceId
    RetentionInDays: logsRetentionInDays
  }
  tags: union(tags,{
    displayName: 'AppInsight'
    ProjectName: tagProjectName
  })
}

resource appInsightsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}diag'
  scope: appInsights
  properties: {
    logs: [
      {
        enabled: true
        category: 'AppAvailabilityResults'
      }
      {
        enabled: true
        category: 'AppBrowserTimings'
      }
      // {
      //   enabled: true
      //   category: 'AppEvents'
      // }
      {
        enabled: true
        category: 'AppMetrics'
      }
      {
        enabled: true
        category: 'AppDependencies'
      }
      // {
      //   enabled: true
      //   category: 'AppExceptions'
      // }
      {
        enabled: true
        category: 'AppPageViews'
      }
      {
        enabled: true
        category: 'AppPerformanceCounters'
      }
      // {
      //   enabled: true
      //   category: 'AppRequests'
      // }
      {
        enabled: true
        category: 'AppSystemEvents'
      }
      // {
      //   enabled: true
      //   category: 'AppTraces'
      // }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

@description('Get resource id for app insight.')
output id string = appInsights.id

@description('Get resource name for app insight.')
output name string = appInsights.name


