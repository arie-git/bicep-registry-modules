//https://learn.microsoft.com/en-us/azure/azure-functions/functions-infrastructure-as-code?tabs=bicep#create-a-function-app

@description('Required. Name for the Azure Function App.')
@maxLength(64)
param name string

@description('Required. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags for all resources within Azure Function App module.')
param tags object = {}

@description('Required. Resource Id of the hosting plan to use.')
param hostingPlanId string

@description('Required. Kind of server OS the plan will host. If Linux also required to provide linuxFxVersion.')
@allowed([ 'Windows', 'Linux' ])
param serverOS string

@allowed([
  'functionapp'
  'functionapp,linux'
  'container'
  'linux,container'
])
param kind string

@allowed(['~4'])
param functionsExtensionVersion string = '~4'

//TODO: think how to support the restrictions in the list
@description('''Only required for Linux app plan to represent runtime stack in the format of \'runtime|runtimeVersion\'.
Select from the list of supported runtimes and versions or leave empty for the custom handler option.
See https://learn.microsoft.com/en-us/azure/azure-functions/set-runtime-version?tabs=portal#manual-version-updates-on-linux for more details.
''')
@allowed([
  'DOTNET-ISOLATED|8'
  'DOTNET-ISOLATED|7'
  'DOTNET-ISOLATED|6'
  'DOTNET|6'
  'Node|18'
  'Node|16'
  'Node|14'
  'Python|3.10'
  'Python|3.9'
  'Python|3.8'
  'Python|3.7'
  'Java|17.0'
  'Java|11.0'
  'Java|8.0'
  'PowerShell|7.2'
  ''
]) // https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version
param linuxFxVersion string = ''

@allowed([
  'dotnet-isolated'
  'dotnet'
  'node'
  'python'
  'java'
  'powershell'
  'custom'
])
param functionsWorkerRuntime string

@description('Windows-only. Version of the .NET Framework used in the Function App.')
@allowed([
  'v6.0'
  'v7.0'
  'v8.0'
])
param netFrameworkVersion string = 'v8.0'

@description('Windows-only. Version of Java used in the Function App.')
@allowed([
  '17'
  '11'
  '1.8'
])
param javaVersion string = '17'

@description('Windows-only. Version of PowerShell used in the Function App.')
param powerShellVersion string = '7.2'

@description('Version of Node.js used in the Function App.')
@allowed([
  '18'
  '16'
  '14'
])
param nodeVersion string = '18'

@allowed([
  'None'
  'SystemAssigned'
  'UserAssigned'
  'SystemAssigned, UserAssigned'
])
@description('Optional. The type of identity used for the virtual machine. The type \'SystemAssigned, UserAssigned\' includes both an implicitly created identity and a set of user assigned identities. The type \'None\' will remove any identities from the sites ( app or functionapp).')
param identityType string = 'SystemAssigned'

@description('Optional. Specify the resource ID of the user assigned Managed Identity, if \'identity\' is set as \'UserAssigned\'.')
param userAssignedIdentityId string = ''

@description('Optional. Configures a site to accept only HTTPS requests. Issues redirect for HTTP requests. Default: true.')
param httpsOnly bool = true

// @description('Optional. The resource ID of the app service environment to use for this resource.')
// param appServiceEnvironmentId string = ''

@description('Optional. If client affinity is enabled. Default: true.')
param clientAffinityEnabled bool = true

@description('Optional. Enabled or Disable Insights for Azure functions')
param enableInsights bool = false

@description('Optional. Resource Group of storage account used by function app, if different from the current one.')
param applicationInsightsName string = ''

@description('Optional. Resource Id of the log analytics workspace for diagnostic logs.')
param logAnalyticsWorkspaceId string = ''

@description('Optional. List of Azure function (Actual object where our code resides).')
param functions array = []

@description('Optional. Enable Vnet Integration or not. Default: true')
param enableVnetIntegration bool = true

@description('The subnet that will be integrated to enable vnet Integration. Leave empty if enableVnetIntegration is false.')
param subnetId string

@description('Optional. Enable Source control for the function. Default: false')
param enableSourceControl bool = false

@description('Optional. Repository or source control URL.')
param repoUrl string = ''

@description('Optional. Folder in the eepository or source control.')
param repoFolder string = ''

@description('Optional. Name of branch to use for deployment.')
param branch string = ''

@description('Optional. to limit to manual integration; to enable continuous integration (which configures webhooks into online repos like GitHub). Default: false.')
param isManualIntegration bool = true

@description('Optional. True to deploy functions from zip package. \'functionPackageUri\' must be specified if enabled. The package option and sourcecontrol option should not be enabled at the same time. Default: false')
param enablePackageDeploy bool = false

@description('Optional. URI to the function source code zip package, must be accessible by the deployer. E.g. A zip file on Azure storage in the same resource group.')
param functionPackageUri string = ''

@description('Optional. Enable docker image deployment. Default: false')
param enableDockerContainer bool = false
@description('FQDN of the ACR registry.')
param dockerRegistry string = ''
@description('Image:tag. E.g. samples:aspnetapp')
param dockerRepositoryPath string = ''
param dockerStartupCommand string = ''

@description('Optional. If to apply appSettings. Default: false')
param applyDefaultAppSettings bool = false

param cors object = {}

@description('Optional. Is the function app using App Service as a hosting plan. Default: true')
param isUsingAppService bool = true

var isLinux = serverOS == 'Linux'

@description('The app or function app resource is a container for storing multiple functions.')
resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  identity: {
    type: identityType
    userAssignedIdentities: (identityType == 'UserAssigned' || identityType == 'SystemAssigned, UserAssigned') ? {
      '${userAssignedIdentityId}': {}
    } : null
  }
  properties: {
    serverFarmId: hostingPlanId
    reserved: isLinux
    publicNetworkAccess: 'Disabled'
    httpsOnly: httpsOnly
    clientAffinityEnabled: enableDockerContainer ? false : clientAffinityEnabled
    vnetImagePullEnabled: enableVnetIntegration
    vnetContentShareEnabled: enableVnetIntegration
    vnetRouteAllEnabled: enableVnetIntegration
    siteConfig: {
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
      publicNetworkAccess: 'Disabled'
      alwaysOn: isUsingAppService // for function app on App Service Plan
      linuxFxVersion: enableDockerContainer ? 'DOCKER|${dockerRegistry}/${dockerRepositoryPath}' : isLinux ? linuxFxVersion : null
      appCommandLine: enableDockerContainer ? dockerStartupCommand : null
      acrUseManagedIdentityCreds: true
      vnetRouteAllEnabled: enableVnetIntegration // https://learn.microsoft.com/en-us/azure/azure-functions/functions-networking-options?tabs=azure-cli#restrict-your-storage-account-to-a-virtual-network
      httpLoggingEnabled: true
      logsDirectorySizeLimit: 45
      detailedErrorLoggingEnabled: true
      use32BitWorkerProcess: functionsWorkerRuntime != 'custom'
      netFrameworkVersion: isLinux ? null : netFrameworkVersion
      javaVersion: isLinux || functionsWorkerRuntime != 'java' ? null : javaVersion
      powerShellVersion: isLinux || functionsWorkerRuntime != 'powershell' ? null : powerShellVersion
      nodeVersion: isLinux || functionsWorkerRuntime != 'node' ? null : nodeVersion
      cors: (!empty(cors)) ? cors : null
    }
  }
}

resource appServiceAppSettings 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: functionApp
  name: 'logs'
  properties: {
    applicationLogs: {
      fileSystem: {
        level: 'Warning'
      }
    }
    httpLogs: {
      fileSystem: {
        retentionInMb: 40
        retentionInDays: 30
        enabled: true
      }
    }
    failedRequestsTracing: {
      enabled: true
    }
    detailedErrorMessages: {
      enabled: true
    }
  }
}

resource networkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = if (enableVnetIntegration) {
  parent: functionApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetId
    swiftSupported: true
  }
}

resource appSettings 'Microsoft.Web/sites/config@2021-02-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    FUNCTIONS_WORKER_RUNTIME: !enableDockerContainer ? functionsWorkerRuntime : any(null)
    FUNCTIONS_EXTENSION_VERSION: functionsExtensionVersion
  }
}

module appSettingsExtra 'config-appsettings.bicep' = if (applyDefaultAppSettings) {
  name: '${deployment().name}-appconfig'
  params: {
    functionAppName: functionApp.name
    // enableInsights: enableInsights
    applicationInsightsName: enableInsights ? applicationInsightsName : any(null)
    enableDockerContainer: enableDockerContainer
    functionsWorkerRuntime: !enableDockerContainer ? functionsWorkerRuntime : 'custom'
    functionsExtensionVersion: functionsExtensionVersion
    functionsDefaultNodeversion: functionsWorkerRuntime == 'node' ? '~${nodeVersion}' : ''
    enableSourceControl: enableSourceControl
    repoFolder: repoFolder
  }
  dependsOn: enableVnetIntegration ? [
    appSettings
    networkConfig
  ] : [
    appSettings
  ]
}


// resource appServiceSiteExtension 'Microsoft.Web/sites/siteextensions@2020-06-01' = if(enableInsights) {
//   parent: functionApp
//   name: 'Microsoft.ApplicationInsights.AzureWebSites'
//   // dependsOn: [
//   //   appInsights
//   // ]
// }

var diagName = '${functionApp.name}diag'

//https://learn.microsoft.com/en-us/azure/app-service/troubleshoot-diagnostic-logs#send-logs-to-azure-monitor
var diagnosticsCategoriesCode = [
  // //'AppServiceHTTPLogs'
  // 'AppServiceConsoleLogs'
  // 'AppServiceAppLogs'
  // 'AppServiceAuditLogs'
  // //'AppServiceFileAuditLogs' // TBA
  // 'AppServiceIPSecAuditLogs'
  // 'AppServicePlatformLogs'
  'FunctionAppLogs'
]
var diagnosticsCategoriesContainer = [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
]

var diagnosticsCategories = enableDockerContainer ? diagnosticsCategoriesContainer : diagnosticsCategoriesCode

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: diagName
  scope: functionApp
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

resource sourcecontrol 'Microsoft.Web/sites/sourcecontrols@2022-03-01' = if (enableSourceControl) {
  parent: functionApp
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: branch
    isManualIntegration: isManualIntegration
    //isMercurial: isMercurial
  }
}

@description('Deploy function app from zip file.')
resource extensions 'Microsoft.Web/sites/extensions@2022-03-01' = if (enablePackageDeploy) {
  parent: functionApp
  name: 'MSDeploy'
  properties: {
    packageUri: functionPackageUri
  }
}

module function 'function.bicep' = {
  name: '${deployment().name}-functions'
  params: {
    functionAppName: functionApp.name
    functions: functions
  }
}

/*output section*/
@description('Get resource id for app or functionapp.')
output id string = functionApp.id

@description('Get resource name for app or functionapp.')
output name string = functionApp.name

@description('Array of functions having name, language, isDisabled and id of functions.')
output functions array = function.outputs.functions

@description('Principal Id of the identity assigned to the function app.')
output sitePrincipalId string = (functionApp.identity.type == 'SystemAssigned') ? functionApp.identity.principalId : ''
