metadata name = 'Metric Alerts'
metadata description = 'This module deploys a Metric Alert.'
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

@description('Optional. The severity of the alert.')
@allowed([
  0
  1
  2
  3
  4
])
param severity int = 3

@description('Optional. how often the metric alert is evaluated represented in ISO 8601 duration format.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT5M'

@description('Optional. the period of time (in ISO 8601 duration format) that is used to monitor alert activity based on the threshold.')
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
  'PT6H'
  'PT12H'
  'P1D'
])
param windowSize string = 'PT15M'

@description('Optional. the list of resource IDs that this metric alert is scoped to.')
param scopes array = [
  subscription().id
]

@description('Conditional. The resource type of the target resource(s) on which the alert is created/updated. Required if alertCriteriaType is MultipleResourceMultipleMetricCriteria.')
param targetResourceType string?

@description('Conditional. The region of the target resource(s) on which the alert is created/updated. Required if alertCriteriaType is MultipleResourceMultipleMetricCriteria.')
param targetResourceRegion string?

@description('Optional. The flag that indicates whether the alert should be auto resolved or not.')
param autoMitigate bool = true

@description('Optional. The list of actions to take when alert triggers.')
param actions array = []

@description('Required. Maps to the \'odata.type\' field. Specifies the type of the alert criteria.')
param criteria alertType

@description('Optional. The lock settings of the service.')
param lock lockType?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType?

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

var actionGroups = [
  for action in actions: {
    actionGroupId: action.?actionGroupId ?? action
    webHookProperties: action.?webHookProperties
  }
]

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
  name: take('${telemetryId}.res.insights-metricalert.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, location), 0, 4)}', 64)
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

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: name
  location: location
  tags: finalTags
  properties: {
    description: alertDescription
    severity: severity
    enabled: enabled
    scopes: scopes
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    targetResourceType: targetResourceType
    targetResourceRegion: targetResourceRegion
    criteria: {
      'odata.type': criteria['odata.type']
      ...(contains(criteria, 'allof') ? { allof: criteria.allof } : {})
      ...(contains(criteria, 'componentResourceId') ? { componentId: criteria.componentResourceId } : {})
      ...(contains(criteria, 'failedLocationCount') ? { failedLocationCount: criteria.failedLocationCount } : {})
      ...(contains(criteria, 'webTestResourceId') ? { webTestId: criteria.webTestResourceId } : {})
    }
    autoMitigate: autoMitigate
    actions: actionGroups
  }
}

resource metricAlert_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: metricAlert
}

resource metricAlert_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(metricAlert.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: metricAlert
  }
]

@description('The resource group the metric alert was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the metric alert.')
output name string = metricAlert.name

@description('The resource ID of the metric alert.')
output resourceId string = metricAlert.id

@description('The location the resource was deployed into.')
output location string = metricAlert.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false

// =============== //
//   Definitions   //
// =============== //

@export()
@discriminator('odata.type')
type alertType = alertWebtestType | alertResourceType | alertMultiResourceType

@description('The alert type for a single resource scenario.')
type alertResourceType = {
  @description('Required. The type of the alert criteria.')
  'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'

  @description('Required. The list of metric criteria for this \'all of\' operation.')
  allof: object[]
}

@description('The alert type for multiple resources scenario.')
type alertMultiResourceType = {
  @description('Required. The type of the alert criteria.')
  'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'

  @description('Required. The list of multiple metric criteria for this \'all of\' operation.')
  allof: object[]
}

@description('The alert type for a web test scenario.')
type alertWebtestType = {
  @description('Required. The type of the alert criteria.')
  'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'

  @description('Required. The Application Insights resource ID.')
  componentResourceId: string

  @description('Required. The number of failed locations.')
  failedLocationCount: int

  @description('Required. The Application Insights web test resource ID.')
  webTestResourceId: string
}

import {
  lockType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'
