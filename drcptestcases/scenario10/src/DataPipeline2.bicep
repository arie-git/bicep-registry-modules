param adfName string

param kvName string

param storageAccountName string = ''

param adlsName string = ''

param fileShareName string = 's2cccscne1002devweshare'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

module kvLinkedService '../../modules/infra/integration/data-factory/linkedService.bicep' = {
  name: '${deployment().name}ls${kvName}'
  params: {
    adfName: adfName
    linkedServiceName: 'LS-KV-${kvName}02'
    keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}/'
    linkedServiceType: 'AzureKeyVault'
  }
}

module adlsLinkedService '../../modules/infra/integration/data-factory/linkedService.bicep' = {
  name: '${deployment().name}ls${adlsName}'
  params: {
    adfName: adfName
    linkedServiceName: 'LS-ADLS-${adlsName}02'
    linkedServiceType: 'AzureBlobFS'
    adlsUri: 'https://${adlsName}.dfs${environment().suffixes.storage}/'
  }
}

module fsLinkedService '../../modules/infra/integration/data-factory/linkedService.bicep' = {
  name: '${deployment().name}ls${storageAccountName}02'
  dependsOn: [
    kvLinkedService
  ]
  params: {
    adfName: adfName
    fileShare: fileShareName
    linkedServiceName: 'LS-FILESHARE-${storageAccountName}'
    linkedServiceType: 'AzureFileStorage'
    lsKeyVaultRefName: 'LS-KV-${kvName}02'
    keyVaultSecretName: 'connstring'
  }
}

resource dsAdls 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'DS_ADLS_Binary'
  parent: adf
  dependsOn: [
    adlsLinkedService
  ]
  properties: {
    linkedServiceName: {
      referenceName: 'LS-ADLS-${adlsName}02'
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureBlobFSLocation'
        folderPath: 'adf/datapipeline2'
      }
    }
    // fileName: '${filename}.json'
  }
}

resource dsFileShare 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'DS_FS_Employees'
  parent: adf
  dependsOn: [
    fsLinkedService
  ]
  properties: {
    linkedServiceName: {
      referenceName: 'LS-FILESHARE-${storageAccountName}'
      type: 'LinkedServiceReference'
    }
    type: 'Binary'
    typeProperties: {
      location: {
        type: 'AzureFileStorageLocation'
        folderPath: 'binary'
      }
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'PL-Datapipeline2'
  parent: adf
  dependsOn: [
    dsAdls
    dsFileShare
  ]
  properties: {
    activities: [
      {
        name: 'Copy FileShare to ADLS in Binary'
        type: 'Copy'
        typeProperties: {
          sink: {
            type: 'BinarySink'
            storeSettings: {
              type: 'AzureBlobFSWriteSettings'
              copyBehavior: 'FlattenHierarchy'
            }
          }
          source: {
            type: 'BinarySource'
            storeSettings: {
              type: 'AzureFileStorageReadSettings'
              recursive: true
            }
            formatSettings: {
              type: 'BinaryReadSettings'
            }
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: 'DS_FS_Employees'
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: 'DS_ADLS_Binary'
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
}
