metadata name = 'Azure SQL Server Security Alert Policies'
metadata description = 'This module deploys an Azure SQL Server Security Alert Policy.'
metadata owner = 'AMCCC'

@description('Conditional. The name of the parent SQL Server. Required if the template is used in a standalone deployment.')
param serverName string

@description('''Optional. Specifies an array of alerts that are disabled. Default: empty.
Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, Brute_Force.''')
param disabledAlerts string[]?

@description('Optional. Specifies that the alert is sent to the account administrators. Default: false.')
param emailAccountAdmins bool = false

@description('Optional. Specifies an array of email addresses to which the alert is sent. Default: empty')
param emailAddresses string[]?

@description('Optional. Specifies the number of days to keep in the Threat Detection audit logs. Default: 0')
param retentionDays int = 0

@description('''Optional. Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific database.
Default: Enabled''')
@allowed([
  'Disabled'
  'Enabled'
])
param state string = 'Enabled'

// @description('''Optional. Specifies the access key to the storage account to hold Threat Detection audit logs.
// Default: key1 (primary) of the storage account identified by storageAccountResourceId.''')
// @secure()
// param storageAccountAccessKey string = ''

// @description('''Optional. A blob storage to hold the scan results. This blob storage will hold all Threat Detection audit logs. Default: empty.

// Use either this or storageEndpoint''')
// param storageAccountResourceId string = ''

// #disable-next-line no-hardcoded-env-urls
// @description('''Optional. Specifies the blob storage endpoint (e.g. https://MyAccount.blob.core.windows.net). Default: emppty.

// This blob storage will hold all Threat Detection audit logs.  Use either this or storageAccountResourceId'.''')
// param storageEndpoint string = ''


// @description('''Optional. Use Access Key to access the storage account. The storage account cannot be behind a firewall or virtual network. Default: false.

// If an access key is not used, the SQL Server system assigned managed identity must be created.
// It will be assigned the Storage Blob Data Contributor role on the storage account.''')
// param useStorageAccountAccessKey bool = false

// @description('''Optional. Create the Storage Blob Data Contributor role assignment for SQL Server system managed identity on the storage account. Default: true.

// Note, the role assignment must not already exist on the storage account.''')
// param createStorageRoleAssignment bool = true

// var storageEndpointComposed = !empty(storageEndpoint)
//                               ? storageEndpoint
//                               : !empty(storageAccountResourceId)
//                                 ? 'https://${last(split(storageAccountResourceId, '/'))}.blob.${environment().suffixes.storage}/'
//                                 : null


resource server 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: serverName
}

// module storageAccountRbac 'modules/nested_storageRoleAssignment.bicep' = if (!useStorageAccountAccessKey && createStorageRoleAssignment && !empty(storageAccountResourceId)) {
//   name: take('${deployment().name}-${uniqueString(serverName)}-sqlserver-secalert-rbac',64)
//   scope: !empty(storageAccountResourceId) ? resourceGroup(split(storageAccountResourceId, '/')[2], split(storageAccountResourceId, '/')[4]) : resourceGroup()
//   params: {
//     storageAccountName: !empty(storageAccountResourceId) ? last(split(storageAccountResourceId, '/')) : ''
//     managedInstanceIdentityPrincipalId: server.identity.principalId
//   }
// }

resource securityAlertPolicy 'Microsoft.Sql/servers/securityAlertPolicies@2023-05-01-preview' = {
  name: 'Default'
  parent: server
  properties: {
    disabledAlerts: disabledAlerts
    emailAccountAdmins: emailAccountAdmins
    emailAddresses: emailAddresses
    retentionDays: retentionDays
    state: state
    // storageAccountAccessKey: !useStorageAccountAccessKey || empty(storageEndpointComposed)
    //                           ? null
    //                           : !empty(storageAccountAccessKey)
    //                             ? storageAccountAccessKey
    //                             : !empty(storageAccountResourceId)
    //                               ? listKeys(storageAccountResourceId, '2019-06-01').keys[0].value
    //                               : null
    // storageEndpoint: storageEndpointComposed
  }
  // dependsOn: [
  //   storageAccountRbac
  // ]
}

@description('The name of the deployed security alert policy.')
output name string = securityAlertPolicy.name

@description('The resource ID of the deployed security alert policy.')
output resourceId string = securityAlertPolicy.id

@description('The resource group of the deployed security alert policy.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

@export()
type securityPolicyAlertType = {
  @description('''Optional. Specifies an array of alerts that are disabled. Default: empty.
  Allowed values are: Sql_Injection, Sql_Injection_Vulnerability, Access_Anomaly, Data_Exfiltration, Unsafe_Action, Brute_Force.''')
  disabledAlerts: string[]?

  @description('Optional. Specifies that the alert is sent to the account administrators.')
  emailAccountAdmins: bool?

  @description('Optional. Specifies an array of email addresses to which the alert is sent.')
  emailAddresses: string[]?

  @description('Optional. Specifies the number of days to keep in the Threat Detection audit logs.')
  retentionDays: int?

  @description('Optional. Specifies the state of the policy, whether it is enabled or disabled or a policy has not been applied yet on the specific database.')
  state: ('Enabled' | 'Disabled')?

  // @description('Optional. Specifies the access key to the storage account to hold Threat Detection audit logs.')
  // @secure()
  // storageAccountAccessKey: string?

  // @description('Optional. A blob storage to hold the scan results. Use either this or storageEndpoint.')
  // storageAccountResourceId: string?

  // #disable-next-line no-hardcoded-env-urls
  // @description('''Optional. Specifies the blob storage endpoint (e.g. https://MyAccount.blob.core.windows.net).
  // This blob storage will hold all Threat Detection audit logs. Use either this or storageAccountResourceId''')
  // storageEndpoint: string?

  // @description('''Optional. Use Access Key to access the storage account.
  // The storage account cannot be behind a firewall or virtual network.
  // If an access key is not used, the SQL Server system assigned managed identity must be assigned the Storage Blob Data Contributor role on the storage account.''')
  // useStorageAccountAccessKey: bool?

  // @description('''Optional. Create the Storage Blob Data Contributor role assignment on the storage account.
  // Note, the role assignment must not already exist on the storage account.''')
  // createStorageRoleAssignment: bool?
}
