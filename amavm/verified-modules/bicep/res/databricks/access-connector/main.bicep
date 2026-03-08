metadata name = 'Azure Databricks Access Connector'
metadata description = 'This module deploys an Azure Databricks Access Connector.'
metadata owner = 'AMCCC'
metadata compliance = 'There are no special compliance requirements for this resource.'
metadata complianceVersion = '20240702'

@description('Required. The name of the Azure Databricks access connector to create.')
param name string

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('''Optional. The managed identity definition for this resource. Default: { systemAssigned: true }.

To disable creating a system-assigned identity, provide an empty object {} or null.''')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? true)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : {
      type: 'None'
    }

// Variables
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' =
  if (enableTelemetry) {
    name: take(
      '${telemetryId}.res.databricks-accessconnector.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource accessConnector 'Microsoft.Databricks/accessConnectors@2024-05-01' = {
  name: name
  location: location
  tags: finalTags
  identity: identity
  properties: {}
}

resource accessConnector_lock 'Microsoft.Authorization/locks@2020-05-01' =
  if (!empty(lock ?? {}) && lock.?kind != 'None') {
    name: lock.?name ?? 'lock-${name}'
    properties: {
      level: lock.?kind ?? ''
      notes: lock.?kind == 'CanNotDelete'
        ? 'Cannot delete resource or child resources.'
        : 'Cannot delete or modify the resource or child resources.'
    }
    scope: accessConnector
  }

resource accessConnector_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(accessConnector.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: accessConnector
  }
]

@description('The name of the deployed access connector.')
output name string = accessConnector.name

@description('The resource ID of the deployed access connector.')
output resourceId string = accessConnector.id

@description('The resource group of the deployed access connector.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = accessConnector.?identity.?principalId ?? ''

@description('The location the resource was deployed into.')
output location string = accessConnector.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false


// =============== //
//   Definitions   //
// =============== //

import {
  lockType
  managedIdentitiesType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'
