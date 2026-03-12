metadata name = 'Storage Account Blob Container'
metadata description = 'This module deploys a Storage Account Blob Container.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of container requires publicAccess set to 'None''''
metadata complianceVersion = '20240705'

@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Required. The name of the storage container to deploy.')
param name string

@description('Optional. Default the container to use specified encryption scope for all writes.')
param defaultEncryptionScope string = ''

@description('Optional. Block override of encryption scope from the container default.')
param denyEncryptionScopeOverride bool = false

@description('Optional. Enable NFSv3 all squash on blob container.')
param enableNfsV3AllSquash bool = false

@description('Optional. Enable NFSv3 root squash on blob container.')
param enableNfsV3RootSquash bool = false

@description('Optional. This is an immutable property, when set to true it enables object level immutability at the container level. The property is immutable and can only be set to true at the container creation time. Existing containers must undergo a migration process.')
param immutableStorageWithVersioningEnabled bool = false

@description('Optional. Name of the immutable policy.')
param immutabilityPolicyName string = 'default'

@description('Optional. Configure immutability policy.')
param immutabilityPolicyProperties immutabilityPolicyPropertiesType?

@description('Optional. A name-value pair to associate with the container as metadata.')
param metadata object = {}

@allowed([
  'Container'
  'Blob'
  'None'
])
@description('''Optional. Specifies whether data in the container may be accessed publicly and the level of access.

Setting the value to other than 'None' will make this resource non-compliant.
''')
param publicAccess string = 'None'

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Reader and Data Access': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','c12c1c16-33a1-487b-954d-41c89c60f349')
  'Storage Account Backup Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1')
  'Storage Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','17d1049b-9a84-46fb-8f53-869881c3d3ab')
  'Storage Account Key Operator Service Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','81a9662b-bebf-436f-a333-f67b29880f12')
  'Storage Blob Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  'Storage Blob Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  'Storage Blob Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  'Storage Blob Delegator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','db58b8e5-c6ad-4a2a-8342-4190687cbf4a')
}
@export()
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

#disable-next-line use-recent-api-versions
resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName

  resource blobServices 'blobServices@2025-01-01' existing = {
    name: 'default'
  }
}

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.storage-storageaccount-container.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, storageAccountName, name), 0, 4)}',
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

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2025-01-01' = {
  name: name
  parent: storageAccount::blobServices
  properties: {
    defaultEncryptionScope: !empty(defaultEncryptionScope) ? defaultEncryptionScope : null
    denyEncryptionScopeOverride: denyEncryptionScopeOverride == true ? denyEncryptionScopeOverride : null
    enableNfsV3AllSquash: enableNfsV3AllSquash == true ? enableNfsV3AllSquash : null
    enableNfsV3RootSquash: enableNfsV3RootSquash == true ? enableNfsV3RootSquash : null
    immutableStorageWithVersioning: immutableStorageWithVersioningEnabled == true
      ? {
          enabled: immutableStorageWithVersioningEnabled
        }
      : null
    metadata: metadata
    publicAccess: publicAccess
  }
}


module immutabilityPolicy 'immutability-policy/main.bicep' = if (!empty((immutabilityPolicyProperties ?? {}))) {
  name: take('${uniqueString(deployment().name, name, immutabilityPolicyName)}-storageaccount-container-immutabilitypolicy',64)
  params: {
    storageAccountName: storageAccount.name
    containerName: container.name
    immutabilityPeriodSinceCreationInDays: immutabilityPolicyProperties.?immutabilityPeriodSinceCreationInDays
    allowProtectedAppendWrites: immutabilityPolicyProperties.?allowProtectedAppendWrites
    allowProtectedAppendWritesAll: immutabilityPolicyProperties.?allowProtectedAppendWritesAll
  }
}

resource container_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(container.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      #disable-next-line use-safe-access
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: container
  }
]

@description('The name of the deployed container.')
output name string = container.name

@description('The resource ID of the deployed container.')
output resourceId string = container.id

@description('The resource group of the deployed container.')
output resourceGroupName string = resourceGroup().name

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (publicAccess != 'None')


// =============== //
//   Definitions   //
// =============== //

import { roleAssignmentType, diagnosticSettingType } from '../../../../../../bicep-shared/types.bicep'

import { immutabilityPolicyPropertiesType } from 'immutability-policy/main.bicep'

@export()
type blobServiceContainerType = {
  @description('Required. The name of the storage container to deploy.')
  name: string

  @description('Optional. By default the container will use specified encryption scope for all writes.')
  defaultEncryptionScope: string?

  @description('Optional. Block override of encryption scope from the container default.')
  denyEncryptionScopeOverride: bool?

  @description('Optional. Enable NFSv3 all squash on blob container.')
  enableNfsV3AllSquash: bool?

  @description('Optional. Enable NFSv3 root squash on blob container.')
  enableNfsV3RootSquash: bool?

  @description('''Optional. This is an immutable property, when set to true it enables object level immutability at the container level.
  The property is immutable and can only be set to true at the container creation time. Existing containers must undergo a migration process.''')
  immutableStorageWithVersioningEnabled: bool?

  @description('Optional. A name-value pair to associate with the container as metadata.')
  metadata: object?

  @description('Optional. Specifies whether data in the container may be accessed publicly and the level of access.')
  publicAccess: 'Blob' | 'Container' | 'None' | null

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType

  @description('Optional. Configure immutability policy.')
  immutabilityPolicyProperties: immutabilityPolicyPropertiesType?
}
