metadata name = 'Azure SQL Server Database'
metadata description = 'This module deploys an Azure SQL Server Database.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of Azure SQL Database requires:
- backupShortTermRetentionPolicy.retentionDays: 5 or higher
'''
metadata complianceVersion = '20240726'

@description('Required. The name of the database.')
param name string

@description('Conditional. The name of the parent SQL Server. Required if the template is used in a standalone deployment.')
@minLength(1)
param serverName string

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. The skuTier or edition of the particular SKU.')
param skuTier string?

@description('''Optional. The name (ServiceObjective) of the SKU, typically, one or more letters (Edition) + optionally a Number (Capacity code), e.g. P3, S1, GP_Gen5, GP_Gen5_2. Default: GP_Gen5_2.

The list of SKUs may vary by region and support offer.To determine the SKUs (including the SKU name, tier/edition, family, and capacity) that are available to your subscription in an Azure region,
use the Capabilities_ListByLocation REST API or one of the following commands:

Azure CLI: `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.

Azure PowerShell: Get-AzSqlServerServiceObjective -Location {location}
''')
param skuName string = 'GP_Gen5_2'

@description('Optional. Capacity of the particular SKU.')
param skuCapacity int?


@description('Optional. If the service has different generations of hardware, for the same SKU, then that can be captured here.')
param skuFamily string = ''

@description('Optional. Size of the particular SKU.')
param skuSize string = ''

@description('Optional. Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled.')
param autoPauseDelay int = 0

@description('Optional.	Specifies the availability zone the database is pinned to. Default: NoPreference')
@allowed([
  '1'
  '2'
  '3'
  'NoPreference'
])
param availabilityZone string = 'NoPreference'

@description('Optional. Collation of the metadata catalog.')
@allowed([
  'DATABASE_DEFAULT'
  'SQL_Latin1_General_CP1_CI_AS'
])
param catalogCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Optional. The collation of the database. Default: SQL_Latin1_General_CP1_CI_AS')
param collation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('''Optional. Specifies the mode of database creation. Default: 'Default'.

Please see https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep#databaseproperties for parameter value explanation.
''')
@allowed([
  'Default'
  'Copy'
  'OnlineSecondary'
  'PointInTimeRestore'
  'Recovery'
  'Restore'
  'RestoreExternalBackupSecondary'
  'RestoreLongTermRetentionBackup'
  'Secondary'
])
param createMode string = 'Default'

@description('Optional. The resource ID of the elastic pool containing this database.')
param elasticPoolId string?

@description('''Optional. Specifies the behavior when monthly free limits are exhausted for the free database. Default: 'BillOverUsage'.

AutoPause: The database will be auto paused upon exhaustion of free limits for remainder of the month.
BillForUsage: The database will continue to be online upon exhaustion of free limits and any overage will be billed.''')
@allowed([
  'AutoPause'
  'BillOverUsage'
])
param freeLimitExhaustionBehavior string = 'BillOverUsage'

@description('Optional. The number of secondary replicas associated with the database that are used to provide high availability. Not applicable to a Hyperscale database within an elastic pool. Default: 0')
param highAvailabilityReplicaCount int = 0

@description('''Optional. Whether or not this database is a ledger database, which means all tables in the database are ledger tables.
Note: the value of this property cannot be changed after the database has been created.
Default: false''')
param isLedgerOn bool = false

@description('''Optional. The license type to apply for this database.
LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit.
Default: 'LicenseIncluded'
''')
@allowed([
  'BasePrice'
  'LicenseIncluded'
])
param licenseType string = 'LicenseIncluded'

@description('Optional. Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur.')
param maintenanceConfigurationId string = ''

@description('''Optional. Whether or not customer controlled manual cutover needs to be done during Update Database operation to Hyperscale tier.

This property is only applicable when scaling database from Business Critical/General Purpose/Premium/Standard tier to Hyperscale tier.

When manualCutover is specified, the scaling operation will wait for user input to trigger cutover to Hyperscale database.

To trigger cutover, please provide 'performCutover' parameter when the Scaling operation is in Waiting state.''')
param manualCutover bool?

@description('''Optional. The max size of the database expressed in bytes.

See https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#maxsize for supported sizes.
''')
param maxSizeBytes int?

@description('Optional. Minimal capacity that database will always have allocated, if not paused. Integers or decimal values. Default: empty.')
param minCapacity string = ''

@description('''
Optional. To trigger customer controlled manual cutover during the wait state while Scaling operation is in progress.

This property parameter is only applicable for scaling operations that are initiated along with 'manualCutover' parameter.

This property is only applicable when scaling database from Business Critical/General Purpose/Premium/Standard tier to Hyperscale tier is already in progress.

When performCutover is specified, the scaling operation will trigger cutover and perform role-change to Hyperscale database.
''')
param performCutover bool?

@description('Optional. Type of enclave requested on the database i.e. Default or VBS enclaves.')
@allowed([
  ''
  'Default'
  'VBS'
])
param preferredEnclaveType string = ''

@description('Optional. The state of read-only routing.')
@allowed([
  'Enabled'
  'Disabled'
])
param readScale string = 'Disabled'

@description('Optional. Resource ID of backup if createMode set to RestoreLongTermRetentionBackup.')
param recoveryServicesRecoveryPointResourceId string = ''

@description('Optional. The storage account type to be used to store backups for this database. Default: Zone.')
@allowed([
  'Geo'
  'GeoZone'
  'Local'
  'Zone'
  ''
])
param requestedBackupStorageRedundancy string = 'Zone'

@description('Optional. Point in time (ISO8601 format) of the source database to restore when createMode set to Restore or PointInTimeRestore.')
param restorePointInTime string = ''

@description('Optional. The name of the sample schema to apply when creating this database.')
@allowed([
  'AdventureWorksLT'
  'WideWorldImportersFull'
  'WideWorldImportersStd'
  ''
])
param sampleName string = ''

@description('Optional. The secondary type of the database if it is a secondary. Valid values are Geo, Named and Standby. Default: empty')
@allowed([
  'Geo'
  'Named'
  'Standby'
  ''
])
param secondaryType string = ''

@description('Optional. The time that the database was deleted when restoring a deleted database.')
param sourceDatabaseDeletionDate string = ''

@description('Optional. Resource ID of database if createMode set to Copy, Secondary, PointInTimeRestore, Recovery or Restore.')
param sourceDatabaseResourceId string = ''

@description('''Optional. The resource identifier of the source associated with the create operation of this database.
This property is only supported for DataWarehouse edition and allows to restore across subscriptions.

Please see the https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep#databaseproperties page for explanation.
''')
param sourceResourceId string = ''

@description('Optional. Whether or not the database uses free monthly limits. Allowed on one database in a subscription.')
param useFreeLimit bool = false

@description('''Optional. Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.
Default: 'true' if skuName is not S or B type.''')
param zoneRedundant bool = ! (startsWith(skuName,'S') || startsWith(skuName,'B')) // Standard and Basic tiers do not support zone-redundant availability

@description('Optional. The short term backup retention policy to create for the database. Default: retentionDays=7, diffBackupIntervalInHours=24')
param backupShortTermRetentionPolicy backupShortTermRetentionPolicyType = {
  retentionDays: 7
  diffBackupIntervalInHours: 24
}

@description('Optional. The long term backup retention policy to create for the database. Default: weekly=P1W, monthly=P4W, and yearly=P520W. ')
param backupLongTermRetentionPolicy backupLongTermRetentionPolicyType?

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// The SKU object must be built in a variable
// The alternative, 'null' as default values, leads to non-terminating deployments
var skuVar = union(
  {
    name: skuName
  },
  (!empty(skuTier))
    ? {
        tier: skuTier
      }
    : {},
  (skuCapacity != null)
    ? {
        capacity: skuCapacity
      }
    : !empty(skuFamily)
        ? {
            family: skuFamily
          }
        : !empty(skuSize)
            ? {
                size: skuSize
              }
            : {}
)

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'SQLInsights'
  'AutomaticTuning'
  'QueryStoreRuntimeStatistics'
  'QueryStoreWaitStatistics'
  'Errors'
  'DatabaseWaitStatistics'
  'Timeouts'
  'Blocks'
  'Deadlocks'
]

var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]

var defaultMetricsCategoryNames = [
  'Basic'
  'InstanceAndAppAdvanced'
  'WorkloadManagement'
]

var defaultMetricsCategories = [for category in defaultMetricsCategoryNames ?? []: {
  category: category
}]

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../../bicep-shared/environments.bicep'

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})


#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.sql-database.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, serverName, name, location), 0, 4)}',
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

resource server 'Microsoft.Sql/servers@2023-08-01-preview' existing = {
  name: serverName
}

resource database 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  name: name
  parent: server
  location: location
  tags: finalTags
  properties: {
    autoPauseDelay: autoPauseDelay
    availabilityZone: availabilityZone
    catalogCollation: !empty(catalogCollation) ? catalogCollation : null
    collation: !empty(collation) ? collation : null
    createMode: !empty(createMode) ? createMode : null
    elasticPoolId: !empty(elasticPoolId) ? elasticPoolId : null
    freeLimitExhaustionBehavior: !empty(freeLimitExhaustionBehavior) ? freeLimitExhaustionBehavior : null
    highAvailabilityReplicaCount: highAvailabilityReplicaCount
    isLedgerOn: isLedgerOn
    licenseType: !empty(licenseType) ? licenseType : null
    maintenanceConfigurationId: !empty(maintenanceConfigurationId) ? maintenanceConfigurationId : null
    manualCutover: manualCutover
    maxSizeBytes: maxSizeBytes
    minCapacity: !empty(minCapacity) ? json(minCapacity) : 0 // The json() function is used to allow specifying a decimal value.
    performCutover: performCutover
    preferredEnclaveType: !empty(preferredEnclaveType) ? preferredEnclaveType : null
    readScale: !empty(readScale) ? readScale : null
    recoveryServicesRecoveryPointId: !empty(recoveryServicesRecoveryPointResourceId) ? recoveryServicesRecoveryPointResourceId : null
    requestedBackupStorageRedundancy: any(requestedBackupStorageRedundancy)
    restorePointInTime: !empty(restorePointInTime) ? restorePointInTime : null
    sampleName: !empty(sampleName) ? sampleName : null
    secondaryType: !empty(secondaryType) ? secondaryType : null
    sourceDatabaseDeletionDate: !empty(sourceDatabaseDeletionDate) ? sourceDatabaseDeletionDate : null
    sourceDatabaseId: !empty(sourceDatabaseResourceId) ? sourceDatabaseResourceId : null
    sourceResourceId:  !empty(sourceResourceId) ? sourceResourceId : null
    useFreeLimit: useFreeLimit
    zoneRedundant: zoneRedundant
  }
  sku: skuVar
}

#disable-next-line use-recent-api-versions
resource database_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? defaultMetricsCategories): {
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
    scope: database
  }
]

module database_backupShortTermRetentionPolicy 'backup-short-term-retention-policy/main.bicep' = {
  name: take('${uniqueString(deployment().name, location)}-${name}-backup-shortretpol',64)
  params: {
    serverName: serverName
    databaseName: database.name
    diffBackupIntervalInHours: backupShortTermRetentionPolicy.?diffBackupIntervalInHours
    retentionDays: backupShortTermRetentionPolicy.?retentionDays
  }
}

module database_backupLongTermRetentionPolicy 'backup-long-term-retention-policy/main.bicep' = {
  name: take('${uniqueString(deployment().name, location)}-${name}-backup-longretpol',64)
  params: {
    serverName: serverName
    databaseName: database.name
    weeklyRetention: backupLongTermRetentionPolicy.?weeklyRetention
    monthlyRetention: backupLongTermRetentionPolicy.?monthlyRetention
    yearlyRetention: backupLongTermRetentionPolicy.?yearlyRetention
    weekOfYear: backupLongTermRetentionPolicy.?weekOfYear
  }
}

@description('The name of the deployed database.')
output name string = database.name

@description('The resource ID of the deployed database.')
output resourceId string = database.id

@description('The resource group of the deployed database.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = database.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = ((backupShortTermRetentionPolicy.?retentionDays ?? 7) < 5)

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
} from '../../../../../bicep-shared/types.bicep'

import { backupShortTermRetentionPolicyType } from 'backup-short-term-retention-policy/main.bicep'
import { backupLongTermRetentionPolicyType } from 'backup-long-term-retention-policy/main.bicep'

@export()
type databaseType = {
  @description('Required. The name of the database.')
  name: string

  @description('Optional. Tags of the resource.')
  tags: object?

  @description('Optional. Location for all resources.')
  location: string?

  @description('Optional. Capacity of the particular SKU.')
  skuCapacity: int?

  @description('Optional. If the service has different generations of hardware, for the same SKU, then that can be captured here.')
  skuFamily: string?

  @description('''Optional. The name of the SKU that represents a Service Objective, e.g. P3, S1, GP_Gen5, GP_Gen5_2. Default: GP_Gen5_2.

  The list of SKUs may vary by region and support offer.To determine the SKUs (including the SKU name, tier/edition, family, and capacity) that are available to your subscription in an Azure region,
  use the Capabilities_ListByLocation REST API or one of the following commands:

  Azure CLI: `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.

  Azure PowerShell: Get-AzSqlServerServiceObjective -Location {location}''')

  skuName: string?

  @description('Optional. Size of the particular SKU.')
  skuSize: string?

  @description('Optional. The skuTier or edition of the particular SKU.')
  skuTier: string?

  @description('Optional. Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled.')
  autoPauseDelay: int?

  @description('Optional.	Specifies the availability zone the database is pinned to. Default: NoPreference')
  availabilityZone: ('1' | '2' | '3' | 'NoPreference')?

  @description('Optional. Collation of the metadata catalog.')
  catalogCollation: ('SQL_Latin1_General_CP1_CI_AS' | 'DATABASE_DEFAULT')?

  @description('Optional. The collation of the database.')
  collation: string?

  @description('Optional. Specifies the mode of database creation.')
  createMode: ('Default' | 'Copy' | 'OnlineSecondary' | 'PointInTimeRestore' | 'Recovery' | 'Restore' | 'RestoreLongTermRetentionBackup' | 'Secondary')?

  @description('''Optional. Specifies the behavior when monthly free limits are exhausted for the free database. Default: 'BillOverUsage'.''')
  freeLimitExhaustionBehavior: ('BillOverUsage' | 'AutoPause')?

  @description('Optional. The resource identifier of the elastic pool containing this database.')
  elasticPoolId: string?

  @description('''Optional. The number of secondary replicas associated with the database that are used to provide high availability.
  Not applicable to a Hyperscale database within an elastic pool.''')
  highAvailabilityReplicaCount: int?

  @description('''Optional. Whether or not this database is a ledger database, which means all tables in the database are ledger tables.
  Note: the value of this property cannot be changed after the database has been created.''')
  isLedgerOn: bool?

  @description('Optional. The license type to apply for this database. LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit.')
  licenseType: ('BasePrice' | 'LicenseIncluded' | '')?

  @description('Optional. Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur.')
  maintenanceConfigurationId: string?

  @description('Optional. Whether or not customer controlled manual cutover needs to be done during Update Database operation to Hyperscale tier.')
  manualCutover: bool?

  @description('''Optional. The max size of the database expressed in bytes.

  See https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#maxsize for supported sizes.''')
  maxSizeBytes: int?

  @description('Optional. Minimal capacity that database will always have allocated.')
  minCapacity: string?

  @description('Optional. To trigger customer controlled manual cutover during the wait state while Scaling operation is in progress.')
  performCutover: bool?

  @description('Optional. Type of enclave requested on the database i.e. Default or VBS enclaves.')
  preferredEnclaveType: ('' | 'Default' | 'VBS')?

  @description('Optional. The state of read-only routing.')
  readScale: ('Disabled' | 'Enabled' | '')?

  @description('Optional. Resource ID of backup if createMode set to RestoreLongTermRetentionBackup.')
  recoveryServicesRecoveryPointResourceId: string?

  @description('Optional. The storage account type to be used to store backups for this database.')
  requestedBackupStorageRedundancy: ( 'Geo' | 'Local' | 'Zone' | '')?

  @description('Optional. Point in time (ISO8601 format) of the source database to restore when createMode set to Restore or PointInTimeRestore.')
  restorePointInTime: string?

  @description('Optional. The name of the sample schema to apply when creating this database.')
  sampleName: string?

  @description('Optional. The secondary type of the database if it is a secondary. Valid values are Geo, Named and Standby. Default: empty')
  secondaryType: ('Geo' | 'Named' | 'Standby' | '')?

  @description('Optional. The time that the database was deleted when restoring a deleted database.')
  sourceDatabaseDeletionDate: string?

  @description('Optional. Resource ID of database if createMode set to Copy, Secondary, PointInTimeRestore, Recovery or Restore.')
  sourceDatabaseResourceId: string?

  @description('''Optional. The resource identifier of the source associated with the create operation of this database.
  This property is only supported for DataWarehouse edition and allows to restore across subscriptions.''')
  sourceResourceId: string?

  @description('Optional. Whether or not the database uses free monthly limits. Allowed on one database in a subscription.')
  useFreeLimit: bool?

  @description('Optional. Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.')
  zoneRedundant: bool?

  @description('Optional. The short term backup retention policy to create for the database.')
  backupShortTermRetentionPolicy: backupShortTermRetentionPolicyType?

  @description('Optional. The long term backup retention policy to create for the database.')
  backupLongTermRetentionPolicy: backupLongTermRetentionPolicyType?

  @description('Optional. The diagnostic settings of the service.')
  diagnosticSettings: diagnosticSettingType
}
