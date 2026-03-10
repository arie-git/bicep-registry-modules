param location string = resourceGroup().location

param tags object = {}

param sqlDbName string
param sqlServerName string
param contactEmail string = ''
param collation string = 'SQL_Latin1_General_CP1_CI_AS'
param catalogCollation string = 'SQL_Latin1_General_CP1_CI_AS'
param zoneRedundant bool = false
param requestedBackupStorageRedundancy string = 'Geo'

// https://learn.microsoft.com/en-us/azure/templates/microsoft.sql/servers/databases?tabs=bicep&pivots=deployment-language-bicep#sku

@description('''The name (ServiceObjective) of the SKU, typically, a letter (Edition) + Number code (Capacity code), e.g. P3, S1, GP_Gen5_2.
Use AZ CLI `az sql db list-editions -l {location} -o table` and find option in ServiceObjective column.
Default: S1
''')
param skuName string = 'S1'

// @description('SQL Server edition. Default: GeneralPurpose') // az sql db list-editions -l {location} -o table
// @allowed([
//   // vCore-based service tiers
//   'GeneralPurpose'
//   'BusinessCritical'
//   //'Hyperscale'
//   // DTU-based tiers
//   'Basic'
//   'Standard'
//   'Premium'
// ])
// param skuTier string = 'Standard'

// @description('Optional. For vCore-based editions. Different generations of hardware, for the same SKU.')
// @allowed([
//   'Gen5'
//   'DC'
//   'Fsv2'
//   ''
// ])
// param skuFamily string = 'Gen5'

// param skuCapacity int = 2

param readScale string = 'Disabled'

param logAnalyticsWorkspaceId string = ''


resource sqlServer 'Microsoft.Sql/servers@2014-04-01' existing ={
  name: sqlServerName
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  name: sqlDbName
  parent: sqlServer
  location: location
  properties: {
    collation: collation
    //maxSizeBytes: 68719476736
    catalogCollation: catalogCollation
    zoneRedundant: zoneRedundant
    licenseType: 'LicenseIncluded'
    readScale: readScale
    requestedBackupStorageRedundancy: requestedBackupStorageRedundancy
    isLedgerOn: false
  }
  sku: {
    name: skuName
    // tier: skuTier
    // family: skuFamily
    // capacity: skuCapacity
  }
  tags: tags
}

resource lngTermBk 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2021-11-01' = {
  name: 'default'
  parent: sqlDatabase
  properties: {
    weeklyRetention: 'P1W'
    monthlyRetention: 'P4W'
    yearlyRetention: 'P520W'
    weekOfYear: 1
  }
}

resource shtTermBk 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2021-11-01' = {
  name: 'default'
  parent: sqlDatabase
  properties:{
    diffBackupIntervalInHours: 12
    retentionDays: 7
  }
}

resource geoBackup 'Microsoft.Sql/servers/databases/geoBackupPolicies@2014-04-01' = {
  name: 'default'
  parent: sqlDatabase
  properties:{
    state: 'Enabled'
  }
}

resource vulAssessment 'Microsoft.Sql/servers/databases/vulnerabilityAssessments@2021-11-01' = if(contactEmail!='') {
  name: 'default'
  parent: sqlDatabase
  properties: {
    recurringScans:{
      isEnabled: true
      emails:[
        contactEmail
      ]
    }
  }
}

var diagName = '${sqlDbName}diag'

resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if(logAnalyticsWorkspaceId!='') {
  name: diagName
  scope: sqlDatabase
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'SQLInsights'
        enabled: true
      }
      {
        category: 'AutomaticTuning'
        enabled: true
      }
      {
        category: 'QueryStoreRuntimeStatistics'
        enabled: true
      }
      {
        category: 'QueryStoreWaitStatistics'
        enabled: true
      }
      {
        category: 'Errors'
        enabled: true
      }
      {
        category: 'DatabaseWaitStatistics'
        enabled: true
      }
      {
        category: 'Timeouts'
        enabled: true
      }
      {
        category: 'Blocks'
        enabled: true
      }
      {
        category: 'Deadlocks'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Basic'
        enabled: true
      }
      {
        category: 'InstanceAndAppAdvanced'
        enabled: true
      }
      {
        category: 'WorkloadManagement'
        enabled: true
      }
    ]
  }
}

output name string = sqlDatabase.name
