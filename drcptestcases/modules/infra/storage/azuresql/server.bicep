param location string = resourceGroup().location

param tags object = {}

@description('''Required. The name of the Sql Server.
Must be unique across Azure.
Valid characters: Lowercase letters, numbers, and hyphens. Can't start or end with hyphen.
''')
@minLength(1)
@maxLength(63)
param sqlServerName string

@description('Whether to allow only Azure AD authentication for server login.')
param azureADOnlyAuthentication bool = true

@description('The display name of the Sql Server administrator user or group.')
param serverAdministratorLoginName string
@description('The SID (object ID from AAD) of the Sql Server administrator user or group.')
param serverAdministratorSid string

@allowed([
  'Application'
  'Group'
  'User'
])
param aadAdministratorPrincipalType string

@description('The public network access to the SQL Server. Default: Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

resource azSqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: 'Enabled'
    administrators: (serverAdministratorSid !='') ? {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: azureADOnlyAuthentication ? true : null
      principalType: aadAdministratorPrincipalType
      login: serverAdministratorLoginName
      sid: serverAdministratorSid
      tenantId: tenant().tenantId
    } : null
  }
  tags: tags
}

output name string = azSqlServer.name
output id string = azSqlServer.id
output fullyQualifiedDomainName string = azSqlServer.properties.fullyQualifiedDomainName
