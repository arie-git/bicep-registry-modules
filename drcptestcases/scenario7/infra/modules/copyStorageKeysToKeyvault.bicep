param keyVaultName string
param keyVaultSecretName string
param storageAccountName string
param attributesExp int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource storageaccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource keyVaultSecret1 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: keyVaultSecretName
  parent: keyVault
  properties: {
    //value: storageaccount.listKeys().keys[0].value
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${storageaccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    attributes:{
      enabled: true
      exp: attributesExp
    }
  }
}

output keyVaultSecretName string = keyVaultSecret1.name
