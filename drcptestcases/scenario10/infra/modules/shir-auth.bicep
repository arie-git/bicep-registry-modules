param shIrName string
param adfName string
param keyVaultName string

// Get the ADF
resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

// Save SHIR auth info to keyvault
resource shir 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01'existing = {
  name: shIrName
  parent: adf
}

// Get the keyvault
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

// Save SHIR auth info to keyvault
resource shirAuth1 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: '${shIrName}-auth1'
  properties: {
    value: shir.listAuthKeys().authKey1
  }
}
resource shirAuth2 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: keyVault
  name: '${shIrName}-auth2'
  properties: {
    value: shir.listAuthKeys().authKey2
  }
}
