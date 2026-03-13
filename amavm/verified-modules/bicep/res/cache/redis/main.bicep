metadata name = 'Redis Cache'
metadata description = 'This module deploys an Azure Cache for Redis.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20250308'
metadata compliance = '''Compliant usage of Azure Cache for Redis requires:
- publicNetworkAccess: 'Disabled' (drcp-redis-02)
- disableAccessKeyAuthentication: true -- Entra ID auth enforced (drcp-redis-05)
- enableNonSslPort: false -- TLS access enforced (drcp-redis-07)
- minimumTlsVersion: '1.2' (drcp-redis-08)
- zoneRedundant: true -- for production workloads (drcp-redis-09)
- skuName: 'Premium' -- required for PE and zone redundancy
- privateEndpoints with private DNS zones (drcp-redis-04)
'''

// ================ //
// Parameters       //
// ================ //
@description('Required. The name of the Redis cache resource.')
param name string

@description('Optional. The location to deploy the Redis cache service.')
param location string = resourceGroup().location

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Resource tags.')
param tags object?

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType?

@description('''Optional. Disable authentication via access keys.

Setting this parameter to false will make the resource non-compliant (drcp-redis-05). [Policy: drcp-redis-05]
''')
param disableAccessKeyAuthentication bool = true

@description('''Optional. Specifies whether the non-ssl Redis server port (6379) is enabled.

Setting this parameter to true will make the resource non-compliant (drcp-redis-07). [Policy: drcp-redis-07]
''')
param enableNonSslPort bool = false

@description('''Optional. Requires clients to use a specified TLS version (or higher) to connect.

Setting this parameter to less than 1.2 will make the resource non-compliant (drcp-redis-08). [Policy: drcp-redis-08]
''')
param minimumTlsVersion resourceInput<'Microsoft.Cache/redis@2024-11-01'>.properties.minimumTlsVersion = '1.2'

@description('''Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set.

Setting this parameter to Enabled will make the resource non-compliant (drcp-redis-02). [Policy: drcp-redis-02]
''')
param publicNetworkAccess resourceInput<'Microsoft.Cache/redis@2024-11-01'>.properties.publicNetworkAccess = 'Disabled'

@description('Optional. All Redis Settings. Few possible keys: rdb-backup-enabled,rdb-storage-connection-string,rdb-backup-frequency,maxmemory-delta,maxmemory-policy,notify-keyspace-events,maxmemory-samples,slowlog-log-slower-than,slowlog-max-len,list-max-ziplist-entries,list-max-ziplist-value,hash-max-ziplist-entries,hash-max-ziplist-value,set-max-intset-entries,zset-max-ziplist-entries,zset-max-ziplist-value etc.')
param redisConfiguration resourceInput<'Microsoft.Cache/redis@2024-11-01'>.properties.redisConfiguration?

@description('Optional. Redis version. Only major version will be used in PUT/PATCH request with current valid values: (4, 6).')
param redisVersion resourceInput<'Microsoft.Cache/redis@2024-11-01'>.properties.redisVersion = '6'

@minValue(1)
@description('Optional. The number of replicas to be created per primary.')
param replicasPerMaster int = 3

@minValue(1)
@description('Optional. The number of replicas to be created per primary. Needs to be the same as replicasPerMaster for a Premium Cluster Cache.')
param replicasPerPrimary int = 3

@minValue(1)
@description('Optional. The number of shards to be created on a Premium Cluster Cache.')
param shardCount int?

@allowed([
  0
  1
  2
  3
  4
  5
  6
])
@description('Optional. The size of the Redis cache to deploy. Valid values: for C (Basic/Standard) family (0, 1, 2, 3, 4, 5, 6), for P (Premium) family (1, 2, 3, 4).')
param capacity int = 1

@allowed([
  'Basic'
  'Premium'
  'Standard'
])
@description('Optional. The type of Redis cache to deploy.')
param skuName string = 'Premium'

@description('Optional. Static IP address. Optionally, may be specified when deploying a Redis cache inside an existing Azure Virtual Network; auto assigned by default.')
param staticIP string?

@description('Optional. The full resource ID of a subnet in a virtual network to deploy the Redis cache in.')
param subnetResourceId string?

@description('Optional. A dictionary of tenant settings.')
param tenantSettings object = {}

@description('''Optional. When true, replicas will be provisioned in availability zones specified in the zones parameter.

Setting this parameter to false will make the resource non-compliant for production workloads (drcp-redis-09). [Policy: drcp-redis-09]
''')
param zoneRedundant bool = true

@description('Optional. If the zoneRedundant parameter is true, replicas will be provisioned in the availability zones specified here. Otherwise, the service will choose where replicas are deployed.')
@allowed([1, 2, 3])
param availabilityZones int[] = [1, 2, 3]

@description('Optional. Specifies how availability zones are allocated to the Redis cache. "Automatic" enables zone redundancy and Azure will automatically select zones. "UserDefined" will select availability zones passed in by you using the "availabilityZones" parameter. "NoZones" will produce a non-zonal cache. Only applicable when zoneRedundant is true.')
param zonalAllocationPolicy resourceInput<'Microsoft.Cache/redis@2024-11-01'>.properties.zonalAllocationPolicy?

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. [Policy: drcp-redis-04] [Policy: drcp-sub-07]')
param privateEndpoints privateEndpointType

@description('Optional. The geo-replication settings of the service. Requires a Premium SKU. Geo-replication is not supported on a cache with multiple replicas per primary. Secondary cache VM Size must be same or higher as compared to the primary cache VM Size. Geo-replication between a vnet and non vnet cache (and vice-a-versa) not supported.')
param geoReplicationObject geoReplicationType?

@description('''Optional. The diagnostic settings of the service.

Currently known available log categories for Microsoft.Cache/redis are:
'ConnectedClientList'
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. Array of access policies to create.')
param accessPolicies accessPolicyType[]?

@description('Optional. Array of access policy assignments.')
param accessPolicyAssignments accessPolicyAssignmentType[]?

@description('Optional. The firewall rules of the Redis Cache.')
param firewallRules firewallRuleType[]?

// =========== //
// Variables   //
// =========== //
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Redis Cache Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'e0f68234-74aa-48ed-b826-c38b57376e17'
  )
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({ telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion }, tags ?? {})

var zones = skuName == 'Premium'
  ? zoneRedundant
      ? !empty(availabilityZones) ? availabilityZones : pickZones('Microsoft.Cache', 'redis', location, 3)
      : []
  : []

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'ConnectedClientList'
]

var defaultLogCategories = [
  for category in defaultLogCategoryNames: {
    category: category
  }
]

// ============ //
// Dependencies //
// ============ //
#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.cache-redis.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource redis 'Microsoft.Cache/redis@2024-11-01' = {
  name: name
  location: location
  tags: finalTags
  identity: identity
  properties: {
    disableAccessKeyAuthentication: disableAccessKeyAuthentication
    enableNonSslPort: enableNonSslPort
    minimumTlsVersion: minimumTlsVersion
    publicNetworkAccess: publicNetworkAccess
    redisConfiguration: redisConfiguration
    redisVersion: redisVersion
    replicasPerMaster: skuName == 'Premium' ? replicasPerMaster : null
    replicasPerPrimary: skuName == 'Premium' ? replicasPerPrimary : null
    shardCount: skuName == 'Premium' ? shardCount : null // Not supported in free tier
    sku: {
      capacity: capacity
      family: skuName == 'Premium' ? 'P' : 'C'
      name: skuName
    }
    staticIP: staticIP
    subnetId: subnetResourceId
    tenantSettings: tenantSettings
    zonalAllocationPolicy: skuName == 'Premium' && zoneRedundant ? zonalAllocationPolicy : null
  }
  zones: zones
}

// Deploy access policies
module redis_accessPolicies 'access-policy/main.bicep' = [
  for (policy, index) in (accessPolicies ?? []): {
    name: '${uniqueString(deployment().name, location)}-redis-AccessPolicy-${index}'
    params: {
      redisCacheName: redis.name
      name: policy.name
      permissions: policy.permissions
    }
  }
]

// Deploy access policy assignments
module redis_policyAssignments 'access-policy-assignment/main.bicep' = [
  for (assignment, index) in (accessPolicyAssignments ?? []): {
    name: '${uniqueString(deployment().name, location)}-redis-PolicyAssignment-${index}'
    params: {
      redisCacheName: redis.name
      name: assignment.?name
      objectId: assignment.objectId
      objectIdAlias: assignment.objectIdAlias
      accessPolicyName: assignment.accessPolicyName
    }
    dependsOn: [
      redis_accessPolicies // Ensure policies exist before assigning them
    ]
  }
]

resource redis_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: redis
}

#disable-next-line use-recent-api-versions
resource redis_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: redis
  }
]

resource redis_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(redis.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      #disable-next-line use-safe-access
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: redis
  }
]

module redis_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location, name)}-redis-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(redis.id, '/'))}-${privateEndpoint.?service ?? 'redisCache'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(redis.id, '/'))}-${privateEndpoint.?service ?? 'redisCache'}-${index}'
              properties: {
                privateLinkServiceId: redis.id
                groupIds: [
                  privateEndpoint.?service ?? 'redisCache'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(redis.id, '/'))}-${privateEndpoint.?service ?? 'redisCache'}-${index}'
              properties: {
                privateLinkServiceId: redis.id
                groupIds: [
                  privateEndpoint.?service ?? 'redisCache'
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
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? finalTags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

module redis_firewallRules 'firewall-rule/main.bicep' = [
  for (firewallRule, index) in (firewallRules ?? []): {
    name: '${uniqueString(deployment().name, location)}-redis-FirewallRules-${index}'
    params: {
      name: firewallRule.name
      redisCacheName: redis.name
      startIP: firewallRule.startIP
      endIP: firewallRule.endIP
    }
  }
]

module redis_geoReplication 'linked-servers/main.bicep' = if (!empty(geoReplicationObject)) {
  name: '${uniqueString(deployment().name, location)}-redis-LinkedServer'
  params: {
    redisCacheName: redis.name
    name: geoReplicationObject!.?name
    linkedRedisCacheResourceId: geoReplicationObject!.linkedRedisCacheResourceId
    linkedRedisCacheLocation: geoReplicationObject!.?linkedRedisCacheLocation
  }
  dependsOn: redis_privateEndpoints
}

// =========== //
// Outputs     //
// =========== //
@description('The name of the Redis Cache.')
output name string = redis.name

@description('The resource ID of the Redis Cache.')
output resourceId string = redis.id

@description('The name of the resource group the Redis Cache was created in.')
output resourceGroupName string = resourceGroup().name

@description('Redis hostname.')
output hostName string = redis.properties.hostName

@description('Redis SSL port.')
output sslPort int = redis.properties.sslPort

@description('The full resource ID of a subnet in a virtual network where the Redis Cache was deployed in.')
output subnetResourceId string = !empty(subnetResourceId) ? redis.properties.subnetId : ''

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = redis.?identity.?principalId

@description('The location the resource was deployed into.')
output location string = redis.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (publicNetworkAccess != 'Disabled' || !disableAccessKeyAuthentication || enableNonSslPort || minimumTlsVersion != '1.2' || (skuName == 'Premium' && !zoneRedundant))

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

type accessPolicyType = {
  @description('Required. Name of the access policy.')
  name: string
  @description('Required. Permissions associated with the access policy.')
  permissions: string
}

type accessPolicyAssignmentType = {
  @description('Optional. The name of the Access Policy Assignment.')
  name: string?
  @description('Required. Object id to which the access policy will be assigned.')
  objectId: string
  @description('Required. Alias for the target object id.')
  objectIdAlias: string
  @description('Required. Name of the access policy to be assigned.')
  accessPolicyName: string
}

@description('The type of a firewall rule.')
type firewallRuleType = {
  @description('Required. The name of the Redis Cache Firewall Rule.')
  name: string

  @description('Required. The start IP address of the firewall rule. Must be IPv4 format. Use value \'0.0.0.0\' for all Azure-internal IP addresses.')
  startIP: string

  @description('Required. The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress. Use value \'0.0.0.0\' for all Azure-internal IP addresses.')
  endIP: string
}

@description('The type of a linked server for geo-replication.')
type geoReplicationType = {
  @description('Optional. The name of the secondary Redis cache. If not provided, the primary Redis cache name is used.')
  name: string?

  @description('Required. The resource ID of the linked server.')
  linkedRedisCacheResourceId: string

  @description('Optional. The location of the linked server. If not provided, the location of the primary Redis cache is used.')
  linkedRedisCacheLocation: string?
}
