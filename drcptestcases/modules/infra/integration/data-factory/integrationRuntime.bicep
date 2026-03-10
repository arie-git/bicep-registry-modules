targetScope = 'resourceGroup'

@description('Name of the data factory. Required.')
param adfName string

@description('''Is the integration runtime linked with existing ADF IR.
If set to true, also provide masterAdfIrId
''')
param linkedIntegrationRuntime bool = true

@description('Resource id of the linked integration runtime. Optional.')
param masterAdfIrId string = ''

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

resource selfhostedIR 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: 'selfhosted'
  parent: adf
  properties: {
    type: 'SelfHosted'
    typeProperties: linkedIntegrationRuntime ? {
      linkedInfo: {
        authorizationType: 'RBAC'
        resourceId: masterAdfIrId
      }
    } : null
  }
}

output name string = selfhostedIR.name
output resourceId string = selfhostedIR.id
