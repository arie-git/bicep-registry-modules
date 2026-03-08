metadata name = 'Storage Account Table'
metadata description = 'This module deploys a Storage Account Table.'
metadata owner = 'Azure/module-maintainers'

@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Optional. List of stored access policies specified on the table.')
param signedIdentifiers tableSignedIdentifier[]?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Required. Name of the table.')
param name string

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true


import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../../../bicep-shared/environments.bicep'

// -------------------
var specificBuiltInRoleNames = {
  'Reader and Data Access': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','c12c1c16-33a1-487b-954d-41c89c60f349')
  'Storage Account Backup Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1')
  'Storage Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','17d1049b-9a84-46fb-8f53-869881c3d3ab')
  'Storage Account Key Operator Service Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','81a9662b-bebf-436f-a333-f67b29880f12')
  'Storage Table Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
  'Storage Table Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','76199698-9eea-4c19-bc75-cec21354c6b6')
}
@export()
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

// -------------------

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.storage-storageaccount-table.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, storageAccountName, name), 0, 4)}',
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

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName

  resource tableServices 'tableServices@2023-05-01' existing = {
    name: 'default'
  }
}

resource table 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
  name: name
  parent: storageAccount::tableServices
  properties:{
    signedIdentifiers: signedIdentifiers
  }
}

resource table_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(table.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: table
  }
]

@description('The name of the deployed file share service.')
output name string = table.name

@description('The resource ID of the deployed file share service.')
output resourceId string = table.id

@description('The resource group of the deployed file share service.')
output resourceGroupName string = resourceGroup().name

// =============== //
//   Definitions   //
// =============== //

import {
  roleAssignmentType
} from '../../../../../../bicep-shared/types.bicep'

@export()
type tableServiceTableType = {
  @description('Required. Name of the table.')
  name: string

  @description('Optional. List of stored access policies specified on the table.')
  signedIdentifiers: tableSignedIdentifier[]?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType?

}

type tableSignedIdentifier = {
  @description('Required. Access policy')
  accessPolicy: {
    @description('Optional. Expiry time of the access policy')
    expiryTime: string?
    @description('''Required. List of abbreviated permissions. Supported permission values include 'r','a','u','d''')
    permission: string
    @description('Optional. Start time of the access policy')
    startTime: string?
  }

  @description('Required. Unique-64-character-value of the stored access policy.')
  id: string
}
