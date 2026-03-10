@description('Required. Name of the Azure Logic App.')
param name string

@description('Required. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags for all resources within Azure Function App module.')
param tags object = {}

@description('Required. Resource Id of the hosting plan (App Service Plan) to use.')
param hostingPlanId string

@description('Required. Name of the storage account to use for the Logic App runtime and content.')
param storageAccountName string

@description('Required. Name of the file share to use for the Logic App content.')
param fileShareName string

@description('Required. Resource Id of the subnet to use for the Logic App outbound VNet integration.')
param subnetId string

@description('Optional. Name of the Application Insights instance to use for the Logic App.')
param appInsightName string = ''

@description('Optional. Resource Id of the Log Analytics instance to use for the diagnostic logs of the Logic App.')
param logAnalyticsWorkspaceId string = ''

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = if (appInsightName!='') {
  name: appInsightName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource logicApp 'Microsoft.Web/sites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlanId
    clientAffinityEnabled: true
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true
    enabled: true
    publicNetworkAccess: 'Disabled'
    httpsOnly: true
    virtualNetworkSubnetId: subnetId
    storageAccountRequired: true
    siteConfig: {
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      publicNetworkAccess: 'Disabled'
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 45
      detailedErrorLoggingEnabled: true
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~14'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: (appInsightName!='') ? appInsights.properties.InstrumentationKey : ''
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: (appInsightName!='') ? appInsights.properties.ConnectionString : ''
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=core.windows.net'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: fileShareName
        }
        {
          name: 'WEBSITE_CONTENTOVERVNET'
          value: '1'
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '10.250.2.133'
        }
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
      ]
      use32BitWorkerProcess: true
      cors: {
        allowedOrigins: [
          'https://afd.hosting.portal.azure.net'
          'https://afd.hosting-ms.portal.azure.net'
          'https://hosting.portal.azure.net'
          'https://ms.hosting.portal.azure.net'
          'https://ema-ms.hosting.portal.azure.net'
          'https://ema.hosting.portal.azure.net'
          'https://ema.hosting.portal.azure.net'
        ]
      }
    }
  }
}

// resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
//   parent: logicApp
//   name: 'logs'
//   properties: {
//     applicationLogs: {
//       fileSystem: {
//         level: 'Warning'
//       }
//     }
//     httpLogs: {
//       fileSystem: {
//         retentionInMb: 40
//         enabled: true
//       }
//     }
//     failedRequestsTracing: {
//       enabled: true
//     }
//     detailedErrorMessages: {
//       enabled: true
//     }
//   }
// }

var diagName = '${logicApp.name}diag'

//https://learn.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs#send-logs-to-azure-monitor
var diagnosticsCategories = [
  'WorkflowRuntime'
  'FunctionAppLogs'
]

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: diagName
  scope: logicApp
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [for category in diagnosticsCategories: {
      category: category
      enabled: true
    }]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Resource Id of the Logic App.')
output id string = logicApp.id
@description('Name of the Logic App.')
output name string = logicApp.name
@description('Principal Id of the identity assigned to the function app.')
output sitePrincipalId string = (logicApp.identity.type == 'SystemAssigned') ? logicApp.identity.principalId : ''
