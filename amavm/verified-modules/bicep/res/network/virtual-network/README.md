# Virtual Network `[Microsoft.Network/virtualNetworks]`

This module deploys a Virtual Network (vNet).

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Notes](#notes)
- [Data Collection](#data-collection)

## Compliance

Version: 20240626

Creating Virtual Networks in spokes is not supported.
Peering these custom VNets or establishing any other type of connectivity links would generally be not-compliant.

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/virtualNetworks` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/virtualNetworks)</li></ul> |
| `Microsoft.Network/virtualNetworks/subnets` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks_subnets.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/virtualNetworks/subnets)</li></ul> |
| `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` | 2023-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks_virtualnetworkpeerings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-04-01/virtualNetworks/virtualNetworkPeerings)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/network/virtual-network:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [Deploying a bi-directional peering](#example-3-deploying-a-bi-directional-peering)
- [WAF-aligned](#example-4-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module virtualNetworkMod 'br/<registry-alias>:res/network/virtual-network:<version>' = {
  name: 'virtualNetwork-mod'
  params: {
    // Required parameters
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    name: 'vnet-min001'
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
using 'br/public:res/network/virtual-network:<version>'

// Required parameters
param addressPrefixes = [
  '10.0.0.0/16'
]
param name = 'vnet-min001'
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
module virtualNetworkMod 'br/<registry-alias>:res/network/virtual-network:<version>' = {
  name: 'virtualNetwork-mod'
  params: {
    // Required parameters
    addressPrefixes: [
      '<addressPrefix>'
    ]
    name: 'nvnmax001'
    // Non-required parameters
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
    dnsServers: [
      '10.0.1.4'
      '10.0.1.5'
    ]
    flowTimeoutInMinutes: 20
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    subnets: [
      {
        addressPrefix: '<addressPrefix>'
        name: 'GatewaySubnet'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'az-subnet-x-001'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
        roleAssignments: [
          {
            principalId: '<principalId>'
            principalType: 'ServicePrincipal'
            roleDefinitionIdOrName: 'Reader'
          }
        ]
        routeTableResourceId: '<routeTableResourceId>'
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.Sql'
          }
        ]
      }
      {
        addressPrefix: '<addressPrefix>'
        delegations: [
          {
            name: 'netappDel'
            properties: {
              serviceName: 'Microsoft.Netapp/volumes'
            }
          }
        ]
        name: 'az-subnet-x-002'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'az-subnet-x-003'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'az-subnet-x-004'
        natGatewayResourceId: ''
        networkSecurityGroupResourceId: ''
        routeTableResourceId: ''
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'AzureBastionSubnet'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'AzureFirewallSubnet'
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
using 'br/public:res/network/virtual-network:<version>'

// Required parameters
param addressPrefixes = [
  '<addressPrefix>'
]
param name = 'nvnmax001'
// Non-required parameters
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
param dnsServers = [
  '10.0.1.4'
  '10.0.1.5'
]
param flowTimeoutInMinutes = 20
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Reader'
  }
]
param subnets = [
  {
    addressPrefix: '<addressPrefix>'
    name: 'GatewaySubnet'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'az-subnet-x-001'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    routeTableResourceId: '<routeTableResourceId>'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
    ]
  }
  {
    addressPrefix: '<addressPrefix>'
    delegations: [
      {
        name: 'netappDel'
        properties: {
          serviceName: 'Microsoft.Netapp/volumes'
        }
      }
    ]
    name: 'az-subnet-x-002'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'az-subnet-x-003'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'az-subnet-x-004'
    natGatewayResourceId: ''
    networkSecurityGroupResourceId: ''
    routeTableResourceId: ''
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'AzureBastionSubnet'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'AzureFirewallSubnet'
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

### Example 3: _Deploying a bi-directional peering_

This instance deploys the module with both an inbound and outbound peering.


<details>

<summary>via Bicep module</summary>

```bicep
module virtualNetworkMod 'br/<registry-alias>:res/network/virtual-network:<version>' = {
  name: 'virtualNetwork-mod'
  params: {
    // Required parameters
    addressPrefixes: [
      '10.1.0.0/24'
    ]
    name: 'nvnpeer001'
    // Non-required parameters
    location: '<location>'
    peerings: [
      {
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: true
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'customName'
        remoteVirtualNetworkId: '<remoteVirtualNetworkId>'
        useRemoteGateways: false
      }
    ]
    subnets: [
      {
        addressPrefix: '10.1.0.0/26'
        name: 'GatewaySubnet'
      }
      {
        addressPrefix: '10.1.0.64/26'
        name: 'AzureBastionSubnet'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }
      {
        addressPrefix: '10.1.0.128/26'
        name: 'AzureFirewallSubnet'
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
using 'br/public:res/network/virtual-network:<version>'

// Required parameters
param addressPrefixes = [
  '10.1.0.0/24'
]
param name = 'nvnpeer001'
// Non-required parameters
param location = '<location>'
param peerings = [
  {
    allowForwardedTraffic: true
    allowGatewayTransit: false
    allowVirtualNetworkAccess: true
    remotePeeringAllowForwardedTraffic: true
    remotePeeringAllowVirtualNetworkAccess: true
    remotePeeringEnabled: true
    remotePeeringName: 'customName'
    remoteVirtualNetworkId: '<remoteVirtualNetworkId>'
    useRemoteGateways: false
  }
]
param subnets = [
  {
    addressPrefix: '10.1.0.0/26'
    name: 'GatewaySubnet'
  }
  {
    addressPrefix: '10.1.0.64/26'
    name: 'AzureBastionSubnet'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
  }
  {
    addressPrefix: '10.1.0.128/26'
    name: 'AzureFirewallSubnet'
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

### Example 4: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module virtualNetworkMod 'br/<registry-alias>:res/network/virtual-network:<version>' = {
  name: 'virtualNetwork-mod'
  params: {
    // Required parameters
    addressPrefixes: [
      '<addressPrefix>'
    ]
    name: 'vnetwaf001'
    // Non-required parameters
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
    dnsServers: [
      '10.0.1.4'
      '10.0.1.5'
    ]
    flowTimeoutInMinutes: 20
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    subnets: [
      {
        addressPrefix: '<addressPrefix>'
        name: 'GatewaySubnet'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'az-subnet-x-001'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
        roleAssignments: [
          {
            principalId: '<principalId>'
            principalType: 'ServicePrincipal'
            roleDefinitionIdOrName: 'Reader'
          }
        ]
        routeTableResourceId: '<routeTableResourceId>'
        serviceEndpoints: [
          {
            service: 'Microsoft.Storage'
          }
          {
            service: 'Microsoft.Sql'
          }
        ]
      }
      {
        addressPrefix: '<addressPrefix>'
        delegations: [
          {
            name: 'netappDel'
            properties: {
              serviceName: 'Microsoft.Netapp/volumes'
            }
          }
        ]
        name: 'az-subnet-x-002'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'az-subnet-x-003'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
        privateEndpointNetworkPolicies: 'Disabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'AzureBastionSubnet'
        networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
      }
      {
        addressPrefix: '<addressPrefix>'
        name: 'AzureFirewallSubnet'
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
using 'br/public:res/network/virtual-network:<version>'

// Required parameters
param addressPrefixes = [
  '<addressPrefix>'
]
param name = 'vnetwaf001'
// Non-required parameters
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
param dnsServers = [
  '10.0.1.4'
  '10.0.1.5'
]
param flowTimeoutInMinutes = 20
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param subnets = [
  {
    addressPrefix: '<addressPrefix>'
    name: 'GatewaySubnet'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'az-subnet-x-001'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    routeTableResourceId: '<routeTableResourceId>'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
      }
      {
        service: 'Microsoft.Sql'
      }
    ]
  }
  {
    addressPrefix: '<addressPrefix>'
    delegations: [
      {
        name: 'netappDel'
        properties: {
          serviceName: 'Microsoft.Netapp/volumes'
        }
      }
    ]
    name: 'az-subnet-x-002'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'az-subnet-x-003'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'AzureBastionSubnet'
    networkSecurityGroupResourceId: '<networkSecurityGroupResourceId>'
  }
  {
    addressPrefix: '<addressPrefix>'
    name: 'AzureFirewallSubnet'
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

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`addressPrefixes`](#parameter-addressprefixes) | array | An Array of 1 or more IP Address Prefixes for the Virtual Network. |
| [`name`](#parameter-name) | string | The name of the Virtual Network (vNet). |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`ddosProtectionPlanResourceId`](#parameter-ddosprotectionplanresourceid) | string | Resource ID of the DDoS protection plan to assign the VNET to. If it's left blank, DDoS protection will not be configured. If it's provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service. |
| [`dnsServers`](#parameter-dnsservers) | array | DNS Servers associated to the Virtual Network. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`flowTimeoutInMinutes`](#parameter-flowtimeoutinminutes) | int | The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. Default value 0 will set the property to null. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`peerings`](#parameter-peerings) | array | Virtual Network Peerings configurations.<p><p>Setting this parameter to any value other than empty array ('[]') will make resource non-compliant. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`subnets`](#parameter-subnets) | array | An array of subnets to deploy to the Virtual Network. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`vnetEncryption`](#parameter-vnetencryption) | bool | Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet. Requires the EnableVNetEncryption feature to be registered for the subscription and a supported region to use this property. |
| [`vnetEncryptionEnforcement`](#parameter-vnetencryptionenforcement) | string | If the encrypted VNet allows VM that does not support encryption. Can only be used when vnetEncryption is enabled. |

### Parameter: `addressPrefixes`

An Array of 1 or more IP Address Prefixes for the Virtual Network.

- Required: Yes
- Type: array

### Parameter: `name`

The name of the Virtual Network (vNet).

- Required: Yes
- Type: string

### Parameter: `ddosProtectionPlanResourceId`

Resource ID of the DDoS protection plan to assign the VNET to. If it's left blank, DDoS protection will not be configured. If it's provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.

- Required: No
- Type: string
- Default: `''`

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.

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

### Parameter: `dnsServers`

DNS Servers associated to the Virtual Network.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `flowTimeoutInMinutes`

The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. Default value 0 will set the property to null.

- Required: No
- Type: int
- Default: `0`
- MaxValue: 30

### Parameter: `location`

Location for all resources.

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

### Parameter: `peerings`

Virtual Network Peerings configurations.<p><p>Setting this parameter to any value other than empty array ('[]') will make resource non-compliant.

- Required: No
- Type: array
- Default: `[]`

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

### Parameter: `subnets`

An array of subnets to deploy to the Virtual Network.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-subnetsname) | string | The Name of the subnet resource. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`addressPrefix`](#parameter-subnetsaddressprefix) | string | The address prefix for the subnet. Required if `addressPrefixes` is empty. |
| [`addressPrefixes`](#parameter-subnetsaddressprefixes) | array | List of address prefixes for the subnet. Required if `addressPrefix` is empty. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationGatewayIPConfigurations`](#parameter-subnetsapplicationgatewayipconfigurations) | array | Application gateway IP configurations of virtual network resource. |
| [`delegations`](#parameter-subnetsdelegations) | array | The delegation to enable on the subnet. |
| [`natGatewayResourceId`](#parameter-subnetsnatgatewayresourceid) | string | The resource ID of the NAT Gateway to use for the subnet. |
| [`networkSecurityGroupResourceId`](#parameter-subnetsnetworksecuritygroupresourceid) | string | The resource ID of the network security group to assign to the subnet.<p><p>For policy compliance must be not empty.<p> |
| [`privateEndpointNetworkPolicies`](#parameter-subnetsprivateendpointnetworkpolicies) | string | Enable or disable apply network policies on private endpoint in the subnet. Default is 'Enabled'.<p><p>For policy compliance must be either 'Enabled' or 'RouteTableEnabled'.<p> |
| [`privateLinkServiceNetworkPolicies`](#parameter-subnetsprivatelinkservicenetworkpolicies) | string | enable or disable apply network policies on private link service in the subnet. |
| [`roleAssignments`](#parameter-subnetsroleassignments) | array | Array of role assignments to create. |
| [`routeTableResourceId`](#parameter-subnetsroutetableresourceid) | string | The resource ID of the route table to assign to the subnet.<p><p>For policy compliance must be not empty.<p> |
| [`serviceEndpointPolicies`](#parameter-subnetsserviceendpointpolicies) | array | An array of service endpoint policies. |
| [`serviceEndpoints`](#parameter-subnetsserviceendpoints) | array | The service endpoints to enable on the subnet. |

### Parameter: `subnets.name`

The Name of the subnet resource.

- Required: Yes
- Type: string

### Parameter: `subnets.addressPrefix`

The address prefix for the subnet. Required if `addressPrefixes` is empty.

- Required: No
- Type: string

### Parameter: `subnets.addressPrefixes`

List of address prefixes for the subnet. Required if `addressPrefix` is empty.

- Required: No
- Type: array

### Parameter: `subnets.applicationGatewayIPConfigurations`

Application gateway IP configurations of virtual network resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-subnetsapplicationgatewayipconfigurationsname) | string | Name of the IP configuration that is unique within an Application Gateway. |
| [`properties`](#parameter-subnetsapplicationgatewayipconfigurationsproperties) | object | Properties of the application gateway IP configuration. |

### Parameter: `subnets.applicationGatewayIPConfigurations.name`

Name of the IP configuration that is unique within an Application Gateway.

- Required: Yes
- Type: string

### Parameter: `subnets.applicationGatewayIPConfigurations.properties`

Properties of the application gateway IP configuration.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnet`](#parameter-subnetsapplicationgatewayipconfigurationspropertiessubnet) | object | Reference to the subnet resource. A subnet from where application gateway gets its private address. |

### Parameter: `subnets.applicationGatewayIPConfigurations.properties.subnet`

Reference to the subnet resource. A subnet from where application gateway gets its private address.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-subnetsapplicationgatewayipconfigurationspropertiessubnetid) | string | esource ID. |

### Parameter: `subnets.applicationGatewayIPConfigurations.properties.subnet.id`

esource ID.

- Required: Yes
- Type: string

### Parameter: `subnets.delegations`

The delegation to enable on the subnet.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-subnetsdelegationsname) | string | The name of the delegation resource that is unique within a subnet.<p>This name can be used to access the resource. (e.g. Microsoft.Web.serverFarms) |
| [`properties`](#parameter-subnetsdelegationsproperties) | object | Contains the name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms). |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`type`](#parameter-subnetsdelegationstype) | string | Resource type (e.g. Microsoft.Network/virtualNetworks/subnets/delegation) |

### Parameter: `subnets.delegations.name`

The name of the delegation resource that is unique within a subnet.<p>This name can be used to access the resource. (e.g. Microsoft.Web.serverFarms)

- Required: Yes
- Type: string

### Parameter: `subnets.delegations.properties`

Contains the name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serviceName`](#parameter-subnetsdelegationspropertiesservicename) | string | The name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms). |

### Parameter: `subnets.delegations.properties.serviceName`

The name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms).

- Required: Yes
- Type: string

### Parameter: `subnets.delegations.type`

Resource type (e.g. Microsoft.Network/virtualNetworks/subnets/delegation)

- Required: No
- Type: string

### Parameter: `subnets.natGatewayResourceId`

The resource ID of the NAT Gateway to use for the subnet.

- Required: No
- Type: string

### Parameter: `subnets.networkSecurityGroupResourceId`

The resource ID of the network security group to assign to the subnet.<p><p>For policy compliance must be not empty.<p>

- Required: No
- Type: string

### Parameter: `subnets.privateEndpointNetworkPolicies`

Enable or disable apply network policies on private endpoint in the subnet. Default is 'Enabled'.<p><p>For policy compliance must be either 'Enabled' or 'RouteTableEnabled'.<p>

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
    'NetworkSecurityGroupEnabled'
    'RouteTableEnabled'
  ]
  ```

### Parameter: `subnets.privateLinkServiceNetworkPolicies`

enable or disable apply network policies on private link service in the subnet.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `subnets.roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-subnetsroleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-subnetsroleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-subnetsroleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-subnetsroleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-subnetsroleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-subnetsroleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-subnetsroleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `subnets.roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `subnets.roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `subnets.roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `subnets.roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `subnets.roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `subnets.roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `subnets.roleAssignments.principalType`

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

### Parameter: `subnets.routeTableResourceId`

The resource ID of the route table to assign to the subnet.<p><p>For policy compliance must be not empty.<p>

- Required: No
- Type: string

### Parameter: `subnets.serviceEndpointPolicies`

An array of service endpoint policies.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-subnetsserviceendpointpoliciesid) | string | Resource ID. |
| [`location`](#parameter-subnetsserviceendpointpolicieslocation) | string | Resource location. |
| [`properties`](#parameter-subnetsserviceendpointpoliciesproperties) | object | Properties of the service end point policy. |
| [`tags`](#parameter-subnetsserviceendpointpoliciestags) | object | Resource tags. |

### Parameter: `subnets.serviceEndpointPolicies.id`

Resource ID.

- Required: No
- Type: string

### Parameter: `subnets.serviceEndpointPolicies.location`

Resource location.

- Required: No
- Type: string

### Parameter: `subnets.serviceEndpointPolicies.properties`

Properties of the service end point policy.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serviceAlias`](#parameter-subnetsserviceendpointpoliciespropertiesservicealias) | string | The alias indicating if the policy belongs to a service |
| [`serviceEndpointPolicyDefinitions`](#parameter-subnetsserviceendpointpoliciespropertiesserviceendpointpolicydefinitions) | array | A collection of service endpoint policy definitions of the service endpoint policy. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`contextualServiceEndpointPolicies`](#parameter-subnetsserviceendpointpoliciespropertiescontextualserviceendpointpolicies) | array | A collection of contextual service endpoint policy. |

### Parameter: `subnets.serviceEndpointPolicies.properties.serviceAlias`

The alias indicating if the policy belongs to a service

- Required: Yes
- Type: string

### Parameter: `subnets.serviceEndpointPolicies.properties.serviceEndpointPolicyDefinitions`

A collection of service endpoint policy definitions of the service endpoint policy.

- Required: Yes
- Type: array

### Parameter: `subnets.serviceEndpointPolicies.properties.contextualServiceEndpointPolicies`

A collection of contextual service endpoint policy.

- Required: No
- Type: array

### Parameter: `subnets.serviceEndpointPolicies.tags`

Resource tags.

- Required: No
- Type: object

### Parameter: `subnets.serviceEndpoints`

The service endpoints to enable on the subnet.

- Required: No
- Type: array

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `vnetEncryption`

Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet. Requires the EnableVNetEncryption feature to be registered for the subscription and a supported region to use this property.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `vnetEncryptionEnforcement`

If the encrypted VNet allows VM that does not support encryption. Can only be used when vnetEncryption is enabled.

- Required: No
- Type: string
- Default: `'AllowUnencrypted'`
- Allowed:
  ```Bicep
  [
    'AllowUnencrypted'
    'DropUnencrypted'
  ]
  ```

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the virtual network. |
| `resourceGroupName` | string | The resource group the virtual network was deployed into. |
| `resourceId` | string | The resource ID of the virtual network. |
| `subnetNames` | array | The names of the deployed subnets. |
| `subnetResourceIds` | array | The resource IDs of the deployed subnets. |

## Notes

### Considerations

The network security group and route table resources must reside in the same resource group as the virtual network.

### Parameter Usage: `peerings`

As the virtual network peering array allows you to deploy not only a one-way but also two-way peering (i.e reverse), you can use the following ***additional*** properties on top of what is documented in _[virtualNetworkPeering](virtual-network-peering/README.md)_.

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `remotePeeringEnabled` | bool | `false` |  | Optional. Set to true to also deploy the reverse peering for the configured remote virtual networks to the local network |
| `remotePeeringName` | string | `'${last(split(peering.remoteVirtualNetworkId, '/'))}-${name}'` | | Optional. The Name of Vnet Peering resource. If not provided, default value will be <remoteVnetName>-<localVnetName> |
| `remotePeeringAllowForwardedTraffic` | bool | `true` | | Optional. Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. |
| `remotePeeringAllowGatewayTransit` | bool | `false` | | Optional. If gateway links can be used in remote virtual networking to link to this virtual network. |
| `remotePeeringAllowVirtualNetworkAccess` | bool | `true` | | Optional. Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space. |
| `remotePeeringDoNotVerifyRemoteGateways` | bool | `true` | | Optional. If we need to verify the provisioning state of the remote gateway. |
| `remotePeeringUseRemoteGateways` | bool | `false` | |  Optional. If remote gateways can be used on this virtual network. If the flag is set to `true`, and allowGatewayTransit on local peering is also `true`, virtual network will use gateways of local virtual network for transit. Only one peering can have this flag set to `true`. This flag cannot be set if virtual network already has a gateway.  |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
