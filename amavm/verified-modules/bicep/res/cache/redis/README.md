# Redis Cache `[Microsoft.Cache/redis]`

This module deploys an Azure Cache for Redis.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Data Collection](#data-collection)

## Compliance

Version: 20250308

Compliant usage of Azure Cache for Redis requires:
- publicNetworkAccess: 'Disabled'
- disableAccessKeyAuthentication: true (Entra ID authentication enforced)
- enableNonSslPort: false (TLS access enforced)
- minimumTlsVersion: '1.2'
- zoneRedundant: true (for production workloads)
- skuName: 'Premium' (required for private endpoints and zone redundancy)


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Cache/redis` | 2024-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.cache_redis.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Cache/2024-11-01/redis)</li></ul> |
| `Microsoft.Cache/redis/accessPolicies` | 2024-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.cache_redis_accesspolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Cache/2024-11-01/redis/accessPolicies)</li></ul> |
| `Microsoft.Cache/redis/accessPolicyAssignments` | 2024-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.cache_redis_accesspolicyassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Cache/2024-11-01/redis/accessPolicyAssignments)</li></ul> |
| `Microsoft.Cache/redis/firewallRules` | 2024-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.cache_redis_firewallrules.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Cache/2024-11-01/redis/firewallRules)</li></ul> |
| `Microsoft.Cache/redis/linkedServers` | 2024-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.cache_redis_linkedservers.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Cache/2024-11-01/redis/linkedServers)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2025-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2025-05-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2025-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2025-05-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/cache/redis:<version>`.

- [Redis Cache - Defaults](#example-1-redis-cache---defaults)
- [Using large parameter set](#example-2-using-large-parameter-set)
- [WAF-aligned](#example-3-waf-aligned)

### Example 1: _Redis Cache - Defaults_

This test deploys a Redis Cache with default configuration and private endpoint (public network access denied by policy).

You can find the full example and the setup of its dependencies in the deployment test folder path [/tests/e2e/defaults]


<details>

<summary>via Bicep module</summary>

```bicep
module redisMod 'br/<registry-alias>:res/cache/redis:<version>' = {
  name: 'redis-mod'
  params: {
    // Required parameters
    name: 'rcdef001'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    capacity: 1
    location: '<location>'
    publicNetworkAccess: 'Disabled'
    skuName: 'Premium'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/cache/redis:<version>'

// Required parameters
param name = 'rcdef001'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param capacity = 1
param location = '<location>'
param publicNetworkAccess = 'Disabled'
param skuName = 'Premium'
```

</details>
<p>

### Example 2: _Using large parameter set_

This instance deploys the module with most of its features enabled.

You can find the full example and the setup of its dependencies in the deployment test folder path [/tests/e2e/max]


<details>

<summary>via Bicep module</summary>

```bicep
module redisMod 'br/<registry-alias>:res/cache/redis:<version>' = {
  name: 'redis-mod'
  params: {
    // Required parameters
    name: 'crmax001'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        roleAssignments: [
          {
            principalId: '<principalId>'
            principalType: 'ServicePrincipal'
            roleDefinitionIdOrName: 'Owner'
          }
          {
            principalId: '<principalId>'
            principalType: 'ServicePrincipal'
            roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
          }
        ]
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
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
    accessPolicies: [
      {
        name: 'testAccessPolicy'
        permissions: '+get +set +del ~*'
      }
    ]
    accessPolicyAssignments: [
      {
        accessPolicyName: 'testAccessPolicy'
        objectId: '<objectId>'
        objectIdAlias: 'testAlias'
      }
    ]
    availabilityZones: [
      1
      2
    ]
    capacity: 2
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        logCategoriesAndGroups: [
          {
            category: 'ConnectedClientList'
          }
        ]
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
    disableAccessKeyAuthentication: true
    enableNonSslPort: false
    firewallRules: [
      {
        endIP: '0.0.0.0'
        name: 'AllowAllWindowsAzureIps'
        startIP: '0.0.0.0'
      }
      {
        endIP: '10.10.10.10'
        name: 'testrule1'
        startIP: '10.10.10.1'
      }
      {
        endIP: '100.100.100.10'
        name: 'testrule2'
        startIP: '100.100.100.1'
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
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    redisConfiguration: {
      'maxmemory-delta': '10'
      'maxmemory-policy': 'allkeys-lru'
    }
    redisVersion: '6'
    replicasPerMaster: 3
    replicasPerPrimary: 3
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
    shardCount: 1
    skuName: 'Premium'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      resourceType: 'Redis Cache'
    }
    tenantSettings: {
      testKey: 'testValue'
    }
    zonalAllocationPolicy: 'UserDefined'
    zoneRedundant: true
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/cache/redis:<version>'

// Required parameters
param name = 'crmax001'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
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
param accessPolicies = [
  {
    name: 'testAccessPolicy'
    permissions: '+get +set +del ~*'
  }
]
param accessPolicyAssignments = [
  {
    accessPolicyName: 'testAccessPolicy'
    objectId: '<objectId>'
    objectIdAlias: 'testAlias'
  }
]
param availabilityZones = [
  1
  2
]
param capacity = 2
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    logCategoriesAndGroups: [
      {
        category: 'ConnectedClientList'
      }
    ]
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
param disableAccessKeyAuthentication = true
param enableNonSslPort = false
param firewallRules = [
  {
    endIP: '0.0.0.0'
    name: 'AllowAllWindowsAzureIps'
    startIP: '0.0.0.0'
  }
  {
    endIP: '10.10.10.10'
    name: 'testrule1'
    startIP: '10.10.10.1'
  }
  {
    endIP: '100.100.100.10'
    name: 'testrule2'
    startIP: '100.100.100.1'
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
param minimumTlsVersion = '1.2'
param publicNetworkAccess = 'Disabled'
param redisConfiguration = {
  'maxmemory-delta': '10'
  'maxmemory-policy': 'allkeys-lru'
}
param redisVersion = '6'
param replicasPerMaster = 3
param replicasPerPrimary = 3
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
param shardCount = 1
param skuName = 'Premium'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  resourceType: 'Redis Cache'
}
param tenantSettings = {
  testKey: 'testValue'
}
param zonalAllocationPolicy = 'UserDefined'
param zoneRedundant = true
```

</details>
<p>

### Example 3: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.

You can find the full example and the setup of its dependencies in the deployment test folder path [/tests/e2e/waf-aligned]


<details>

<summary>via Bicep module</summary>

```bicep
module redisMod 'br/<registry-alias>:res/cache/redis:<version>' = {
  name: 'redis-mod'
  params: {
    // Required parameters
    name: 'crwaf001'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
    ]
    // Non-required parameters
    availabilityZones: [
      1
      2
      3
    ]
    capacity: 2
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        logCategoriesAndGroups: [
          {
            category: 'ConnectedClientList'
          }
        ]
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
    disableAccessKeyAuthentication: true
    enableNonSslPort: false
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
    }
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    redisVersion: '6'
    replicasPerMaster: 3
    replicasPerPrimary: 3
    shardCount: 1
    skuName: 'Premium'
    tags: {
      'hidden-title': 'This is visible in the resource name'
      resourceType: 'Redis Cache'
    }
    zonalAllocationPolicy: 'UserDefined'
    zoneRedundant: true
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/cache/redis:<version>'

// Required parameters
param name = 'crwaf001'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
]
// Non-required parameters
param availabilityZones = [
  1
  2
  3
]
param capacity = 2
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    logCategoriesAndGroups: [
      {
        category: 'ConnectedClientList'
      }
    ]
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
param disableAccessKeyAuthentication = true
param enableNonSslPort = false
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  systemAssigned: true
}
param minimumTlsVersion = '1.2'
param publicNetworkAccess = 'Disabled'
param redisVersion = '6'
param replicasPerMaster = 3
param replicasPerPrimary = 3
param shardCount = 1
param skuName = 'Premium'
param tags = {
  'hidden-title': 'This is visible in the resource name'
  resourceType: 'Redis Cache'
}
param zonalAllocationPolicy = 'UserDefined'
param zoneRedundant = true
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the Redis cache resource. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`accessPolicies`](#parameter-accesspolicies) | array | Array of access policies to create. |
| [`accessPolicyAssignments`](#parameter-accesspolicyassignments) | array | Array of access policy assignments. |
| [`availabilityZones`](#parameter-availabilityzones) | array | If the zoneRedundant parameter is true, replicas will be provisioned in the availability zones specified here. Otherwise, the service will choose where replicas are deployed. |
| [`capacity`](#parameter-capacity) | int | The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4). |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service.<p><p>Currently known available log categories for Microsoft.Cache/redis are:<p>'ConnectedClientList'<p> |
| [`disableAccessKeyAuthentication`](#parameter-disableaccesskeyauthentication) | bool | Disable authentication via access keys.<p><p>Setting this parameter to false will make the resource non-compliant (drcp-redis-05). [Policy: drcp-redis-05]<p> |
| [`enableNonSslPort`](#parameter-enablenonsslport) | bool | Specifies whether the non-ssl Redis server port (6379) is enabled.<p><p>Setting this parameter to true will make the resource non-compliant (drcp-redis-07). [Policy: drcp-redis-07]<p> |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`firewallRules`](#parameter-firewallrules) | array | The firewall rules of the Redis Cache. |
| [`geoReplicationObject`](#parameter-georeplicationobject) | object | The geo-replication settings of the service. Requires a Premium SKU. Geo-replication is not supported on a cache with multiple replicas per primary. Secondary cache VM Size must be same or higher as compared to the primary cache VM Size. Geo-replication between a vnet and non vnet cache (and vice-a-versa) not supported. |
| [`location`](#parameter-location) | string | The location to deploy the Redis cache service. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. |
| [`minimumTlsVersion`](#parameter-minimumtlsversion) | string | Requires clients to use a specified TLS version (or higher) to connect.<p><p>Setting this parameter to less than 1.2 will make the resource non-compliant (drcp-redis-08). [Policy: drcp-redis-08]<p> |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. [Policy: drcp-redis-04] [Policy: drcp-sub-07] |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.<p><p>Setting this parameter to Enabled will make the resource non-compliant (drcp-redis-02). [Policy: drcp-redis-02]<p> |
| [`redisConfiguration`](#parameter-redisconfiguration) | object | All Redis Settings. Few possible keys: rdb-backup-enabled,rdb-storage-connection-string,rdb-backup-frequency,maxmemory-delta,maxmemory-policy,notify-keyspace-events,maxmemory-samples,slowlog-log-slower-than,slowlog-max-len,list-max-ziplist-entries,list-max-ziplist-value,hash-max-ziplist-entries,hash-max-ziplist-value,set-max-intset-entries,zset-max-ziplist-entries,zset-max-ziplist-value etc. |
| [`redisVersion`](#parameter-redisversion) | string | Redis version. Only major version will be used in PUT/PATCH request with current valid values: (4, 6). |
| [`replicasPerMaster`](#parameter-replicaspermaster) | int | The number of replicas to be created per primary. |
| [`replicasPerPrimary`](#parameter-replicasperprimary) | int | The number of replicas to be created per primary. Needs to be the same as replicasPerMaster for a Premium Cluster Cache. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`shardCount`](#parameter-shardcount) | int | The number of shards to be created on a Premium Cluster Cache. |
| [`skuName`](#parameter-skuname) | string | The type of Redis cache to deploy. |
| [`staticIP`](#parameter-staticip) | string | Static IP address. Optionally, may be specified when deploying a Redis cache inside an existing Azure Virtual Network; auto assigned by default. |
| [`subnetResourceId`](#parameter-subnetresourceid) | string | The full resource ID of a subnet in a virtual network to deploy the Redis cache in. |
| [`tags`](#parameter-tags) | object | Resource tags. |
| [`tenantSettings`](#parameter-tenantsettings) | object | A dictionary of tenant settings. |
| [`zonalAllocationPolicy`](#parameter-zonalallocationpolicy) | string | Specifies how availability zones are allocated to the Redis cache. "Automatic" enables zone redundancy and Azure will automatically select zones. "UserDefined" will select availability zones passed in by you using the "availabilityZones" parameter. "NoZones" will produce a non-zonal cache. Only applicable when zoneRedundant is true. |
| [`zoneRedundant`](#parameter-zoneredundant) | bool | When true, replicas will be provisioned in availability zones specified in the zones parameter.<p><p>Setting this parameter to false will make the resource non-compliant for production workloads (drcp-redis-09). [Policy: drcp-redis-09]<p> |

### Parameter: `name`

The name of the Redis cache resource.

- Required: Yes
- Type: string

### Parameter: `accessPolicies`

Array of access policies to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-accesspoliciesname) | string | Name of the access policy. |
| [`permissions`](#parameter-accesspoliciespermissions) | string | Permissions associated with the access policy. |

### Parameter: `accessPolicies.name`

Name of the access policy.

- Required: Yes
- Type: string

### Parameter: `accessPolicies.permissions`

Permissions associated with the access policy.

- Required: Yes
- Type: string

### Parameter: `accessPolicyAssignments`

Array of access policy assignments.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`accessPolicyName`](#parameter-accesspolicyassignmentsaccesspolicyname) | string | Name of the access policy to be assigned. |
| [`objectId`](#parameter-accesspolicyassignmentsobjectid) | string | Object id to which the access policy will be assigned. |
| [`objectIdAlias`](#parameter-accesspolicyassignmentsobjectidalias) | string | Alias for the target object id. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-accesspolicyassignmentsname) | string | The name of the Access Policy Assignment. |

### Parameter: `accessPolicyAssignments.accessPolicyName`

Name of the access policy to be assigned.

- Required: Yes
- Type: string

### Parameter: `accessPolicyAssignments.objectId`

Object id to which the access policy will be assigned.

- Required: Yes
- Type: string

### Parameter: `accessPolicyAssignments.objectIdAlias`

Alias for the target object id.

- Required: Yes
- Type: string

### Parameter: `accessPolicyAssignments.name`

The name of the Access Policy Assignment.

- Required: No
- Type: string

### Parameter: `availabilityZones`

If the zoneRedundant parameter is true, replicas will be provisioned in the availability zones specified here. Otherwise, the service will choose where replicas are deployed.

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    1
    2
    3
  ]
  ```
- Allowed:
  ```Bicep
  [
    1
    2
    3
  ]
  ```

### Parameter: `capacity`

The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4).

- Required: No
- Type: int
- Default: `1`
- Allowed:
  ```Bicep
  [
    0
    1
    2
    3
    4
    5
    6
  ]
  ```

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.<p><p>Currently known available log categories for Microsoft.Cache/redis are:<p>'ConnectedClientList'<p>

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

### Parameter: `disableAccessKeyAuthentication`

Disable authentication via access keys.<p><p>Setting this parameter to false will make the resource non-compliant (drcp-redis-05). [Policy: drcp-redis-05]<p>

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableNonSslPort`

Specifies whether the non-ssl Redis server port (6379) is enabled.<p><p>Setting this parameter to true will make the resource non-compliant (drcp-redis-07). [Policy: drcp-redis-07]<p>

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `firewallRules`

The firewall rules of the Redis Cache.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`endIP`](#parameter-firewallrulesendip) | string | The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress. Use value '0.0.0.0' for all Azure-internal IP addresses. |
| [`name`](#parameter-firewallrulesname) | string | The name of the Redis Cache Firewall Rule. |
| [`startIP`](#parameter-firewallrulesstartip) | string | The start IP address of the firewall rule. Must be IPv4 format. Use value '0.0.0.0' for all Azure-internal IP addresses. |

### Parameter: `firewallRules.endIP`

The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress. Use value '0.0.0.0' for all Azure-internal IP addresses.

- Required: Yes
- Type: string

### Parameter: `firewallRules.name`

The name of the Redis Cache Firewall Rule.

- Required: Yes
- Type: string

### Parameter: `firewallRules.startIP`

The start IP address of the firewall rule. Must be IPv4 format. Use value '0.0.0.0' for all Azure-internal IP addresses.

- Required: Yes
- Type: string

### Parameter: `geoReplicationObject`

The geo-replication settings of the service. Requires a Premium SKU. Geo-replication is not supported on a cache with multiple replicas per primary. Secondary cache VM Size must be same or higher as compared to the primary cache VM Size. Geo-replication between a vnet and non vnet cache (and vice-a-versa) not supported.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`linkedRedisCacheResourceId`](#parameter-georeplicationobjectlinkedrediscacheresourceid) | string | The resource ID of the linked server. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`linkedRedisCacheLocation`](#parameter-georeplicationobjectlinkedrediscachelocation) | string | The location of the linked server. If not provided, the location of the primary Redis cache is used. |
| [`name`](#parameter-georeplicationobjectname) | string | The name of the secondary Redis cache. If not provided, the primary Redis cache name is used. |

### Parameter: `geoReplicationObject.linkedRedisCacheResourceId`

The resource ID of the linked server.

- Required: Yes
- Type: string

### Parameter: `geoReplicationObject.linkedRedisCacheLocation`

The location of the linked server. If not provided, the location of the primary Redis cache is used.

- Required: No
- Type: string

### Parameter: `geoReplicationObject.name`

The name of the secondary Redis cache. If not provided, the primary Redis cache name is used.

- Required: No
- Type: string

### Parameter: `location`

The location to deploy the Redis cache service.

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

### Parameter: `minimumTlsVersion`

Requires clients to use a specified TLS version (or higher) to connect.<p><p>Setting this parameter to less than 1.2 will make the resource non-compliant (drcp-redis-08). [Policy: drcp-redis-08]<p>

- Required: No
- Type: string
- Default: `'1.2'`

### Parameter: `privateEndpoints`

Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. [Policy: drcp-redis-04] [Policy: drcp-sub-07]

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

Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.<p><p>Setting this parameter to Enabled will make the resource non-compliant (drcp-redis-02). [Policy: drcp-redis-02]<p>

- Required: No
- Type: string
- Default: `'Disabled'`

### Parameter: `redisConfiguration`

All Redis Settings. Few possible keys: rdb-backup-enabled,rdb-storage-connection-string,rdb-backup-frequency,maxmemory-delta,maxmemory-policy,notify-keyspace-events,maxmemory-samples,slowlog-log-slower-than,slowlog-max-len,list-max-ziplist-entries,list-max-ziplist-value,hash-max-ziplist-entries,hash-max-ziplist-value,set-max-intset-entries,zset-max-ziplist-entries,zset-max-ziplist-value etc.

- Required: No
- Type: object

### Parameter: `redisVersion`

Redis version. Only major version will be used in PUT/PATCH request with current valid values: (4, 6).

- Required: No
- Type: string
- Default: `'6'`

### Parameter: `replicasPerMaster`

The number of replicas to be created per primary.

- Required: No
- Type: int
- Default: `3`
- MinValue: 1

### Parameter: `replicasPerPrimary`

The number of replicas to be created per primary. Needs to be the same as replicasPerMaster for a Premium Cluster Cache.

- Required: No
- Type: int
- Default: `3`
- MinValue: 1

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Redis Cache Contributor'`

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

### Parameter: `shardCount`

The number of shards to be created on a Premium Cluster Cache.

- Required: No
- Type: int
- MinValue: 1

### Parameter: `skuName`

The type of Redis cache to deploy.

- Required: No
- Type: string
- Default: `'Premium'`
- Allowed:
  ```Bicep
  [
    'Basic'
    'Premium'
    'Standard'
  ]
  ```

### Parameter: `staticIP`

Static IP address. Optionally, may be specified when deploying a Redis cache inside an existing Azure Virtual Network; auto assigned by default.

- Required: No
- Type: string

### Parameter: `subnetResourceId`

The full resource ID of a subnet in a virtual network to deploy the Redis cache in.

- Required: No
- Type: string

### Parameter: `tags`

Resource tags.

- Required: No
- Type: object

### Parameter: `tenantSettings`

A dictionary of tenant settings.

- Required: No
- Type: object
- Default: `{}`

### Parameter: `zonalAllocationPolicy`

Specifies how availability zones are allocated to the Redis cache. "Automatic" enables zone redundancy and Azure will automatically select zones. "UserDefined" will select availability zones passed in by you using the "availabilityZones" parameter. "NoZones" will produce a non-zonal cache. Only applicable when zoneRedundant is true.

- Required: No
- Type: string

### Parameter: `zoneRedundant`

When true, replicas will be provisioned in availability zones specified in the zones parameter.<p><p>Setting this parameter to false will make the resource non-compliant for production workloads (drcp-redis-09). [Policy: drcp-redis-09]<p>

- Required: No
- Type: bool
- Default: `True`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `hostName` | string | Redis hostname. |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the Redis Cache. |
| `resourceGroupName` | string | The name of the resource group the Redis Cache was created in. |
| `resourceId` | string | The resource ID of the Redis Cache. |
| `sslPort` | int | Redis SSL port. |
| `subnetResourceId` | string | The full resource ID of a subnet in a virtual network where the Redis Cache was deployed in. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `bicep/res/network/private-endpoint` | Local reference |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
