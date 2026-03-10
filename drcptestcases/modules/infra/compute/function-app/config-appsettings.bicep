// https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings

param functionAppName string

@description('Required. Version of the functions extension.')
@allowed([
  '~4'
])
param functionsExtensionVersion string = '~4'

@description('The language worker runtime to load in the function app. This corresponds to the language being used in your application (for example, dotnet).')
@allowed([
  'dotnet'
  'dotnet-isolated'
  'node'
  'python'
  'java'
  'powershell'
  'custom'
  ''
])
param functionsWorkerRuntime string

@description('Optional. NodeJS version.')
param functionsDefaultNodeversion string = '~18'

@description('Should function app use managed identity and RBAC to access storage account. Default: true')
param storageAccountUseManagedIdentity bool = true

@description('Name of the storage account used by function app. Required for Premium plans and some extensions.')
param storageAccountName string = ''

// @description('Optional. Resource Group of storage account used by function app, if different from the current one.')
// param storageAccountResourceGroupName string = resourceGroup().name

@description('''Optional. Extra app settings that should be provisioned while creating the function app.
Note! Settings below should not be included unless absolutely necessary, because any settings in this param will override the ones added by the module by default:
AzureWebJobsStorage
AzureWebJobsDashboard
APPINSIGHTS_INSTRUMENTATIONKEY
APPLICATIONINSIGHTS_CONNECTION_STRING
FUNCTIONS_EXTENSION_VERSION
FUNCTIONS_WORKER_RUNTIME
Project
WEBSITE_CONTENTSHARE
WEBSITE_CONTENTAZUREFILECONNECTIONSTRING
WEBSITES_ENABLE_APP_SERVICE_STORAGE
WEBSITE_ENABLE_SYNC_UPDATE_SITE
WEBSITE_NODE_DEFAULT_VERSION
WEBSITE_RUN_FROM_PACKAGE
''')
param extraAppSettings object = {}

@description('Optional. Enable Source control for the function. Default: false')
param enableSourceControl bool = false

@description('Optional. Folder path within source control repository to use.')
param repoFolder string = ''

@description('Optional. Enable Source control for the function. Default: false')
param enablePackageDeploy bool = false

// @description('Optional. Enabled application insights for Azure functions. Default: false')
// param enableInsights bool = false

@description('Optional. Name of the application insights resource to use.')
param applicationInsightsName string = ''

@description('Optional. Enable support for Docker containers. Default: false')
param enableDockerContainer bool = false

// get reference to function app
resource functionApp 'Microsoft.Web/sites@2023-12-01' existing = {
  name: functionAppName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' existing = if (!empty(storageAccountName)) {
  name: storageAccountName
  // scope: resourceGroup(storageAccountResourceGroupName)
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = if (applicationInsightsName!='') {
  name: applicationInsightsName
}

// create new module for other config types (logs)

@description('Appsettings/config for the sites (app or functionapp).')
resource config 'Microsoft.Web/sites/config@2023-12-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: union({
      FUNCTIONS_EXTENSION_VERSION:  functionsExtensionVersion
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: !enableDockerContainer // https://learn.microsoft.com/en-us/azure/app-service/configure-custom-container?pivots=container-linux&tabs=debian#use-persistent-shared-storage

      // TODO: Elastic Premium and other tiers support
        //WEBSITE_DNS_SERVER: '168.63.129.16'  // needed for Elastic Premium plan when using private endpoint for storage
        //WEBSITE_CONTENTSHARE: name  // needed for Elastic Premium and Consumption plans
        //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: !empty(storageAccount.id) ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};' : any(null)  // needed for Elastic Premium and Consumption plans
    },
    !enableDockerContainer && functionsWorkerRuntime != '' ? {
      FUNCTIONS_WORKER_RUNTIME: functionsWorkerRuntime
    } : {},
    (storageAccountName != '' && storageAccountUseManagedIdentity) ? {
      AzureWebJobsStorage__accountName: storageAccount.name
      AzureWebJobsDashboard__accountName: storageAccount.name
    } : {},
    // (storageAccountName != '' && !storageAccountUseManagedIdentity) ? {
    //   AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value};'
    //   AzureWebJobsDashboard: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value};'
    // } : {},
    (functionsWorkerRuntime == 'node' && functionsDefaultNodeversion != '') ? {
      WEBSITE_NODE_DEFAULT_VERSION: functionsDefaultNodeversion
    } : {},
    (applicationInsightsName != '') ? {
      APPINSIGHTS_INSTRUMENTATIONKEY: appInsights.properties.InstrumentationKey
      APPLICATIONINSIGHTS_CONNECTION_STRING: appInsights.properties.ConnectionString
    } : {},
    enableSourceControl && !enableDockerContainer ? {
      WEBSITE_RUN_FROM_PACKAGE: 0
      Project: repoFolder
    } : {},
    enablePackageDeploy && !enableDockerContainer ? {
      WEBSITE_RUN_FROM_PACKAGE: 1
    } : {},
    extraAppSettings)
}

output resourceId string = config.id
