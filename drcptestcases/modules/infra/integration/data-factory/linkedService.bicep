@description('Name of the data factory. Required.')
param adfName string
@description('Name of the linked service. Required.')
param linkedServiceName string
@description('Type of linked service. Required.')
@allowed([
  'AzureBlobFS'
  'AzureBlobStorage'
  'AzureKeyVault'
  'AzureFileStorage'
  'AzureSqlDatabase'
  'SqlServer'
])
param linkedServiceType string
@description('Azure Data Lake endpoint. Optional.')
param adlsUri string = ''
@description('Azure Blob storage endpoint. Optional.')
param blobServiceEndpoint string = ''
@description('Name of fileshare. Optional.')
param fileShare string = ''
@description('Azure Key-vault endpoint url. Optional.')
param keyVaultUrl string = ''
@description('Key-vault linked service name which is to be used in configuration of other linked services. Optional.')
param lsKeyVaultRefName string = ''
@description('Name of Key-vault secret which is to be used in configuration of other linked services. Optional.')
param keyVaultSecretName string = ''
@description('Sql Server connection string which is used in configuration of SQL linked service. Optional.')
param sqlServerConnectionString string = ''
@maxLength(63)
@description('Name of the data factory integration runtime. Optional.')
param adfIntegrationRuntimeName string = '${adfName}-selfhosted'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

resource adfIR 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' existing = {
  name: adfIntegrationRuntimeName
}
// https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/linkedservices?pivots=deployment-language-bicep

resource kvLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (linkedServiceType == 'AzureKeyVault') {
  name: linkedServiceName
  parent: adf
  properties: {
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: keyVaultUrl
    }
  }
}

resource adlsLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (linkedServiceType == 'AzureBlobFS') {
  name: linkedServiceName
  parent: adf
  properties: {
    type: 'AzureBlobFS'
    typeProperties: {
      url: adlsUri
    }
    connectVia: {
      referenceName: adfIR.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource blobLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (linkedServiceType == 'AzureBlobStorage') {
  name: linkedServiceName
  parent: adf
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      serviceEndpoint: blobServiceEndpoint
      accountKind: 'StorageV2'
    }
    connectVia: {
      referenceName: adfIR.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource fsLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (linkedServiceType == 'AzureFileStorage') {
  name: linkedServiceName
  parent: adf
  properties: {
    type: 'AzureFileStorage'
    typeProperties: {
      connectionString: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: lsKeyVaultRefName
          type: 'LinkedServiceReference'
        }
        secretName: keyVaultSecretName
      }
      fileShare: fileShare
    }
    connectVia: {
      referenceName: adfIR.name
      type: 'IntegrationRuntimeReference'
    }
  }
}

resource sqlLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = if (linkedServiceType == 'SqlServer') {
  name: linkedServiceName
  parent: adf
  properties: {
    type: 'SqlServer'
    typeProperties: {
      connectionString: sqlServerConnectionString
      password: {
        secretName: keyVaultSecretName
        store: {
          referenceName: lsKeyVaultRefName
          type: 'LinkedServiceReference'
        }
        type: 'AzureKeyVaultSecret'
      }
    }
    connectVia: {
      referenceName: adfIR.name
      type: 'IntegrationRuntimeReference'
    }
  }
}
