metadata name = 'Data Collection Endpoints'
metadata description = 'This module deploys a Data Collection Endpoint.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20250328'
metadata compliance = 'This is a utility module. No specific compliance requirements.'

// ============== //
//   Parameters   //
// ============== //

@sys.description('Required. The name of the data collection endpoint. The name is case insensitive.')
param name string

@sys.description('Optional. Description of the data collection endpoint.')
param description string?

@sys.description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@sys.description('Optional. The kind of the resource.')
@allowed([
  'Linux'
  'Windows'
])
param kind string = 'Linux'

@sys.description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@sys.description('Optional. The lock settings of the service.')
param lock lockType?

@sys.description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType?

@sys.description('Optional. The configuration to set whether network access from public internet to the endpoints are allowed.')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Disabled'

@sys.description('Optional. Resource tags.')
param tags object?

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId as telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version

var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]

// =============== //
//   Deployments   //
// =============== //

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take('${telemetryId}.res.insights-datacollectionendpoint.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}', 64)
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

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  kind: kind
  location: location
  name: name
  tags: finalTags
  properties: {
    networkAcls: {
      publicNetworkAccess: publicNetworkAccess
    }
    description: description
  }
}

resource dataCollectionEndpoint_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: dataCollectionEndpoint
}

resource dataCollectionEndpoint_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(
      dataCollectionEndpoint.id,
      roleAssignment.principalId,
      roleAssignment.roleDefinitionId
    )
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: dataCollectionEndpoint
  }
]

// =========== //
//   Outputs   //
// =========== //

@sys.description('The name of the dataCollectionEndpoint.')
output name string = dataCollectionEndpoint.name

@sys.description('The resource ID of the dataCollectionEndpoint.')
output resourceId string = dataCollectionEndpoint.id

@sys.description('The name of the resource group the dataCollectionEndpoint was created in.')
output resourceGroupName string = resourceGroup().name

@sys.description('The location the resource was deployed into.')
output location string = dataCollectionEndpoint.location

@sys.description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false

// =============== //
//   Definitions   //
// =============== //

import {
  roleAssignmentType
  lockType
} from '../../../../bicep-shared/types.bicep'
