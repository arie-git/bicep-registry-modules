metadata name = 'Azure Cosmos DB account'
metadata description = 'This module deploys an Azure Cosmos DB account. Only the NoSQL API is enabled per company policy.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20250308'
metadata compliance = '''Compliant usage of Azure Cosmos DB requires:
- disableLocalAuth: true
- disableKeyBasedMetadataWriteAccess: true
- publicNetworkAccess: 'Disabled'
- minimumTlsVersion: 'Tls12'
- locations[*].isZoneRedundant: true (production)
- Only NoSQL capability (Mongo, Cassandra, Table, Gremlin disabled)
'''

// ================ //
// Parameters       //
// ================ //

@description('Required. The name of the account.')
param name string

@description('Optional. Defaults to the current resource group scope location. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags for the resource.')
param tags object?

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType?

@description('Optional. The offer type for the account. Defaults to "Standard".')
@allowed([
  'Standard'
])
param databaseAccountOfferType string = 'Standard'

@description('Optional. The set of locations enabled for the account. Defaults to the location where the account is deployed. [Policy: drcp-cosmos-10]')
param failoverLocations failoverLocationType[]?

@description('Optional. Indicates whether the single-region account is zone redundant. Defaults to true. This property is ignored for multi-region accounts. [Policy: drcp-cosmos-10]')
param zoneRedundant bool = true

@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
@description('Optional. The default consistency level of the account. Defaults to "Session".')
param defaultConsistencyLevel string = 'Session'

@description('Optional. Opt-out of local authentication and ensure that only Microsoft Entra can be used exclusively for authentication. Defaults to true. [Policy: drcp-cosmos-02]')
param disableLocalAuthentication bool = true

@description('Optional. Flag to indicate whether to enable storage analytics. Defaults to false.')
param enableAnalyticalStorage bool = false

@description('Optional. Enable automatic failover for regions. Defaults to true.')
param enableAutomaticFailover bool = true

@description('Optional. Flag to indicate whether "Free Tier" is enabled. Defaults to false.')
param enableFreeTier bool = false

@description('Optional. Enables the account to write in multiple locations. Periodic backup must be used if enabled. Defaults to false.')
param enableMultipleWriteLocations bool = false

@description('Optional. Disable write operations on metadata resources (databases, containers, throughput) via account keys. Defaults to true. [Policy: drcp-cosmos-03]')
param disableKeyBasedMetadataWriteAccess bool = true

@minValue(1)
@maxValue(2147483647)
@description('Optional. The maximum stale requests. Required for "BoundedStaleness" consistency level. Valid ranges, Single Region: 10 to 1000000. Multi Region: 100000 to 1000000. Defaults to 100000.')
param maxStalenessPrefix int = 100000

@minValue(5)
@maxValue(86400)
@description('Optional. The maximum lag time in minutes. Required for "BoundedStaleness" consistency level. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400. Defaults to 300.')
param maxIntervalInSeconds int = 300

// COMMENTED OUT: serverVersion is MongoDB-only, which is not allowed per company policy (NoSQL only).
// @description('Optional. Specifies the MongoDB server version to use if using Azure Cosmos DB for MongoDB RU. Defaults to "4.2".')
// @allowed([
//   '3.2'
//   '3.6'
//   '4.0'
//   '4.2'
//   '5.0'
//   '6.0'
//   '7.0'
// ])
// param serverVersion string = '4.2'

@description('Optional. Configuration for databases when using Azure Cosmos DB for NoSQL.')
param sqlDatabases sqlDatabaseType[]?

// COMMENTED OUT: Future feature -- MongoDB databases are not allowed per company policy (NoSQL only).
// @description('Optional. Configuration for databases when using Azure Cosmos DB for MongoDB RU.')
// param mongodbDatabases mongoDbType[]?

// COMMENTED OUT: Future feature -- Gremlin databases are not allowed per company policy (NoSQL only).
// @description('Optional. Configuration for databases when using Azure Cosmos DB for Apache Gremlin.')
// param gremlinDatabases gremlinDatabaseType[]?

// COMMENTED OUT: Future feature -- Tables are not allowed per company policy (NoSQL only).
// @description('Optional. Configuration for databases when using Azure Cosmos DB for Table.')
// param tables tableType[]?

// COMMENTED OUT: Future feature -- Cassandra keyspaces are not allowed per company policy (NoSQL only).
// @description('Optional. Configuration for keyspaces when using Azure Cosmos DB for Apache Cassandra.')
// param cassandraKeyspaces cassandraKeyspaceType[]?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. The total throughput limit imposed on this account in request units per second (RU/s). Default to unlimited throughput.')
param totalThroughputLimit int = -1

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. An array of control plane Azure role-based access control assignments.')
param roleAssignments roleAssignmentType

@description('Optional. Configurations for Azure Cosmos DB for NoSQL native role-based access control definitions. Allows the creations of custom role definitions.')
param sqlRoleDefinitions sqlRoleDefinitionType[]?

@description('Optional. Configurations for Azure Cosmos DB for NoSQL native role-based access control assignments.')
param sqlRoleAssignments sqlRoleAssignmentType[]?

// COMMENTED OUT: Future feature -- Cassandra role definitions are not allowed per company policy (NoSQL only).
// @description('Optional. Configurations for Azure Cosmos DB for Apache Cassandra native role-based access control definitions. Allows the creations of custom role definitions.')
// param cassandraRoleDefinitions cassandraRoleDefinitionType[]?

// COMMENTED OUT: Future feature -- Cassandra role assignments are not allowed per company policy (NoSQL only).
// @description('Optional. Azure Cosmos DB for Apache Cassandra native data plane role-based access control assignments. Each assignment references a role definition unique identifier and a principal identifier.')
// param cassandraRoleAssignments cassandraStandaloneRoleAssignmentType[]?

@description('Optional. The diagnostic settings for the service.')
param diagnosticSettings diagnosticSettingType

@allowed([
  // COMMENTED OUT: Non-NoSQL capabilities are not allowed per company policy.
  // 'EnableCassandra'
  // 'EnableTable'
  // 'EnableGremlin'
  // 'EnableMongo'
  'DisableRateLimitingResponses'
  'EnableServerless'
  'EnableNoSQLVectorSearch'
  'EnableNoSQLFullTextSearch'
  'EnableMaterializedViews'
  'DeleteAllItemsByPartitionKey'
])
@description('Optional. A list of Azure Cosmos DB specific capabilities for the account. [Policy: drcp-cosmos-06]')
param capabilitiesToAdd string[]?

@allowed([
  'Periodic'
  'Continuous'
])
@description('Optional. Configures the backup mode. Periodic backup must be used if multiple write locations are used. Defaults to "Continuous".')
param backupPolicyType string = 'Continuous'

@allowed([
  'Continuous30Days'
  'Continuous7Days'
])
@description('Optional. Configuration values to specify the retention period for continuous mode backup. Default to "Continuous30Days".')
param backupPolicyContinuousTier string = 'Continuous30Days'

@minValue(60)
@maxValue(1440)
@description('Optional. An integer representing the interval in minutes between two backups. This setting only applies to the periodic backup type. Defaults to 240.')
param backupIntervalInMinutes int = 240

@minValue(2)
@maxValue(720)
@description('Optional. An integer representing the time (in hours) that each backup is retained. This setting only applies to the periodic backup type. Defaults to 8.')
param backupRetentionIntervalInHours int = 8

@allowed([
  'Geo'
  'Local'
  'Zone'
])
@description('Optional. Setting that indicates the type of backup residency. This setting only applies to the periodic backup type. Defaults to "Local".')
param backupStorageRedundancy string = 'Local'

@description('Optional. Configuration details for private endpoints. For security reasons, it is advised to use private endpoints whenever possible. [Policy: drcp-sub-07]')
param privateEndpoints privateEndpointType

@description('Optional. The network configuration of this module. Defaults to `{ ipRules: [], virtualNetworkRules: [], publicNetworkAccess: \'Disabled\' }`. [Policy: drcp-cosmos-01]')
param networkRestrictions networkRestrictionType = {
  ipRules: []
  virtualNetworkRules: []
  publicNetworkAccess: 'Disabled'
}

@allowed([
  'Tls12'
])
@description('Optional. Setting that indicates the minimum allowed TLS version. Defaults to "Tls12" (TLS 1.2). [Policy: drcp-cosmos-05]')
param minimumTlsVersion string = 'Tls12'

@description('Optional. Flag to indicate enabling/disabling of Burst Capacity feature on the account. Cannot be enabled for serverless accounts.')
param enableBurstCapacity bool = true

// COMMENTED OUT: enableCassandraConnector is Cassandra-only, which is not allowed per company policy (NoSQL only).
// @description('Optional. Enables the cassandra connector on the Cosmos DB C* account.')
// param enableCassandraConnector bool = false

@description('Optional. Flag to enable/disable the \'Partition Merge\' feature on the account.')
param enablePartitionMerge bool = false

@description('Optional. Flag to enable/disable the \'PerRegionPerPartitionAutoscale\' feature on the account.')
param enablePerRegionPerPartitionAutoscale bool = false

@description('Optional. Analytical storage specific properties.')
param analyticalStorageConfiguration object?

@description('Optional. The CORS policy for the Cosmos DB database account.')
param cors object?

@description('Optional. The default identity for accessing key vault used in features like customer managed keys. Use `FirstPartyIdentity` to use the tenant-level CosmosDB enterprise application. The default identity needs to be explicitly set by the users.')
param defaultIdentity defaultIdentityType = {
  name: 'FirstPartyIdentity'
}

@description('Optional. The customer managed key definition. If specified, the parameter `defaultIdentity` must be configured as well.')
param customerManagedKey customerManagedKeyType

// =========== //
// Variables   //
// =========== //

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Cosmos DB Account Reader Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'fbdf93bf-df7d-467e-a4d2-9458aa1360c8')
  'Cosmos DB Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '230815da-be43-4aae-9cb4-875f7bd000aa')
  CosmosBackupOperator: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'db7b14f2-5adf-42da-9f96-f2ee17bab5cb')
  CosmosRestoreOperator: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5432c526-bc82-444a-b7ba-57c5b0b5b34f')
  'DocumentDB Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5bd9cd88-fe45-4216-938b-f97437e15450')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion}, tags ?? {})

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'DataPlaneRequests'
  'MongoRequests'
  'QueryRuntimeStatistics'
  'PartitionKeyStatistics'
  'PartitionKeyRUConsumption'
  'ControlPlaneRequests'
  'TableApiRequests'
  'GremlinRequests'
  'CassandraRequests'
]

var defaultLogCategories = [for category in defaultLogCategoryNames: {
  category: category
}]

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(formattedUserAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(formattedUserAssignedIdentities) ? 'UserAssigned' : null)
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

// ============ //
// Dependencies //
// ============ //

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.documentdb-databaseaccount.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}',
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

var isHSMManagedCMK = split(customerManagedKey.?keyVaultResourceId ?? '', '/')[?7] == 'managedHSMs'
resource cMKKeyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
  name: last(split((customerManagedKey!.keyVaultResourceId!), '/'))
  scope: resourceGroup(
    split(customerManagedKey!.keyVaultResourceId!, '/')[2],
    split(customerManagedKey!.keyVaultResourceId!, '/')[4]
  )

  resource cMKKey 'keys@2024-11-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
    name: customerManagedKey!.keyName
  }
}

// Only NoSQL is allowed -- kind is always 'GlobalDocumentDB'
resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: name
  location: location
  tags: finalTags
  identity: identity
  kind: 'GlobalDocumentDB' // Only NoSQL is allowed per company policy
  properties: {
    enableBurstCapacity: !contains((capabilitiesToAdd ?? []), 'EnableServerless') ? enableBurstCapacity : false
    databaseAccountOfferType: databaseAccountOfferType
    analyticalStorageConfiguration: analyticalStorageConfiguration
    defaultIdentity: !empty(defaultIdentity) && defaultIdentity.?name != 'UserAssignedIdentity'
      ? defaultIdentity!.name
      : 'UserAssignedIdentity=${defaultIdentity!.?resourceId}'
    keyVaultKeyUri: !empty(customerManagedKey)
      ? !isHSMManagedCMK
          ? '${cMKKeyVault::cMKKey!.properties.keyUri}'
          : 'https://${last(split((customerManagedKey!.keyVaultResourceId), '/'))}.managedhsm.azure.net/keys/${customerManagedKey!.keyName}'
      : null
    enablePartitionMerge: enablePartitionMerge
    enablePerRegionPerPartitionAutoscale: enablePerRegionPerPartitionAutoscale
    backupPolicy: {
      #disable-next-line BCP225 // Value has a default
      type: backupPolicyType
      ...(backupPolicyType == 'Continuous'
        ? {
            continuousModeProperties: {
              tier: backupPolicyContinuousTier
            }
          }
        : {})
      ...(backupPolicyType == 'Periodic'
        ? {
            periodicModeProperties: {
              backupIntervalInMinutes: backupIntervalInMinutes
              backupRetentionIntervalInHours: backupRetentionIntervalInHours
              backupStorageRedundancy: backupStorageRedundancy
            }
          }
        : {})
    }
    capabilities: map(capabilitiesToAdd ?? [], capability => {
      name: capability
    })
    ...(!empty(cors) ? { cors: cors } : {}) // Cors can only be provided if not null/empty
    // Cassandra connector removed -- not applicable for NoSQL-only
    minimalTlsVersion: minimumTlsVersion
    capacity: {
      totalThroughputLimit: totalThroughputLimit
    }
    publicNetworkAccess: networkRestrictions.?publicNetworkAccess ?? 'Disabled'
    locations: !empty(failoverLocations)
      ? map(failoverLocations!, failoverLocation => {
          failoverPriority: failoverLocation.failoverPriority
          locationName: failoverLocation.locationName
          isZoneRedundant: failoverLocation.?isZoneRedundant ?? true
        })
      : [
          {
            failoverPriority: 0
            locationName: location
            isZoneRedundant: zoneRedundant
          }
        ]
    // NoSQL common properties -- always applied since we only support NoSQL
    consistencyPolicy: {
      defaultConsistencyLevel: defaultConsistencyLevel
      ...(defaultConsistencyLevel == 'BoundedStaleness'
        ? {
            maxStalenessPrefix: maxStalenessPrefix
            maxIntervalInSeconds: maxIntervalInSeconds
          }
        : {})
    }
    enableMultipleWriteLocations: enableMultipleWriteLocations
    ipRules: map(networkRestrictions.?ipRules ?? [], ipRule => {
      ipAddressOrRange: ipRule
    })
    virtualNetworkRules: map(networkRestrictions.?virtualNetworkRules ?? [], rule => {
      id: rule.subnetResourceId
      ignoreMissingVNetServiceEndpoint: false
    })
    networkAclBypass: networkRestrictions.?networkAclBypass ?? 'None'
    networkAclBypassResourceIds: networkRestrictions.?networkAclBypassResourceIds
    isVirtualNetworkFilterEnabled: !empty(networkRestrictions.?ipRules) || !empty(networkRestrictions.?virtualNetworkRules)
    enableFreeTier: enableFreeTier
    enableAutomaticFailover: enableAutomaticFailover
    enableAnalyticalStorage: enableAnalyticalStorage
    // NoSQL supports Microsoft Entra authentication -- always use the disableLocalAuthentication parameter
    disableLocalAuth: disableLocalAuthentication
    disableKeyBasedMetadataWriteAccess: disableKeyBasedMetadataWriteAccess
    // MongoDB apiProperties block removed -- not applicable for NoSQL-only
  }
}

resource databaseAccount_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: databaseAccount
}

#disable-next-line use-recent-api-versions
resource databaseAccount_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: databaseAccount
  }
]

resource databaseAccount_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(databaseAccount.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: databaseAccount
  }
]

module databaseAccount_sqlDatabases 'sql-database/main.bicep' = [
  for sqlDatabase in (sqlDatabases ?? []): {
    name: '${uniqueString(deployment().name, location)}-sqldb-${sqlDatabase.name}'
    params: {
      name: sqlDatabase.name
      containers: sqlDatabase.?containers
      throughput: sqlDatabase.?throughput
      databaseAccountName: databaseAccount.name
      autoscaleSettingsMaxThroughput: sqlDatabase.?autoscaleSettingsMaxThroughput
    }
  }
]

module databaseAccount_sqlRoleDefinitions 'sql-role-definition/main.bicep' = [
  for (nosqlRoleDefinition, index) in (sqlRoleDefinitions ?? []): {
    name: '${uniqueString(deployment().name, location)}-sqlrd-${index}'
    params: {
      databaseAccountName: databaseAccount.name
      name: nosqlRoleDefinition.?name
      dataActions: nosqlRoleDefinition.dataActions
      roleName: nosqlRoleDefinition.roleName
      assignableScopes: nosqlRoleDefinition.?assignableScopes
      sqlRoleAssignments: nosqlRoleDefinition.?assignments
      enableTelemetry: false
    }
  }
]

module databaseAccount_sqlRoleAssignments 'sql-role-assignment/main.bicep' = [
  for (noSqlRoleAssignment, index) in (sqlRoleAssignments ?? []): {
    name: '${uniqueString(deployment().name)}-sqlra-${index}'
    params: {
      databaseAccountName: databaseAccount.name
      roleDefinitionIdOrName: noSqlRoleAssignment.roleDefinitionId
      principalId: noSqlRoleAssignment.principalId
      name: noSqlRoleAssignment.?name
      scope: noSqlRoleAssignment.?scope
      enableTelemetry: false
    }
    dependsOn: [
      databaseAccount_sqlDatabases
      databaseAccount_sqlRoleDefinitions
    ]
  }
]

// COMMENTED OUT: Future feature -- Cassandra role definitions are not allowed per company policy (NoSQL only).
// module databaseAccount_cassandraRoleDefinitions 'cassandra-role-definition/main.bicep' = [
//   for (cassandraRoleDefinition, index) in (cassandraRoleDefinitions ?? []): {
//     name: '${uniqueString(deployment().name, location)}-cassandra-rd-${index}'
//     params: {
//       databaseAccountName: databaseAccount.name
//       name: cassandraRoleDefinition.?name
//       roleName: cassandraRoleDefinition.roleName
//       dataActions: cassandraRoleDefinition.?dataActions
//       notDataActions: cassandraRoleDefinition.?notDataActions
//       assignableScopes: cassandraRoleDefinition.?assignableScopes
//       cassandraRoleAssignments: cassandraRoleDefinition.?assignments
//     }
//   }
// ]

// COMMENTED OUT: Future feature -- Cassandra role assignments are not allowed per company policy (NoSQL only).
// module databaseAccount_cassandraRoleAssignments 'cassandra-role-assignment/main.bicep' = [
//   for (cassandraRoleAssignment, index) in (cassandraRoleAssignments ?? []): {
//     name: '${uniqueString(deployment().name)}-cassandra-ra-${index}'
//     params: {
//       databaseAccountName: databaseAccount.name
//       roleDefinitionId: cassandraRoleAssignment.roleDefinitionId
//       principalId: cassandraRoleAssignment.principalId
//       name: cassandraRoleAssignment.?name
//       scope: cassandraRoleAssignment.?scope
//     }
//     dependsOn: [
//       databaseAccount_cassandraKeyspaces
//       databaseAccount_cassandraRoleDefinitions
//     ]
//   }
// ]

// COMMENTED OUT: Future feature -- MongoDB databases are not allowed per company policy (NoSQL only).
// module databaseAccount_mongodbDatabases 'mongodb-database/main.bicep' = [
//   for mongodbDatabase in (mongodbDatabases ?? []): {
//     name: '${uniqueString(deployment().name, location)}-mongodb-${mongodbDatabase.name}'
//     params: {
//       databaseAccountName: databaseAccount.name
//       name: mongodbDatabase.name
//       tags: mongodbDatabase.?tags ?? finalTags
//       collections: mongodbDatabase.?collections
//       throughput: mongodbDatabase.?throughput
//       autoscaleSettings: mongodbDatabase.?autoscaleSettings
//     }
//   }
// ]

// COMMENTED OUT: Future feature -- Gremlin databases are not allowed per company policy (NoSQL only).
// module databaseAccount_gremlinDatabases 'gremlin-database/main.bicep' = [
//   for gremlinDatabase in (gremlinDatabases ?? []): {
//     name: '${uniqueString(deployment().name, location)}-gremlin-${gremlinDatabase.name}'
//     params: {
//       databaseAccountName: databaseAccount.name
//       name: gremlinDatabase.name
//       tags: gremlinDatabase.?tags ?? finalTags
//       graphs: gremlinDatabase.?graphs
//       maxThroughput: gremlinDatabase.?maxThroughput
//       throughput: gremlinDatabase.?throughput
//     }
//   }
// ]

// COMMENTED OUT: Future feature -- Tables are not allowed per company policy (NoSQL only).
// module databaseAccount_tables 'table/main.bicep' = [
//   for table in (tables ?? []): {
//     name: '${uniqueString(deployment().name, location)}-table-${table.name}'
//     params: {
//       databaseAccountName: databaseAccount.name
//       name: table.name
//       tags: table.?tags ?? finalTags
//       maxThroughput: table.?maxThroughput
//       throughput: table.?throughput
//     }
//   }
// ]

// COMMENTED OUT: Future feature -- Cassandra keyspaces are not allowed per company policy (NoSQL only).
// module databaseAccount_cassandraKeyspaces 'cassandra-keyspace/main.bicep' = [
//   for cassandraKeyspace in (cassandraKeyspaces ?? []): {
//     name: '${uniqueString(deployment().name, location)}-cassandradb-${cassandraKeyspace.name}'
//     params: {
//       databaseAccountName: databaseAccount.name
//       name: cassandraKeyspace.name
//       tags: cassandraKeyspace.?tags ?? finalTags
//       tables: cassandraKeyspace.?tables
//       views: cassandraKeyspace.?views
//       autoscaleSettingsMaxThroughput: cassandraKeyspace.?autoscaleSettingsMaxThroughput
//       throughput: cassandraKeyspace.?throughput
//     }
//   }
// ]

module databaseAccount_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location, name)}-dbAccount-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(databaseAccount.id, '/'))}-pep-${privateEndpoint.?service ?? 'Sql'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(databaseAccount.id, '/'))}-${privateEndpoint.?service ?? 'Sql'}-${index}'
              properties: {
                privateLinkServiceId: databaseAccount.id
                groupIds: [
                  privateEndpoint.?service ?? 'Sql'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(databaseAccount.id, '/'))}-${privateEndpoint.?service ?? 'Sql'}-${index}'
              properties: {
                privateLinkServiceId: databaseAccount.id
                groupIds: [
                  privateEndpoint.?service ?? 'Sql'
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

// =========== //
// Outputs     //
// =========== //

@description('The name of the database account.')
output name string = databaseAccount.name

@description('The resource ID of the database account.')
output resourceId string = databaseAccount.id

@description('The name of the resource group the database account was created in.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = databaseAccount.?identity.?principalId

@description('The location the resource was deployed into.')
output location string = databaseAccount.location

@description('The endpoint of the database account.')
output endpoint string = databaseAccount.properties.documentEndpoint

@description('The private endpoints of the database account.')
output privateEndpoints privateEndpointOutputType[] = [
  for (pe, index) in (privateEndpoints ?? []): {
    name: databaseAccount_privateEndpoints[index].outputs.name
    resourceId: databaseAccount_privateEndpoints[index].outputs.resourceId
    groupId: databaseAccount_privateEndpoints[index].outputs.?groupId!
    customDnsConfigs: databaseAccount_privateEndpoints[index].outputs.customDnsConfigs
    networkInterfaceResourceIds: databaseAccount_privateEndpoints[index].outputs.networkInterfaceResourceIds
  }
]

@secure()
@description('The primary read-write key.')
output primaryReadWriteKey string = databaseAccount.listKeys().primaryMasterKey

@secure()
@description('The primary read-only key.')
output primaryReadOnlyKey string = databaseAccount.listKeys().primaryReadonlyMasterKey

@secure()
@description('The primary read-write connection string.')
output primaryReadWriteConnectionString string = databaseAccount.listConnectionStrings().connectionStrings[0].connectionString

@secure()
@description('The primary read-only connection string.')
output primaryReadOnlyConnectionString string = databaseAccount.listConnectionStrings().connectionStrings[2].connectionString

@secure()
@description('The secondary read-write key.')
output secondaryReadWriteKey string = databaseAccount.listKeys().secondaryMasterKey

@secure()
@description('The secondary read-only key.')
output secondaryReadOnlyKey string = databaseAccount.listKeys().secondaryReadonlyMasterKey

@secure()
@description('The secondary read-write connection string.')
output secondaryReadWriteConnectionString string = databaseAccount.listConnectionStrings().connectionStrings[1].connectionString

@secure()
@description('The secondary read-only connection string.')
output secondaryReadOnlyConnectionString string = databaseAccount.listConnectionStrings().connectionStrings[3].connectionString

@description('Is there evidence of usage in non-compliance with policies? Checks: drcp-cosmos-01 (publicNetworkAccess), drcp-cosmos-02 (disableLocalAuth), drcp-cosmos-03 (disableKeyBasedMetadataWriteAccess), drcp-cosmos-05 (minimumTlsVersion), drcp-cosmos-10 (zoneRedundant).')
output evidenceOfNonCompliance bool = (databaseAccount.properties.publicNetworkAccess != 'Disabled' || !disableLocalAuthentication || !disableKeyBasedMetadataWriteAccess || minimumTlsVersion != 'Tls12' || (empty(failoverLocations) && !zoneRedundant))

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

import { customerManagedKeyType } from '../../../../bicep-shared/types.bicep'

import { containerType } from 'sql-database/main.bicep'
import { sqlRoleAssignmentType as nestedSqlRoleAssignmentType } from 'sql-role-definition/main.bicep'

@export()
@description('The type for the private endpoint output.')
type privateEndpointOutputType = {
  @description('The name of the private endpoint.')
  name: string

  @description('The resource ID of the private endpoint.')
  resourceId: string

  @description('The group ID for the private endpoint group.')
  groupId: string?

  @description('The custom DNS configurations of the private endpoint.')
  customDnsConfigs: {
    @description('fully-qualified domain name (FQDN) that resolves to private endpoint IP address.')
    fqdn: string?

    @description('A list of private IP addresses for the private endpoint.')
    ipAddresses: string[]
  }[]

  @description('The IDs of the network interfaces associated with the private endpoint.')
  networkInterfaceResourceIds: string[]
}

@export()
@description('The type for the failover location.')
type failoverLocationType = {
  @description('Required. The failover priority of the region. A failover priority of 0 indicates a write region. The maximum value for a failover priority = (total number of regions - 1). Failover priority values must be unique for each of the regions in which the database account exists.')
  failoverPriority: int

  @description('Optional. Flag to indicate whether or not this region is an AvailabilityZone region. Defaults to true.')
  isZoneRedundant: bool?

  @description('Required. The name of the region.')
  locationName: string
}

@export()
@description('The type for an Azure Cosmos DB for NoSQL native role-based access control assignment.')
type sqlRoleAssignmentType = {
  @description('Optional. The unique name of the role assignment.')
  name: string?

  @description('Required. The unique identifier of the Azure Cosmos DB for NoSQL native role-based access control definition.')
  roleDefinitionId: string

  @description('Required. The unique identifier for the associated Microsoft Entra ID principal to which access is being granted through this role-based access control assignment. The tenant ID for the principal is inferred using the tenant associated with the subscription.')
  principalId: string

  @description('Optional. The data plane resource id for which access is being granted through this Role Assignment. Defaults to the root of the database account, but can also be scoped to e.g., the container and database level.')
  scope: string?
}

@export()
@description('The type for an Azure Cosmos DB for NoSQL native role-based access control definition.')
type sqlRoleDefinitionType = {
  @description('Optional. The unique identifier of the role-based access control definition.')
  name: string?

  @description('Required. A user-friendly name for the role-based access control definition. This must be unique within the database account.')
  roleName: string

  @description('Required. An array of data actions that are allowed.')
  @minLength(1)
  dataActions: string[]

  @description('Optional. A set of fully-qualified scopes at or below which role-based access control assignments may be created using this definition. This setting allows application of this definition on the entire account or any underlying resource. This setting must have at least one element. Scopes higher than the account level are not enforceable as assignable scopes. Resources referenced in assignable scopes do not need to exist at creation. Defaults to the current account scope.')
  assignableScopes: string[]?

  @description('Optional. An array of role-based access control assignments to be created for the definition.')
  assignments: nestedSqlRoleAssignmentType[]?
}

@export()
@description('The type for the network restriction.')
type networkRestrictionType = {
  @description('Optional. A single IPv4 address or a single IPv4 address range in Classless Inter-Domain Routing (CIDR) format. Provided IPs must be well-formatted and cannot be contained in one of the following ranges: `10.0.0.0/8`, `100.64.0.0/10`, `172.16.0.0/12`, `192.168.0.0/16`, since these are not enforceable by the IP address filter. Example of valid inputs: `23.40.210.245` or `23.40.210.0/8`.')
  ipRules: string[]?

  @description('Optional. Specifies the network ACL bypass for Azure services. Default to "None".')
  networkAclBypass: ('AzureServices' | 'None')?

  @description('Optional. Whether requests from the public network are allowed. Default to "Disabled".')
  publicNetworkAccess: ('Enabled' | 'Disabled')?

  @description('Optional. List of virtual network access control list (ACL) rules configured for the account.')
  virtualNetworkRules: {
    @description('Required. Resource ID of a subnet.')
    subnetResourceId: string
  }[]?

  @description('Optional. An array that contains the Resource Ids for Network Acl Bypass for the Cosmos DB account.')
  networkAclBypassResourceIds: string[]?
}

@export()
@description('The type for a sql database.')
type sqlDatabaseType = {
  @description('Required. Name of the SQL database .')
  name: string

  @description('Optional. Array of containers to deploy in the SQL database.')
  containers: containerType[]?

  @description('Optional. Request units per second. Will be ignored if autoscaleSettingsMaxThroughput is used. Setting throughput at the database level is only recommended for development/test or when workload across all containers in the shared throughput database is uniform. For best performance for large production workloads, it is recommended to set dedicated throughput (autoscale or manual) at the container level and not at the database level.')
  throughput: int?

  @description('Optional. Specifies the Autoscale settings and represents maximum throughput, the resource can scale up to. The autoscale throughput should have valid throughput values between 1000 and 1000000 inclusive in increments of 1000. If value is set to null, then autoscale will be disabled. Setting throughput at the database level is only recommended for development/test or when workload across all containers in the shared throughput database is uniform. For best performance for large production workloads, it is recommended to set dedicated throughput (autoscale or manual) at the container level and not at the database level.')
  autoscaleSettingsMaxThroughput: int?

  @description('Optional. Tags of the SQL database resource.')
  tags: object?
}

// COMMENTED OUT: Future feature -- Gremlin database type is not allowed per company policy (NoSQL only).
// import { graphType } from 'gremlin-database/main.bicep'
// @export()
// @description('The type for a gremlin database.')
// type gremlinDatabaseType = {
//   @description('Required. Name of the Gremlin database.')
//   name: string
//   @description('Optional. Tags of the Gremlin database resource.')
//   tags: object?
//   @description('Optional. Array of graphs to deploy in the Gremlin database.')
//   graphs: graphType[]?
//   @description('Optional. Represents maximum throughput, the resource can scale up to.')
//   maxThroughput: int?
//   @description('Optional. Request Units per second.')
//   throughput: int?
// }

// COMMENTED OUT: Future feature -- MongoDB database type is not allowed per company policy (NoSQL only).
// import { collectionType } from 'mongodb-database/main.bicep'
// @export()
// @description('The type for a mongo database.')
// type mongoDbType = {
//   @description('Required. Name of the mongodb database.')
//   name: string
//   @description('Optional. Request Units per second.')
//   throughput: int?
//   @description('Optional. Collections in the mongodb database.')
//   collections: collectionType[]?
//   @description('Optional. Specifies the Autoscale settings.')
//   autoscaleSettings: object?
//   @description('Optional. Tags of the resource.')
//   tags: object?
// }

// COMMENTED OUT: Future feature -- Table type is not allowed per company policy (NoSQL only).
// @export()
// @description('The type for a table.')
// type tableType = {
//   @description('Required. Name of the table.')
//   name: string
//   @description('Optional. Tags for the table.')
//   tags: object?
//   @description('Optional. Represents maximum throughput, the resource can scale up to.')
//   maxThroughput: int?
//   @description('Optional. Request Units per second.')
//   throughput: int?
// }

// COMMENTED OUT: Future feature -- Cassandra types are not allowed per company policy (NoSQL only).
// import { cassandraRoleAssignmentType } from 'cassandra-role-definition/main.bicep'
// import { tableType as cassandraTableType, viewType as cassandraViewType } from 'cassandra-keyspace/main.bicep'
// @export()
// @description('The type for an Azure Cosmos DB for Apache Cassandra native role-based access control assignment.')
// type cassandraStandaloneRoleAssignmentType = {
//   @description('Optional. The unique name of the role assignment.')
//   name: string?
//   @description('Required. The unique identifier of the Azure Cosmos DB for Apache Cassandra native role-based access control definition.')
//   roleDefinitionId: string
//   @description('Required. The unique identifier for the associated Microsoft Entra ID principal.')
//   principalId: string
//   @description('Optional. The data plane resource path for which access is being granted.')
//   scope: string?
// }
// @export()
// @description('The type for an Azure Cosmos DB for Apache Cassandra native role-based access control definition.')
// type cassandraRoleDefinitionType = {
//   @description('Optional. The unique identifier of the role-based access control definition.')
//   name: string?
//   @description('Required. A user-friendly name for the role-based access control definition.')
//   roleName: string
//   @description('Optional. An array of data actions that are allowed.')
//   dataActions: string[]?
//   @description('Optional. An array of data actions that are denied.')
//   notDataActions: string[]?
//   @description('Optional. A set of fully qualified Scopes at or below which Role Assignments may be created.')
//   assignableScopes: string[]?
//   @description('Optional. An array of role-based access control assignments to be created for the definition.')
//   assignments: cassandraRoleAssignmentType[]?
// }
// @export()
// @description('The type for an Azure Cosmos DB Cassandra keyspace.')
// type cassandraKeyspaceType = {
//   @description('Required. Name of the Cassandra keyspace.')
//   name: string
//   @description('Optional. Array of Cassandra tables to deploy in the keyspace.')
//   tables: cassandraTableType[]?
//   @description('Optional. Array of Cassandra views (materialized views) to deploy in the keyspace.')
//   views: cassandraViewType[]?
//   @description('Optional. Represents maximum throughput, the resource can scale up to.')
//   autoscaleSettingsMaxThroughput: int?
//   @description('Optional. Request Units per second.')
//   throughput: int?
//   @description('Optional. Tags of the Cassandra keyspace resource.')
//   tags: object?
// }

@export()
@discriminator('name')
@description('The type for the default identity.')
type defaultIdentityType =
  | defaultIdentityFirstPartyType
  | defaultIdentitySystemAssignedType
  | defaultIdentityUserAssignedType
type defaultIdentityFirstPartyType = {
  @description('Required. The type of default identity to use.')
  name: 'FirstPartyIdentity'
}
type defaultIdentitySystemAssignedType = {
  @description('Required. The type of default identity to use.')
  name: 'SystemAssignedIdentity'
}
type defaultIdentityUserAssignedType = {
  @description('Required. The type of default identity to use.')
  name: 'UserAssignedIdentity'

  @description('Required. The resource ID of the user assigned identity to use as the default identity.')
  resourceId: string
}
