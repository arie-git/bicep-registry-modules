//Store the keys and connection strings of the Cosmos DB in key vault
@description('Required. Name of the Cosmos Database.')
param cosmosDbName string

@description('Required. Name of the Key Vault.')
param keyVaultName string

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2023-03-01-preview' existing = {
  name: cosmosDbName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

module setSecretConnectionString '../../security/keyvault/modules/secrets.bicep' = {
  name: 'cosmosDB-secret-connectionString1'
  params: {
    keyVaultName: keyVault.name
    secretName: '${cosmosDb.name}-connectionString1'
    secretValue: cosmosDb.listConnectionStrings().connectionStrings[0].connectionString
  }
}

module setSecretConnectionString1 '../../security/keyvault/modules/secrets.bicep' = {
  name: 'cosmosDB-secret-connectionString2'
  params: {
    keyVaultName: keyVault.name
    secretName: '${cosmosDb.name}-connectionString2'
    secretValue: cosmosDb.listConnectionStrings().connectionStrings[1].connectionString
  }
}

module setSecretPrimaryKey '../../security/keyvault/modules/secrets.bicep' = {
  name: 'cosmosDB-secret-primaryKey'
  params: {
    keyVaultName: keyVault.name
    secretName: '${cosmosDb.name}-primaryKey'
    secretValue: cosmosDb.listKeys().primaryMasterKey
  }
}
module setSecretSecondryKey '../../security/keyvault/modules/secrets.bicep' = {
  name: 'cosmosDB-secret-secondaryKey'
  params: {
    keyVaultName: keyVault.name
    secretName: '${cosmosDb.name}-secondaryKey'
    secretValue: cosmosDb.listKeys(). secondaryMasterKey
  }
}
