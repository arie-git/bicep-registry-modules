metadata name = 'Azure Container Registry Cache'
metadata description = 'Cache for Azure Container Registry (Preview) feature allows users to cache container images in a private container registry. Cache for ACR, is a preview feature available in Basic, Standard, and Premium service tiers ([ref](https://learn.microsoft.com/en-us/azure/container-registry/tutorial-registry-cache)).'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''There are no special compliance requirements for Cache Rules.'''

@description('Required. The name of the parent registry. Required if the template is used in a standalone deployment.')
param registryName string

@description('Optional. The name of the cache rule. Will be derived from the source repository name if not defined.')
param name string = replace(replace(replace(sourceRepository, '/', '-'), '.', '-'), '*', '')

@description('Required. Source repository pulled from upstream.')
param sourceRepository string

@description('Optional. Target repository specified in docker pull command. E.g.: docker pull myregistry.azurecr.io/{targetRepository}:{tag}.')
param targetRepository string = sourceRepository

@description('Required. The resource ID of the credential store which is associated with the cache rule.')
param credentialSetResourceId string?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

import { telemetryId } from '../../../../../bicep-shared/environments.bicep'


#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.containerregistry-cacherule.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, registryName, name), 0, 4)}',
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

resource registry 'Microsoft.ContainerRegistry/registries@2023-06-01-preview' existing = {
  name: registryName
}

resource cacheRule 'Microsoft.ContainerRegistry/registries/cacheRules@2023-06-01-preview' = {
  name: name
  parent: registry
  properties: {
    sourceRepository: sourceRepository
    targetRepository: targetRepository
    credentialSetResourceId: credentialSetResourceId
  }
}

@description('The Name of the Cache Rule.')
output name string = cacheRule.name

@description('The name of the Cache Rule.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the Cache Rule.')
output resourceId string = cacheRule.id

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false

@description('Describes how to create cache rule set.')
@export()
type cacheRuleType = {
  @description('Optional. The name of the cache rule. Will be derived from the source repository name if not defined.')
  name: string?

  @description('Required. Source repository pulled from upstream.')
  sourceRepository: string

  @description('Optional. Target repository specified in docker pull command. E.g.: docker pull myregistry.azurecr.io/{targetRepository}:{tag}.')
  targetRepository: string?

  @description('Optional. The resource ID of the credential store which is associated with the cache rule.')
  credentialSetResourceId: string?
}
