metadata name = 'Azure SQL Server Database Short Term Backup Retention Policies'
metadata description = 'This module deploys an Azure SQL Server Database Short-Term Backup Retention Policy.'
metadata owner = 'AMCCC'
metadata compliance = 'inherited from parent'
metadata complianceVersion = '20260309'

@description('Required. The name of the parent SQL Server.')
param serverName string

@description('Required. The name of the database.')
param databaseName string

@description('''Optional. The differential backup interval in hours. Default: 24

This is how many interval hours between each differential backup will be supported. Available option: 12 and 24.
Only applicable to live databases but not dropped databases.''')
@allowed([
  12
  24
])
param diffBackupIntervalInHours int = 24

@description('''Optional. The backup retention period in days. This is how many days Point-in-Time Restore will be supported. Default: 7

Basic-tier databases are limited to a maximum of 7 days. For all databases, the maximum is 35 days.
''')
@minValue(1)
@maxValue(35)
param retentionDays int = 7

resource server 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: serverName

  resource database 'databases@2023-08-01' existing = {
    name: databaseName
  }
}

resource backupShortTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupShortTermRetentionPolicies@2023-08-01' = {
  name: 'default'
  parent: server::database
  properties: {
    diffBackupIntervalInHours: diffBackupIntervalInHours
    retentionDays: retentionDays
  }
}

@description('The resource group the short-term policy was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the short-term policy.')
output name string = backupShortTermRetentionPolicy.name

@description('The resource ID of the short-term policy.')
output resourceId string = backupShortTermRetentionPolicy.id

// =============== //
//   Definitions   //
// =============== //

@export()
type backupShortTermRetentionPolicyType = {
  @description('''Optional. The differential backup interval in hours.
  This is how many interval hours between each differential backup will be supported.
  Only applicable to live databases but not dropped databases.''')
  diffBackupIntervalInHours: (12 | 24)?

  @description('''Optional. The backup retention period in days. This is how many days Point-in-Time Restore will be supported.
  Basic-tier databases are limited to a maximum of 7 days. For all databases, the maximum is 35 days.''')
  retentionDays: int?
}

@description('Evidence of non-compliance (inherited from parent).')
output evidenceOfNonCompliance bool = false
