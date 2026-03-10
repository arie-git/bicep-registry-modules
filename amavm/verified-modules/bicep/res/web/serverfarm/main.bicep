metadata name = 'App Service Plan'
metadata description = 'This module deploys an App Service Plan.'
metadata owner = 'AMCCC'
metadata compliance = '''This resource does not have any special compliance requirements.
However, make sure to choose the 'skuName' parameter that supports private endpoints an VNet injection, or you won't be able to deploy a compliant app.'''
metadata complianceVersion = '20260309'

@description('Required. Name of the app service plan.')
@minLength(1)
@maxLength(60)
param name string

@description('''Required. The name of the SKU will Determine the tier, size, family of the App Service Plan.
See https://azure.microsoft.com/en-us/pricing/details/app-service/ for details.

This defaults to P1v3 to leverage availability zones.

Setting this parameter to any Basic or Free tiers won't allow to have a compliant deployment with private endpoints.
''')
@metadata({
  example: '''
  'F1'
  'B1'
  'S1'
  'P1v3'
  'I1v2'
  'WS1'
  '''
})
param skuName string = 'P1v3'

@description('Required. Number of workers associated with the App Service Plan. This defaults to 3, to leverage availability zones.')
param skuCapacity int = 3

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Kind of hosting.')
param kind resourceInput<'Microsoft.Web/serverfarms@2025-03-01'>.kind = 'App'

@description('Conditional. Defaults to false when creating Windows/app App Service Plan. Required if creating a Linux App Service Plan and must be set to true.')
param reserved bool = (kind == 'Linux')

@description('Optional. The Resource ID of the App Service Environment to use for the App Service Plan.')
param appServiceEnvironmentId string = ''

@description('Optional. Target worker tier assigned to the App Service plan.')
param workerTierName string = ''

@description('Optional. If true, apps assigned to this App Service plan can be scaled independently. If false, apps assigned to this App Service plan will scale to all instances of the plan.')
param perSiteScaling bool = false

@description('Optional. Enable/Disable ElasticScaleEnabled App Service Plan.')
param elasticScaleEnabled bool = maximumElasticWorkerCount > 1

@description('Optional. Maximum number of total workers allowed for this ElasticScaleEnabled App Service Plan.')
param maximumElasticWorkerCount int = 1

@description('Optional. Scaling worker count.')
param targetWorkerCount int = 0

@description('Optional. The instance size of the hosting plan (small, medium, or large).')
@allowed([
  0
  1
  2
])
param targetWorkerSize int = 0

@description('Optional. Zone Redundant server farms can only be used on Premium or ElasticPremium SKU tiers within ZRS Supported regions (https://learn.microsoft.com/en-us/azure/storage/common/redundancy-regions-zrs).')
param zoneRedundant bool = startsWith(skuName, 'P') || startsWith(skuName, 'EP') ? true : false

@description('Optional. If Hyper-V container app service plan true, false otherwise.')
param hyperV bool?

@description('Optional. The resource ID of the subnet to integrate the App Service Plan with for VNet integration.')
param virtualNetworkSubnetId string?

@description('Optional. Set to true to enable Managed Instance custom mode. Required for App Service Managed Instance plans.')
param isCustomMode bool = false

@description('Optional. Whether RDP is enabled for Managed Instance plans. Only applicable when isCustomMode is true. Requires a Bastion host deployed in the VNet.')
param rdpEnabled bool?

@description('Optional. A list of install scripts for Managed Instance plans. Only applicable when isCustomMode is true.')
param installScripts array?

@description('Optional. The default identity configuration for Managed Instance plans. Only applicable when isCustomMode is true.')
param planDefaultIdentity string?

@description('Optional. A list of registry adapters for Managed Instance plans. Only applicable when isCustomMode is true.')
param registryAdapters array?

@description('Optional. A list of storage mounts for Managed Instance plans. Only applicable when isCustomMode is true.')
param storageMounts array?

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType?

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

// =========== //
// Variables   //
// =========== //
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Web Plan Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','2cc479cb-7b4d-49a8-b449-8c00fd0f0a4b')
  'Website Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','de139f84-1756-47ae-9be6-808fbbe84772')
}

var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

var defaultLogCategoryNames = []
var defaultLogCategories = [
  for category in defaultLogCategoryNames ?? []: {
    category: category
  }
]

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

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
)

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

// ============ //
// Dependencies //
// ============ //

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.app-service-plan.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: name
  kind: kind
  location: location
  tags: finalTags
  identity: identity
  sku: union({
    name: skuName
  },
  (skuName == 'FC1') ? {
    tier : 'FlexConsumption'
  } : {
    capacity: skuCapacity
  })
  properties: {
    workerTierName: workerTierName
    hostingEnvironmentProfile: !empty(appServiceEnvironmentId)
      ? {
          id: appServiceEnvironmentId
        }
      : null
    perSiteScaling: perSiteScaling
    maximumElasticWorkerCount: maximumElasticWorkerCount
    elasticScaleEnabled: elasticScaleEnabled
    reserved: reserved
    targetWorkerCount: targetWorkerCount
    targetWorkerSizeId: targetWorkerSize
    zoneRedundant: zoneRedundant
    hyperV: hyperV
    isCustomMode: isCustomMode
    network: virtualNetworkSubnetId != null
      ? {
          virtualNetworkSubnetId: virtualNetworkSubnetId
        }
      : null
    rdpEnabled: isCustomMode ? rdpEnabled : null
    installScripts: isCustomMode ? installScripts : null
    planDefaultIdentity: isCustomMode ? planDefaultIdentity : null
    registryAdapters: isCustomMode ? registryAdapters : null
    storageMounts: isCustomMode ? storageMounts : null
  }
}

#disable-next-line use-recent-api-versions
resource appServicePlan_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? defaultLogCategories): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: appServicePlan
  }
]

resource appServicePlan_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: appServicePlan
}

resource appServicePlan_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(appServicePlan.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: appServicePlan
  }
]

@description('The resource group the app service plan was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the app service plan.')
output name string = appServicePlan.name

@description('The resource ID of the app service plan.')
output resourceId string = appServicePlan.id

@description('The location the resource was deployed into.')
output location string = appServicePlan.location

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = appServicePlan.?identity.?principalId

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false


// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  lockType
  managedIdentitiesType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'
