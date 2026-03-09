metadata name = 'SQL Server Database Long Term Backup Retention Policies'
metadata description = 'This module deploys an Azure SQL Server Database Long-Term Backup Retention Policy.'
metadata owner = 'AMCCC'

@description('Required. The name of the parent SQL Server.')
param serverName string

@description('Required. The name of the database.')
param databaseName string


@description('''Optional. Monthly retention in ISO 8601 duration format, e.g. \'P1W\'. Default: P1W.

If you specify a value, one backup every week is copied to long-term storage, and deleted after the specified period.
If an empty value is provided, the setting is removed.''')
param weeklyRetention string = 'P1W'

@description('''Optional. Weekly retention in ISO 8601 duration format, e.g. \'P1M\'. Default: P1M.

If you specify a value, the first backup of each month is copied to the long-term storage, and deleted after the specified period.
If an empty value is provided, the setting is removed.''')

param monthlyRetention string = 'P1M'

@description('''Optional. Week of year backup to keep for yearly retention. Default: 1.

If the specified WeekOfYear is in the past when the policy is configured, the first LTR backup is created the following year.''')
param weekOfYear int = 1

@description('''Optional. Yearly retention in ISO 8601 duration format. Default: P1Y.

If you specify a value, one backup during the week specified by WeekOfYear is copied to the long-term storage, and deleted after the specified period.
If an empty value is provided, the setting is removed.''')
param yearlyRetention string = 'P1Y'


resource server 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: serverName

  resource database 'databases@2023-08-01' existing = {
    name: databaseName
  }
}

resource backupLongTermRetentionPolicy 'Microsoft.Sql/servers/databases/backupLongTermRetentionPolicies@2023-08-01' = {
  name: 'default'
  parent: server::database
  properties: {
    monthlyRetention: !empty(monthlyRetention) ? monthlyRetention : null
    weeklyRetention: !empty(weeklyRetention) ? weeklyRetention : null
    weekOfYear: !empty(yearlyRetention) ? weekOfYear ?? 1 : null
    yearlyRetention: !empty(yearlyRetention) ? yearlyRetention : null
    // remaining properties are not implementable
  }
}

@description('The resource group the long-term policy was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the long-term policy.')
output name string = backupLongTermRetentionPolicy.name

@description('The resource ID of the long-term policy.')
output resourceId string = backupLongTermRetentionPolicy.id

// =============== //
//   Definitions   //
// =============== //

@export()
type backupLongTermRetentionPolicyType = {
  @description('''Optional. Monthly retention in ISO 8601 duration format. Default: 'P1W'.

  If you specify a value, one backup every week is copied to long-term storage, and deleted after the specified period.
  If an empty ('') value is provided, the setting is removed.''')
  weeklyRetention: string?

  @description('''Optional. Weekly retention in ISO 8601 duration format. Default: 'P1M'.

  If you specify a value, the first backup of each month is copied to the long-term storage, and deleted after the specified period.
  If an empty ('') value is provided, the setting is removed.''')
  monthlyRetention: string?

  @description('''Optional. Week of year backup to keep for yearly retention. Default: 1.

  If the specified WeekOfYear is in the past when the policy is configured, the first LTR backup is created the following year.
  ''')
  weekOfYear: int?

  @description('''Optional. Yearly retention in ISO 8601 duration format. Default: 'P1Y'.

  If you specify a value, one backup during the week specified by WeekOfYear is copied to the long-term storage, and deleted after the specified period.
  If an empty ('') value is provided, the setting is removed.''')
  yearlyRetention: string?
}
