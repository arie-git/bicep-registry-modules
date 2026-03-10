@description('Required. Name for the Azure App Service.')
@maxLength(64)
param name string

@description('Required. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags for all resources within Azure App Service module.')
param tags object = {}

@description('Required. Resource Id of the hosting plan to use.')
param hostingPlanId string

@description('Required. Kind of server OS the plan will host. If Linux also required to provide linuxFxVersion.')
@allowed([ 'Windows', 'Linux' ])
param serverOS string

@description('''Only required for Linux app plan to represent runtime stack in the format of \'runtime|runtimeVersion\'.
Select from the list of supported runtimes and versions or leave empty for the custom handler option.
See https://learn.microsoft.com/en-us/azure/azure-functions/set-runtime-version?tabs=portal#manual-version-updates-on-linux for more details.
''')
@allowed([
  'DOTNET|8'
  'DOTNET|7'
  'DOTNET|6'
  'Node|20-lts'
  'Node|18-lts'
  'Python|3.12'
  'Python|3.11'
  'Python|3.10'
  'Python|3.9'
  'Python|3.8'
  'Java|17-java17'
  'Java|11-java11'
  'Java|8-java8'
  'PHP|8.2'
  ''
]) // https://learn.microsoft.com/en-us/azure/azure-functions/supported-languages#languages-by-runtime-version
param linuxFxVersion string = ''

@allowed([
  'dotnet'
  'node'
  'python'
  'java'
  'php'
])
param webAppWorkerRuntime string

@description('Windows-only. Version of the .NET Framework used in the App Service.')
@allowed([
  'v6.0'
  'v7.0'
  'v8.0'
])
param netFrameworkVersion string = 'v6.0'

@description('Windows-only. Version of Java used in the App Service.')
@allowed([
  '17'
  '11'
  '1.8'
])
param javaVersion string = '17'

@description('Version of Node.js used in the App Service.')
@allowed([
  '18'
  '16'
  '14'
])
param nodeVersion string = '18'

@description('Linux-only. Version of PHP used in the App Service.')
@allowed([
  '8.2'
])
param phpVersion string = '8.2'

@description('Linux-only. Version of Python used in the Web App.')
@allowed([
  '3.8'
  '3.9'
  '3.10'
  '3.11'
  '3.12'
])
param pythonVersion string = '3.8'

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

@description('Optional. If client affinity is enabled. Default: true.')
param clientAffinityEnabled bool = true

@description('Optional. Configures a site to accept only HTTPS requests. Issues redirect for HTTP requests. Default: true.')
param httpsOnly bool = true

@description('Optional. Enabled or Disable Insights for Azure functions')
param enableInsights bool = false

@description('Optional. Resource Group of storage account used by web app, if different from the current one.')
param applicationInsightsName string = ''

@description('Optional. Resource Id of the log analytics workspace for diagnostic logs.')
param logAnalyticsWorkspaceId string = ''

@description('Optional. Enable Vnet Integration or not. Default: true')
param enableVnetIntegration bool = true

@description('The subnet that will be integrated to enable vnet Integration. Leave empty if enableVnetIntegration is false.')
param subnetId string

@description('Optional. Enable docker image deployment. Default: false')
param enableDockerContainer bool = false
@description('FQDN of the ACR registry.')
param dockerRegistry string = ''
@description('Image:tag. E.g. samples:aspnetapp')
param dockerRepositoryPath string = ''
param dockerStartupCommand string = ''

param cors object = {}

var isLinux = serverOS == 'Linux'

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: identityType
    userAssignedIdentities: (identityType == 'UserAssigned' || identityType == 'SystemAssigned, UserAssigned') ? {
      '${userAssignedIdentityId}': {}
    } : null
  }
  properties: {
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: httpsOnly
    publicNetworkAccess: 'Disabled'
    reserved: isLinux
    serverFarmId: hostingPlanId
    siteConfig: {
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      appCommandLine: enableDockerContainer ? dockerStartupCommand : null
      cors: (!empty(cors)) ? cors : null
      ftpsState: 'Disabled'
      http20Enabled: true
      httpLoggingEnabled: true
      linuxFxVersion: enableDockerContainer ? 'DOCKER|${dockerRegistry}/${dockerRepositoryPath}' : isLinux ? linuxFxVersion : null
      logsDirectorySizeLimit: 45
      minTlsVersion: '1.2'

      javaVersion: isLinux || webAppWorkerRuntime != 'java' ? null : javaVersion
      netFrameworkVersion: netFrameworkVersion
      nodeVersion: isLinux || webAppWorkerRuntime != 'node' ? null : nodeVersion
      phpVersion: isLinux || webAppWorkerRuntime != 'powershell' ? null : phpVersion
      pythonVersion: isLinux || webAppWorkerRuntime != 'powershell' ? null : pythonVersion
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: webAppWorkerRuntime
        }
      ]
      vnetRouteAllEnabled: enableVnetIntegration
    }
    vnetContentShareEnabled: enableVnetIntegration
    vnetImagePullEnabled: enableVnetIntegration
    vnetRouteAllEnabled: enableVnetIntegration
  }
}

resource networkConfig 'Microsoft.Web/sites/networkConfig@2022-03-01' = if (enableVnetIntegration) {
  parent: webApp
  name: 'virtualNetwork'
  properties: {
    subnetResourceId: subnetId
    swiftSupported: true
  }
}

resource appSettingsConfig 'Microsoft.Web/sites/config@2023-01-01' = {
  parent: webApp
  name: 'appsettings'
  properties: {
    WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
    APPINSIGHTS_INSTRUMENTATIONKEY: !empty(appInsights.id) ? appInsights.properties.InstrumentationKey : ''
    APPLICATIONINSIGHTS_CONNECTION_STRING: !empty(appInsights.id) ? appInsights.properties.ConnectionString : ''
  }
}

var diagnosticsCategories = [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
]

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${name}-diag'
  scope: webApp
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

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = if (enableInsights && !empty(applicationInsightsName)) {
  name: applicationInsightsName
}

/*output section*/
@description('Get resource id for app.')
output id string = webApp.id

@description('Get resource name for app.')
output name string = webApp.name

@description('Principal Id of the identity assigned to the app.')
output sitePrincipalId string = (webApp.identity.type == 'SystemAssigned') ? webApp.identity.principalId : ''

@description('Default host name of the app service')
output hostName string = webApp.properties.defaultHostName
