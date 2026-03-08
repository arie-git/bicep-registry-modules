# App Service Plan Apps `[Microsoft.Web/sites]`

This module deploys apps on an App Service Plan. It supports Web App, Function App, API App, Logic App, and Containers.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Notes](#notes)
- [Data Collection](#data-collection)

## Compliance

Version: 20241112

Compliant usage of this module requires:

- publicNetworkAccess: 'Disabled'
- httpsOnly: true
- siteConfig.http20Enabled: true
- siteConfig.minTlsVersion: '1.2'
- siteConfig.cors: should be either null, or cors.allowedOrigins array not to contain a value of '*'
- either a virtualNetworkSubnetId or a appServiceEnvironmentResourceId need to be provided
- vnetContentShareEnabled: true
- vnetImagePullEnabled: true
- vnetRouteAllEnabled: true
- siteConfig.ftpsState: 'Disabled' or 'FtpsOnly'
- basicPublishingCredentialsPolicies: both ftp and scm must be allow=false
- siteConfig.remoteDebuggingEnabled: false
- config.linuxFxVersion: latest runtimes are used. IMPORTANT: This module does not ensure this control by default.
- authSettingV2Configuration.enabled: true and authSettingV2Configuration.platform.enabled: true
- managedIdentities: not empty


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |
| `Microsoft.Web/sites` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_sites.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/sites)</li></ul> |
| `Microsoft.Web/sites/basicPublishingCredentialsPolicies` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_sites_basicpublishingcredentialspolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/sites/basicPublishingCredentialsPolicies)</li></ul> |
| `Microsoft.Web/sites/config` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_sites_config.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/sites/config)</li></ul> |
| `Microsoft.Web/sites/extensions` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_sites_extensions.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/sites/extensions)</li></ul> |
| `Microsoft.Web/sites/hybridConnectionNamespaces/relays` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_sites_hybridconnectionnamespaces_relays.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/sites/hybridConnectionNamespaces/relays)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/web/site:<version>`.

- [Web App (Linux), using only defaults](#example-1-web-app-linux-using-only-defaults)
- [Web App (Linux), using large parameter set](#example-2-web-app-linux-using-large-parameter-set)
- [Web App (Windows), using only defaults](#example-3-web-app-windows-using-only-defaults)
- [Web App (Windows), using large parameter set](#example-4-web-app-windows-using-large-parameter-set)
- [WAF-aligned](#example-5-waf-aligned)
- [(NOT VALIDATED) Web App](#example-6-not-validated-web-app)
- [(NOT VALIDATED) Function App, using only defaults](#example-7-not-validated-function-app-using-only-defaults)
- [(NOT VALIDATED) Function App, using large parameter set](#example-8-not-validated-function-app-using-large-parameter-set)
- [(NOT VALIDATED) Function App, using defaults and some settings](#example-9-not-validated-function-app-using-defaults-and-some-settings)
- [(NOT VALIDATED) Web App, using only defaults](#example-10-not-validated-web-app-using-only-defaults)
- [(NOT VALIDATED) Windows Web App for Containers, using only defaults](#example-11-not-validated-windows-web-app-for-containers-using-only-defaults)

### Example 1: _Web App (Linux), using only defaults_

This instance deploys the module as a Linux Web App with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app,linux'
    name: 'minwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    linuxFxVersion: 'DOTNETCORE|8.0'
    location: '<location>'
    virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app,linux'
param name = 'minwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param linuxFxVersion = 'DOTNETCORE|8.0'
param location = '<location>'
param virtualNetworkSubnetId = '<virtualNetworkSubnetId>'
```

</details>
<p>

### Example 2: _Web App (Linux), using large parameter set_

This instance deploys the module asa Linux Web App with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app,linux'
    name: 'maxwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    appInsightResourceId: '<appInsightResourceId>'
    appSettingsKeyValuePairs: {
      ASPNETCORE_ENVIRONMENT: 'Development'
      AzureAd__ClientId: 'ClientId-guid-value-from-EntraID'
      DetailedErrors: 'true'
      DownstreamApis__MyApi__BaseUrl: 'https://www.someapi.com'
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=keyvaultName;SecretName=secretName)'
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: '<WEBSITE_AUTH_AAD_ALLOWED_TENANTS>'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITE_RUN_FROM_PACKAGE: '1'
    }
    authSettingApplicationId: 'ClientId-guid-value-from-EntraID'
    authSettingV2ConfigurationAdditional: {
      identityProviders: {
        azureActiveDirectory: {
          login: {
            loginParameters: [
              'scope=openid profile email offline_access api://ClientId-guid-value-from-EntraID/user_impersonation'
            ]
          }
        }
      }
    }
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    linuxFxVersion: 'DOTNETCORE|8.0'
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    publicNetworkAccess: 'Disabled'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    scmSiteAlsoStopped: true
    siteConfigurationAdditional: {
      cors: {
        allowedOrigins: [
          'https://ms.portal.azure.com'
          'https://portal.azure.com'
        ]
      }
    }
    storageAccountResourceId: '<storageAccountResourceId>'
    storageAccountUseIdentityAuthentication: true
    virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app,linux'
param name = 'maxwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param appInsightResourceId = '<appInsightResourceId>'
param appSettingsKeyValuePairs = {
  ASPNETCORE_ENVIRONMENT: 'Development'
  AzureAd__ClientId: 'ClientId-guid-value-from-EntraID'
  DetailedErrors: 'true'
  DownstreamApis__MyApi__BaseUrl: 'https://www.someapi.com'
  MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=keyvaultName;SecretName=secretName)'
  WEBSITE_AUTH_AAD_ALLOWED_TENANTS: '<WEBSITE_AUTH_AAD_ALLOWED_TENANTS>'
  WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
  WEBSITE_RUN_FROM_PACKAGE: '1'
}
param authSettingApplicationId = 'ClientId-guid-value-from-EntraID'
authSettingV2ConfigurationAdditional: {
  identityProviders: {
    azureActiveDirectory: {
      login: {
        loginParameters: [
          'scope=openid profile email offline_access api://ClientId-guid-value-from-EntraID/user_impersonation'
        ]
      }
    }
  }
}
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param linuxFxVersion = 'DOTNETCORE|8.0'
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param publicNetworkAccess = 'Disabled'
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param scmSiteAlsoStopped = true
param siteConfigurationAdditional = {
  cors: {
    allowedOrigins: [
      'https://ms.portal.azure.com'
      'https://portal.azure.com'
    ]
  }
}
param storageAccountResourceId = '<storageAccountResourceId>'
param storageAccountUseIdentityAuthentication = true
param virtualNetworkSubnetId = '<virtualNetworkSubnetId>'
param vnetContentShareEnabled = true
param vnetImagePullEnabled = true
param vnetRouteAllEnabled = true
```

</details>
<p>

### Example 3: _Web App (Windows), using only defaults_

This instance deploys the module as Web App with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app'
    name: 'minwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    location: '<location>'
    netFrameworkVersion: 'v9.0'
    virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app'
param name = 'minwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param location = '<location>'
param netFrameworkVersion = 'v9.0'
param virtualNetworkSubnetId = '<virtualNetworkSubnetId>'
```

</details>
<p>

### Example 4: _Web App (Windows), using large parameter set_

This instance deploys the module as Web App with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app'
    name: 'maxwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    appInsightResourceId: '<appInsightResourceId>'
    appSettingsKeyValuePairs: {
      ASPNETCORE_ENVIRONMENT: 'Development'
      'AzureAd:ClientId': 'ClientId-guid-value-from-EntraID'
      DetailedErrors: 'true'
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=keyvaultName;SecretName=secretName)'
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: '<WEBSITE_AUTH_AAD_ALLOWED_TENANTS>'
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITE_RUN_FROM_PACKAGE: '1'
    }
    authSettingApplicationId: 'ClientId-guid-value-from-EntraID'
    authSettingV2ConfigurationAdditional: {
      enabled: true
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'Return401'
      }
      identityProviders: {
        azureActiveDirectory: {
          login: {
            loginParameters: [
              'response_type=code id_token'
              'scope=openid profile email offline_access https://graph.microsoft.com/User.Read https://<value>/user_impersonation'
            ]
          }
        }
      }
      platform: {
        enabled: false
        runtimeVersion: '~1'
      }
    }
    connectionStrings: [
      {
        connectionString: 'server=tcp:sqlserverFQDN;database=databaseName;'
        name: 'SqlDbConnection'
        slotSetting: true
        type: 'SQLAzure'
      }
    ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    httpsOnly: true
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    netFrameworkVersion: 'v9.0'
    publicNetworkAccess: 'Disabled'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    scmSiteAlsoStopped: true
    storageAccountResourceId: '<storageAccountResourceId>'
    storageAccountUseIdentityAuthentication: true
    virtualNetworkSubnetId: '<virtualNetworkSubnetId>'
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
    webSiteConfigurationAdditional: {
      cors: {
        allowedOrigins: [
          'https://portal.azure.com'
        ]
        supportCredentials: false
      }
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app'
param name = 'maxwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param appInsightResourceId = '<appInsightResourceId>'
param appSettingsKeyValuePairs = {
  ASPNETCORE_ENVIRONMENT: 'Development'
  'AzureAd:ClientId': 'ClientId-guid-value-from-EntraID'
  DetailedErrors: 'true'
  MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=keyvaultName;SecretName=secretName)'
  WEBSITE_AUTH_AAD_ALLOWED_TENANTS: '<WEBSITE_AUTH_AAD_ALLOWED_TENANTS>'
  WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
  WEBSITE_RUN_FROM_PACKAGE: '1'
}
param authSettingApplicationId = 'ClientId-guid-value-from-EntraID'
authSettingV2ConfigurationAdditional: {
  enabled: true
  globalValidation: {
    requireAuthentication: true
    unauthenticatedClientAction: 'Return401'
  }
  identityProviders: {
    azureActiveDirectory: {
      login: {
        loginParameters: [
          'response_type=code id_token'
          'scope=openid profile email offline_access https://graph.microsoft.com/User.Read https://<value>/user_impersonation'
        ]
      }
    }
  }
  platform: {
    enabled: false
    runtimeVersion: '~1'
  }
}
param connectionStrings = [
  {
    connectionString: 'server=tcp:sqlserverFQDN;database=databaseName;'
    name: 'SqlDbConnection'
    slotSetting: true
    type: 'SQLAzure'
  }
]
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param httpsOnly = true
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param netFrameworkVersion = 'v9.0'
param publicNetworkAccess = 'Disabled'
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param scmSiteAlsoStopped = true
param storageAccountResourceId = '<storageAccountResourceId>'
param storageAccountUseIdentityAuthentication = true
param virtualNetworkSubnetId = '<virtualNetworkSubnetId>'
param vnetContentShareEnabled = true
param vnetImagePullEnabled = true
param vnetRouteAllEnabled = true
param webSiteConfigurationAdditional = {
  cors: {
    allowedOrigins: [
      'https://portal.azure.com'
    ]
    supportCredentials: false
  }
}
```

</details>
<p>

### Example 5: _WAF-aligned_

This instance deploys the Web App in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app'
    name: 'wafwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    basicPublishingCredentialsPolicies: [
      {
        allow: false
        name: 'ftp'
      }
      {
        allow: false
        name: 'scm'
      }
    ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    httpsOnly: true
    location: '<location>'
    publicNetworkAccess: 'Disabled'
    scmSiteAlsoStopped: true
    siteConfiguration: {
      alwaysOn: true
      cors: '<cors>'
      ftpsState: 'Disabled'
      healthCheckPath: '/healthz'
      http20Enabled: true
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnetcore'
        }
      ]
      minTlsVersion: '1.2'
    }
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app'
param name = 'wafwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param basicPublishingCredentialsPolicies = [
  {
    allow: false
    name: 'ftp'
  }
  {
    allow: false
    name: 'scm'
  }
]
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param httpsOnly = true
param location = '<location>'
param publicNetworkAccess = 'Disabled'
param scmSiteAlsoStopped = true
param siteConfiguration = {
  alwaysOn: true
  cors: '<cors>'
  ftpsState: 'Disabled'
  healthCheckPath: '/healthz'
  http20Enabled: true
  metadata: [
    {
      name: 'CURRENT_STACK'
      value: 'dotnetcore'
    }
  ]
  minTlsVersion: '1.2'
}
param vnetContentShareEnabled = true
param vnetImagePullEnabled = true
param vnetRouteAllEnabled = true
```

</details>
<p>

### Example 6: _(NOT VALIDATED) Web App_

This instance deploys the module as Web App with the set of logs configuration.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app'
    name: 'wslc001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    appInsightResourceId: '<appInsightResourceId>'
    appSettingsKeyValuePairs: {
      ENABLE_ORYX_BUILD: 'True'
      JAVA_OPTS: '<JAVA_OPTS>'
      SCM_DO_BUILD_DURING_DEPLOYMENT: 'True'
    }
    location: '<location>'
    logsConfiguration: {
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
    managedIdentities: {
      systemAssigned: true
    }
    siteConfiguration: {
      alwaysOn: true
      appCommandLine: ''
      cors: '<cors>'
      ftpsState: 'Disabled'
      http20Enabled: true
      minTlsVersion: '1.2'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app'
param name = 'wslc001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param appInsightResourceId = '<appInsightResourceId>'
param appSettingsKeyValuePairs = {
  ENABLE_ORYX_BUILD: 'True'
  JAVA_OPTS: '<JAVA_OPTS>'
  SCM_DO_BUILD_DURING_DEPLOYMENT: 'True'
}
param location = '<location>'
param logsConfiguration = {
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
param managedIdentities = {
  systemAssigned: true
}
param siteConfiguration = {
  alwaysOn: true
  appCommandLine: ''
  cors: '<cors>'
  ftpsState: 'Disabled'
  http20Enabled: true
  minTlsVersion: '1.2'
}
```

</details>
<p>

### Example 7: _(NOT VALIDATED) Function App, using only defaults_

This instance deploys the module as Function App with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'functionapp'
    name: 'minfapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'functionapp'
param name = 'minfapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param location = '<location>'
```

</details>
<p>

### Example 8: _(NOT VALIDATED) Function App, using large parameter set_

This instance deploys the module as Function App with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'functionapp'
    name: 'wsfamax001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    appInsightResourceId: '<appInsightResourceId>'
    appSettingsKeyValuePairs: {
      AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
      EASYAUTH_SECRET: '<EASYAUTH_SECRET>'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    }
    authSettingV2Configuration: {
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'Return401'
      }
      httpSettings: {
        forwardProxy: {
          convention: 'NoProxy'
        }
        requireHttps: true
        routes: {
          apiPrefix: '/.auth'
        }
      }
      identityProviders: {
        azureActiveDirectory: {
          enabled: true
          login: {
            disableWWWAuthenticate: false
          }
          registration: {
            clientId: 'd874dd2f-2032-4db1-a053-f0ec243685aa'
            clientSecretSettingName: 'EASYAUTH_SECRET'
            openIdIssuer: '<openIdIssuer>'
          }
          validation: {
            allowedAudiences: [
              'api://d874dd2f-2032-4db1-a053-f0ec243685aa'
            ]
            defaultAuthorizationPolicy: {
              allowedPrincipals: {}
            }
            jwtClaimChecks: {}
          }
        }
      }
      login: {
        allowedExternalRedirectUrls: [
          'string'
        ]
        cookieExpiration: {
          convention: 'FixedTime'
          timeToExpiration: '08:00:00'
        }
        nonce: {
          nonceExpirationInterval: '00:05:00'
          validateNonce: true
        }
        preserveUrlFragmentsForLogins: false
        routes: {}
        tokenStore: {
          azureBlobStorage: {}
          enabled: true
          fileSystem: {}
          tokenRefreshExtensionHours: 72
        }
      }
      platform: {
        enabled: true
        runtimeVersion: '~1'
      }
    }
    basicPublishingCredentialsPolicies: [
      {
        allow: false
        name: 'ftp'
      }
      {
        allow: false
        name: 'scm'
      }
    ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    hybridConnectionRelays: [
      {
        resourceId: '<resourceId>'
        sendKeyName: 'defaultSender'
      }
    ]
    keyVaultAccessIdentityResourceId: '<keyVaultAccessIdentityResourceId>'
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    siteConfiguration: {
      alwaysOn: true
      use32BitWorkerProcess: false
    }
    storageAccountResourceId: '<storageAccountResourceId>'
    storageAccountUseIdentityAuthentication: true
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'functionapp'
param name = 'wsfamax001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param appInsightResourceId = '<appInsightResourceId>'
param appSettingsKeyValuePairs = {
  AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
  EASYAUTH_SECRET: '<EASYAUTH_SECRET>'
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
}
authSettingV2Configuration: {
  globalValidation: {
    requireAuthentication: true
    unauthenticatedClientAction: 'Return401'
  }
  httpSettings: {
    forwardProxy: {
      convention: 'NoProxy'
    }
    requireHttps: true
    routes: {
      apiPrefix: '/.auth'
    }
  }
  identityProviders: {
    azureActiveDirectory: {
      enabled: true
      login: {
        disableWWWAuthenticate: false
      }
      registration: {
        clientId: 'd874dd2f-2032-4db1-a053-f0ec243685aa'
        clientSecretSettingName: 'EASYAUTH_SECRET'
        openIdIssuer: '<openIdIssuer>'
      }
      validation: {
        allowedAudiences: [
          'api://d874dd2f-2032-4db1-a053-f0ec243685aa'
        ]
        defaultAuthorizationPolicy: {
          allowedPrincipals: {}
        }
        jwtClaimChecks: {}
      }
    }
  }
  login: {
    allowedExternalRedirectUrls: [
      'string'
    ]
    cookieExpiration: {
      convention: 'FixedTime'
      timeToExpiration: '08:00:00'
    }
    nonce: {
      nonceExpirationInterval: '00:05:00'
      validateNonce: true
    }
    preserveUrlFragmentsForLogins: false
    routes: {}
    tokenStore: {
      azureBlobStorage: {}
      enabled: true
      fileSystem: {}
      tokenRefreshExtensionHours: 72
    }
  }
  platform: {
    enabled: true
    runtimeVersion: '~1'
  }
}
param basicPublishingCredentialsPolicies = [
  {
    allow: false
    name: 'ftp'
  }
  {
    allow: false
    name: 'scm'
  }
]
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param hybridConnectionRelays = [
  {
    resourceId: '<resourceId>'
    sendKeyName: 'defaultSender'
  }
]
param keyVaultAccessIdentityResourceId = '<keyVaultAccessIdentityResourceId>'
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param siteConfiguration = {
  alwaysOn: true
  use32BitWorkerProcess: false
}
param storageAccountResourceId = '<storageAccountResourceId>'
param storageAccountUseIdentityAuthentication = true
```

</details>
<p>

### Example 9: _(NOT VALIDATED) Function App, using defaults and some settings_

This instance deploys the module as Function App with the minimum set of required parameters, and some settings.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'functionapp'
    name: 'wsfaset001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    appSettingsKeyValuePairs: {
      AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    }
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'functionapp'
param name = 'wsfaset001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param appSettingsKeyValuePairs = {
  AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
}
param location = '<location>'
```

</details>
<p>

### Example 10: _(NOT VALIDATED) Web App, using only defaults_

This instance deploys the module as a Linux Container Web App with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app,linux,container'
    name: 'minwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    location: '<location>'
    siteConfiguration: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app,linux,container'
param name = 'minwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param location = '<location>'
param siteConfiguration = {
  appSettings: [
    {
      name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
      value: 'false'
    }
  ]
  linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
}
```

</details>
<p>

### Example 11: _(NOT VALIDATED) Windows Web App for Containers, using only defaults_

This instance deploys the module as a Windows based Container Web App with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module siteMod 'br/<registry-alias>:res/web/site:<version>' = {
  name: 'site-mod'
  params: {
    // Required parameters
    kind: 'app,container,windows'
    name: 'minwapp001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    serverFarmResourceId: '<serverFarmResourceId>'
    // Non-required parameters
    location: '<location>'
    siteConfiguration: {
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/site:<version>'

// Required parameters
param kind = 'app,container,windows'
param name = 'minwapp001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
param serverFarmResourceId = '<serverFarmResourceId>'
// Non-required parameters
param location = '<location>'
param siteConfiguration = {
  appSettings: [
    {
      name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
      value: 'false'
    }
  ]
  windowsFxVersion: 'DOCKER|mcr.microsoft.com/azure-app-service/windows/parkingpage:latest'
}
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-kind) | string | Type of site to deploy. |
| [`name`](#parameter-name) | string | Name of the site. |
| [`serverFarmResourceId`](#parameter-serverfarmresourceid) | string | The resource ID of the app service plan to use for the site. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`linuxFxVersion`](#parameter-linuxfxversion) | string | Required for Linux app plan to represent runtime stack in the format of 'runtime\|runtimeVersion'.<p>Select from the list of supported runtimes and versions or leave empty for the custom handler option.<p><p>See `az webapp list-runtimes --os linux --output table` for available runtimes, and replace ':' with '\|' symbol.<p><p>For Docker containers use format 'DOCKER\|dockerRegistry/dockerRepositoryPath'<p> |
| [`storageAccountResourceId`](#parameter-storageaccountresourceid) | string | Required if app of kind functionapp. Resource ID of the storage account to manage triggers and logging function executions. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`appInsightResourceId`](#parameter-appinsightresourceid) | string | Resource ID of the app insight to leverage for this resource. |
| [`appServiceEnvironmentResourceId`](#parameter-appserviceenvironmentresourceid) | string | The resource ID of the app service environment to use for this resource. |
| [`appSettingsKeyValuePairs`](#parameter-appsettingskeyvaluepairs) | object | The app settings-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING. |
| [`authSettingApplicationId`](#parameter-authsettingapplicationid) | string | Application Id of the EntraID application registration used for authentication. |
| [`authSettingV2Configuration`](#parameter-authsettingv2configuration) | object | The auth settings V2 configuration.<p>When using parameter defaults it configures Entra ID 'Easy Auth' using the application ID provided in the 'authSettingApplicationId' parameter.<p><p>Leaving this parameter empty will make the resource non-compliant.<p> |
| [`authSettingV2ConfigurationAdditional`](#parameter-authsettingv2configurationadditional) | object | Additional auth settings V2 configuration to the values in siteConfiguration parameter.<p><p>Use it when you want to keep defaults in siteConfiguration, but override or append them with additional configurations.<p> |
| [`basicPublishingCredentialsPolicies`](#parameter-basicpublishingcredentialspolicies) | array | The site publishing credential policy names which are associated with the sites.<p><p>Providing empty values for this parameter or setting allow to 'true' will make the resource non-compliant.<p> |
| [`clientAffinityEnabled`](#parameter-clientaffinityenabled) | bool | If client affinity is enabled. Default: false |
| [`clientCertEnabled`](#parameter-clientcertenabled) | bool | To enable client certificate authentication (TLS mutual authentication). |
| [`clientCertExclusionPaths`](#parameter-clientcertexclusionpaths) | string | Client certificate authentication comma-separated exclusion paths. |
| [`clientCertMode`](#parameter-clientcertmode) | string | This composes with ClientCertEnabled setting.<li>ClientCertEnabled=false means ClientCert is ignored.<li>ClientCertEnabled=true and ClientCertMode=Required means ClientCert is required.<li>ClientCertEnabled=true and ClientCertMode=Optional means ClientCert is optional or accepted.<p> |
| [`cloningInfo`](#parameter-cloninginfo) | object | If specified during app creation, the app is cloned from a source app. |
| [`connectionStrings`](#parameter-connectionstrings) | array | An array of connection string for Web App.<p><p>If provided, it will be added to the webSiteConfiguration parameter.<p> |
| [`containerSize`](#parameter-containersize) | int | Size of the function container. |
| [`dailyMemoryTimeQuota`](#parameter-dailymemorytimequota) | int | Maximum allowed daily memory-time quota (applicable on dynamic apps only). |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service.<p><p>Currently known available log categories that are enabled by default:<p>  'AppServiceHTTPLogs'<p>  'AppServiceConsoleLogs'<p>  'AppServiceAppLogs'<p>  'AppServiceAuditLogs'<p>  'AppServiceIPSecAuditLogs'<p>  'AppServicePlatformLogs'<p>  'AppServiceAuthenticationLogs'<p><p>Additionally available in Premiums sku that can be used :<p>  'AppServiceAntivirusScanAuditLogs'<p>  'AppServiceFileAuditLogs'<p><p> |
| [`enabled`](#parameter-enabled) | bool | Setting this value to false disables the app (takes the app offline). |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`functionAppConfiguration`](#parameter-functionappconfiguration) | object | The Function App configuration object. |
| [`hostNameSslStates`](#parameter-hostnamesslstates) | array | Hostname SSL states are used to manage the SSL bindings for app's hostnames. |
| [`httpsOnly`](#parameter-httpsonly) | bool | Configures a site to accept only HTTPS requests, and issues redirect for HTTP requests. Default: true.<p><p>Setting this parameter to 'false' will make the resource non-compliant.<p> |
| [`hybridConnectionRelays`](#parameter-hybridconnectionrelays) | array | Names of hybrid connection relays to connect app with. |
| [`hyperV`](#parameter-hyperv) | bool | Hyper-V sandbox. Default: false |
| [`javaVersion`](#parameter-javaversion) | string | Windows-only. Version of Java used in the App Service app. Examples: 21, 17, 11, 1.8 |
| [`keyVaultAccessIdentityResourceId`](#parameter-keyvaultaccessidentityresourceid) | string | The resource ID of the assigned identity to be used to access a key vault with. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`logsConfiguration`](#parameter-logsconfiguration) | object | The logs settings configuration.<p>By default it is configured as Verbose level logging to the file system with 1 day of retention.<p> |
| [`managedEnvironmentId`](#parameter-managedenvironmentid) | string | Azure Resource Manager ID of the customers selected Managed Environment on which to host this app. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. Default: systemAssigned is true. |
| [`msDeployConfiguration`](#parameter-msdeployconfiguration) | object | The extension MSDeployment configuration. |
| [`netFrameworkVersion`](#parameter-netframeworkversion) | string | Windows-only. Version of the .NET Framework used in the App Service app. Examples: v9.0, v8.0, v7.0 |
| [`nodeVersion`](#parameter-nodeversion) | string | Windows-only. Version of Node.js used in the App Service app. Examples: 22, 18, 16. |
| [`phpVersion`](#parameter-phpversion) | string | Windows-only. Version of PHP used in the App Service app. Examples: 8.2 |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints.<p>For security reasons, it is recommended to use private endpoints whenever possible.<p><p>Available values for 'service' are:<li>sites<p><p>Default: sites is used if at least one subnetResourceId is provided but 'service' is not specified.<p> |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Whether or not public network access is allowed for this resource.<p>For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant. |
| [`pythonVersion`](#parameter-pythonversion) | string | Windows-only. Version of Python used in the App Service app. Examples: 3.11, 3.10, 3.9 |
| [`redundancyMode`](#parameter-redundancymode) | string | Site redundancy mode. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`scmSiteAlsoStopped`](#parameter-scmsitealsostopped) | bool | Stop SCM (KUDU) site when the app is stopped. |
| [`siteConfiguration`](#parameter-siteconfiguration) | object | The site configuration object.<p>Please refer to the Microsoft documentation for available parameters https://learn.microsoft.com/en-gb/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep#siteconfig<p><p>To maintain compliant state, the following values are required and configured by default:<li>http20Enabled: true<li>ftpsState: 'Disabled' or 'FtpsOnly' (default: 'Disabled')<li>minTlsVersion: '1.3'<li>cors: must be either null, or cors.allowedOrigins contains an array of values other than '*' (default: null)<li>remoteDebuggingEnabled: false<p> |
| [`siteConfigurationAdditional`](#parameter-siteconfigurationadditional) | object | The additional site config object key-value pairs to the values in siteConfiguration parameter.<p><p>Use it when you want to keep defaults in siteConfiguration, but override or append them with additional configurations.<p> |
| [`storageAccountRequired`](#parameter-storageaccountrequired) | bool | Checks if Customer provided storage account is required. |
| [`storageAccountUseIdentityAuthentication`](#parameter-storageaccountuseidentityauthentication) | bool | If the provided storage account requires Identity based authentication ('allowSharedKeyAccess' is set to false).<p>When set to true, the minimum role assignment required for the App Service Managed Identity to the storage account is 'Storage Blob Data Owner'. Default: true |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`virtualNetworkSubnetId`](#parameter-virtualnetworksubnetid) | string | Azure resource ID of the Virtual network subnet to be joined by Regional VNET Integration.<p><p>Leaving this parameter empty when appServiceEnvironmentResourceId is also not provided will make the resource non-compliant.<p> |
| [`vnetContentShareEnabled`](#parameter-vnetcontentshareenabled) | bool | To enable accessing content over virtual network. |
| [`vnetImagePullEnabled`](#parameter-vnetimagepullenabled) | bool | To enable pulling image over Virtual Network. |
| [`vnetRouteAllEnabled`](#parameter-vnetrouteallenabled) | bool | Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied. |
| [`webSiteConfiguration`](#parameter-websiteconfiguration) | object | The web site settings configuration.<p><p>Please refer to the documentation for available options https://learn.microsoft.com/en-gb/azure/templates/microsoft.web/sites/config?pivots=deployment-language-bicep#siteconfig<p> |
| [`webSiteConfigurationAdditional`](#parameter-websiteconfigurationadditional) | object | The additional web site settings configuration.<p><p>Use it when you want to keep defaults in webSiteConfiguration, but override or append them with additional configurations.<p> |

### Parameter: `kind`

Type of site to deploy.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'api'
    'app'
    'app,container,windows'
    'app,linux'
    'app,linux,container'
    'functionapp'
    'functionapp,linux'
    'functionapp,linux,container'
    'functionapp,linux,container,azurecontainerapps'
    'functionapp,workflowapp'
    'functionapp,workflowapp,linux'
    'linux,api'
  ]
  ```
- Example:
  ```Bicep
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
  ```

### Parameter: `name`

Name of the site.

- Required: Yes
- Type: string

### Parameter: `serverFarmResourceId`

The resource ID of the app service plan to use for the site.

- Required: Yes
- Type: string

### Parameter: `linuxFxVersion`

Required for Linux app plan to represent runtime stack in the format of 'runtime\|runtimeVersion'.<p>Select from the list of supported runtimes and versions or leave empty for the custom handler option.<p><p>See `az webapp list-runtimes --os linux --output table` for available runtimes, and replace ':' with '\|' symbol.<p><p>For Docker containers use format 'DOCKER\|dockerRegistry/dockerRepositoryPath'<p>

- Required: No
- Type: string

### Parameter: `storageAccountResourceId`

Required if app of kind functionapp. Resource ID of the storage account to manage triggers and logging function executions.

- Required: No
- Type: string

### Parameter: `appInsightResourceId`

Resource ID of the app insight to leverage for this resource.

- Required: No
- Type: string

### Parameter: `appServiceEnvironmentResourceId`

The resource ID of the app service environment to use for this resource.

- Required: No
- Type: string

### Parameter: `appSettingsKeyValuePairs`

The app settings-value pairs except for AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING.

- Required: No
- Type: object

### Parameter: `authSettingApplicationId`

Application Id of the EntraID application registration used for authentication.

- Required: No
- Type: string

### Parameter: `authSettingV2Configuration`

The auth settings V2 configuration.<p>When using parameter defaults it configures Entra ID 'Easy Auth' using the application ID provided in the 'authSettingApplicationId' parameter.<p><p>Leaving this parameter empty will make the resource non-compliant.<p>

- Required: No
- Type: object
- Default: `[if(startsWith(parameters('kind'), 'app'), createObject('enabled', true(), 'platform', createObject('enabled', true(), 'runtimeVersion', '~1'), 'globalValidation', createObject('requireAuthentication', true(), 'unauthenticatedClientAction', 'RedirectToLoginPage', 'redirectToProvider', 'azureactivedirectory'), 'identityProviders', createObject('azureActiveDirectory', if(empty(parameters('authSettingApplicationId')), null(), createObject('enabled', true(), 'registration', createObject('openIdIssuer', format('https://sts.windows.net/{0}/v2.0', tenant().tenantId), 'clientId', parameters('authSettingApplicationId'), 'clientSecretSettingName', 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'), 'login', createObject('disableWWWAuthenticate', false()), 'validation', createObject('jwtClaimChecks', createObject(), 'allowedAudiences', createArray(format('api://{0}/user_impersonation', parameters('authSettingApplicationId'))), 'defaultAuthorizationPolicy', createObject('allowedPrincipals', createObject(), 'allowedApplications', createArray(parameters('authSettingApplicationId'))))))), 'login', createObject('routes', createObject(), 'tokenStore', createObject('enabled', true(), 'tokenRefreshExtensionHours', json('72.0'), 'fileSystem', createObject(), 'azureBlobStorage', createObject()), 'preserveUrlFragmentsForLogins', false(), 'cookieExpiration', createObject('convention', 'FixedTime', 'timeToExpiration', '08:00:00'), 'nonce', createObject('validateNonce', true(), 'nonceExpirationInterval', '00:05:00')), 'httpSettings', createObject('requireHttps', true(), 'routes', createObject('apiPrefix', '/.auth'), 'forwardProxy', createObject('convention', 'NoProxy')), 'clearInboundClaimsMapping', 'false'), createObject('enabled', true(), 'platform', createObject('enabled', false(), 'runtimeVersion', '~1'), 'globalValidation', createObject('requireAuthentication', true(), 'unauthenticatedClientAction', 'Return401'), 'identityProviders', createObject('azureActiveDirectory', if(empty(parameters('authSettingApplicationId')), null(), createObject('enabled', true(), 'registration', createObject('openIdIssuer', format('https://sts.windows.net/{0}/v2.0', tenant().tenantId), 'clientId', parameters('authSettingApplicationId'), 'clientSecretSettingName', 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'), 'login', createObject('disableWWWAuthenticate', false()), 'validation', createObject('jwtClaimChecks', createObject(), 'allowedAudiences', createArray(), 'defaultAuthorizationPolicy', createObject('allowedPrincipals', createObject(), 'allowedApplications', createArray())))))))]`

### Parameter: `authSettingV2ConfigurationAdditional`

Additional auth settings V2 configuration to the values in siteConfiguration parameter.<p><p>Use it when you want to keep defaults in siteConfiguration, but override or append them with additional configurations.<p>

- Required: No
- Type: object
- Default: `{}`

### Parameter: `basicPublishingCredentialsPolicies`

The site publishing credential policy names which are associated with the sites.<p><p>Providing empty values for this parameter or setting allow to 'true' will make the resource non-compliant.<p>

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    {
      allow: false
      name: 'ftp'
    }
    {
      allow: false
      name: 'scm'
    }
  ]
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-basicpublishingcredentialspoliciesname) | string | The name of the resource |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`allow`](#parameter-basicpublishingcredentialspoliciesallow) | bool | Set to true to enable or false to disable a publishing method. Default: true. |

### Parameter: `basicPublishingCredentialsPolicies.name`

The name of the resource

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'ftp'
    'scm'
  ]
  ```

### Parameter: `basicPublishingCredentialsPolicies.allow`

Set to true to enable or false to disable a publishing method. Default: true.

- Required: No
- Type: bool

### Parameter: `clientAffinityEnabled`

If client affinity is enabled. Default: false

- Required: No
- Type: bool
- Default: `False`

### Parameter: `clientCertEnabled`

To enable client certificate authentication (TLS mutual authentication).

- Required: No
- Type: bool
- Default: `False`

### Parameter: `clientCertExclusionPaths`

Client certificate authentication comma-separated exclusion paths.

- Required: No
- Type: string

### Parameter: `clientCertMode`

This composes with ClientCertEnabled setting.<li>ClientCertEnabled=false means ClientCert is ignored.<li>ClientCertEnabled=true and ClientCertMode=Required means ClientCert is required.<li>ClientCertEnabled=true and ClientCertMode=Optional means ClientCert is optional or accepted.<p>

- Required: No
- Type: string
- Default: `'Optional'`
- Allowed:
  ```Bicep
  [
    'Optional'
    'OptionalInteractiveUser'
    'Required'
  ]
  ```

### Parameter: `cloningInfo`

If specified during app creation, the app is cloned from a source app.

- Required: No
- Type: object

### Parameter: `connectionStrings`

An array of connection string for Web App.<p><p>If provided, it will be added to the webSiteConfiguration parameter.<p>

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`connectionString`](#parameter-connectionstringsconnectionstring) | string | Connection string value. |
| [`name`](#parameter-connectionstringsname) | string | Name of connection string. |
| [`type`](#parameter-connectionstringstype) | string | Type of database. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`slotSetting`](#parameter-connectionstringsslotsetting) | bool | Is it a deployment slot setting |

### Parameter: `connectionStrings.connectionString`

Connection string value.

- Required: Yes
- Type: string

### Parameter: `connectionStrings.name`

Name of connection string.

- Required: Yes
- Type: string

### Parameter: `connectionStrings.type`

Type of database.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'ApiHub'
    'Custom'
    'DocDb'
    'EventHub'
    'MySql'
    'NotificationHub'
    'PostgreSQL'
    'RedisCache'
    'ServiceBus'
    'SQLAzure'
    'SQLServer'
  ]
  ```

### Parameter: `connectionStrings.slotSetting`

Is it a deployment slot setting

- Required: No
- Type: bool

### Parameter: `containerSize`

Size of the function container.

- Required: No
- Type: int

### Parameter: `dailyMemoryTimeQuota`

Maximum allowed daily memory-time quota (applicable on dynamic apps only).

- Required: No
- Type: int

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.<p><p>Currently known available log categories that are enabled by default:<p>  'AppServiceHTTPLogs'<p>  'AppServiceConsoleLogs'<p>  'AppServiceAppLogs'<p>  'AppServiceAuditLogs'<p>  'AppServiceIPSecAuditLogs'<p>  'AppServicePlatformLogs'<p>  'AppServiceAuthenticationLogs'<p><p>Additionally available in Premiums sku that can be used :<p>  'AppServiceAntivirusScanAuditLogs'<p>  'AppServiceFileAuditLogs'<p><p>

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`eventHubAuthorizationRuleResourceId`](#parameter-diagnosticsettingseventhubauthorizationruleresourceid) | string | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| [`eventHubName`](#parameter-diagnosticsettingseventhubname) | string | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`logAnalyticsDestinationType`](#parameter-diagnosticsettingsloganalyticsdestinationtype) | string | A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type. |
| [`logCategoriesAndGroups`](#parameter-diagnosticsettingslogcategoriesandgroups) | array | The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection. |
| [`marketplacePartnerResourceId`](#parameter-diagnosticsettingsmarketplacepartnerresourceid) | string | The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. |
| [`metricCategories`](#parameter-diagnosticsettingsmetriccategories) | array | The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection. |
| [`name`](#parameter-diagnosticsettingsname) | string | The name of diagnostic setting. |
| [`storageAccountResourceId`](#parameter-diagnosticsettingsstorageaccountresourceid) | string | Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`workspaceResourceId`](#parameter-diagnosticsettingsworkspaceresourceid) | string | Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |

### Parameter: `diagnosticSettings.eventHubAuthorizationRuleResourceId`

Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.eventHubName`

Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logAnalyticsDestinationType`

A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureDiagnostics'
    'Dedicated'
  ]
  ```

### Parameter: `diagnosticSettings.logCategoriesAndGroups`

The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingslogcategoriesandgroupscategory) | string | Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here. |
| [`categoryGroup`](#parameter-diagnosticsettingslogcategoriesandgroupscategorygroup) | string | Name of a Diagnostic Log category group for a resource type this setting is applied to. |
| [`enabled`](#parameter-diagnosticsettingslogcategoriesandgroupsenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.logCategoriesAndGroups.category`

Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.categoryGroup`

Name of a Diagnostic Log category group for a resource type this setting is applied to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.marketplacePartnerResourceId`

The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.metricCategories`

The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingsmetriccategoriescategory) | string | Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-diagnosticsettingsmetriccategoriesenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.metricCategories.category`

Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.

- Required: Yes
- Type: string

### Parameter: `diagnosticSettings.metricCategories.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.name`

The name of diagnostic setting.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.storageAccountResourceId`

Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.workspaceResourceId`

Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `enabled`

Setting this value to false disables the app (takes the app offline).

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `functionAppConfiguration`

The Function App configuration object.

- Required: No
- Type: object

### Parameter: `hostNameSslStates`

Hostname SSL states are used to manage the SSL bindings for app's hostnames.

- Required: No
- Type: array

### Parameter: `httpsOnly`

Configures a site to accept only HTTPS requests, and issues redirect for HTTP requests. Default: true.<p><p>Setting this parameter to 'false' will make the resource non-compliant.<p>

- Required: No
- Type: bool
- Default: `True`

### Parameter: `hybridConnectionRelays`

Names of hybrid connection relays to connect app with.

- Required: No
- Type: array

### Parameter: `hyperV`

Hyper-V sandbox. Default: false

- Required: No
- Type: bool
- Default: `False`

### Parameter: `javaVersion`

Windows-only. Version of Java used in the App Service app. Examples: 21, 17, 11, 1.8

- Required: No
- Type: string

### Parameter: `keyVaultAccessIdentityResourceId`

The resource ID of the assigned identity to be used to access a key vault with.

- Required: No
- Type: string

### Parameter: `location`

Location for all Resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `logsConfiguration`

The logs settings configuration.<p>By default it is configured as Verbose level logging to the file system with 1 day of retention.<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
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
  ```

### Parameter: `managedEnvironmentId`

Azure Resource Manager ID of the customers selected Managed Environment on which to host this app.

- Required: No
- Type: string

### Parameter: `managedIdentities`

The managed identity definition for this resource. Default: systemAssigned is true.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      systemAssigned: true
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`systemAssigned`](#parameter-managedidentitiessystemassigned) | bool | Enables system assigned managed identity on the resource. |
| [`userAssignedResourceIds`](#parameter-managedidentitiesuserassignedresourceids) | array | The resource ID(s) to assign to the resource. |

### Parameter: `managedIdentities.systemAssigned`

Enables system assigned managed identity on the resource.

- Required: No
- Type: bool

### Parameter: `managedIdentities.userAssignedResourceIds`

The resource ID(s) to assign to the resource.

- Required: No
- Type: array

### Parameter: `msDeployConfiguration`

The extension MSDeployment configuration.

- Required: No
- Type: object

### Parameter: `netFrameworkVersion`

Windows-only. Version of the .NET Framework used in the App Service app. Examples: v9.0, v8.0, v7.0

- Required: No
- Type: string

### Parameter: `nodeVersion`

Windows-only. Version of Node.js used in the App Service app. Examples: 22, 18, 16.

- Required: No
- Type: string

### Parameter: `phpVersion`

Windows-only. Version of PHP used in the App Service app. Examples: 8.2

- Required: No
- Type: string

### Parameter: `privateEndpoints`

Configuration details for private endpoints.<p>For security reasons, it is recommended to use private endpoints whenever possible.<p><p>Available values for 'service' are:<li>sites<p><p>Default: sites is used if at least one subnetResourceId is provided but 'service' is not specified.<p>

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnetResourceId`](#parameter-privateendpointssubnetresourceid) | string | Resource ID of the subnet where the endpoint needs to be created. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`service`](#parameter-privateendpointsservice) | string | If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationSecurityGroupResourceIds`](#parameter-privateendpointsapplicationsecuritygroupresourceids) | array | Application security groups in which the private endpoint IP configuration is included. |
| [`customDnsConfigs`](#parameter-privateendpointscustomdnsconfigs) | array | Custom DNS configurations. |
| [`customNetworkInterfaceName`](#parameter-privateendpointscustomnetworkinterfacename) | string | The custom name of the network interface attached to the private endpoint. |
| [`enableTelemetry`](#parameter-privateendpointsenabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`ipConfigurations`](#parameter-privateendpointsipconfigurations) | array | A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints. |
| [`isManualConnection`](#parameter-privateendpointsismanualconnection) | bool | If Manual Private Link Connection is required. |
| [`location`](#parameter-privateendpointslocation) | string | The location to deploy the private endpoint to. |
| [`lock`](#parameter-privateendpointslock) | object | Specify the type of lock. |
| [`manualConnectionRequestMessage`](#parameter-privateendpointsmanualconnectionrequestmessage) | string | A message passed to the owner of the remote resource with the manual connection request. |
| [`name`](#parameter-privateendpointsname) | string | The name of the private endpoint. |
| [`privateDnsZoneGroupName`](#parameter-privateendpointsprivatednszonegroupname) | string | The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided. |
| [`privateDnsZoneResourceIds`](#parameter-privateendpointsprivatednszoneresourceids) | array | The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones. |
| [`privateLinkServiceConnectionName`](#parameter-privateendpointsprivatelinkserviceconnectionname) | string | The name of the private link connection to create. |
| [`resourceGroupName`](#parameter-privateendpointsresourcegroupname) | string | Specify if you want to deploy the Private Endpoint into a different resource group than the main resource. |
| [`roleAssignments`](#parameter-privateendpointsroleassignments) | array | Array of role assignments to create. |
| [`tags`](#parameter-privateendpointstags) | object | Tags to be applied on all resources/resource groups in this deployment. |

### Parameter: `privateEndpoints.subnetResourceId`

Resource ID of the subnet where the endpoint needs to be created.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.service`

If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource

- Required: No
- Type: string

### Parameter: `privateEndpoints.applicationSecurityGroupResourceIds`

Application security groups in which the private endpoint IP configuration is included.

- Required: No
- Type: array

### Parameter: `privateEndpoints.customDnsConfigs`

Custom DNS configurations.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`fqdn`](#parameter-privateendpointscustomdnsconfigsfqdn) | string | Fqdn that resolves to private endpoint IP address. |
| [`ipAddresses`](#parameter-privateendpointscustomdnsconfigsipaddresses) | array | A list of private IP addresses of the private endpoint. |

### Parameter: `privateEndpoints.customDnsConfigs.fqdn`

Fqdn that resolves to private endpoint IP address.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.customDnsConfigs.ipAddresses`

A list of private IP addresses of the private endpoint.

- Required: Yes
- Type: array

### Parameter: `privateEndpoints.customNetworkInterfaceName`

The custom name of the network interface attached to the private endpoint.

- Required: No
- Type: string

### Parameter: `privateEndpoints.enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool

### Parameter: `privateEndpoints.ipConfigurations`

A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-privateendpointsipconfigurationsname) | string | The name of the resource that is unique within a resource group. |
| [`properties`](#parameter-privateendpointsipconfigurationsproperties) | object | Properties of private endpoint IP configurations. |

### Parameter: `privateEndpoints.ipConfigurations.name`

The name of the resource that is unique within a resource group.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties`

Properties of private endpoint IP configurations.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`groupId`](#parameter-privateendpointsipconfigurationspropertiesgroupid) | string | The ID of a group obtained from the remote resource that this private endpoint should connect to. |
| [`memberName`](#parameter-privateendpointsipconfigurationspropertiesmembername) | string | The member name of a group obtained from the remote resource that this private endpoint should connect to. |
| [`privateIPAddress`](#parameter-privateendpointsipconfigurationspropertiesprivateipaddress) | string | A private IP address obtained from the private endpoint's subnet. |

### Parameter: `privateEndpoints.ipConfigurations.properties.groupId`

The ID of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties.memberName`

The member name of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties.privateIPAddress`

A private IP address obtained from the private endpoint's subnet.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.isManualConnection`

If Manual Private Link Connection is required.

- Required: No
- Type: bool

### Parameter: `privateEndpoints.location`

The location to deploy the private endpoint to.

- Required: No
- Type: string

### Parameter: `privateEndpoints.lock`

Specify the type of lock.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-privateendpointslockkind) | string | Specify the type of lock. |
| [`name`](#parameter-privateendpointslockname) | string | Specify the name of lock. |

### Parameter: `privateEndpoints.lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `privateEndpoints.lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `privateEndpoints.manualConnectionRequestMessage`

A message passed to the owner of the remote resource with the manual connection request.

- Required: No
- Type: string

### Parameter: `privateEndpoints.name`

The name of the private endpoint.

- Required: No
- Type: string

### Parameter: `privateEndpoints.privateDnsZoneGroupName`

The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided.

- Required: No
- Type: string

### Parameter: `privateEndpoints.privateDnsZoneResourceIds`

The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones.

- Required: No
- Type: array

### Parameter: `privateEndpoints.privateLinkServiceConnectionName`

The name of the private link connection to create.

- Required: No
- Type: string

### Parameter: `privateEndpoints.resourceGroupName`

Specify if you want to deploy the Private Endpoint into a different resource group than the main resource.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'DNS Resolver Contributor'`
  - `'DNS Zone Contributor'`
  - `'Domain Services Contributor'`
  - `'Domain Services Reader'`
  - `'Network Contributor'`
  - `'Private DNS Zone Contributor'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-privateendpointsroleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-privateendpointsroleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-privateendpointsroleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-privateendpointsroleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-privateendpointsroleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-privateendpointsroleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-privateendpointsroleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `privateEndpoints.roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `privateEndpoints.roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `privateEndpoints.tags`

Tags to be applied on all resources/resource groups in this deployment.

- Required: No
- Type: object

### Parameter: `publicNetworkAccess`

Whether or not public network access is allowed for this resource.<p>For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `pythonVersion`

Windows-only. Version of Python used in the App Service app. Examples: 3.11, 3.10, 3.9

- Required: No
- Type: string

### Parameter: `redundancyMode`

Site redundancy mode.

- Required: No
- Type: string
- Default: `'None'`
- Allowed:
  ```Bicep
  [
    'ActiveActive'
    'Failover'
    'GeoRedundant'
    'Manual'
    'None'
  ]
  ```

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'App Compliance Automation Administrator'`
  - `'Web Plan Contributor'`
  - `'Website Contributor'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-roleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-roleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `scmSiteAlsoStopped`

Stop SCM (KUDU) site when the app is stopped.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `siteConfiguration`

The site configuration object.<p>Please refer to the Microsoft documentation for available parameters https://learn.microsoft.com/en-gb/azure/templates/microsoft.web/sites?pivots=deployment-language-bicep#siteconfig<p><p>To maintain compliant state, the following values are required and configured by default:<li>http20Enabled: true<li>ftpsState: 'Disabled' or 'FtpsOnly' (default: 'Disabled')<li>minTlsVersion: '1.3'<li>cors: must be either null, or cors.allowedOrigins contains an array of values other than '*' (default: null)<li>remoteDebuggingEnabled: false<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      acrUseManagedIdentityCreds: true
      alwaysOn: true
      cors: null
      ftpsState: 'Disabled'
      http20Enabled: true
      httpLoggingEnabled: true
      linuxFxVersion: '[if(contains(parameters(\'kind\'), \'linux\'), parameters(\'linuxFxVersion\'), null())]'
      logsDirectorySizeLimit: 45
      metadata: '[if(contains(parameters(\'kind\'), \'linux\'), createArray(), createArray(createObject(\'name\', \'CURRENT_STACK\', \'value\', if(not(empty(parameters(\'netFrameworkVersion\'))), \'dotnet\', if(not(empty(parameters(\'javaVersion\'))), \'java\', if(not(empty(parameters(\'nodeVersion\'))), \'node\', if(not(empty(parameters(\'pythonVersion\'))), \'python\', if(not(empty(parameters(\'phpVersion\'))), \'php\', \'\'))))))))]'
      minTlsVersion: '1.3'
      remoteDebuggingEnabled: false
  }
  ```

### Parameter: `siteConfigurationAdditional`

The additional site config object key-value pairs to the values in siteConfiguration parameter.<p><p>Use it when you want to keep defaults in siteConfiguration, but override or append them with additional configurations.<p>

- Required: No
- Type: object
- Default: `{}`

### Parameter: `storageAccountRequired`

Checks if Customer provided storage account is required.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `storageAccountUseIdentityAuthentication`

If the provided storage account requires Identity based authentication ('allowSharedKeyAccess' is set to false).<p>When set to true, the minimum role assignment required for the App Service Managed Identity to the storage account is 'Storage Blob Data Owner'. Default: true

- Required: No
- Type: bool
- Default: `True`

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `virtualNetworkSubnetId`

Azure resource ID of the Virtual network subnet to be joined by Regional VNET Integration.<p><p>Leaving this parameter empty when appServiceEnvironmentResourceId is also not provided will make the resource non-compliant.<p>

- Required: No
- Type: string

### Parameter: `vnetContentShareEnabled`

To enable accessing content over virtual network.

- Required: No
- Type: bool
- Default: `[or(not(empty(parameters('virtualNetworkSubnetId'))), not(empty(parameters('appServiceEnvironmentResourceId'))))]`

### Parameter: `vnetImagePullEnabled`

To enable pulling image over Virtual Network.

- Required: No
- Type: bool
- Default: `[or(not(empty(parameters('virtualNetworkSubnetId'))), not(empty(parameters('appServiceEnvironmentResourceId'))))]`

### Parameter: `vnetRouteAllEnabled`

Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied.

- Required: No
- Type: bool
- Default: `[or(not(empty(parameters('virtualNetworkSubnetId'))), not(empty(parameters('appServiceEnvironmentResourceId'))))]`

### Parameter: `webSiteConfiguration`

The web site settings configuration.<p><p>Please refer to the documentation for available options https://learn.microsoft.com/en-gb/azure/templates/microsoft.web/sites/config?pivots=deployment-language-bicep#siteconfig<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      javaVersion: '[if(or(contains(parameters(\'kind\'), \'linux\'), empty(parameters(\'javaVersion\'))), null(), parameters(\'javaVersion\'))]'
      netFrameworkVersion: '[if(or(contains(parameters(\'kind\'), \'linux\'), empty(parameters(\'netFrameworkVersion\'))), null(), parameters(\'netFrameworkVersion\'))]'
      nodeVersion: '[if(or(contains(parameters(\'kind\'), \'linux\'), empty(parameters(\'nodeVersion\'))), null(), parameters(\'nodeVersion\'))]'
      phpVersion: '[if(or(contains(parameters(\'kind\'), \'linux\'), empty(parameters(\'phpVersion\'))), null(), parameters(\'phpVersion\'))]'
      pythonVersion: '[if(or(contains(parameters(\'kind\'), \'linux\'), empty(parameters(\'pythonVersion\'))), null(), parameters(\'pythonVersion\'))]'
      use32BitWorkerProcess: false
  }
  ```

### Parameter: `webSiteConfigurationAdditional`

The additional web site settings configuration.<p><p>Use it when you want to keep defaults in webSiteConfiguration, but override or append them with additional configurations.<p>

- Required: No
- Type: object
- Default: `{}`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `customDomainVerificationId` | string | Unique identifier that verifies the custom domains assigned to the app. Customer will add this ID to a txt record for verification. |
| `defaultHostname` | string | Default hostname of the app. |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the site. |
| `privateEndpoints` | array | The private endpoints of the site. |
| `resourceGroupName` | string | The resource group the site was deployed into. |
| `resourceId` | string | The resource ID of the site. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Notes

### Parameter Usage: `appSettingsKeyValuePairs`

AzureWebJobsStorage, AzureWebJobsDashboard, APPINSIGHTS_INSTRUMENTATIONKEY and APPLICATIONINSIGHTS_CONNECTION_STRING are set separately (check parameters storageAccountId, setAzureWebJobsDashboard, appInsightId).
For all other app settings key-value pairs use this object.

<details>

<summary>Bicep format</summary>

```bicep
appSettingsKeyValuePairs: {
  AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
  EASYAUTH_SECRET: 'https://s2#_namePrefix_#kv.vault.azure.net/secrets/Modules-Test-SP-Password'
  FUNCTIONS_EXTENSION_VERSION: '~4'
  FUNCTIONS_WORKER_RUNTIME: 'dotnet'
}
```

</details>

<details>

<summary>Parameter JSON format</summary>

```json
"appSettingsKeyValuePairs": {
    "value": {
      "AzureFunctionsJobHost__logging__logLevel__default": "Trace",
      "EASYAUTH_SECRET": "https://s2#_namePrefix_#kv.vault.azure.net/secrets/Modules-Test-SP-Password",
      "FUNCTIONS_EXTENSION_VERSION": "~4",
      "FUNCTIONS_WORKER_RUNTIME": "dotnet"
    }
}
```

</details>
<p>

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
