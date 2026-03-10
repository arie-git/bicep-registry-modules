param adfName string

param kvName string

param adlsName string

param filename string = utcNow()

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

module kvLinkedService '../../modules/infra/integration/data-factory/linkedService.bicep' = {
  name: '${deployment().name}ls${kvName}'
  params: {
    adfName: adfName
    linkedServiceName: 'LS-KV-${kvName}01'
    keyVaultUrl: 'https://${kvName}${environment().suffixes.keyvaultDns}'
    linkedServiceType: 'AzureKeyVault'
  }
}

module adlsLinkedService '../../modules/infra/integration/data-factory/linkedService.bicep' = {
  name: '${deployment().name}ls${adlsName}'
  dependsOn: [
    kvLinkedService
  ]
  params: {
    adfName: adfName
    linkedServiceName: 'LS-ADLS-${adlsName}01'
    linkedServiceType: 'AzureBlobFS'
    adlsUri: 'https://${adlsName}.dfs${environment().suffixes.storage}/'
  }
}

module sqlServerLinkedService '../../modules/infra/integration/data-factory/linkedService.bicep' = {
  name: '${deployment().name}lslsonpremsql'
  dependsOn: [
    kvLinkedService
  ]
  params: {
    adfName: adfName
    linkedServiceName: 'LS-SQLSERVER-OnPrem'
    linkedServiceType: 'SqlServer'
    lsKeyVaultRefName: 'LS-KV-${kvName}01'
    sqlServerConnectionString: 'Integrated Security=False;Data Source=172.16.1.5;Initial Catalog=ADFTest;User ID=vmadmin'
    keyVaultSecretName: 'sqlpassword'
  }
}

resource dsSql 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'DS_SQL_Employees'
  parent: adf
  dependsOn: [
    sqlServerLinkedService
  ]
  properties: {
    linkedServiceName: {
      referenceName: 'LS-SQLSERVER-OnPrem'
      type: 'LinkedServiceReference'
    }
    structure: [
      {
        name: 'ID'
        type: 'Int32'
      }
      {
        name: 'Name'
        type: 'String'
      }
      {
        name: 'Age'
        type: 'Int32'
      }
      {
        name: 'Place'
        type: 'String'
      }
    ]
    typeProperties: {
      schema: 'dbo'
      tableName: 'Employees'
    }
    type: 'SqlServerTable'
  }
}

resource dsAdls 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  name: 'DS_ADLS_Employees'
  parent: adf
  dependsOn: [
    adlsLinkedService
  ]
  properties: {
    linkedServiceName: {
      referenceName: 'LS-ADLS-${adlsName}01'
      type: 'LinkedServiceReference'
    }
    type: 'AzureBlobFSFile'
    typeProperties: {
      format: {
        type: 'JsonFormat'
      }
      folderPath: 'adf/datapipeline1'
      fileName: '${filename}.json'
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'PL-Datapipeline1'
  parent: adf
  dependsOn: [
    dsAdls
    dsSql
  ]
  properties: {
    activities: [
      {
        name: 'Copy Sql to ADLS'
        type: 'Copy'
        typeProperties: {
          sink: {
            type: 'AzureBlobFSSink'
            copyBehavior: 'PreserveHierarchy'
          }
          source: {
            type: 'SqlServerSource'
            isolationLevel: 'ReadCommitted'
            partitionOption: 'none'
          }
          enableStaging: false
        }
        inputs: [
          {
            referenceName: 'DS_SQL_Employees'
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: 'DS_ADLS_Employees'
            type: 'DatasetReference'
          }
        ]
      }
    ]
  }
}
