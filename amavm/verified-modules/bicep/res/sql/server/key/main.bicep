metadata name = 'Azure SQL Server Keys'
metadata description = 'This module deploys an Azure SQL Server Key.'
metadata owner = 'AMCCC'
metadata compliance = 'inherited from parent'
metadata complianceVersion = '20260309'

@description('Optional. The name of the key. Must follow the [<keyVaultName>_<keyName>_<keyVersion>] pattern.')
param name string?

@description('Conditional. The name of the SQL server. Required if the template is used in a standalone deployment.')
param serverName string

@description('Optional. The encryption protector type like "ServiceManaged", "AzureKeyVault". Default: ServiceManaged.')
@allowed([
  'AzureKeyVault'
  'ServiceManaged'
])
param serverKeyType string = 'ServiceManaged'

@description('''Optional. The URI of the key. If the ServerKeyType is AzureKeyVault, then either the URI or the keyVaultName/keyName combination is required.
The AKV URI is required to be in this format: 'https://YourVaultName.vault.azure.net/keys/YourKeyName/YourKeyVersion'
''')
param uri string = ''

var splittedKeyUri = split(uri, '/')

// if serverManaged, use serverManaged, if uri provided use concated uri value
// MUST match the pattern '<keyVaultName>_<keyName>_<keyVersion>'
var serverKeyName = empty(uri)
  ? 'ServiceManaged'
  : '${split(splittedKeyUri[2], '.')[0]}_${splittedKeyUri[4]}_${splittedKeyUri[5]}'

resource server 'Microsoft.Sql/servers@2023-08-01' existing = {
  name: serverName
}

resource key 'Microsoft.Sql/servers/keys@2023-08-01' = {
  name: name ?? serverKeyName
  parent: server
  properties: {
    serverKeyType: serverKeyType
    uri: uri
  }
}

@description('The name of the deployed server key.')
output name string = key.name

@description('The resource ID of the deployed server key.')
output resourceId string = key.id

@description('The resource group of the deployed server key.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

@export()
type keyType = {
  @description('Optional. The name of the key. Must follow the [<keyVaultName>_<keyName>_<keyVersion>] pattern.')
  name: string?

  @description('Optional. The encryption protector type like "ServiceManaged", "AzureKeyVault". Default: ServiceManaged.')
  serverKeyType: 'ServiceManaged' | 'AzureKeyVault'

  @description('''Optional. The URI of the key. If the ServerKeyType is AzureKeyVault, then either the URI or the keyVaultName/keyName combination is required.
  The AKV URI is required to be in this format: 'https://YourVaultName.vault.azure.net/keys/YourKeyName/YourKeyVersion'
  ''')
  uri: string?
}

@description('Evidence of non-compliance (inherited from parent).')
output evidenceOfNonCompliance bool = false
