# Azure Databricks Workspace `[Microsoft.Databricks/workspaces]`

This module deploys an Azure Databricks Workspace.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Data Collection](#data-collection)

## Compliance

Version: 20240702

Compliant usage of Databricks requires:

- skuName: 'premium'
- disablePublicIp: true
- publicNetworkAccess: 'Disabled'
- requireInfrastructureEncryption: true
- complianceSecurityProfile: 'Enabled'
- automaticClusterUpdate: 'Enabled'
- enhancedSecurityMonitoring: 'Enabled'
- managedResourceGroupResourceId: if provided, must end with '-adbmanaged-rg'

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Databricks/workspaces` | 2024-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.databricks_workspaces.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Databricks/2024-05-01/workspaces)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/databricks/workspace:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module workspaceMod 'br/<registry-alias>:res/databricks/workspace:<version>' = {
  name: 'workspace-mod'
  params: {
    // Required parameters
    customPrivateSubnetName: 'tbd'
    customPublicSubnetName: 'tbd'
    customVirtualNetworkResourceId: 'tbd'
    name: 'min001dbw'
    privateEndpoints: [
      {
        subnetResourceId: 'tbd'
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
using 'br/public:res/databricks/workspace:<version>'

// Required parameters
param customPrivateSubnetName = 'tbd'
param customPublicSubnetName = 'tbd'
param customVirtualNetworkResourceId = 'tbd'
param name = 'min001dbw'
param privateEndpoints = [
  {
    subnetResourceId: 'tbd'
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
module workspaceMod 'br/<registry-alias>:res/databricks/workspace:<version>' = {
  name: 'workspace-mod'
  params: {
    // Required parameters
    customPrivateSubnetName: '<customPrivateSubnetName>'
    customPublicSubnetName: '<customPublicSubnetName>'
    customVirtualNetworkResourceId: '<customVirtualNetworkResourceId>'
    name: 'max001dbw'
    privateEndpoints: [
      {
        service: 'databricks_ui_api'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
      {
        service: 'browser_authentication'
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    amlWorkspaceResourceId: '<amlWorkspaceResourceId>'
    automaticClusterUpdate: 'Enabled'
    complianceSecurityProfile: 'Enabled'
    customerManagedKey: {
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
    }
    customerManagedKeyManagedDisk: {
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
      rotationToLatestKeyVersionEnabled: true
    }
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        logCategoriesAndGroups: [
          {
            category: 'jobs'
          }
          {
            category: 'notebook'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    disablePublicIp: true
    enableTelemetry: true
    enhancedSecurityMonitoring: 'Enabled'
    loadBalancerBackendPoolName: '<loadBalancerBackendPoolName>'
    loadBalancerResourceId: '<loadBalancerResourceId>'
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedResourceGroupResourceId: '<managedResourceGroupResourceId>'
    managedVnetAddressPrefix: '10.100'
    natGatewayName: 'nat-gateway'
    prepareEncryption: true
    publicIpName: 'nat-gw-public-ip'
    publicNetworkAccess: 'Disabled'
    requiredNsgRules: 'NoAzureDatabricksRules'
    requireInfrastructureEncryption: true
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
    skuName: 'premium'
    storageAccountName: 'max001sta'
    storageAccountSkuName: 'Standard_ZRS'
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
using 'br/public:res/databricks/workspace:<version>'

// Required parameters
param customPrivateSubnetName = '<customPrivateSubnetName>'
param customPublicSubnetName = '<customPublicSubnetName>'
param customVirtualNetworkResourceId = '<customVirtualNetworkResourceId>'
param name = 'max001dbw'
param privateEndpoints = [
  {
    service: 'databricks_ui_api'
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
  {
    service: 'browser_authentication'
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param amlWorkspaceResourceId = '<amlWorkspaceResourceId>'
param automaticClusterUpdate = 'Enabled'
param complianceSecurityProfile = 'Enabled'
param customerManagedKey = {
  keyName: '<keyName>'
  keyVaultResourceId: '<keyVaultResourceId>'
}
param customerManagedKeyManagedDisk = {
  keyName: '<keyName>'
  keyVaultResourceId: '<keyVaultResourceId>'
  rotationToLatestKeyVersionEnabled: true
}
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    logCategoriesAndGroups: [
      {
        category: 'jobs'
      }
      {
        category: 'notebook'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param disablePublicIp = true
param enableTelemetry = true
param enhancedSecurityMonitoring = 'Enabled'
param loadBalancerBackendPoolName = '<loadBalancerBackendPoolName>'
param loadBalancerResourceId = '<loadBalancerResourceId>'
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedResourceGroupResourceId = '<managedResourceGroupResourceId>'
param managedVnetAddressPrefix = '10.100'
param natGatewayName = 'nat-gateway'
param prepareEncryption = true
param publicIpName = 'nat-gw-public-ip'
param publicNetworkAccess = 'Disabled'
param requiredNsgRules = 'NoAzureDatabricksRules'
param requireInfrastructureEncryption = true
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
param skuName = 'premium'
param storageAccountName = 'max001sta'
param storageAccountSkuName = 'Standard_ZRS'
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
module workspaceMod 'br/<registry-alias>:res/databricks/workspace:<version>' = {
  name: 'workspace-mod'
  params: {
    // Required parameters
    customPrivateSubnetName: '<customPrivateSubnetName>'
    customPublicSubnetName: '<customPublicSubnetName>'
    customVirtualNetworkResourceId: '<customVirtualNetworkResourceId>'
    name: 'waf001dbw'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        service: 'databricks_ui_api'
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
    // Non-required parameters
    amlWorkspaceResourceId: '<amlWorkspaceResourceId>'
    customerManagedKey: {
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
    }
    customerManagedKeyManagedDisk: {
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
      rotationToLatestKeyVersionEnabled: true
    }
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        logCategoriesAndGroups: [
          {
            category: 'jobs'
          }
          {
            category: 'notebook'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    disablePublicIp: true
    loadBalancerBackendPoolName: '<loadBalancerBackendPoolName>'
    loadBalancerResourceId: '<loadBalancerResourceId>'
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedResourceGroupResourceId: '<managedResourceGroupResourceId>'
    managedVnetAddressPrefix: '10.100'
    natGatewayName: 'nat-gateway'
    prepareEncryption: true
    publicIpName: 'nat-gw-public-ip'
    publicNetworkAccess: 'Disabled'
    requiredNsgRules: 'NoAzureDatabricksRules'
    requireInfrastructureEncryption: true
    skuName: 'premium'
    storageAccountName: 'waf001sta'
    storageAccountSkuName: 'Standard_ZRS'
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
using 'br/public:res/databricks/workspace:<version>'

// Required parameters
param customPrivateSubnetName = '<customPrivateSubnetName>'
param customPublicSubnetName = '<customPublicSubnetName>'
param customVirtualNetworkResourceId = '<customVirtualNetworkResourceId>'
param name = 'waf001dbw'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    service: 'databricks_ui_api'
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
]
// Non-required parameters
param amlWorkspaceResourceId = '<amlWorkspaceResourceId>'
param customerManagedKey = {
  keyName: '<keyName>'
  keyVaultResourceId: '<keyVaultResourceId>'
}
param customerManagedKeyManagedDisk = {
  keyName: '<keyName>'
  keyVaultResourceId: '<keyVaultResourceId>'
  rotationToLatestKeyVersionEnabled: true
}
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    logCategoriesAndGroups: [
      {
        category: 'jobs'
      }
      {
        category: 'notebook'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param disablePublicIp = true
param loadBalancerBackendPoolName = '<loadBalancerBackendPoolName>'
param loadBalancerResourceId = '<loadBalancerResourceId>'
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedResourceGroupResourceId = '<managedResourceGroupResourceId>'
param managedVnetAddressPrefix = '10.100'
param natGatewayName = 'nat-gateway'
param prepareEncryption = true
param publicIpName = 'nat-gw-public-ip'
param publicNetworkAccess = 'Disabled'
param requiredNsgRules = 'NoAzureDatabricksRules'
param requireInfrastructureEncryption = true
param skuName = 'premium'
param storageAccountName = 'waf001sta'
param storageAccountSkuName = 'Standard_ZRS'
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
| [`customPrivateSubnetName`](#parameter-customprivatesubnetname) | string | The name of the 1st Subnet for clusters within the Virtual Network. |
| [`customPublicSubnetName`](#parameter-custompublicsubnetname) | string | The name of a 2nd Subnet for clusters within the Virtual Network. |
| [`customVirtualNetworkResourceId`](#parameter-customvirtualnetworkresourceid) | string | The resource ID of a Virtual Network where Databricks clusters should be created. |
| [`name`](#parameter-name) | string | The name of the Azure Databricks workspace to create. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`accessConnectorResourceId`](#parameter-accessconnectorresourceid) | string | The resource ID of the associated access connector for private access to the managed storage account.<p><p>Required if defaultStorageFirewall parameter is 'Enabled' |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`amlWorkspaceResourceId`](#parameter-amlworkspaceresourceid) | string | The resource ID of a Azure Machine Learning workspace to link with Databricks workspace. |
| [`automaticClusterUpdate`](#parameter-automaticclusterupdate) | string | Set to \'Enabled\' for automatic updates of clusters. Default: Enabled.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p> |
| [`complianceSecurityProfile`](#parameter-compliancesecurityprofile) | string | Set to \'Enabled\' for compliance security profile features. Default: Enabled.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p> |
| [`customerManagedKey`](#parameter-customermanagedkey) | object | The customer managed key definition to use for the managed service. |
| [`customerManagedKeyManagedDisk`](#parameter-customermanagedkeymanageddisk) | object | The customer managed key definition to use for the managed disk. |
| [`defaultStorageFirewall`](#parameter-defaultstoragefirewall) | string | Enables the firewall on the default storage account. Default: Disabled.<p><p>For best security practices, set it to 'Enabled' and configure storageAccountPrivateEndpoints. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service.<p><p>Currently known available log categories are:<p>  'accounts'<p>  'BrickStoreHttpGateway'<p>  'capsule8Dataplane'<p>  'clamAVScan'<p>  'CloudStorageMetadata'<p>  'clusterLibraries'<p>  'clusters'<p>  'Dashboards'<p>  'databrickssql'<p>  'DataMonitoring'<p>  'dbfs'<p>  'deltaPipelines'<p>  'featureStore'<p>  'genie'<p>  'gitCredentials'<p>  'globalInitScripts'<p>  'iamRole'<p>  'Ingestion'<p>  'instancePools'<p>  'jobs'<p>  'LineageTracking'<p>  'MarketplaceConsumer'<p>  'mlflowAcledArtifact'<p>  'mlflowExperiment'<p>  'modelRegistry'<p>  'notebook'<p>  'partnerHub'<p>  'PredictiveOptimization'<p>  'RemoteHistoryService'<p>  'repos'<p>  'secrets'<p>  'serverlessRealTimeInference'<p>  'sqlAnalytics'<p>  'sqlPermissions'<p>  'ssh'<p>  'unityCatalog'<p>  'webTerminal'<p>  'workspace'<p> |
| [`disablePublicIp`](#parameter-disablepublicip) | bool | Disable Public IP. Default: true<p><p>Setting this parameter to false will make the resource non-compliant.<p> |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`enhancedSecurityMonitoring`](#parameter-enhancedsecuritymonitoring) | string | Set to \'Enabled\' for security monitoring features. Default: Enabled.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p> |
| [`loadBalancerBackendPoolName`](#parameter-loadbalancerbackendpoolname) | string | Name of the outbound Load Balancer Backend Pool for Secure Cluster Connectivity (No Public IP). |
| [`loadBalancerResourceId`](#parameter-loadbalancerresourceid) | string | Resource ID of Outbound Load balancer for Secure Cluster Connectivity (No Public IP) workspace. |
| [`location`](#parameter-location) | string | Location for all Resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedResourceGroupResourceId`](#parameter-managedresourcegroupresourceid) | string | The managed resource group ID. It is created by the module as per the to-be resource ID you provide.<p>Default: the module calculates this ID using the name of the resource.<p><p>To be compliant, the resource group name needs to end with an authorized suffix, e.g. '-adbmanaged-rg'.<p> |
| [`managedVnetAddressPrefix`](#parameter-managedvnetaddressprefix) | string | Address prefix for Managed virtual network. |
| [`natGatewayName`](#parameter-natgatewayname) | string | Name of the NAT gateway for Secure Cluster Connectivity (No Public IP) workspace subnets. |
| [`prepareEncryption`](#parameter-prepareencryption) | bool | Prepare the workspace for encryption. Enables the Managed Identity for managed storage account. |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.<p>Available values for 'service' are: 'databricks_ui_api'.<p><p>Default: 'databricks_ui_api' is used if  subnetResourceId is provided but 'service' is not specified.<p> |
| [`publicIpName`](#parameter-publicipname) | string | Name of the Public IP for No Public IP workspace with managed vNet. |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | The network access type for accessing workspace. Set value to disabled to access workspace only via private link. Default: Disabled<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.<p> |
| [`requiredNsgRules`](#parameter-requirednsgrules) | string | Sets a value indicating which NSG rules should be deployed for data plane (clusters) to control plane communication.<p>'NoAzureDatabricksRules' are used when the communication happens over private endpoint. Default: \'NoAzureDatabricksRules\' |
| [`requireInfrastructureEncryption`](#parameter-requireinfrastructureencryption) | bool | A boolean indicating whether or not the DBFS root file system will be enabled with secondary layer of encryption.<p>Platform managed keys will be used for data at rest.<p><p>Setting this parameter to 'false' will make the resource non-compliant.<p> |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`skuName`](#parameter-skuname) | string | The pricing tier of workspace. Default: premium.<p><p>Setting this parameter to a value other than 'premium' will make the resource non-compliant. |
| [`storageAccountName`](#parameter-storageaccountname) | string | Name of the default storage account containing DBFS.<p><p>If not provided the account name will be generated by the Databricks service. |
| [`storageAccountPrivateEndpoints`](#parameter-storageaccountprivateendpoints) | array | Configuration details for private endpoints for the managed storage account.<p><p>Default: configures blob and dfs endpoints using subnetResourceId from the privateEndpoints[0]. |
| [`storageAccountSkuName`](#parameter-storageaccountskuname) | string | Default DBFS storage account SKU name. Default: 'Standard_ZRS' |
| [`tags`](#parameter-tags) | object | Tags of the resource. |

### Parameter: `customPrivateSubnetName`

The name of the 1st Subnet for clusters within the Virtual Network.

- Required: Yes
- Type: string

### Parameter: `customPublicSubnetName`

The name of a 2nd Subnet for clusters within the Virtual Network.

- Required: Yes
- Type: string

### Parameter: `customVirtualNetworkResourceId`

The resource ID of a Virtual Network where Databricks clusters should be created.

- Required: Yes
- Type: string

### Parameter: `name`

The name of the Azure Databricks workspace to create.

- Required: Yes
- Type: string

### Parameter: `accessConnectorResourceId`

The resource ID of the associated access connector for private access to the managed storage account.<p><p>Required if defaultStorageFirewall parameter is 'Enabled'

- Required: No
- Type: string
- Default: `''`

### Parameter: `amlWorkspaceResourceId`

The resource ID of a Azure Machine Learning workspace to link with Databricks workspace.

- Required: No
- Type: string
- Default: `''`

### Parameter: `automaticClusterUpdate`

Set to \'Enabled\' for automatic updates of clusters. Default: Enabled.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'Enabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `complianceSecurityProfile`

Set to \'Enabled\' for compliance security profile features. Default: Enabled.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'Enabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `customerManagedKey`

The customer managed key definition to use for the managed service.

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

### Parameter: `customerManagedKeyManagedDisk`

The customer managed key definition to use for the managed disk.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`keyName`](#parameter-customermanagedkeymanageddiskkeyname) | string | The name of the customer managed key to use for encryption. |
| [`keyVaultResourceId`](#parameter-customermanagedkeymanageddiskkeyvaultresourceid) | string | The resource ID of a key vault to reference a customer managed key for encryption from. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`keyVersion`](#parameter-customermanagedkeymanageddiskkeyversion) | string | The version of the customer managed key to reference for encryption. If not provided, using 'latest'. |
| [`rotationToLatestKeyVersionEnabled`](#parameter-customermanagedkeymanageddiskrotationtolatestkeyversionenabled) | bool | Indicate whether the latest key version should be automatically used for Managed Disk Encryption. Enabled by default. |
| [`userAssignedIdentityResourceId`](#parameter-customermanagedkeymanageddiskuserassignedidentityresourceid) | string | User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use. |

### Parameter: `customerManagedKeyManagedDisk.keyName`

The name of the customer managed key to use for encryption.

- Required: Yes
- Type: string

### Parameter: `customerManagedKeyManagedDisk.keyVaultResourceId`

The resource ID of a key vault to reference a customer managed key for encryption from.

- Required: Yes
- Type: string

### Parameter: `customerManagedKeyManagedDisk.keyVersion`

The version of the customer managed key to reference for encryption. If not provided, using 'latest'.

- Required: No
- Type: string

### Parameter: `customerManagedKeyManagedDisk.rotationToLatestKeyVersionEnabled`

Indicate whether the latest key version should be automatically used for Managed Disk Encryption. Enabled by default.

- Required: No
- Type: bool

### Parameter: `customerManagedKeyManagedDisk.userAssignedIdentityResourceId`

User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use.

- Required: No
- Type: string

### Parameter: `defaultStorageFirewall`

Enables the firewall on the default storage account. Default: Disabled.<p><p>For best security practices, set it to 'Enabled' and configure storageAccountPrivateEndpoints.

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

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.<p><p>Currently known available log categories are:<p>  'accounts'<p>  'BrickStoreHttpGateway'<p>  'capsule8Dataplane'<p>  'clamAVScan'<p>  'CloudStorageMetadata'<p>  'clusterLibraries'<p>  'clusters'<p>  'Dashboards'<p>  'databrickssql'<p>  'DataMonitoring'<p>  'dbfs'<p>  'deltaPipelines'<p>  'featureStore'<p>  'genie'<p>  'gitCredentials'<p>  'globalInitScripts'<p>  'iamRole'<p>  'Ingestion'<p>  'instancePools'<p>  'jobs'<p>  'LineageTracking'<p>  'MarketplaceConsumer'<p>  'mlflowAcledArtifact'<p>  'mlflowExperiment'<p>  'modelRegistry'<p>  'notebook'<p>  'partnerHub'<p>  'PredictiveOptimization'<p>  'RemoteHistoryService'<p>  'repos'<p>  'secrets'<p>  'serverlessRealTimeInference'<p>  'sqlAnalytics'<p>  'sqlPermissions'<p>  'ssh'<p>  'unityCatalog'<p>  'webTerminal'<p>  'workspace'<p>

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

### Parameter: `disablePublicIp`

Disable Public IP. Default: true<p><p>Setting this parameter to false will make the resource non-compliant.<p>

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enhancedSecurityMonitoring`

Set to \'Enabled\' for security monitoring features. Default: Enabled.<p><p>Setting this parameter to 'Disabled' will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'Enabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `loadBalancerBackendPoolName`

Name of the outbound Load Balancer Backend Pool for Secure Cluster Connectivity (No Public IP).

- Required: No
- Type: string
- Default: `''`

### Parameter: `loadBalancerResourceId`

Resource ID of Outbound Load balancer for Secure Cluster Connectivity (No Public IP) workspace.

- Required: No
- Type: string
- Default: `''`

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

### Parameter: `managedResourceGroupResourceId`

The managed resource group ID. It is created by the module as per the to-be resource ID you provide.<p>Default: the module calculates this ID using the name of the resource.<p><p>To be compliant, the resource group name needs to end with an authorized suffix, e.g. '-adbmanaged-rg'.<p>

- Required: No
- Type: string
- Default: `''`

### Parameter: `managedVnetAddressPrefix`

Address prefix for Managed virtual network.

- Required: No
- Type: string
- Default: `'10.139'`

### Parameter: `natGatewayName`

Name of the NAT gateway for Secure Cluster Connectivity (No Public IP) workspace subnets.

- Required: No
- Type: string
- Default: `''`

### Parameter: `prepareEncryption`

Prepare the workspace for encryption. Enables the Managed Identity for managed storage account.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `privateEndpoints`

Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.<p>Available values for 'service' are: 'databricks_ui_api'.<p><p>Default: 'databricks_ui_api' is used if  subnetResourceId is provided but 'service' is not specified.<p>

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

### Parameter: `publicIpName`

Name of the Public IP for No Public IP workspace with managed vNet.

- Required: No
- Type: string
- Default: `''`

### Parameter: `publicNetworkAccess`

The network access type for accessing workspace. Set value to disabled to access workspace only via private link. Default: Disabled<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.<p>

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

### Parameter: `requiredNsgRules`

Sets a value indicating which NSG rules should be deployed for data plane (clusters) to control plane communication.<p>'NoAzureDatabricksRules' are used when the communication happens over private endpoint. Default: \'NoAzureDatabricksRules\'

- Required: No
- Type: string
- Default: `'NoAzureDatabricksRules'`
- Allowed:
  ```Bicep
  [
    'AllRules'
    'NoAzureDatabricksRules'
  ]
  ```

### Parameter: `requireInfrastructureEncryption`

A boolean indicating whether or not the DBFS root file system will be enabled with secondary layer of encryption.<p>Platform managed keys will be used for data at rest.<p><p>Setting this parameter to 'false' will make the resource non-compliant.<p>

- Required: No
- Type: bool
- Default: `True`

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

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

### Parameter: `skuName`

The pricing tier of workspace. Default: premium.<p><p>Setting this parameter to a value other than 'premium' will make the resource non-compliant.

- Required: No
- Type: string
- Default: `'premium'`
- Allowed:
  ```Bicep
  [
    'premium'
    'standard'
    'trial'
  ]
  ```

### Parameter: `storageAccountName`

Name of the default storage account containing DBFS.<p><p>If not provided the account name will be generated by the Databricks service.

- Required: No
- Type: string
- Default: `''`

### Parameter: `storageAccountPrivateEndpoints`

Configuration details for private endpoints for the managed storage account.<p><p>Default: configures blob and dfs endpoints using subnetResourceId from the privateEndpoints[0].

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    {
      service: 'blob'
      subnetResourceId: '[parameters(\'privateEndpoints\')[0].subnetResourceId]'
    }
    {
      service: 'dfs'
      subnetResourceId: '[parameters(\'privateEndpoints\')[0].subnetResourceId]'
    }
  ]
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnetResourceId`](#parameter-storageaccountprivateendpointssubnetresourceid) | string | Resource ID of the subnet where the endpoint needs to be created. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`service`](#parameter-storageaccountprivateendpointsservice) | string | If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationSecurityGroupResourceIds`](#parameter-storageaccountprivateendpointsapplicationsecuritygroupresourceids) | array | Application security groups in which the private endpoint IP configuration is included. |
| [`customDnsConfigs`](#parameter-storageaccountprivateendpointscustomdnsconfigs) | array | Custom DNS configurations. |
| [`customNetworkInterfaceName`](#parameter-storageaccountprivateendpointscustomnetworkinterfacename) | string | The custom name of the network interface attached to the private endpoint. |
| [`enableTelemetry`](#parameter-storageaccountprivateendpointsenabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`ipConfigurations`](#parameter-storageaccountprivateendpointsipconfigurations) | array | A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints. |
| [`isManualConnection`](#parameter-storageaccountprivateendpointsismanualconnection) | bool | If Manual Private Link Connection is required. |
| [`location`](#parameter-storageaccountprivateendpointslocation) | string | The location to deploy the private endpoint to. |
| [`lock`](#parameter-storageaccountprivateendpointslock) | object | Specify the type of lock. |
| [`manualConnectionRequestMessage`](#parameter-storageaccountprivateendpointsmanualconnectionrequestmessage) | string | A message passed to the owner of the remote resource with the manual connection request. |
| [`name`](#parameter-storageaccountprivateendpointsname) | string | The name of the private endpoint. |
| [`privateDnsZoneGroupName`](#parameter-storageaccountprivateendpointsprivatednszonegroupname) | string | The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided. |
| [`privateDnsZoneResourceIds`](#parameter-storageaccountprivateendpointsprivatednszoneresourceids) | array | The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones. |
| [`privateLinkServiceConnectionName`](#parameter-storageaccountprivateendpointsprivatelinkserviceconnectionname) | string | The name of the private link connection to create. |
| [`resourceGroupName`](#parameter-storageaccountprivateendpointsresourcegroupname) | string | Specify if you want to deploy the Private Endpoint into a different resource group than the main resource. |
| [`roleAssignments`](#parameter-storageaccountprivateendpointsroleassignments) | array | Array of role assignments to create. |
| [`tags`](#parameter-storageaccountprivateendpointstags) | object | Tags to be applied on all resources/resource groups in this deployment. |

### Parameter: `storageAccountPrivateEndpoints.subnetResourceId`

Resource ID of the subnet where the endpoint needs to be created.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.service`

If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.applicationSecurityGroupResourceIds`

Application security groups in which the private endpoint IP configuration is included.

- Required: No
- Type: array

### Parameter: `storageAccountPrivateEndpoints.customDnsConfigs`

Custom DNS configurations.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`fqdn`](#parameter-storageaccountprivateendpointscustomdnsconfigsfqdn) | string | Fqdn that resolves to private endpoint IP address. |
| [`ipAddresses`](#parameter-storageaccountprivateendpointscustomdnsconfigsipaddresses) | array | A list of private IP addresses of the private endpoint. |

### Parameter: `storageAccountPrivateEndpoints.customDnsConfigs.fqdn`

Fqdn that resolves to private endpoint IP address.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.customDnsConfigs.ipAddresses`

A list of private IP addresses of the private endpoint.

- Required: Yes
- Type: array

### Parameter: `storageAccountPrivateEndpoints.customNetworkInterfaceName`

The custom name of the network interface attached to the private endpoint.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool

### Parameter: `storageAccountPrivateEndpoints.ipConfigurations`

A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-storageaccountprivateendpointsipconfigurationsname) | string | The name of the resource that is unique within a resource group. |
| [`properties`](#parameter-storageaccountprivateendpointsipconfigurationsproperties) | object | Properties of private endpoint IP configurations. |

### Parameter: `storageAccountPrivateEndpoints.ipConfigurations.name`

The name of the resource that is unique within a resource group.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.ipConfigurations.properties`

Properties of private endpoint IP configurations.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`groupId`](#parameter-storageaccountprivateendpointsipconfigurationspropertiesgroupid) | string | The ID of a group obtained from the remote resource that this private endpoint should connect to. |
| [`memberName`](#parameter-storageaccountprivateendpointsipconfigurationspropertiesmembername) | string | The member name of a group obtained from the remote resource that this private endpoint should connect to. |
| [`privateIPAddress`](#parameter-storageaccountprivateendpointsipconfigurationspropertiesprivateipaddress) | string | A private IP address obtained from the private endpoint's subnet. |

### Parameter: `storageAccountPrivateEndpoints.ipConfigurations.properties.groupId`

The ID of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.ipConfigurations.properties.memberName`

The member name of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.ipConfigurations.properties.privateIPAddress`

A private IP address obtained from the private endpoint's subnet.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.isManualConnection`

If Manual Private Link Connection is required.

- Required: No
- Type: bool

### Parameter: `storageAccountPrivateEndpoints.location`

The location to deploy the private endpoint to.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.lock`

Specify the type of lock.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-storageaccountprivateendpointslockkind) | string | Specify the type of lock. |
| [`name`](#parameter-storageaccountprivateendpointslockname) | string | Specify the name of lock. |

### Parameter: `storageAccountPrivateEndpoints.lock.kind`

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

### Parameter: `storageAccountPrivateEndpoints.lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.manualConnectionRequestMessage`

A message passed to the owner of the remote resource with the manual connection request.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.name`

The name of the private endpoint.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.privateDnsZoneGroupName`

The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.privateDnsZoneResourceIds`

The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones.

- Required: No
- Type: array

### Parameter: `storageAccountPrivateEndpoints.privateLinkServiceConnectionName`

The name of the private link connection to create.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.resourceGroupName`

Specify if you want to deploy the Private Endpoint into a different resource group than the main resource.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-storageaccountprivateendpointsroleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-storageaccountprivateendpointsroleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-storageaccountprivateendpointsroleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-storageaccountprivateendpointsroleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-storageaccountprivateendpointsroleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-storageaccountprivateendpointsroleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-storageaccountprivateendpointsroleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `storageAccountPrivateEndpoints.roleAssignments.principalType`

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

### Parameter: `storageAccountPrivateEndpoints.tags`

Tags to be applied on all resources/resource groups in this deployment.

- Required: No
- Type: object

### Parameter: `storageAccountSkuName`

Default DBFS storage account SKU name. Default: 'Standard_ZRS'

- Required: No
- Type: string
- Default: `'Standard_ZRS'`
- Allowed:
  ```Bicep
  [
    'Premium_LRS'
    'Premium_ZRS'
    'Standard_GRS'
    'Standard_GZRS'
    'Standard_LRS'
    'Standard_RAGRS'
    'Standard_RAGZRS'
    'Standard_ZRS'
  ]
  ```

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `managedResourceGroupId` | string | The resource ID of the managed resource group. |
| `managedResourceGroupName` | string | The name of the managed resource group. |
| `name` | string | The name of the deployed databricks workspace. |
| `privateEndpoints` | array | The private endpoints for the Databricks Workspace. |
| `privateEndpointsStorage` | array | The private endpoints for the default storage account. |
| `resourceGroupName` | string | The resource group of the deployed databricks workspace. |
| `resourceId` | string | The resource ID of the deployed databricks workspace. |
| `storageAccountId` | string | The resource ID of the DBFS storage account. |
| `storageAccountName` | string | The name of the DBFS storage account. |
| `workspaceId` | string | The unique identifier of the databricks workspace in databricks control plane. |
| `workspaceUrl` | string | The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
