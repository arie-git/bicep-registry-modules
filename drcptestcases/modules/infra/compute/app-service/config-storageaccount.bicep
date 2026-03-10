param appServiceName string

param storageAccountName string

param shareName string = ''

param mountPath string = ''

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource configAzurestorageaccounts 'Microsoft.Web/sites/config@2021-03-01' = {
  name: '${appServiceName}/azurestorageaccounts'
  properties: {
    storageAccountSettingsName: {
      type: 'AzureFiles'
      accountName: storageAccountName
      shareName: shareName
      mountPath: mountPath
      accessKey: storageAccount.listKeys().keys[0].value
    }
  }
}
