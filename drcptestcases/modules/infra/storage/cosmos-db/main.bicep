@description('Deployment Location')
param location string

@description('Key vaule pair.')
param tags object = {}

@description('Name of Cosmos DB Resource')
param name string

@description('The API to use for the database account. Default: GlobalDocumentDB.')
@allowed([
  'GlobalDocumentDB'
  'MongoDB'
])
param kind string = 'GlobalDocumentDB'

@allowed([
  'None'
  'SystemAssigned'
  'UserAssigned'
  'SystemAssigned,UserAssigned'
])
@description('Optional. The type of identity used for the virtual machine. The type \'SystemAssigned, UserAssigned\' includes both an implicitly created identity and a set of user assigned identities. The type \'None\' will remove any identities from the sites ( app or functionapp).')
param identityType string = 'SystemAssigned'

@description('Optional. Specify the resource ID of the user assigned Managed Identity, if \'identity\' is set as \'UserAssigned\'.')
param userAssignedIdentityId string = ''

@description('Max stale requests. Required for BoundedStaleness. Valid ranges, Single Region: 10 to 2147483647. Multi Region: 100000 to 2147483647.')
@minValue(10)
@maxValue(2147483647)
param maxStalenessPrefix int = 100000

@description('Max lag time (minutes). Required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400.')
@minValue(5)
@maxValue(86400)
param maxIntervalInSeconds int = 300

@allowed([ 'Eventual', 'ConsistentPrefix', 'Session', 'BoundedStaleness', 'Strong' ])
@description('The default consistency level of the Cosmos DB account.')
param defaultConsistencyLevel string = 'Session'

@description('Enable system managed failover for regions')
param systemManagedFailover bool = true

@description('Array of region objects or regions: [region: string]')
param secondaryLocations array = []

@description('Multi-region writes capability allows you to take advantage of the provisioned throughput for your databases and containers across the globe.')
param enableMultipleWriteLocations bool = true

@description('Enable Cassandra Backend.')
@allowed([false])
param enableCassandra bool = false

@description('Enable Serverless for consumption-based usage.')
@allowed([false])
param enableServerless bool = false

@description('Disable Local authentication. If true, only AAD and MSI authentication is possible. Default: true')
@allowed([true])
param disableLocalAuthentication bool = true

@description('The backup policy type. Default: Periodic')
@allowed([
  'Periodic'
  'Continuous'
])
param backupPolicyType string = 'Periodic'

@allowed([
  'Continuous30Days'
  'Continuous7Days'
])
param continuousBackupTier string = 'Continuous30Days'

@description('The backup storage redundancy type. Default: Local')
@allowed([
  'Geo'
  'Zone'
  'Local'
])
param periodicBackupStorageRedundancy string = 'Local'

param periodicBackupIntervalInMinutes int = 300

param periodicBackupRetentionIntervalInHours int = 12

@description('Optional.Resource Id of the log analytics workspace which the data will be ingested to.')
param logAnalyticsWorkspaceId string = ''

@description('Toggle to enable or disable zone redundance. Default: false')
param isZoneRedundant bool = false

@description('Optional. Object Id of the principal (User, Group, Service Principal) to be assigned the Data Writer role.')
param objectId string = ''

var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: maxStalenessPrefix
    maxIntervalInSeconds: maxIntervalInSeconds
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}

var secondaryRegions = [for (region, i) in secondaryLocations: {
  locationName: region.?locationName ?? region
  failoverPriority: region.?failoverPriority ?? i + 1
  isZoneRedundant: region.?isZoneRedundant ?? isZoneRedundant
}]

var locations = union([
    {
      locationName: location
      failoverPriority: 0
      isZoneRedundant: isZoneRedundant
    }
  ], secondaryRegions)

var capabilities = union(
  enableCassandra ? [ { name: 'EnableCassandra' } ] : [],
  enableServerless ? [ { name: 'EnableServerless' } ] : []
)

resource cosmosDbAaccount 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
  name: name
  location: location
  kind: kind
  identity: {
    type: identityType
    userAssignedIdentities: (identityType == 'UserAssigned' || identityType == 'SystemAssigned, UserAssigned') ? {
      '${userAssignedIdentityId}': {}
    } : null
  }
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: locations
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: systemManagedFailover
    enableMultipleWriteLocations: enableMultipleWriteLocations
    capabilities: capabilities
    backupPolicy: {
      #disable-next-line BCP225
      type: backupPolicyType
      periodicModeProperties: (backupPolicyType == 'Periodic') ? {
        backupIntervalInMinutes: periodicBackupIntervalInMinutes
        backupRetentionIntervalInHours: periodicBackupRetentionIntervalInHours
        backupStorageRedundancy: periodicBackupStorageRedundancy
      } : {}
      continuousModeProperties: (backupPolicyType == 'Continuous') ? {
        tier: continuousBackupTier
      } : {}
    }
    disableLocalAuth: disableLocalAuthentication
    disableKeyBasedMetadataWriteAccess: disableLocalAuthentication
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: 'Tls12'
  }
  tags: tags
}

module cosmosDbRoleAssignment 'modules/role-assignment.bicep' = if (!empty(objectId)) {
  name: '${name}-${uniqueString(objectId)}-rbac'
  params: {
    resourceName: cosmosDbAaccount.name
    principals: [
      {
        objectId: objectId
      }
    ]
    rbacRole: '00000000-0000-0000-0000-000000000002' // Cosmos DB Built-in Data Contributor Role
  }
}

resource digLog 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: '${name}_diagnostics'
  scope: cosmosDbAaccount
  properties: {
    logs: [
      {
        enabled: true
        category: 'ControlPlaneRequests'
      }
      {
        enabled: true
        category: 'DataPlaneRequests'
      }
      {
        enabled: true
        category: 'PartitionKeyStatistics'
      }
      {
        enabled: true
        category: 'PartitionKeyRUConsumption'
      }
      {
        enabled: true
        category: 'QueryRuntimeStatistics'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
    workspaceId: logAnalyticsWorkspaceId
  }
}

@description('Cosmos DB Resource ID')
output id string = cosmosDbAaccount.id

@description('Cosmos DB Resource Name')
output name string = cosmosDbAaccount.name

output documentEndpoint string = cosmosDbAaccount.properties.documentEndpoint
