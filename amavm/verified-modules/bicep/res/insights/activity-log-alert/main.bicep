metadata name = 'Activity Log Alerts'
metadata description = 'This module deploys an Activity Log Alert.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = 'This is a utility module. No specific compliance requirements.'

@description('Required. The name of the alert.')
param name string

@description('Optional. Description of the alert.')
param alertDescription string = ''

@description('Optional. Location for all resources.')
param location string = 'global'

@description('Optional. Indicates whether this alert is enabled.')
param enabled bool = true

@description('Optional. The list of resource IDs that this Activity Log Alert is scoped to.')
param scopes string[] = [
  subscription().id
]

@description('Optional. The list of actions to take when alert triggers.')
param actions array = []

@description('Required. An Array of objects containing conditions that will cause this alert to activate. Conditions can also be combined with logical operators `allOf` and `anyOf`. Each condition can specify only one field between `equals` and `containsAny`. An alert rule condition must have exactly one category (Administrative, ServiceHealth, ResourceHealth, Alert, Autoscale, Recommendation, Security, or Policy).')
param conditions resourceInput<'Microsoft.Insights/activityLogAlerts@2026-01-01'>.properties.condition.allOf

@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the resource.')
param tags resourceInput<'Microsoft.Insights/activityLogAlerts@2026-01-01'>.tags?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

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

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take('${telemetryId}.res.insights-activitylogalert.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}', 64)
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

resource activityLogAlert 'Microsoft.Insights/activityLogAlerts@2026-01-01' = {
  name: name
  location: location
  tags: finalTags
  properties: {
    scopes: scopes
    condition: {
      allOf: conditions
    }
    actions: {
      actionGroups: [
        for action in actions: {
          actionGroupId: action.?actionGroupId ?? action
          webhookProperties: action.?webhookProperties
        }
      ]
    }
    enabled: enabled
    description: alertDescription
  }
}

resource activityLogAlert_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: activityLogAlert
}

resource activityLogAlert_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(activityLogAlert.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: activityLogAlert
  }
]

@description('The name of the activity log alert.')
output name string = activityLogAlert.name

@description('The resource ID of the activity log alert.')
output resourceId string = activityLogAlert.id

@description('The resource group the activity log alert was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = activityLogAlert.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false

// =============== //
//   Definitions   //
// =============== //

import {
  lockType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'
