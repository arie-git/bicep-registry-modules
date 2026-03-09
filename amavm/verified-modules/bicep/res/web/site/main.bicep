metadata name = 'App Service Plan Apps'
metadata description = 'This module deploys apps on an App Service Plan. It supports Web App, Function App, API App, Logic App, and Containers.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of this module requires:

- publicNetworkAccess: 'Disabled'
- httpsOnly: true
- siteConfig.http20Enabled: true
- siteConfig.minTlsVersion: '1.2'
- siteConfig.cors: should be either null, or cors.allowedOrigins array not to contain a value of '*'
- either a virtualNetworkSubnetId or a appServiceEnvironmentResourceId need to be provided
- outboundVnetRouting: configured to route all traffic through the virtual network
- siteConfig.ftpsState: 'Disabled' or 'FtpsOnly'
- basicPublishingCredentialsPolicies: both ftp and scm must be allow=false
- siteConfig.remoteDebuggingEnabled: false
- config.linuxFxVersion: latest runtimes are used. IMPORTANT: This module does not ensure this control by default.
- authSettingV2Configuration.enabled: true and authSettingV2Configuration.platform.enabled: true
- managedIdentities: not empty
'''
metadata complianceVersion = '20260309'

@description('Required. Name of the site.')
param name string

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Required. Type of site to deploy.')
@metadata({
  example: '''
  'functionapp' // function app windows os
  'functionapp,linux' // function app linux os
  'functionapp,workflowapp' // logic app workflow
  'functionapp,workflowapp,linux' // logic app docker container
  'functionapp,linux,container' // function app linux container
  'functionapp,linux,container,azurecontainerapps' // function app linux container azure container apps
  'app,linux' // linux web app
  'app' // windows web app
  'linux,api' // linux api app
  'api' // windows api app
  'app,linux,container' // linux container app
  'app,container,windows' // windows container app
  '''
})
@allowed([
  'functionapp' // function app windows os
  'functionapp,linux' // function app linux os
  'functionapp,workflowapp' // logic app workflow
  'functionapp,workflowapp,linux' // logic app docker container
  'functionapp,linux,container' // function app linux container
  'functionapp,linux,container,azurecontainerapps' // function app linux container azure container apps
  'app,linux' // linux web app
  'app' // windows web app
  'linux,api' // linux api app
  'api' // windows api app
  'app,linux,container' // linux container app
  'app,container,windows' // windows container app
])
param kind string

@description('Required. The resource ID of the app service plan to use for the site.')
param serverFarmResourceId string

@description('Optional. Azure Resource Manager ID of the customers selected Managed Environment on which to host this app.')
param managedEnvironmentId string?

@description('''Optional. Configures a site to accept only HTTPS requests, and issues redirect for HTTP requests. Default: true.
[Policy: drcp-aps-02] Setting this parameter to 'false' will make the resource non-compliant.
''')
param httpsOnly bool = true

@description('Optional. If client affinity is enabled. Default: false')
param clientAffinityEnabled bool = false

@description('''Optional. The resource ID of the app service environment to use for this resource.
[Policy: drcp-aps-08] Either this or virtualNetworkSubnetId must be provided.
''')
param appServiceEnvironmentResourceId string?

@description('''Optional. The managed identity definition for this resource. Default: systemAssigned is true.
[Policy: drcp-aps-19] A managed identity must be configured.
''')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('Optional. The resource ID of the assigned identity to be used to access a key vault with.')
param keyVaultAccessIdentityResourceId string?

@description('Optional. Checks if Customer provided storage account is required.')
param storageAccountRequired bool = false

@description('''Optional. Azure resource ID of the Virtual network subnet to be joined by Regional VNET Integration.
[Policy: drcp-aps-08] Leaving this parameter empty when appServiceEnvironmentResourceId is also not provided will make the resource non-compliant.
''')
param virtualNetworkSubnetId string?

@description('Optional. Stop SCM (KUDU) site when the app is stopped.')
param scmSiteAlsoStopped bool = true

@description('''Conditional. Required for Linux app plan to represent runtime stack in the format of 'runtime\|runtimeVersion'.
Select from the list of supported runtimes and versions or leave empty for the custom handler option.

See `az webapp list-runtimes --os linux --output table` for available runtimes, and replace ':' with '\|' symbol.

For Docker containers use format 'DOCKER\|dockerRegistry/dockerRepositoryPath'
''')
param linuxFxVersion string?

@description('Optional. Windows-only. Version of the .NET Framework used in the App Service app. Examples: v9.0, v8.0, v7.0')
param netFrameworkVersion string?

@description('Optional. Windows-only. Version of Java used in the App Service app. Examples: 21, 17, 11, 1.8')
param javaVersion string?

@description('Optional. Windows-only. Version of Node.js used in the App Service app. Examples: 22, 18, 16.')
param nodeVersion string?

@description('Optional. Windows-only. Version of PHP used in the App Service app. Examples: 8.2')
param phpVersion string?

@description('Optional. Windows-only. Version of Python used in the App Service app. Examples: 3.11, 3.10, 3.9')
param pythonVersion string?

@description('''Optional. The site configuration object.
Please refer to the Microsoft documentation for available parameters https://learn.microsoft.com/en-gb/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep#siteconfig

To maintain compliant state, the following values are required and configured by default:
- [Policy: drcp-aps-03] http20Enabled: true
- [Policy: drcp-aps-11] ftpsState: 'Disabled' or 'FtpsOnly' (default: 'Disabled')
- [Policy: drcp-aps-04] minTlsVersion: '1.3'
- [Policy: drcp-aps-07] cors: must be either null, or cors.allowedOrigins contains an array of values other than '*' (default: null)
- [Policy: drcp-aps-16] remoteDebuggingEnabled: false
''')
param siteConfiguration object = {
  alwaysOn: true
  minTlsVersion: '1.3'
  ftpsState: 'Disabled'
  http20Enabled: true
  cors: null
  remoteDebuggingEnabled: false
  httpLoggingEnabled: true
  acrUseManagedIdentityCreds: true
  logsDirectorySizeLimit: 45

  linuxFxVersion: contains(kind, 'linux') ? linuxFxVersion : null
  metadata: contains(kind,'linux') ? [] : [
    {
      name: 'CURRENT_STACK'
      value: !empty(netFrameworkVersion)
              ? 'dotnet'
              : !empty(javaVersion)
                ? 'java'
                : !empty(nodeVersion)
                  ? 'node'
                  : !empty(pythonVersion)
                    ? 'python'
                    : !empty(phpVersion)
                      ? 'php'
                      : ''
    }
  ]
}

@description('''Optional. The additional site config object key-value pairs to the values in siteConfiguration parameter.

Use it when you want to keep defaults in siteConfiguration, but override or append them with additional configurations.
''')
param siteConfigurationAdditional object = {}

@description('Optional. The Function App configuration object.')
param functionAppConfiguration object? //TODO

@description('Conditional. Required if app of kind functionapp. Resource ID of the storage account to manage triggers and logging function executions.')
param storageAccountResourceId string? //TODO

@description('''Optional. If the provided storage account requires Identity based authentication ('allowSharedKeyAccess' is set to false).
When set to true, the minimum role assignment required for the App Service Managed Identity to the storage account is 'Storage Blob Data Owner'. Default: true''')
param storageAccountUseIdentityAuthentication bool = true

@description('''Optional. The web site settings configuration.

Please refer to the documentation for available options https://learn.microsoft.com/en-gb/azure/templates/microsoft.web/sites/config?pivots=deployment-language-bicep#siteconfig
''')
param webSiteConfiguration object = {
  netFrameworkVersion: (contains(kind, 'linux') || empty(netFrameworkVersion)) ? null : netFrameworkVersion
  javaVersion: (contains(kind, 'linux') || empty(javaVersion)) ? null : javaVersion
  nodeVersion: (contains(kind, 'linux') || empty(nodeVersion)) ? null : nodeVersion
  phpVersion: (contains(kind, 'linux') || empty(phpVersion)) ? null : phpVersion
  pythonVersion: (contains(kind, 'linux') || empty(pythonVersion)) ? null : pythonVersion
  use32BitWorkerProcess: false
}

@description('''Optional. The additional web site settings configuration.

Use it when you want to keep defaults in webSiteConfiguration, but override or append them with additional configurations.
''')
param webSiteConfigurationAdditional object = {}

@description('''Optional. An array of connection string for Web App.

If provided, it will be added to the webSiteConfiguration parameter.
''')
param connectionStrings connectionStringType[]?

@description('Optional. The extension MSDeployment configuration.')
param msDeployConfiguration object?

@description('Optional. Resource ID of the app insight to leverage for this resource.')
param appInsightResourceId string?

@description('Optional. The app settings-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING.')
param appSettingsKeyValuePairs object?

@description('''Optional. The auth settings V2 configuration.
When using parameter defaults it configures Entra ID 'Easy Auth' using the application ID provided in the 'authSettingApplicationId' parameter.
[Policy: drcp-aps-18] Leaving this parameter empty will make the resource non-compliant.
''')
param authSettingV2Configuration object = startsWith(kind, 'app')
  ? {
      enabled: true
      platform: {
        enabled: true // when Easy Auth
        runtimeVersion: '~1'
      }
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'RedirectToLoginPage' // 'Return401' when not Easy Auth
        redirectToProvider: 'azureactivedirectory' // absent when not Easy Auth
      }
      identityProviders: {
        azureActiveDirectory: empty(authSettingApplicationId)
          ? null
          : {
              enabled: true
              registration: {
                openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
                clientId: authSettingApplicationId
                clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
              }
              login: {
                disableWWWAuthenticate: false
              }
              validation: {
                jwtClaimChecks: {}
                allowedAudiences: [
                  'api://${authSettingApplicationId}/user_impersonation'
                ]
                defaultAuthorizationPolicy: {
                  allowedPrincipals: {}
                  allowedApplications: [
                    authSettingApplicationId // when Easy Auth
                  ]
                }
              }
            }
      }
      login: {
        routes: {}
        tokenStore: {
          enabled: true
          tokenRefreshExtensionHours: json('72.0')
          fileSystem: {}
          azureBlobStorage: {}
        }
        preserveUrlFragmentsForLogins: false
        cookieExpiration: {
          convention: 'FixedTime'
          timeToExpiration: '08:00:00'
        }
        nonce: {
          validateNonce: true
          nonceExpirationInterval: '00:05:00'
        }
      }
      httpSettings: {
        requireHttps: true
        routes: {
          apiPrefix: '/.auth'
        }
        forwardProxy: {
          convention: 'NoProxy'
        }
      }
      clearInboundClaimsMapping: 'false'
    }
  : {
      enabled: true
      platform: {
        enabled: false
        runtimeVersion: '~1'
      }
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'Return401' // When not Easy Auth
      }
      identityProviders: {
        azureActiveDirectory: empty(authSettingApplicationId)
          ? null
          : {
              enabled: true
              registration: {
                openIdIssuer: 'https://sts.windows.net/${tenant().tenantId}/v2.0'
                clientId: authSettingApplicationId
                clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
              }
              login: {
                disableWWWAuthenticate: false
              }
              validation: {
                jwtClaimChecks: {}
                allowedAudiences: []
                defaultAuthorizationPolicy: {
                  allowedPrincipals: {}
                  allowedApplications: []
                }
              }
            }
      }
    }

@description('''Optional. Additional auth settings V2 configuration to the values in siteConfiguration parameter.

Use it when you want to keep defaults in siteConfiguration, but override or append them with additional configurations.
''')
param authSettingV2ConfigurationAdditional object = {}

@description('Optional. Application Id of the EntraID application registration used for authentication.')
param authSettingApplicationId string?

@description('Optional. The lock settings of the service.')
param lock lockType

@description('''Optional. The logs settings configuration.
By default it is configured as Verbose level logging to the file system with 1 day of retention.
''')
param logsConfiguration object = {
  applicationLogs: {
    fileSystem: {
      level: 'Verbose'
    }
  }
  detailedErrorMessages: {
    enabled: true
  }
  failedRequestsTracing: {
    enabled: true
  }
  httpLogs: {
    fileSystem: {
      enabled: true
      retentionInDays: 1
      retentionInMb: 35
    }
  }
}

@description('''Optional. Configuration details for private endpoints.
For security reasons, it is recommended to use private endpoints whenever possible.
[Policy: drcp-sub-07] Private endpoint connections must not cross subscription boundaries.

Available values for 'service' are:
- sites

Default: sites is used if at least one subnetResourceId is provided but 'service' is not specified.
''')
param privateEndpoints privateEndpointType

@description('Optional. Configuration for deployment slots for an app.')
param slots slotType[]?

@description('Optional. End to End Encryption Setting.')
param e2eEncryptionEnabled bool?

@description('Optional. Property to configure various DNS related settings for a site.')
param dnsConfiguration object?

@description('Optional. Dapr configuration of the app.')
param daprConfig object?

@description('Optional. Whether to enable SSH access.')
param sshEnabled bool?

@description('Optional. Specifies the IP mode of the app.')
param ipMode string?

@description('Optional. Function app resource requirements.')
param resourceConfig object?

@description('Optional. Workload profile name for function app to execute on.')
param workloadProfileName string?

@description('Optional. True to disable the public hostnames of the app; otherwise, false.')
param hostNamesDisabled bool?

@description('''Optional. The outbound VNET routing configuration for the site.
[Policy: drcp-aps-10] All outbound traffic must be routed through the virtual network.
''')
param outboundVnetRouting resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.outboundVnetRouting?

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('''Optional. The diagnostic settings of the service.

Currently known available log categories that are enabled by default:
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
  'AppServiceAuthenticationLogs'

Additionally available in Premiums sku that can be used :
  'AppServiceAntivirusScanAuditLogs'
  'AppServiceFileAuditLogs'

''')
param diagnosticSettings diagnosticSettingType

@description('Optional. To enable client certificate authentication (TLS mutual authentication).')
param clientCertEnabled bool = false

@description('Optional. Client certificate authentication comma-separated exclusion paths.')
param clientCertExclusionPaths string?

@description('''
Optional. This composes with ClientCertEnabled setting.
- ClientCertEnabled=false means ClientCert is ignored.
- ClientCertEnabled=true and ClientCertMode=Required means ClientCert is required.
- ClientCertEnabled=true and ClientCertMode=Optional means ClientCert is optional or accepted.
''')
@allowed([
  'Optional'
  'OptionalInteractiveUser'
  'Required'
])
param clientCertMode string = 'Optional'

@description('Optional. If specified during app creation, the app is cloned from a source app.')
param cloningInfo object?

@description('Optional. Size of the function container.')
param containerSize int?

@description('Optional. Maximum allowed daily memory-time quota (applicable on dynamic apps only).')
param dailyMemoryTimeQuota int?

@description('Optional. Setting this value to false disables the app (takes the app offline).')
param enabled bool = true

@description('Optional. Hostname SSL states are used to manage the SSL bindings for app\'s hostnames.')
param hostNameSslStates array?

@description('Optional. Hyper-V sandbox. Default: false')
param hyperV bool = false

@description('Optional. Site redundancy mode.')
@allowed([
  'ActiveActive'
  'Failover'
  'GeoRedundant'
  'Manual'
  'None'
])
param redundancyMode string = 'None'

@description('''Optional. The site publishing credential policy names which are associated with the sites.
[Policy: drcp-aps-12] Providing empty values for this parameter or setting allow to 'true' will make the resource non-compliant.
''')
param basicPublishingCredentialsPolicies basicPublishingCredentialsPolicyType[] = [
  {
    name: 'ftp'
    allow: false
  }
  {
    name: 'scm'
    allow: false
  }
]

@description('Optional. Names of hybrid connection relays to connect app with.')
param hybridConnectionRelays array?

@description('''Optional. Whether or not public network access is allowed for this resource.
For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.
[Policy: drcp-aps-01] Setting this parameter to 'Enabled' will make the resource non-compliant.''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'App Compliance Automation Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0f37683f-2463-46b6-9ce7-9b788b988ba2'
  )
  'Web Plan Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '2cc479cb-7b4d-49a8-b449-8c00fd0f0a4b'
  )
  'Website Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'de139f84-1756-47ae-9be6-808fbbe84772'
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

// When a private endpoint configuration is provided without the service name, this array will be used to lookup default services for each privateEndpoint in the parameters
var privateEndpointDefaultServices = [
  'sites'
]
var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  // 'AppServiceAntivirusScanAuditLogs' // Not available in Standard SKU
  // 'AppServiceFileAuditLogs' // Not available in Standard SKU
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServiceIPSecAuditLogs'
  'AppServicePlatformLogs'
  'AppServiceAuthenticationLogs'
]
var defaultLogCategories = [
  for category in defaultLogCategoryNames: {
    category: category
  }
]

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.web-site.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource app 'Microsoft.Web/sites@2025-03-01' = {
  name: name
  location: location
  kind: kind
  tags: finalTags
  identity: identity
  properties: {
    managedEnvironmentId: !empty(managedEnvironmentId) ? managedEnvironmentId : null
    serverFarmId: serverFarmResourceId
    clientAffinityEnabled: clientAffinityEnabled
    httpsOnly: httpsOnly
    hostingEnvironmentProfile: !empty(appServiceEnvironmentResourceId)
      ? {
          id: appServiceEnvironmentResourceId
        }
      : null
    storageAccountRequired: storageAccountRequired
    keyVaultReferenceIdentity: keyVaultAccessIdentityResourceId
    virtualNetworkSubnetId: virtualNetworkSubnetId
    siteConfig: union(siteConfiguration, siteConfigurationAdditional)
    endToEndEncryptionEnabled: e2eEncryptionEnabled
    dnsConfiguration: dnsConfiguration
    daprConfig: daprConfig
    ipMode: ipMode
    resourceConfig: resourceConfig
    workloadProfileName: workloadProfileName
    hostNamesDisabled: hostNamesDisabled
    functionAppConfig: functionAppConfiguration
    clientCertEnabled: clientCertEnabled
    clientCertExclusionPaths: clientCertExclusionPaths
    clientCertMode: clientCertMode
    cloningInfo: cloningInfo
    containerSize: containerSize
    dailyMemoryTimeQuota: dailyMemoryTimeQuota
    enabled: enabled
    hostNameSslStates: hostNameSslStates
    hyperV: hyperV
    reserved: contains(kind, 'linux')
    redundancyMode: redundancyMode
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? any(publicNetworkAccess)
      : (!empty(privateEndpoints) ? 'Disabled' : 'Enabled')
    scmSiteAlsoStopped: scmSiteAlsoStopped
    sshEnabled: sshEnabled
    outboundVnetRouting: outboundVnetRouting
  }
}

module app_appsettings 'config--appsettings/main.bicep' = if (!empty(appSettingsKeyValuePairs) || !empty(appInsightResourceId) || !empty(storageAccountResourceId)) {
  name: '${uniqueString(deployment().name, location)}-site-config-appsettings'
  params: {
    appName: app.name
    kind: kind
    storageAccountResourceId: storageAccountResourceId
    storageAccountUseIdentityAuthentication: storageAccountUseIdentityAuthentication
    appInsightResourceId: appInsightResourceId
    appSettingsKeyValuePairs: appSettingsKeyValuePairs ?? {}
    currentAppSettings: !empty(app.id) ? list('${app.id}/config/appsettings', '2025-03-01').properties : {}
  }
}

module app_authsettingsv2 'config--authsettingsv2/main.bicep' = if (!empty(authSettingV2Configuration) || !empty(authSettingV2ConfigurationAdditional)) {
  name: '${uniqueString(deployment().name, location)}-site-config-authsettingsv2'
  params: {
    appName: app.name
    kind: kind
    authSettingV2Configuration: union(
      authSettingV2Configuration ?? {},
      authSettingV2ConfigurationAdditional ?? {}
    )
  }
}

module app_logssettings 'config--logs/main.bicep' = if (!empty(logsConfiguration ?? {})) {
  name: '${uniqueString(deployment().name, location)}-site-config-logs'
  params: {
    appName: app.name
    logsConfiguration: logsConfiguration
  }
  dependsOn: [
    app_appsettings
  ]
}

module app_websettings 'config--web/main.bicep' = if (!empty(webSiteConfiguration ?? {})) {
  name: '${uniqueString(deployment().name, location)}-site-config-web'
  params: {
    appName: app.name
    siteConfiguration: union(
      webSiteConfiguration,
      webSiteConfigurationAdditional ?? {},
      !empty(connectionStrings) ? { connectionStrings: connectionStrings } : {}
    )
  }
}

module extension_msdeploy 'extensions--msdeploy/main.bicep' = if (!empty(msDeployConfiguration)) {
  name: '${uniqueString(deployment().name, location)}-site-extension-msdeploy'
  params: {
    appName: app.name
    msDeployConfiguration: msDeployConfiguration ?? {}
  }
}

@batchSize(1)
module app_slots 'slot/main.bicep' = [
  for (slot, index) in (slots ?? []): {
    name: '${uniqueString(deployment().name, location)}-slot-${slot.name}'
    params: {
      name: slot.name
      appName: app.name
      location: location
      kind: kind
      serverFarmResourceId: serverFarmResourceId
      httpsOnly: slot.?httpsOnly ?? httpsOnly
      appServiceEnvironmentResourceId: appServiceEnvironmentResourceId
      clientAffinityEnabled: slot.?clientAffinityEnabled ?? clientAffinityEnabled
      managedIdentities: slot.?managedIdentities ?? managedIdentities
      keyVaultAccessIdentityResourceId: slot.?keyVaultAccessIdentityResourceId ?? keyVaultAccessIdentityResourceId
      storageAccountRequired: slot.?storageAccountRequired ?? storageAccountRequired
      virtualNetworkSubnetId: slot.?virtualNetworkSubnetId ?? virtualNetworkSubnetId
      siteConfig: slot.?siteConfig ?? siteConfiguration
      functionAppConfig: slot.?functionAppConfig ?? functionAppConfiguration
      storageAccountResourceId: slot.?storageAccountResourceId ?? storageAccountResourceId
      storageAccountUseIdentityAuthentication: slot.?storageAccountUseIdentityAuthentication ?? storageAccountUseIdentityAuthentication
      appInsightResourceId: slot.?appInsightResourceId ?? appInsightResourceId
      authSettingV2Configuration: slot.?authSettingV2Configuration ?? authSettingV2Configuration
      msDeployConfiguration: slot.?msDeployConfiguration ?? msDeployConfiguration
      diagnosticSettings: slot.?diagnosticSettings
      roleAssignments: slot.?roleAssignments
      appSettingsKeyValuePairs: slot.?appSettingsKeyValuePairs ?? appSettingsKeyValuePairs
      basicPublishingCredentialsPolicies: slot.?basicPublishingCredentialsPolicies ?? basicPublishingCredentialsPolicies
      lock: slot.?lock ?? lock
      privateEndpoints: slot.?privateEndpoints ?? []
      tags: slot.?tags ?? tags
      clientCertEnabled: slot.?clientCertEnabled
      clientCertExclusionPaths: slot.?clientCertExclusionPaths
      clientCertMode: slot.?clientCertMode
      cloningInfo: slot.?cloningInfo
      containerSize: slot.?containerSize
      customDomainVerificationId: slot.?customDomainVerificationId
      dailyMemoryTimeQuota: slot.?dailyMemoryTimeQuota
      enabled: slot.?enabled
      enableTelemetry: slot.?enableTelemetry ?? enableTelemetry
      hostNameSslStates: slot.?hostNameSslStates
      hyperV: slot.?hyperV
      publicNetworkAccess: slot.?publicNetworkAccess ?? ((!empty(slot.?privateEndpoints) || !empty(privateEndpoints))
        ? 'Disabled'
        : 'Enabled')
      redundancyMode: slot.?redundancyMode
      outboundVnetRouting: slot.?outboundVnetRouting ?? outboundVnetRouting
      hybridConnectionRelays: slot.?hybridConnectionRelays
    }
  }
]

module app_basicPublishingCredentialsPolicies 'basic-publishing-credentials-policy/main.bicep' = [
  for (basicPublishingCredentialsPolicy, index) in (basicPublishingCredentialsPolicies ?? []): {
    name: '${uniqueString(deployment().name, location)}-site-publish-cred-${index}'
    params: {
      webAppName: app.name
      name: basicPublishingCredentialsPolicy.name
      allow: basicPublishingCredentialsPolicy.?allow
      location: location
    }
  }
]

module app_hybridConnectionRelays 'hybrid-connection-namespace/relay/main.bicep' = [
  for (hybridConnectionRelay, index) in (hybridConnectionRelays ?? []): {
    name: '${uniqueString(deployment().name, location)}-hybridconnectionrelay-${index}'
    params: {
      hybridConnectionResourceId: hybridConnectionRelay.resourceId
      appName: app.name
      sendKeyName: hybridConnectionRelay.?sendKeyName
    }
  }
]

resource app_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: app
}

#disable-next-line use-recent-api-versions
resource app_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: app
  }
]

resource app_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(app.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: app
  }
]

var defaultPrivateEndpoints = [
  for service in privateEndpointDefaultServices ?? []: {
    service: service
    subnetResourceId: !empty(privateEndpoints) ? privateEndpoints[0].subnetResourceId : null
  }
]
var applyingPrivateEndpoints = (empty(privateEndpoints) || (length(privateEndpoints) == 1 && privateEndpoints[0].?service != null))
  ? privateEndpoints
  : defaultPrivateEndpoints

module app_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (applyingPrivateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-app-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(app.id, '/'))}-pep-${privateEndpoint.?service ?? 'sites'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(app.id, '/'))}-${privateEndpoint.?service ?? 'sites'}-${index}'
              properties: {
                privateLinkServiceId: app.id
                groupIds: [
                  privateEndpoint.?service ?? 'sites'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(app.id, '/'))}-${privateEndpoint.?service ?? 'sites'}-${index}'
              properties: {
                privateLinkServiceId: app.id
                groupIds: [
                  privateEndpoint.?service ?? 'sites'
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: privateEndpoint.?enableTelemetry ?? enableTelemetry
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2024-05-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? tags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

@description('The name of the site.')
output name string = app.name

@description('The resource ID of the site.')
output resourceId string = app.id

@description('The list of the slots.')
output slotNames array = [for (slot, index) in (slots ?? []): app_slots[index].name]

@description('The list of the slot resource ids.')
output slotResourceIds array = [for (slot, index) in (slots ?? []): app_slots[index].outputs.resourceId]

@description('The resource group the site was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = app.?identity.?principalId ?? ''

@description('The principal ID of the system assigned identity of slots.')
output slotSystemAssignedMIPrincipalIds array = [
  for (slot, index) in (slots ?? []): app_slots[index].outputs.systemAssignedMIPrincipalId
]

@description('The location the resource was deployed into.')
output location string = app.location

@description('Default hostname of the app.')
output defaultHostname string = app.properties.defaultHostName

@description('Unique identifier that verifies the custom domains assigned to the app. Customer will add this ID to a txt record for verification.')
output customDomainVerificationId string = app.properties.customDomainVerificationId

@description('The private endpoints of the site.')
output privateEndpoints array = [
  for (pe, i) in (!empty(privateEndpoints) ? array(privateEndpoints) : []): {
    name: app_privateEndpoints[i].outputs.name
    resourceId: app_privateEndpoints[i].outputs.resourceId
    groupId: app_privateEndpoints[i].outputs.groupId
    customDnsConfigs: app_privateEndpoints[i].outputs.customDnsConfigs
    networkInterfaceResourceIds: app_privateEndpoints[i].outputs.networkInterfaceResourceIds
  }
]

@description('The private endpoints of the slots.')
output slotPrivateEndpoints array = [for (slot, index) in (slots ?? []): app_slots[index].outputs.privateEndpoints]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !(publicNetworkAccess == 'Disabled') || !httpsOnly || !(siteConfiguration.?http20Enabled ?? false) || !contains(['Disabled', 'FtpsOnly', ''],(siteConfiguration.?ftpsState ?? '')) || contains(['1.0', '1.1', ''], (siteConfiguration.?minTlsVersion ?? '')) || contains((siteConfiguration.?cors.?allowedOrigins ?? ['']),'*') || empty(virtualNetworkSubnetId ?? appServiceEnvironmentResourceId) || ((!empty(virtualNetworkSubnetId) || !empty(appServiceEnvironmentResourceId)) && empty(outboundVnetRouting)) || siteConfiguration.remoteDebuggingEnabled || empty(managedIdentities) || !((authSettingV2Configuration.?enabled ?? false) && (authSettingV2Configuration.?platform.?enabled ?? false)) || contains(map(basicPublishingCredentialsPolicies, policy => (policy.?allow ?? true)),true)

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

import { basicPublishingCredentialsPolicyType } from 'basic-publishing-credentials-policy/main.bicep'

type connectionStringType = {
  @description('Required. Name of connection string.')
  name: string

  @description('Required. Connection string value.')
  connectionString: string

  @description('Optional. Is it a deployment slot setting')
  slotSetting: bool?

  @description('Required. Type of database.')
  type: 'ApiHub' | 'Custom' | 'DocDb' | 'EventHub' | 'MySql' | 'NotificationHub' | 'PostgreSQL' | 'RedisCache' | 'ServiceBus' | 'SQLAzure' | 'SQLServer'
}

@export()
@description('The type of a deployment slot.')
type slotType = {
  @description('Required. Name of the slot.')
  name: string

  @description('Optional. Configures a slot to accept only HTTPS requests.')
  httpsOnly: bool?

  @description('Optional. If client affinity is enabled.')
  clientAffinityEnabled: bool?

  @description('Optional. The managed identity definition for this resource.')
  managedIdentities: managedIdentitiesType?

  @description('Optional. The resource ID of the assigned identity to be used to access a key vault with.')
  keyVaultAccessIdentityResourceId: string?

  @description('Optional. Checks if Customer provided storage account is required.')
  storageAccountRequired: bool?

  @description('Optional. Azure Resource Manager ID of the Virtual network and subnet to be joined by Regional VNET Integration.')
  virtualNetworkSubnetId: string?

  @description('Optional. The site config object.')
  siteConfig: object?

  @description('Optional. The Function App config object.')
  functionAppConfig: object?

  @description('Optional. Resource ID of the storage account to manage triggers and logging function executions.')
  storageAccountResourceId: string?

  @description('Optional. If the provided storage account requires Identity based authentication.')
  storageAccountUseIdentityAuthentication: bool?

  @description('Optional. Resource ID of the app insight to leverage for this resource.')
  appInsightResourceId: string?

  @description('Optional. The app settings-value pairs.')
  appSettingsKeyValuePairs: object?

  @description('Optional. The auth settings V2 configuration.')
  authSettingV2Configuration: object?

  @description('Optional. The extension MSDeployment configuration.')
  msDeployConfiguration: object?

  @description('Optional. The diagnostic settings of the service.')
  diagnosticSettings: diagnosticSettingType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType?

  @description('Optional. The site publishing credential policy names which are associated with the site slot.')
  basicPublishingCredentialsPolicies: basicPublishingCredentialsPolicyType[]?

  @description('Optional. The lock settings of the service.')
  lock: lockType?

  @description('Optional. Configuration details for private endpoints.')
  privateEndpoints: privateEndpointType?

  @description('Optional. Tags of the resource.')
  tags: object?

  @description('Optional. To enable client certificate authentication (TLS mutual authentication).')
  clientCertEnabled: bool?

  @description('Optional. Client certificate authentication comma-separated exclusion paths.')
  clientCertExclusionPaths: string?

  @description('Optional. This composes with ClientCertEnabled setting.')
  clientCertMode: ('Optional' | 'OptionalInteractiveUser' | 'Required')?

  @description('Optional. If specified during app creation, the app is cloned from a source app.')
  cloningInfo: object?

  @description('Optional. Size of the function container.')
  containerSize: int?

  @description('Optional. Unique identifier that verifies the custom domains assigned to the app.')
  customDomainVerificationId: string?

  @description('Optional. Maximum allowed daily memory-time quota (applicable on dynamic apps only).')
  dailyMemoryTimeQuota: int?

  @description('Optional. Setting this value to false disables the app (takes the app offline).')
  enabled: bool?

  @description('Optional. Enable/Disable usage telemetry for module.')
  enableTelemetry: bool?

  @description('Optional. Hostname SSL states are used to manage the SSL bindings for app\'s hostnames.')
  hostNameSslStates: array?

  @description('Optional. Hyper-V sandbox.')
  hyperV: bool?

  @description('Optional. Allow or block all public traffic.')
  publicNetworkAccess: ('Enabled' | 'Disabled')?

  @description('Optional. Site redundancy mode.')
  redundancyMode: ('ActiveActive' | 'Failover' | 'GeoRedundant' | 'Manual' | 'None')?

  @description('Optional. The outbound VNET routing configuration for the slot.')
  outboundVnetRouting: resourceInput<'Microsoft.Web/sites/slots@2025-03-01'>.properties.outboundVnetRouting?

  @description('Optional. Names of hybrid connection relays to connect app with.')
  hybridConnectionRelays: array?
}
