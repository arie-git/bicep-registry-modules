# Azure SQL Server Database `[Microsoft.Sql/servers/databases]`

This module deploys an Azure SQL Server Database.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20240726

Compliant usage of Azure SQL Database requires:
- backupShortTermRetentionPolicy.retentionDays: 5 or higher


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Sql/servers/databases` | 2023-08-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-08-01-preview/servers/databases)</li></ul> |
| `Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases_backuplongtermretentionpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/databases/backupLongTermRetentionPolicies)</li></ul> |
| `Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies` | 2023-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.sql_servers_databases_backupshorttermretentionpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Sql/2023-05-01-preview/servers/databases/backupShortTermRetentionPolicies)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the database. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serverName`](#parameter-servername) | string | The name of the parent SQL Server. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoPauseDelay`](#parameter-autopausedelay) | int | Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled. |
| [`backupLongTermRetentionPolicy`](#parameter-backuplongtermretentionpolicy) | object | The long term backup retention policy to create for the database. Default: weekly=P1W, monthly=P4W, and yearly=P520W.  |
| [`backupShortTermRetentionPolicy`](#parameter-backupshorttermretentionpolicy) | object | The short term backup retention policy to create for the database. Default: retentionDays=7, diffBackupIntervalInHours=24 |
| [`catalogCollation`](#parameter-catalogcollation) | string | Collation of the metadata catalog. |
| [`collation`](#parameter-collation) | string | The collation of the database. Default: SQL_Latin1_General_CP1_CI_AS |
| [`createMode`](#parameter-createmode) | string | Specifies the mode of database creation. Default: 'Default'.<p><p>Please see https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep#databaseproperties for parameter value explanation.<p> |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service. |
| [`elasticPoolId`](#parameter-elasticpoolid) | string | The resource ID of the elastic pool containing this database. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`freeLimitExhaustionBehavior`](#parameter-freelimitexhaustionbehavior) | string | Specifies the behavior when monthly free limits are exhausted for the free database. Default: 'BillOverUsage'.<p><p>AutoPause: The database will be auto paused upon exhaustion of free limits for remainder of the month.<p>BillForUsage: The database will continue to be online upon exhaustion of free limits and any overage will be billed. |
| [`highAvailabilityReplicaCount`](#parameter-highavailabilityreplicacount) | int | The number of secondary replicas associated with the database that are used to provide high availability. Not applicable to a Hyperscale database within an elastic pool. Default: 0 |
| [`isLedgerOn`](#parameter-isledgeron) | bool | Whether or not this database is a ledger database, which means all tables in the database are ledger tables.<p>Note: the value of this property cannot be changed after the database has been created.<p>Default: false |
| [`licenseType`](#parameter-licensetype) | string | The license type to apply for this database.<p>LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit.<p>Default: 'LicenseIncluded'<p> |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`maintenanceConfigurationId`](#parameter-maintenanceconfigurationid) | string | Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur. |
| [`manualCutover`](#parameter-manualcutover) | bool | Whether or not customer controlled manual cutover needs to be done during Update Database operation to Hyperscale tier.<p><p>This property is only applicable when scaling database from Business Critical/General Purpose/Premium/Standard tier to Hyperscale tier.<p><p>When manualCutover is specified, the scaling operation will wait for user input to trigger cutover to Hyperscale database.<p><p>To trigger cutover, please provide 'performCutover' parameter when the Scaling operation is in Waiting state. |
| [`maxSizeBytes`](#parameter-maxsizebytes) | int | The max size of the database expressed in bytes.<p><p>See https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#maxsize for supported sizes.<p> |
| [`minCapacity`](#parameter-mincapacity) | string | Minimal capacity that database will always have allocated, if not paused. Integers or decimal values. Default: empty. |
| [`performCutover`](#parameter-performcutover) | bool | To trigger customer controlled manual cutover during the wait state while Scaling operation is in progress.<p><p>This property parameter is only applicable for scaling operations that are initiated along with 'manualCutover' parameter.<p><p>This property is only applicable when scaling database from Business Critical/General Purpose/Premium/Standard tier to Hyperscale tier is already in progress.<p><p>When performCutover is specified, the scaling operation will trigger cutover and perform role-change to Hyperscale database.<p> |
| [`preferredEnclaveType`](#parameter-preferredenclavetype) | string | Type of enclave requested on the database i.e. Default or VBS enclaves. |
| [`readScale`](#parameter-readscale) | string | The state of read-only routing. |
| [`recoveryServicesRecoveryPointResourceId`](#parameter-recoveryservicesrecoverypointresourceid) | string | Resource ID of backup if createMode set to RestoreLongTermRetentionBackup. |
| [`requestedBackupStorageRedundancy`](#parameter-requestedbackupstorageredundancy) | string | The storage account type to be used to store backups for this database. Default: Zone. |
| [`restorePointInTime`](#parameter-restorepointintime) | string | Point in time (ISO8601 format) of the source database to restore when createMode set to Restore or PointInTimeRestore. |
| [`sampleName`](#parameter-samplename) | string | The name of the sample schema to apply when creating this database. |
| [`secondaryType`](#parameter-secondarytype) | string | The secondary type of the database if it is a secondary. Valid values are Geo, Named and Standby. Default: empty |
| [`skuCapacity`](#parameter-skucapacity) | int | Capacity of the particular SKU. |
| [`skuFamily`](#parameter-skufamily) | string | If the service has different generations of hardware, for the same SKU, then that can be captured here. |
| [`skuName`](#parameter-skuname) | string | The name (ServiceObjective) of the SKU, typically, one or more letters (Edition) + optionally a Number (Capacity code), e.g. P3, S1, GP_Gen5, GP_Gen5_2. Default: GP_Gen5_2.<p><p>The list of SKUs may vary by region and support offer.To determine the SKUs (including the SKU name, tier/edition, family, and capacity) that are available to your subscription in an Azure region,<p>use the Capabilities_ListByLocation REST API or one of the following commands:<p><p>Azure CLI: `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.<p><p>Azure PowerShell: Get-AzSqlServerServiceObjective -Location {location}<p> |
| [`skuSize`](#parameter-skusize) | string | Size of the particular SKU. |
| [`skuTier`](#parameter-skutier) | string | The skuTier or edition of the particular SKU. |
| [`sourceDatabaseDeletionDate`](#parameter-sourcedatabasedeletiondate) | string | The time that the database was deleted when restoring a deleted database. |
| [`sourceDatabaseResourceId`](#parameter-sourcedatabaseresourceid) | string | Resource ID of database if createMode set to Copy, Secondary, PointInTimeRestore, Recovery or Restore. |
| [`sourceResourceId`](#parameter-sourceresourceid) | string | The resource identifier of the source associated with the create operation of this database.<p>This property is only supported for DataWarehouse edition and allows to restore across subscriptions.<p><p>Please see the https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep#databaseproperties page for explanation.<p> |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`useFreeLimit`](#parameter-usefreelimit) | bool | Whether or not the database uses free monthly limits. Allowed on one database in a subscription. |
| [`zoneRedundant`](#parameter-zoneredundant) | bool | Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.<p>Default: 'true' if skuName is not S or B type. |

### Parameter: `name`

The name of the database.

- Required: Yes
- Type: string

### Parameter: `serverName`

The name of the parent SQL Server. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `autoPauseDelay`

Time in minutes after which database is automatically paused. A value of -1 means that automatic pause is disabled.

- Required: No
- Type: int
- Default: `0`

### Parameter: `backupLongTermRetentionPolicy`

The long term backup retention policy to create for the database. Default: weekly=P1W, monthly=P4W, and yearly=P520W. 

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`monthlyRetention`](#parameter-backuplongtermretentionpolicymonthlyretention) | string | Weekly retention in ISO 8601 duration format. Default: 'P1M'.<p><p>If you specify a value, the first backup of each month is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed. |
| [`weeklyRetention`](#parameter-backuplongtermretentionpolicyweeklyretention) | string | Monthly retention in ISO 8601 duration format. Default: 'P1W'.<p><p>If you specify a value, one backup every week is copied to long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed. |
| [`weekOfYear`](#parameter-backuplongtermretentionpolicyweekofyear) | int | Week of year backup to keep for yearly retention. Default: 1.<p><p>If the specified WeekOfYear is in the past when the policy is configured, the first LTR backup is created the following year.<p> |
| [`yearlyRetention`](#parameter-backuplongtermretentionpolicyyearlyretention) | string | Yearly retention in ISO 8601 duration format. Default: 'P1Y'.<p><p>If you specify a value, one backup during the week specified by WeekOfYear is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed. |

### Parameter: `backupLongTermRetentionPolicy.monthlyRetention`

Weekly retention in ISO 8601 duration format. Default: 'P1M'.<p><p>If you specify a value, the first backup of each month is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed.

- Required: No
- Type: string

### Parameter: `backupLongTermRetentionPolicy.weeklyRetention`

Monthly retention in ISO 8601 duration format. Default: 'P1W'.<p><p>If you specify a value, one backup every week is copied to long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed.

- Required: No
- Type: string

### Parameter: `backupLongTermRetentionPolicy.weekOfYear`

Week of year backup to keep for yearly retention. Default: 1.<p><p>If the specified WeekOfYear is in the past when the policy is configured, the first LTR backup is created the following year.<p>

- Required: No
- Type: int

### Parameter: `backupLongTermRetentionPolicy.yearlyRetention`

Yearly retention in ISO 8601 duration format. Default: 'P1Y'.<p><p>If you specify a value, one backup during the week specified by WeekOfYear is copied to the long-term storage, and deleted after the specified period.<p>If an empty ('') value is provided, the setting is removed.

- Required: No
- Type: string

### Parameter: `backupShortTermRetentionPolicy`

The short term backup retention policy to create for the database. Default: retentionDays=7, diffBackupIntervalInHours=24

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      diffBackupIntervalInHours: 24
      retentionDays: 7
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`diffBackupIntervalInHours`](#parameter-backupshorttermretentionpolicydiffbackupintervalinhours) | int | The differential backup interval in hours.<p>This is how many interval hours between each differential backup will be supported.<p>Only applicable to live databases but not dropped databases. |
| [`retentionDays`](#parameter-backupshorttermretentionpolicyretentiondays) | int | The backup retention period in days. This is how many days Point-in-Time Restore will be supported.<p>Basic-tier databases are limited to a maximum of 7 days. For all databases, the maximum is 35 days. |

### Parameter: `backupShortTermRetentionPolicy.diffBackupIntervalInHours`

The differential backup interval in hours.<p>This is how many interval hours between each differential backup will be supported.<p>Only applicable to live databases but not dropped databases.

- Required: No
- Type: int
- Allowed:
  ```Bicep
  [
    12
    24
  ]
  ```

### Parameter: `backupShortTermRetentionPolicy.retentionDays`

The backup retention period in days. This is how many days Point-in-Time Restore will be supported.<p>Basic-tier databases are limited to a maximum of 7 days. For all databases, the maximum is 35 days.

- Required: No
- Type: int

### Parameter: `catalogCollation`

Collation of the metadata catalog.

- Required: No
- Type: string
- Default: `'SQL_Latin1_General_CP1_CI_AS'`
- Allowed:
  ```Bicep
  [
    'DATABASE_DEFAULT'
    'SQL_Latin1_General_CP1_CI_AS'
  ]
  ```

### Parameter: `collation`

The collation of the database. Default: SQL_Latin1_General_CP1_CI_AS

- Required: No
- Type: string
- Default: `'SQL_Latin1_General_CP1_CI_AS'`

### Parameter: `createMode`

Specifies the mode of database creation. Default: 'Default'.<p><p>Please see https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep#databaseproperties for parameter value explanation.<p>

- Required: No
- Type: string
- Default: `'Default'`
- Allowed:
  ```Bicep
  [
    'Copy'
    'Default'
    'OnlineSecondary'
    'PointInTimeRestore'
    'Recovery'
    'Restore'
    'RestoreExternalBackupSecondary'
    'RestoreLongTermRetentionBackup'
    'Secondary'
  ]
  ```

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

### Parameter: `elasticPoolId`

The resource ID of the elastic pool containing this database.

- Required: No
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `freeLimitExhaustionBehavior`

Specifies the behavior when monthly free limits are exhausted for the free database. Default: 'BillOverUsage'.<p><p>AutoPause: The database will be auto paused upon exhaustion of free limits for remainder of the month.<p>BillForUsage: The database will continue to be online upon exhaustion of free limits and any overage will be billed.

- Required: No
- Type: string
- Default: `'BillOverUsage'`
- Allowed:
  ```Bicep
  [
    'AutoPause'
    'BillOverUsage'
  ]
  ```

### Parameter: `highAvailabilityReplicaCount`

The number of secondary replicas associated with the database that are used to provide high availability. Not applicable to a Hyperscale database within an elastic pool. Default: 0

- Required: No
- Type: int
- Default: `0`

### Parameter: `isLedgerOn`

Whether or not this database is a ledger database, which means all tables in the database are ledger tables.<p>Note: the value of this property cannot be changed after the database has been created.<p>Default: false

- Required: No
- Type: bool
- Default: `False`

### Parameter: `licenseType`

The license type to apply for this database.<p>LicenseIncluded if you need a license, or BasePrice if you have a license and are eligible for the Azure Hybrid Benefit.<p>Default: 'LicenseIncluded'<p>

- Required: No
- Type: string
- Default: `'LicenseIncluded'`
- Allowed:
  ```Bicep
  [
    'BasePrice'
    'LicenseIncluded'
  ]
  ```

### Parameter: `location`

Location for all resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `maintenanceConfigurationId`

Maintenance configuration ID assigned to the database. This configuration defines the period when the maintenance updates will occur.

- Required: No
- Type: string
- Default: `''`

### Parameter: `manualCutover`

Whether or not customer controlled manual cutover needs to be done during Update Database operation to Hyperscale tier.<p><p>This property is only applicable when scaling database from Business Critical/General Purpose/Premium/Standard tier to Hyperscale tier.<p><p>When manualCutover is specified, the scaling operation will wait for user input to trigger cutover to Hyperscale database.<p><p>To trigger cutover, please provide 'performCutover' parameter when the Scaling operation is in Waiting state.

- Required: No
- Type: bool

### Parameter: `maxSizeBytes`

The max size of the database expressed in bytes.<p><p>See https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=azuresqldb-current&tabs=sqlpool#maxsize for supported sizes.<p>

- Required: No
- Type: int

### Parameter: `minCapacity`

Minimal capacity that database will always have allocated, if not paused. Integers or decimal values. Default: empty.

- Required: No
- Type: string
- Default: `''`

### Parameter: `performCutover`

To trigger customer controlled manual cutover during the wait state while Scaling operation is in progress.<p><p>This property parameter is only applicable for scaling operations that are initiated along with 'manualCutover' parameter.<p><p>This property is only applicable when scaling database from Business Critical/General Purpose/Premium/Standard tier to Hyperscale tier is already in progress.<p><p>When performCutover is specified, the scaling operation will trigger cutover and perform role-change to Hyperscale database.<p>

- Required: No
- Type: bool

### Parameter: `preferredEnclaveType`

Type of enclave requested on the database i.e. Default or VBS enclaves.

- Required: No
- Type: string
- Default: `''`
- Allowed:
  ```Bicep
  [
    ''
    'Default'
    'VBS'
  ]
  ```

### Parameter: `readScale`

The state of read-only routing.

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

### Parameter: `recoveryServicesRecoveryPointResourceId`

Resource ID of backup if createMode set to RestoreLongTermRetentionBackup.

- Required: No
- Type: string
- Default: `''`

### Parameter: `requestedBackupStorageRedundancy`

The storage account type to be used to store backups for this database. Default: Zone.

- Required: No
- Type: string
- Default: `'Zone'`
- Allowed:
  ```Bicep
  [
    ''
    'Geo'
    'GeoZone'
    'Local'
    'Zone'
  ]
  ```

### Parameter: `restorePointInTime`

Point in time (ISO8601 format) of the source database to restore when createMode set to Restore or PointInTimeRestore.

- Required: No
- Type: string
- Default: `''`

### Parameter: `sampleName`

The name of the sample schema to apply when creating this database.

- Required: No
- Type: string
- Default: `''`
- Allowed:
  ```Bicep
  [
    ''
    'AdventureWorksLT'
    'WideWorldImportersFull'
    'WideWorldImportersStd'
  ]
  ```

### Parameter: `secondaryType`

The secondary type of the database if it is a secondary. Valid values are Geo, Named and Standby. Default: empty

- Required: No
- Type: string
- Default: `''`
- Allowed:
  ```Bicep
  [
    ''
    'Geo'
    'Named'
    'Standby'
  ]
  ```

### Parameter: `skuCapacity`

Capacity of the particular SKU.

- Required: No
- Type: int

### Parameter: `skuFamily`

If the service has different generations of hardware, for the same SKU, then that can be captured here.

- Required: No
- Type: string
- Default: `''`

### Parameter: `skuName`

The name (ServiceObjective) of the SKU, typically, one or more letters (Edition) + optionally a Number (Capacity code), e.g. P3, S1, GP_Gen5, GP_Gen5_2. Default: GP_Gen5_2.<p><p>The list of SKUs may vary by region and support offer.To determine the SKUs (including the SKU name, tier/edition, family, and capacity) that are available to your subscription in an Azure region,<p>use the Capabilities_ListByLocation REST API or one of the following commands:<p><p>Azure CLI: `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.<p><p>Azure PowerShell: Get-AzSqlServerServiceObjective -Location {location}<p>

- Required: No
- Type: string
- Default: `'GP_Gen5_2'`

### Parameter: `skuSize`

Size of the particular SKU.

- Required: No
- Type: string
- Default: `''`

### Parameter: `skuTier`

The skuTier or edition of the particular SKU.

- Required: No
- Type: string

### Parameter: `sourceDatabaseDeletionDate`

The time that the database was deleted when restoring a deleted database.

- Required: No
- Type: string
- Default: `''`

### Parameter: `sourceDatabaseResourceId`

Resource ID of database if createMode set to Copy, Secondary, PointInTimeRestore, Recovery or Restore.

- Required: No
- Type: string
- Default: `''`

### Parameter: `sourceResourceId`

The resource identifier of the source associated with the create operation of this database.<p>This property is only supported for DataWarehouse edition and allows to restore across subscriptions.<p><p>Please see the https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/databases?pivots=deployment-language-bicep#databaseproperties page for explanation.<p>

- Required: No
- Type: string
- Default: `''`

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `useFreeLimit`

Whether or not the database uses free monthly limits. Allowed on one database in a subscription.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `zoneRedundant`

Whether or not this database is zone redundant, which means the replicas of this database will be spread across multiple availability zones.<p>Default: 'true' if skuName is not S or B type.

- Required: No
- Type: bool
- Default: `[not(or(startsWith(parameters('skuName'), 'S'), startsWith(parameters('skuName'), 'B')))]`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the deployed database. |
| `resourceGroupName` | string | The resource group of the deployed database. |
| `resourceId` | string | The resource ID of the deployed database. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
