# Azure Data Factory `[Microsoft.DataFactory/factories]`

This module deploys Azure Data Factory.

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

Version: 20240722

Compliant usage of Azure Data Factory requires:
- managedVirtualNetworkName: empty
- managedPrivateEndpoints : empty array
- publicNetworkAccess: 'Disabled'
- adoRepoConfiguration: only in Dev
- gitRepoType: 'FactoryVSTSConfiguration'
- gitAccountName : 'connectdrcpapg1'


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.DataFactory/factories` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories)</li></ul> |
| `Microsoft.DataFactory/factories/integrationRuntimes` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_integrationruntimes.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/integrationRuntimes)</li></ul> |
| `Microsoft.DataFactory/factories/linkedservices` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_linkedservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/linkedservices)</li></ul> |
| `Microsoft.DataFactory/factories/managedVirtualNetworks` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_managedvirtualnetworks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/managedVirtualNetworks)</li></ul> |
| `Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_managedvirtualnetworks_managedprivateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/managedVirtualNetworks/managedPrivateEndpoints)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/data-factory/factory:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module factoryMod 'br/<registry-alias>:res/data-factory/factory:<version>' = {
  name: 'factory-mod'
  params: {
    // Required parameters
    name: 'dffmin001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
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
using 'br/public:res/data-factory/factory:<version>'

// Required parameters
param name = 'dffmin001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param location = '<location>'
```

</details>
<p>

### Example 2: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module factoryMod 'br/<registry-alias>:res/data-factory/factory:<version>' = {
  name: 'factory-mod'
  params: {
    // Required parameters
    name: 'dffmax001'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
        tags: {
          application: 'AVM'
          'hidden-title': 'This is visible in the resource name'
        }
      }
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    customerManagedKey: {
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
      userAssignedIdentityResourceId: '<userAssignedIdentityResourceId>'
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
    gitConfigureLater: true
    globalParameters: {
      testParameter1: {
        type: 'String'
        value: 'testValue1'
      }
    }
    integrationRuntimes: [
      {
        name: 'TestRuntime'
        type: 'SelfHosted'
      }
      {
        managedVirtualNetworkName: 'default'
        name: 'IRvnetManaged'
        type: 'Managed'
        typeProperties: {
          computeProperties: {
            location: 'AutoResolve'
          }
        }
      }
    ]
    linkedServices: [
      {
        name: 'SQLdbLinkedservice'
        type: 'AzureSqlDatabase'
        typeProperties: {
          connectionString: '<connectionString>'
        }
      }
      {
        description: 'This is a description for the linked service using the IRvnetManaged integration runtime.'
        integrationRuntimeName: 'IRvnetManaged'
        name: 'LakeStoreLinkedservice'
        parameters: {
          storageAccountName: {
            defaultValue: 'madeupstorageaccname'
            type: 'String'
          }
        }
        type: 'AzureBlobFS'
        typeProperties: {
          url: '<url>'
        }
      }
    ]
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
    managedPrivateEndpoints: [
      {
        fqdns: [
          '<storageAccountBlobEndpoint>'
        ]
        groupId: 'blob'
        name: '<name>'
        privateLinkResourceId: '<privateLinkResourceId>'
      }
    ]
    managedVirtualNetworkName: 'default'
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
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/data-factory/factory:<version>'

// Required parameters
param name = 'dffmax001'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
    tags: {
      application: 'AVM'
      'hidden-title': 'This is visible in the resource name'
    }
  }
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param customerManagedKey = {
  keyName: '<keyName>'
  keyVaultResourceId: '<keyVaultResourceId>'
  userAssignedIdentityResourceId: '<userAssignedIdentityResourceId>'
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
param gitConfigureLater = true
param globalParameters = {
  testParameter1: {
    type: 'String'
    value: 'testValue1'
  }
}
param integrationRuntimes = [
  {
    name: 'TestRuntime'
    type: 'SelfHosted'
  }
  {
    managedVirtualNetworkName: 'default'
    name: 'IRvnetManaged'
    type: 'Managed'
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
      }
    }
  }
]
param linkedServices = [
  {
    name: 'SQLdbLinkedservice'
    type: 'AzureSqlDatabase'
    typeProperties: {
      connectionString: '<connectionString>'
    }
  }
  {
    description: 'This is a description for the linked service using the IRvnetManaged integration runtime.'
    integrationRuntimeName: 'IRvnetManaged'
    name: 'LakeStoreLinkedservice'
    parameters: {
      storageAccountName: {
        defaultValue: 'madeupstorageaccname'
        type: 'String'
      }
    }
    type: 'AzureBlobFS'
    typeProperties: {
      url: '<url>'
    }
  }
]
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
param managedPrivateEndpoints = [
  {
    fqdns: [
      '<storageAccountBlobEndpoint>'
    ]
    groupId: 'blob'
    name: '<name>'
    privateLinkResourceId: '<privateLinkResourceId>'
  }
]
param managedVirtualNetworkName = 'default'
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
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 3: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module factoryMod 'br/<registry-alias>:res/data-factory/factory:<version>' = {
  name: 'factory-mod'
  params: {
    // Required parameters
    name: 'dffwaf001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    gitConfigureLater: true
    integrationRuntimes: [
      {
        name: 'TestRuntime'
        type: 'SelfHosted'
      }
    ]
    location: '<location>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/data-factory/factory:<version>'

// Required parameters
param name = 'dffwaf001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param gitConfigureLater = true
param integrationRuntimes = [
  {
    name: 'TestRuntime'
    type: 'SelfHosted'
  }
]
param location = '<location>'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the Azure Factory to create. Must be globally unique. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`customerManagedKey`](#parameter-customermanagedkey) | object | The customer managed key definition. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service.<p>Currently known available log categories are:<p><p>'ActivityRuns'<p>'PipelineRuns'<p>'TriggerRuns'<p>'SandboxActivityRuns'<p>'SandboxPipelineRuns'<p>'SSISPackageEventMessages'<p>'SSISPackageExecutableStatistics'<p>'SSISPackageEventMessageContext'<p>'SSISPackageExecutionComponentPhases'<p>'SSISPackageExecutionDataStatistics'<p>'SSISIntegrationRuntimeLogs'<p>'AirflowTaskLogs'<p>'AirflowWorkerLogs'<p>'AirflowDagProcessingLogs'<p>'AirflowSchedulerLogs'<p>'AirflowWebLogs'<p> |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`gitconfiguration`](#parameter-gitconfiguration) | object | Object to define git configuration for Data Factory.<p><p>Setting this object in non-Dev enviroment will make the Data Factory resource non-compliant.<p> |
| [`gitConfigureLater`](#parameter-gitconfigurelater) | bool | Boolean to define whether or not to configure git during template deployment.<p><p>Setting this parameter to 'false' in non-development usages will make the Data Factory resource non-compliant.<p> |
| [`globalParameters`](#parameter-globalparameters) | object | List of Global Parameters for the factory. |
| [`integrationRuntimes`](#parameter-integrationruntimes) | array | An array of objects for the configuration of an Integration Runtime.<p><p>Managed Virtual Network, Azure-SSIS and Airflow type Integration runtime will make the Data Factory resource non-compliant.<p> |
| [`linkedServices`](#parameter-linkedservices) | array | An array of objects for the configuration of Linked Services. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. |
| [`managedPrivateEndpoints`](#parameter-managedprivateendpoints) | array | An array of managed private endpoints objects created in the Data Factory managed virtual network.<p><p>Adding managed private endpoints will make the Data Factory resource non-compliant.<p> |
| [`managedVirtualNetworkName`](#parameter-managedvirtualnetworkname) | string | The name of the Managed Virtual Network.<p><p>Configuring Data Factory with Managed Virtual Network will make the resource non-compliant.<p> |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration Details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.<p><p>Setting this parameter to any other than 'Disabled' will make the Data Factory resource non-compliant.<p> |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`tags`](#parameter-tags) | object | Resource tags. |

### Parameter: `name`

The name of the Azure Factory to create. Must be globally unique.

- Required: Yes
- Type: string

### Parameter: `customerManagedKey`

The customer managed key definition.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`keyName`](#parameter-customermanagedkeykeyname) | string | The name of the customer managed key to use for encryption. |
| [`keyVaultResourceId`](#parameter-customermanagedkeykeyvaultresourceid) | string | The resource ID of a key vault to reference a customer managed key for encryption from. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoRotationEnabled`](#parameter-customermanagedkeyautorotationenabled) | bool | Enable or disable auto-rotating to the latest key version. Default is true. If set to false, the latest key version at the time of the deployment is used. |
| [`keyVersion`](#parameter-customermanagedkeykeyversion) | string | The version of the customer managed key to reference for encryption. If not provided, using 'latest'. |
| [`userAssignedIdentityResourceId`](#parameter-customermanagedkeyuserassignedidentityresourceid) | string | User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use. |

### Parameter: `customerManagedKey.keyName`

The name of the customer managed key to use for encryption.

- Required: Yes
- Type: string

### Parameter: `customerManagedKey.keyVaultResourceId`

The resource ID of a key vault to reference a customer managed key for encryption from.

- Required: Yes
- Type: string

### Parameter: `customerManagedKey.autoRotationEnabled`

Enable or disable auto-rotating to the latest key version. Default is true. If set to false, the latest key version at the time of the deployment is used.

- Required: No
- Type: bool

### Parameter: `customerManagedKey.keyVersion`

The version of the customer managed key to reference for encryption. If not provided, using 'latest'.

- Required: No
- Type: string

### Parameter: `customerManagedKey.userAssignedIdentityResourceId`

User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use.

- Required: No
- Type: string

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.<p>Currently known available log categories are:<p><p>'ActivityRuns'<p>'PipelineRuns'<p>'TriggerRuns'<p>'SandboxActivityRuns'<p>'SandboxPipelineRuns'<p>'SSISPackageEventMessages'<p>'SSISPackageExecutableStatistics'<p>'SSISPackageEventMessageContext'<p>'SSISPackageExecutionComponentPhases'<p>'SSISPackageExecutionDataStatistics'<p>'SSISIntegrationRuntimeLogs'<p>'AirflowTaskLogs'<p>'AirflowWorkerLogs'<p>'AirflowDagProcessingLogs'<p>'AirflowSchedulerLogs'<p>'AirflowWebLogs'<p>

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

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `gitconfiguration`

Object to define git configuration for Data Factory.<p><p>Setting this object in non-Dev enviroment will make the Data Factory resource non-compliant.<p>

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`gitAccountName`](#parameter-gitconfigurationgitaccountname) | string | The account name. This name is the ADO organization name.<p>Setting this parameter to any other than 'connectdrcpapg1' will make the Data Factory resource non-compliant.<p> |
| [`gitCollaborationBranch`](#parameter-gitconfigurationgitcollaborationbranch) | string | The collaboration branch name. Default is 'main'. |
| [`gitDisablePublish`](#parameter-gitconfigurationgitdisablepublish) | bool | Disable manual publish operation in ADF studio to favor automated publish. |
| [`gitHostName`](#parameter-gitconfigurationgithostname) | string | The GitHub Enterprise Server host (prefixed with 'https://'). Only relevant for 'FactoryGitHubConfiguration'. |
| [`gitLastCommitId`](#parameter-gitconfigurationgitlastcommitid) | string | Add the last commit id from your git repo. |
| [`gitProjectName`](#parameter-gitconfigurationgitprojectname) | string | The project name. Only relevant for 'FactoryVSTSConfiguration'. |
| [`gitRepositoryName`](#parameter-gitconfigurationgitrepositoryname) | string | The repository name. |
| [`gitRepoType`](#parameter-gitconfigurationgitrepotype) | string | Repository type - can be \'FactoryVSTSConfiguration\' or \'FactoryGitHubConfiguration\'. Default is \'FactoryVSTSConfiguration\'.<p><p>Setting this parameter to any other than 'FactoryVSTSConfiguration' will make the Data Factory resource non-compliant.<p> |
| [`gitRootFolder`](#parameter-gitconfigurationgitrootfolder) | string | The root folder path name. Default is '/'. |
| [`gitTenantId`](#parameter-gitconfigurationgittenantid) | string | Add the tenantId of your Azure subscription. |

### Parameter: `gitconfiguration.gitAccountName`

The account name. This name is the ADO organization name.<p>Setting this parameter to any other than 'connectdrcpapg1' will make the Data Factory resource non-compliant.<p>

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'connectdrcpapg1'
  ]
  ```

### Parameter: `gitconfiguration.gitCollaborationBranch`

The collaboration branch name. Default is 'main'.

- Required: No
- Type: string

### Parameter: `gitconfiguration.gitDisablePublish`

Disable manual publish operation in ADF studio to favor automated publish.

- Required: Yes
- Type: bool

### Parameter: `gitconfiguration.gitHostName`

The GitHub Enterprise Server host (prefixed with 'https://'). Only relevant for 'FactoryGitHubConfiguration'.

- Required: No
- Type: string

### Parameter: `gitconfiguration.gitLastCommitId`

Add the last commit id from your git repo.

- Required: No
- Type: string

### Parameter: `gitconfiguration.gitProjectName`

The project name. Only relevant for 'FactoryVSTSConfiguration'.

- Required: No
- Type: string

### Parameter: `gitconfiguration.gitRepositoryName`

The repository name.

- Required: No
- Type: string

### Parameter: `gitconfiguration.gitRepoType`

Repository type - can be \'FactoryVSTSConfiguration\' or \'FactoryGitHubConfiguration\'. Default is \'FactoryVSTSConfiguration\'.<p><p>Setting this parameter to any other than 'FactoryVSTSConfiguration' will make the Data Factory resource non-compliant.<p>

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'FactoryVSTSConfiguration'
  ]
  ```

### Parameter: `gitconfiguration.gitRootFolder`

The root folder path name. Default is '/'.

- Required: No
- Type: string

### Parameter: `gitconfiguration.gitTenantId`

Add the tenantId of your Azure subscription.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'c1f94f0d-9a3d-4854-9288-bb90dcf2a90d'
  ]
  ```

### Parameter: `gitConfigureLater`

Boolean to define whether or not to configure git during template deployment.<p><p>Setting this parameter to 'false' in non-development usages will make the Data Factory resource non-compliant.<p>

- Required: No
- Type: bool
- Default: `True`

### Parameter: `globalParameters`

List of Global Parameters for the factory.

- Required: No
- Type: object
- Default: `{}`

### Parameter: `integrationRuntimes`

An array of objects for the configuration of an Integration Runtime.<p><p>Managed Virtual Network, Azure-SSIS and Airflow type Integration runtime will make the Data Factory resource non-compliant.<p>

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-integrationruntimesname) | string | The name of the integration runtime. |
| [`type`](#parameter-integrationruntimestype) | string | The name of the integration runtime. Choose from SelfHosted or Managed |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`integrationRuntimeCustomDescription`](#parameter-integrationruntimesintegrationruntimecustomdescription) | string | The description of the integration runtime. |
| [`managedVirtualNetworkName`](#parameter-integrationruntimesmanagedvirtualnetworkname) | string | The name of the managed virtual network. |
| [`typeProperties`](#parameter-integrationruntimestypeproperties) | object | The typed properties. |

### Parameter: `integrationRuntimes.name`

The name of the integration runtime.

- Required: Yes
- Type: string

### Parameter: `integrationRuntimes.type`

The name of the integration runtime. Choose from SelfHosted or Managed

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Managed'
    'SelfHosted'
  ]
  ```

### Parameter: `integrationRuntimes.integrationRuntimeCustomDescription`

The description of the integration runtime.

- Required: No
- Type: string

### Parameter: `integrationRuntimes.managedVirtualNetworkName`

The name of the managed virtual network.

- Required: No
- Type: string

### Parameter: `integrationRuntimes.typeProperties`

The typed properties.

- Required: No
- Type: object

### Parameter: `linkedServices`

An array of objects for the configuration of Linked Services.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-linkedservicesname) | string | The name of the Linked Service. |
| [`type`](#parameter-linkedservicestype) | string | The type of Linked Service. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-linkedservicesdescription) | string | The description of the Linked Service. |
| [`integrationRuntimeName`](#parameter-linkedservicesintegrationruntimename) | string | The name of the Integration Runtime to use. |
| [`parameters`](#parameter-linkedservicesparameters) | object | Use this to add parameters for a linked service connection string. |
| [`typeProperties`](#parameter-linkedservicestypeproperties) | object | Used to add connection properties for your linked services. |

### Parameter: `linkedServices.name`

The name of the Linked Service.

- Required: Yes
- Type: string

### Parameter: `linkedServices.type`

The type of Linked Service.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureBlobFS'
    'AzureBlobStorage'
    'AzureDatabricks'
    'AzureFunction'
    'AzureKeyVault'
    'AzureSqlDatabase'
    'FileServer'
    'Jira'
    'SqlServer'
  ]
  ```

### Parameter: `linkedServices.description`

The description of the Linked Service.

- Required: No
- Type: string

### Parameter: `linkedServices.integrationRuntimeName`

The name of the Integration Runtime to use.

- Required: No
- Type: string

### Parameter: `linkedServices.parameters`

Use this to add parameters for a linked service connection string.

- Required: No
- Type: object

### Parameter: `linkedServices.typeProperties`

Used to add connection properties for your linked services.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`azureBlobFSLinkedServiceConfig`](#parameter-linkedservicestypepropertiesazureblobfslinkedserviceconfig) | object | Details to configure Azure storage linked services. |
| [`azureBlobStorageLinkedServiceConfig`](#parameter-linkedservicestypepropertiesazureblobstoragelinkedserviceconfig) | object | Details to configure Azure storage linked services. |
| [`azureDatabricksLinkedServiceConfig`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfig) | object | Details to configure Azure Databricks linked service. |
| [`azureFunctionAppLinkedServiceConfig`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfig) | object | Details to configure Azure Function App linked service. |
| [`azureKeyVaultLinkedServiceConfig`](#parameter-linkedservicestypepropertiesazurekeyvaultlinkedserviceconfig) | object | Details to configure Azure Key-Vault linked service. |
| [`azureSqlDatabaseLinkedServiceConfig`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfig) | object | Details to configure Azure SQL Database linked service. |
| [`fileServerLinkedServiceConfig`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfig) | object | Details to configure File Server linked service. |
| [`jiraLinkedServiceConfig`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfig) | object | Details to configure JIRA linked service. |
| [`sqlServerLinkedServiceConfig`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfig) | object | Details to configure (on-premises) SQL Server linked service. |

### Parameter: `linkedServices.typeProperties.azureBlobFSLinkedServiceConfig`

Details to configure Azure storage linked services.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`url`](#parameter-linkedservicestypepropertiesazureblobfslinkedserviceconfigurl) | string | Endpoint for the Azure Data Lake Storage Gen2 service.<p>Format - https://accountname.dfs.core.windows.net/  |

### Parameter: `linkedServices.typeProperties.azureBlobFSLinkedServiceConfig.url`

Endpoint for the Azure Data Lake Storage Gen2 service.<p>Format - https://accountname.dfs.core.windows.net/ 

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureBlobStorageLinkedServiceConfig`

Details to configure Azure storage linked services.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serviceEndpoint`](#parameter-linkedservicestypepropertiesazureblobstoragelinkedserviceconfigserviceendpoint) | string | Blob service endpoint of the Azure Blob Storage resource.<p>It is mutually exclusive with connectionString, sasUri property.<p>Format - https://accountname.blob.core.windows.net/ |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`accountKind`](#parameter-linkedservicestypepropertiesazureblobstoragelinkedserviceconfigaccountkind) | string | AzureBlobStorage linked service only. The kind of your storage account. |

### Parameter: `linkedServices.typeProperties.azureBlobStorageLinkedServiceConfig.serviceEndpoint`

Blob service endpoint of the Azure Blob Storage resource.<p>It is mutually exclusive with connectionString, sasUri property.<p>Format - https://accountname.blob.core.windows.net/

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureBlobStorageLinkedServiceConfig.accountKind`

AzureBlobStorage linked service only. The kind of your storage account.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'BlobStorage'
    'BlockBlobStorage'
    'Storage'
    'StorageV2'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig`

Details to configure Azure Databricks linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`domain`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfigdomain) | string | The Databricks Workspace URL, it can be found in Azure portal under workspace overview. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authentication`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfigauthentication) | string | The Databricks authentication mechanism. |
| [`clusterOption`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfigclusteroption) | string | This is required when creating a new job cluster. The exptected value is worker options either fixed or autoscaling. |
| [`dataSecurityMode`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfigdatasecuritymode) | string | Optional setting for creating a new job cluster. The exptected value is Unity Catalog Access Mode. |
| [`existingClusterId`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfigexistingclusterid) | string | This is required when using existinng cluster. Exptected value is the existing interactive cluster ID. |
| [`instancePoolId`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfiginstancepoolid) | string | This is required when using existing instance pool. The expected value is the id of existing cluster pool. |
| [`newClusterNodeType`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfignewclusternodetype) | string | This is required when creating a new job cluster or using existing instance pool. This field encodes, through a single value, the resources available to each of the Spark nodes in this cluster. |
| [`newClusterNumOfWorker`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfignewclusternumofworker) | string | This is required when creating a new job cluster. The exptected value is number of worker nodes that this cluster should have. When cluster option is Autoscaling then<p>provide the number of min and max workers e.g. such as 1:3 |
| [`newClusterVersion`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfignewclusterversion) | string | This is required when creating a new job cluster. Exptected value is the Spark version of the cluster. |
| [`workspaceResourceId`](#parameter-linkedservicestypepropertiesazuredatabrickslinkedserviceconfigworkspaceresourceid) | string | The resource ID of the Databricks workspace. This can be found in the properties of the Databricks workspace, and it should be of the format:<p>/subscriptions/{subscriptionID}/resourceGroups/{resourceGroup}/providers/Microsoft.Databricks/workspaces/{workspaceName}  |

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.domain`

The Databricks Workspace URL, it can be found in Azure portal under workspace overview.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.authentication`

The Databricks authentication mechanism.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'MSI'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.clusterOption`

This is required when creating a new job cluster. The exptected value is worker options either fixed or autoscaling.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Autoscaling'
    'Fixed'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.dataSecurityMode`

Optional setting for creating a new job cluster. The exptected value is Unity Catalog Access Mode.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'NONE'
    'SINGLE_USER'
    'USER_ISOLATION'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.existingClusterId`

This is required when using existinng cluster. Exptected value is the existing interactive cluster ID.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.instancePoolId`

This is required when using existing instance pool. The expected value is the id of existing cluster pool.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.newClusterNodeType`

This is required when creating a new job cluster or using existing instance pool. This field encodes, through a single value, the resources available to each of the Spark nodes in this cluster.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.newClusterNumOfWorker`

This is required when creating a new job cluster. The exptected value is number of worker nodes that this cluster should have. When cluster option is Autoscaling then<p>provide the number of min and max workers e.g. such as 1:3

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.newClusterVersion`

This is required when creating a new job cluster. Exptected value is the Spark version of the cluster.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureDatabricksLinkedServiceConfig.workspaceResourceId`

The resource ID of the Databricks workspace. This can be found in the properties of the Databricks workspace, and it should be of the format:<p>/subscriptions/{subscriptionID}/resourceGroups/{resourceGroup}/providers/Microsoft.Databricks/workspaces/{workspaceName} 

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig`

Details to configure Azure Function App linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authentication`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigauthentication) | string | The type used for authentication. |
| [`functionAppUrl`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionappurl) | string | Function App endpoint.<p>Format - https://functionappname.azurewebsites.net |
| [`functionKey`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkey) | object | Specify the key for the function (userName). |

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.authentication`

The type used for authentication.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Anonymous'
    'MSI'
    'Service principal'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionAppUrl`

Function App endpoint.<p>Format - https://functionappname.azurewebsites.net

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey`

Specify the key for the function (userName).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkeysecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkeystore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkeytype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkeysecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkeystorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-linkedservicestypepropertiesazurefunctionapplinkedserviceconfigfunctionkeystoretype) | string | LinkedServiceReference the type. |

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureKeyVaultLinkedServiceConfig`

Details to configure Azure Key-Vault linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`baseUrl`](#parameter-linkedservicestypepropertiesazurekeyvaultlinkedserviceconfigbaseurl) | string | The Azure Key-vault URL. Format - https://keyvaultname.vault.azure.net/ |

### Parameter: `linkedServices.typeProperties.azureKeyVaultLinkedServiceConfig.baseUrl`

The Azure Key-vault URL. Format - https://keyvaultname.vault.azure.net/

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig`

Details to configure Azure SQL Database linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authenticationType`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigauthenticationtype) | string | The type used for authentication. |
| [`database`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigdatabase) | string | The name of the database. |
| [`server`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserver) | string | The FQDN or network address of the SQL server instance you want to connect to. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`azureCloudType`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigazurecloudtype) | string | For service principal authentication, specify the type of Azure cloud environment to which your Microsoft Entra application is registered.<p>Allowed value is AzurePublic. |
| [`encrypt`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigencrypt) | bool | Indicate whether TLS encryption is required for all data sent between the client and server. |
| [`servicePrincipalCredential`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredential) | object | The service principal credential, reference a secret stored in Azure Key Vault. |
| [`servicePrincipalId`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalid) | string | Specify the application client ID. |
| [`tenant`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigtenant) | string | Specify the tenant information, like the domain name or tenant ID, under which your application resides. |
| [`trustServerCertificate`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigtrustservercertificate) | bool | Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust. |

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.authenticationType`

The type used for authentication.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'ServicePrincipal'
    'SystemAssignedManagedIdentity'
    'UserAssignedManagedIdentity'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.database`

The name of the database.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.server`

The FQDN or network address of the SQL server instance you want to connect to.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.azureCloudType`

For service principal authentication, specify the type of Azure cloud environment to which your Microsoft Entra application is registered.<p>Allowed value is AzurePublic.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.encrypt`

Indicate whether TLS encryption is required for all data sent between the client and server.

- Required: No
- Type: bool

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential`

The service principal credential, reference a secret stored in Azure Key Vault.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-linkedservicestypepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialstoretype) | string | LinkedServiceReference the type. |

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalId`

Specify the application client ID.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.tenant`

Specify the tenant information, like the domain name or tenant ID, under which your application resides.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.azureSqlDatabaseLinkedServiceConfig.trustServerCertificate`

Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust.

- Required: No
- Type: bool

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig`

Details to configure File Server linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`host`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfighost) | string | Specifies the root path of the folder that you want to copy. |
| [`password`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpassword) | object | Specify the password for the user (userId). |
| [`userId`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfiguserid) | string | Specify the ID of the user who has access to the server. |

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.host`

Specifies the root path of the folder that you want to copy.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password`

Specify the password for the user (userId).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpasswordsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpasswordstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpasswordtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpasswordsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpasswordstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-linkedservicestypepropertiesfileserverlinkedserviceconfigpasswordstoretype) | string | LinkedServiceReference the type. |

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.password.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.fileServerLinkedServiceConfig.userId`

Specify the ID of the user who has access to the server.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig`

Details to configure JIRA linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`host`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfighost) | string | The hostname or IP address of the JIRA server. |
| [`password`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpassword) | object | Specify the password for the user. |
| [`username`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigusername) | string | The username used to authenticate with the JIRA server. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`port`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigport) | string | The port number used to connect to the JIRA server. |
| [`useEncryptedEndpoints`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfiguseencryptedendpoints) | bool | Indicates whether encrypted endpoints should be used. |
| [`useHostVerification`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigusehostverification) | bool | Indicates whether to verify the host during SSL handshake. |
| [`usePeerVerification`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigusepeerverification) | bool | Indicates whether to verify the peer certificate during SSL handshake. |

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.host`

The hostname or IP address of the JIRA server.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password`

Specify the password for the user.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpasswordsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpasswordstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpasswordtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpasswordsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpasswordstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-linkedservicestypepropertiesjiralinkedserviceconfigpasswordstoretype) | string | LinkedServiceReference the type. |

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.password.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.username`

The username used to authenticate with the JIRA server.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.port`

The port number used to connect to the JIRA server.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.useEncryptedEndpoints`

Indicates whether encrypted endpoints should be used.

- Required: No
- Type: bool

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.useHostVerification`

Indicates whether to verify the host during SSL handshake.

- Required: No
- Type: bool

### Parameter: `linkedServices.typeProperties.jiraLinkedServiceConfig.usePeerVerification`

Indicates whether to verify the peer certificate during SSL handshake.

- Required: No
- Type: bool

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig`

Details to configure (on-premises) SQL Server linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authenticationType`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigauthenticationtype) | string | The type used for authentication. |
| [`database`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigdatabase) | string | The name of the database. |
| [`password`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpassword) | object | Specify the password for the user (userName). |
| [`server`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigserver) | string | The name or network address of the SQL server instance you want to connect to. |
| [`userName`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigusername) | string | Specify the ID of the user who has access to the SQL server database. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`alwaysEncryptedSettings`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigalwaysencryptedsettings) | object | Specify always encryptedsettings information that's needed to enable Always Encrypted to protect sensitive data stored in SQL server<p>by using either managed identity or service principal. Find example here -<p>https://learn.microsoft.com/en-us/azure/data-factory/connector-sql-server?tabs=data-factory#using-always-encrypted |
| [`encrypt`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigencrypt) | bool | Indicate whether TLS encryption is required for all data sent between the client and server. |
| [`trustServerCertificate`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigtrustservercertificate) | bool | Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust. |

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.authenticationType`

The type used for authentication.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'SQL'
    'Windows'
  ]
  ```

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.database`

The name of the database.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password`

Specify the password for the user (userName).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpasswordsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpasswordstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpasswordtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpasswordsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpasswordstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-linkedservicestypepropertiessqlserverlinkedserviceconfigpasswordstoretype) | string | LinkedServiceReference the type. |

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.password.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.server`

The name or network address of the SQL server instance you want to connect to.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.userName`

Specify the ID of the user who has access to the SQL server database.

- Required: Yes
- Type: string

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.alwaysEncryptedSettings`

Specify always encryptedsettings information that's needed to enable Always Encrypted to protect sensitive data stored in SQL server<p>by using either managed identity or service principal. Find example here -<p>https://learn.microsoft.com/en-us/azure/data-factory/connector-sql-server?tabs=data-factory#using-always-encrypted

- Required: No
- Type: object

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.encrypt`

Indicate whether TLS encryption is required for all data sent between the client and server.

- Required: No
- Type: bool

### Parameter: `linkedServices.typeProperties.sqlServerLinkedServiceConfig.trustServerCertificate`

Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust.

- Required: No
- Type: bool

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

### Parameter: `managedIdentities`

The managed identity definition for this resource.

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

### Parameter: `managedPrivateEndpoints`

An array of managed private endpoints objects created in the Data Factory managed virtual network.<p><p>Adding managed private endpoints will make the Data Factory resource non-compliant.<p>

- Required: No
- Type: array
- Default: `[]`

### Parameter: `managedVirtualNetworkName`

The name of the Managed Virtual Network.<p><p>Configuring Data Factory with Managed Virtual Network will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `''`

### Parameter: `privateEndpoints`

Configuration Details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.

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

Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.<p><p>Setting this parameter to any other than 'Disabled' will make the Data Factory resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    ''
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Data Factory Contributor'`

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

### Parameter: `tags`

Resource tags.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The Name of the Azure Data Factory instance. |
| `resourceGroupName` | string | The name of the Resource Group with the Data factory. |
| `resourceId` | string | The Resource ID of the Data factory. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Notes

### Parameter Usage: `managedPrivateEndpoints`

To use Managed Private Endpoints the following dependencies must be deployed:

- The `managedVirtualNetworkName` property must be set to allow provisioning of a managed virtual network in Azure Data Factory.
- Destination private link resource must be created before and permissions allow requesting a private link connection to that resource.

<details>

<summary>Parameter JSON format</summary>

```json
"managedPrivateEndpoints": {
    "value": [
        {
            "name": "mystorageaccount-managed-privateEndpoint", // Required: The managed private endpoint resource name
            "groupId": "blob", // Required: The groupId to which the managed private endpoint is created
            "fqdns": [
                "mystorageaccount.blob.core.windows.net" // Required: Fully qualified domain names
            ],
            "privateLinkResourceId": "/subscriptions/[[subscriptionId]]/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/mystorageaccount"
            // Required: The ARM resource ID of the resource to which the managed private endpoint is created.
        }
    ]
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
managedPrivateEndpoints:  [
    // Example showing all available fields
    {
        name: 'mystorageaccount-managed-privateEndpoint' // Required: The managed private endpoint resource name
        groupId: 'blob' // Required: The groupId to which the managed private endpoint is created
        fqdns: [
          'mystorageaccount.blob.core.windows.net' // Required: Fully qualified domain names
        ]
        privateLinkResourceId: '/subscriptions/[[subscriptionId]]/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/mystorageaccount'
    } // Required: The ARM resource ID of the resource to which the managed private endpoint is created.
]
```

</details>
<p>

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
