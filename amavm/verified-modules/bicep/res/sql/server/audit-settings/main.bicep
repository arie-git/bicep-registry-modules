metadata name = 'Azure SQL Server Audit Settings'
metadata description = 'This module deploys an Azure SQL Server Audit Settings.'
metadata owner = 'AMCCC'

@description('Required. The name of the audit settings. Default: DefaultAuditingSettings')
param name string = 'DefaultAuditingSettings'

@description('Conditional. The Name of SQL Server. Required if the template is used in a standalone deployment.')
param serverName string

@description('''Required. Specifies the state of the audit.

If state is Enabled, storageAccountResourceId or isAzureMonitorTargetEnabled are required.''')
@allowed([
  'Enabled'
  'Disabled'
])
param state string

@description('''Optional. Specifies the Actions-Groups and Actions to audit.


Please see https://learn.microsoft.com/en-gb/azure/templates/microsoft.sql/servers/auditingsettings?pivots=deployment-language-bicep#serverblobauditingpolicyproperties for explanation.
''')
param auditActionsAndGroups string[] = [
  'BATCH_COMPLETED_GROUP'
  'SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP'
  'FAILED_DATABASE_AUTHENTICATION_GROUP'
]

@description('''Conditional. Specifies whether audit events are sent to Azure Monitor. Default: true.

In order to send the events to Azure Monitor, specify 'State' as 'Enabled' and 'IsAzureMonitorTargetEnabled' as true.
''')
param isAzureMonitorTargetEnabled bool = true

@description('''Optional. Specifies the state of devops audit. Default: true.

In order to send the events to Azure Monitor, specify 'State' as 'Enabled' and 'IsAzureMonitorTargetEnabled' as true.
''')
param isDevopsAuditEnabled bool = true

@description('Optional. Specifies whether Managed Identity is used to access blob storage. Default: true.')
param isManagedIdentityInUse bool = true

@description('Optional. Specifies whether storageAccountAccessKey value is the storage\'s secondary key. Default: false.')
param isStorageSecondaryKeyInUse bool = false

@description('Optional. Specifies the amount of time in milliseconds that can elapse before audit actions are forced to be processed. Default: 1000.')
@minValue(1000)
@maxValue(2147483647)
param queueDelayMs int = 1000

@description('Optional. Specifies the number of days to keep in the audit logs in the storage account. Default: 90.')
param retentionDays int = 90

@description('Conditional. A blob storage to hold the auditing for storage account.')
param storageAccountResourceId string = ''

@description('''Optional. Resource ID of the diagnostic log analytics workspace. Default: empty.

If provided and isAzureMonitorTargetEnabled=true the 'master' database will be configured to send audit logs to the Log Analytics.''')
param workspaceResourceId string?


resource server 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: serverName
}

// Assign SQL Server MSI access to storage account
var rbacResourceGroupName = (isManagedIdentityInUse && !empty(storageAccountResourceId))
    ? split(storageAccountResourceId!, '/')[4]
    : resourceGroup().name
var rbacSubscriptionId = (isManagedIdentityInUse && !empty(storageAccountResourceId))
    ? split(storageAccountResourceId!, '/')[2]
    : subscription().id
module storageAccount_sbdc_rbac 'modules/nested_storageRoleAssignment.bicep' = if (isManagedIdentityInUse && !empty(storageAccountResourceId)) {
  name: '${server.name}-stau-rbac'
  scope: resourceGroup(rbacSubscriptionId, rbacResourceGroupName)
  params: {
    storageAccountName: last(split(storageAccountResourceId!, '/'))
    managedInstanceIdentityPrincipalId: server.identity.principalId
  }
}

resource auditSettings 'Microsoft.Sql/servers/auditingSettings@2023-05-01-preview' = {
  name: name
  parent: server
  properties: {
    state: state
    auditActionsAndGroups: auditActionsAndGroups
    isAzureMonitorTargetEnabled: isAzureMonitorTargetEnabled
    isDevopsAuditEnabled: isDevopsAuditEnabled
    isManagedIdentityInUse: isManagedIdentityInUse
    isStorageSecondaryKeyInUse: isStorageSecondaryKeyInUse
    queueDelayMs: queueDelayMs
    retentionDays: retentionDays
    storageAccountAccessKey: !empty(storageAccountResourceId) && !isManagedIdentityInUse
      ? listKeys(storageAccountResourceId, '2019-06-01').keys[0].value
      : any(null)
    storageAccountSubscriptionId: !empty(storageAccountResourceId) ? split(storageAccountResourceId, '/')[2] : any(null)
    storageEndpoint: !empty(storageAccountResourceId)
      ? 'https://${last(split(storageAccountResourceId, '/'))}.blob.${environment().suffixes.storage}'
      : any(null)
  }
}

resource masterDb 'Microsoft.Sql/servers/databases@2023-05-01-preview' existing = if (isAzureMonitorTargetEnabled && !empty(workspaceResourceId)) {
  parent: server
  name: 'master'
}

#disable-next-line use-recent-api-versions
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (isAzureMonitorTargetEnabled && !empty(workspaceResourceId)) {
  scope: masterDb
  name: 'SQLSecurityAuditLogs'
  properties: {
    workspaceId: workspaceResourceId
    logs: union([
      {
        category: 'SQLSecurityAuditEvents'
        enabled: true
      }],
      isDevopsAuditEnabled ? [
      {
        category: 'DevOpsOperationsAudit'
        enabled: true
      }] : []
    )
  }
}

@description('The name of the deployed audit settings.')
output name string = auditSettings.name

@description('The resource ID of the deployed audit settings.')
output resourceId string = auditSettings.id

@description('The resource group of the deployed audit settings.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

@export()
type auditSettingsType = {
  @description('Optional. Specifies the name of the audit setting.')
  name: string?

  @description('Optional. Specifies the Actions-Groups and Actions to audit.')
  auditActionsAndGroups: string[]?

  @description('Optional. Specifies whether audit events are sent to Azure Monitor. If true, the workspaceResourceId also needs to be provided.')
  isAzureMonitorTargetEnabled: bool?

  @description('Optional. Specifies the state of devops audit. If state is Enabled, devops logs will be sent to Azure Monitor.')
  isDevopsAuditEnabled: bool?

  @description('Optional. Specifies whether Managed Identity is used to access blob storage.')
  isManagedIdentityInUse: bool?

  @description('Optional. Specifies whether storageAccountAccessKey value is the storage\'s secondary key.')
  isStorageSecondaryKeyInUse: bool?

  @description('Optional. Specifies the amount of time in milliseconds that can elapse before audit actions are forced to be processed.')
  queueDelayMs: int?

  @description('Optional. Specifies the number of days to keep in the audit logs in the storage account.')
  retentionDays: int?

  @description('Required. Specifies the state of the audit setting. If state is Enabled, storageEndpoint or isAzureMonitorTargetEnabled are required.')
  state: 'Enabled' | 'Disabled'

  @description('Optional. Specifies the identifier key of the storage account that audit logs will be sent to.')
  storageAccountResourceId: string?

  @description('Optional. Resource ID of the log analytics workspace that audit logs will be sent to.')
  workspaceResourceId: string?
}
