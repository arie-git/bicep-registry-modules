metadata name = 'Azure Data Factory Integration Runtime'
metadata description = 'This module deploys a Managed or Self-Hosted Integration Runtime for Azure Data Factory.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''Compliant usage of Azure Data Factory requires:
- type: 'SelfHosted'
- managedVirtualNetworkName: empty
- typeProperties: empty
'''

@description('Conditional. The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.')
param dataFactoryName string

@description('Required. The name of the Integration Runtime.')
param name string

@allowed([
  'Managed'
  'SelfHosted'
])
@description('''Required. The type of Integration Runtime.

Setting this parameter to any other than SelfHosted will make the resource non-compliant.
''')
param type string = 'SelfHosted'

@description('''Optional. The name of the Managed Virtual Network if using type "Managed".

Setting this paramter value will make the resource non-compliant.
''')
param managedVirtualNetworkName string = ''

@description('''Optional. Integration Runtime type properties. Required if type is "Managed".

Setting this paramter value will make the resource non-compliant.
''')
param typeProperties object = {}

@description('Optional. The description of the Integration Runtime.')
param integrationRuntimeCustomDescription string = 'Managed Integration Runtime created by amavm-res-datafactory-factories'

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //

import { telemetryId } from '../../../../../bicep-shared/environments.bicep'

var managedVirtualNetworkVar = {
  referenceName: type == 'Managed' ? managedVirtualNetworkName : null
  type: type == 'Managed' ? 'ManagedVirtualNetworkReference' : null
}

// ============ //
// Dependencies //
// ============ //
#disable-next-line no-deployments-resources
// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-11-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.data-factory-integration-runtime.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, dataFactoryName), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource integrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  name: name
  parent: dataFactory
  #disable-next-line BCP225
  properties: type == 'Managed'
    ? {
        description: integrationRuntimeCustomDescription
        type: type
        managedVirtualNetwork: managedVirtualNetworkVar
        typeProperties: typeProperties
      }
    : {
        type: type
      }
}

@description('The name of the Resource Group the Integration Runtime was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the Integration Runtime.')
output name string = integrationRuntime.name

@description('The resource ID of the Integration Runtime.')
output resourceId string = integrationRuntime.id

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = type != 'SelfHosted' || !empty(managedVirtualNetworkName) || !empty(typeProperties)

// ================ //
// Definitions      //
// ================ //

@export()
type integrationRuntimeType = {
  @description('Required. The name of the integration runtime.')
  name: string

  @description('Required. The name of the integration runtime. Choose from SelfHosted or Managed')
  type: ('Managed' | 'SelfHosted')

  @description('Optional. The description of the integration runtime.')
  integrationRuntimeCustomDescription: string?

  @description('Optional. The name of the managed virtual network.')
  managedVirtualNetworkName: string?

  @description('Optional. The typed properties.')
  typeProperties: object?
}[]?
