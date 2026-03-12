metadata name = 'Azure Data Factory'
metadata description = 'This module deploys Azure Data Factory.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''Compliant usage of Azure Data Factory requires:
- managedVirtualNetworkName: empty
- managedPrivateEndpoints : empty array
- publicNetworkAccess: 'Disabled'
- adoRepoConfiguration: only in Dev
- gitRepoType: 'FactoryVSTSConfiguration'
- gitAccountName : 'connectdrcpapg1'
'''

@description('Required. The name of the Azure Factory to create. Must be globally unique.')
@minLength(3)
@maxLength(24)
param name string

@description('''Optional. The name of the Managed Virtual Network. [Policy: drcp-adf-01]

Configuring Data Factory with Managed Virtual Network will make the resource non-compliant.
''')
param managedVirtualNetworkName string = ''

@description('''Optional. An array of managed private endpoints objects created in the Data Factory managed virtual network. [Policy: drcp-adf-01]

Adding managed private endpoints will make the Data Factory resource non-compliant.
''')
param managedPrivateEndpoints array = []

@description('''Optional. An array of objects for the configuration of an Integration Runtime. [Policy: drcp-adf-01]

Managed Virtual Network, Azure-SSIS and Airflow type Integration runtime will make the Data Factory resource non-compliant.
''')
param integrationRuntimes integrationRuntimeType

@description('Optional. An array of objects for the configuration of Linked Services. [Policy: drcp-adf-04, drcp-adf-05]')
param linkedServices linkedServiceType

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('''Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set. [Policy: drcp-adf-02]

Setting this parameter to any other than 'Disabled' will make the Data Factory resource non-compliant.
''')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('''Optional. Boolean to define whether or not to configure git during template deployment. [Policy: drcp-adf-06]

Setting this parameter to 'false' in non-development usages will make the Data Factory resource non-compliant.
''')
param gitConfigureLater bool = true

@description('''Optional. Object to define git configuration for Data Factory. [Policy: drcp-adf-06]

Setting this object in non-Dev enviroment will make the Data Factory resource non-compliant.
''')
param gitconfiguration gitRepoConfig

@description('Optional. List of Global Parameters for the factory.')
param globalParameters resourceInput<'Microsoft.DataFactory/factories@2018-06-01'>.properties.globalParameters?

@description('Optional. Purview Account resource identifier. [Policy: drcp-adf-07]')
param purviewResourceId string?

@description('''Optional. The diagnostic settings of the service.
Currently known available log categories are:

'ActivityRuns'
'PipelineRuns'
'TriggerRuns'
'SandboxActivityRuns'
'SandboxPipelineRuns'
'SSISPackageEventMessages'
'SSISPackageExecutableStatistics'
'SSISPackageEventMessageContext'
'SSISPackageExecutionComponentPhases'
'SSISPackageExecutionDataStatistics'
'SSISIntegrationRuntimeLogs'
'AirflowTaskLogs'
'AirflowWorkerLogs'
'AirflowDagProcessingLogs'
'AirflowSchedulerLogs'
'AirflowWebLogs'
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('Optional. Configuration Details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. [Policy: drcp-sub-07]')
param privateEndpoints privateEndpointType

@description('Optional. The customer managed key definition.')
param customerManagedKey customerManagedKeyType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Resource tags.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId, adoOrgnization, gitRepoType } from '../../../../bicep-shared/environments.bicep'

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var specificBuiltInRoleNames = {
  'Data Factory Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '673868aa-7521-48a0-acc6-0f60742d39f5'
  )
}

var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)
var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'ActivityRuns'
  'PipelineRuns'
  'TriggerRuns'
  'SandboxActivityRuns'
  'SandboxPipelineRuns'
  'SSISPackageEventMessages'
  'SSISPackageExecutableStatistics'
  'SSISPackageEventMessageContext'
  'SSISPackageExecutionComponentPhases'
  'SSISPackageExecutionDataStatistics'
  'SSISIntegrationRuntimeLogs'
  'AirflowTaskLogs'
  'AirflowWorkerLogs'
  'AirflowDagProcessingLogs'
  'AirflowSchedulerLogs'
  'AirflowWebLogs'
]
var defaultLogCategories = [
  for category in defaultLogCategoryNames ?? []: {
    category: category
  }
]

var isHSMManagedCMK = split(customerManagedKey.?keyVaultResourceId ?? '', '/')[?7] == 'managedHSMs'
resource cMKKeyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
  name: last(split((customerManagedKey.?keyVaultResourceId!), '/'))
  scope: resourceGroup(
    split(customerManagedKey.?keyVaultResourceId!, '/')[2],
    split(customerManagedKey.?keyVaultResourceId!, '/')[4]
  )

  resource cMKKey 'keys@2025-05-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
    name: customerManagedKey.?keyName!
  }
}

resource cMKUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = if (!empty(customerManagedKey.?userAssignedIdentityResourceId)) {
  name: last(split(customerManagedKey.?userAssignedIdentityResourceId!, '/'))
  scope: resourceGroup(
    split(customerManagedKey.?userAssignedIdentityResourceId!, '/')[2],
    split(customerManagedKey.?userAssignedIdentityResourceId!, '/')[4]
  )
}

// ============ //
// Dependencies //
// ============ //
#disable-next-line no-deployments-resources
// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-11-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.data-factory.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  tags: finalTags
  identity: identity
  properties: {
    repoConfiguration: bool(gitConfigureLater)
      ? null
      : union(
          {
            type: gitconfiguration.?gitRepoType
            hostName: gitconfiguration.?gitHostName
            accountName: gitconfiguration.?gitAccountName
            repositoryName: gitconfiguration.?gitRepositoryName
            collaborationBranch: gitconfiguration.?gitCollaborationBranch
            rootFolder: gitconfiguration.?gitRootFolder
            disablePublish: gitconfiguration.?gitDisablePublish
            lastCommitId: gitconfiguration.?gitLastCommitId
            tenantId: gitconfiguration.?gitTenantId
          },
          (gitconfiguration.?gitRepoType == 'FactoryVSTSConfiguration'
            ? {
                projectName: gitconfiguration.?gitProjectName
              }
            : {}),
          {}
        )
    globalParameters: globalParameters
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? any(publicNetworkAccess)
      : (!empty(privateEndpoints) ? 'Disabled' : null)
    encryption: !empty(customerManagedKey)
      ? {
          identity: !empty(customerManagedKey.?userAssignedIdentityResourceId)
            ? {
                userAssignedIdentity: cMKUserAssignedIdentity.id
              }
            : null
          keyName: customerManagedKey!.keyName
          keyVersion: !empty(customerManagedKey.?keyVersion)
            ? customerManagedKey!.keyVersion!
            : (customerManagedKey.?autoRotationEnabled ?? true)
                ? null
                : (!isHSMManagedCMK
                    ? last(split(cMKKeyVault::cMKKey!.properties.keyUriWithVersion, '/'))
                    : fail('Managed HSM CMK encryption requires either specifying the \'keyVersion\' or omitting the \'autoRotationEnabled\' property. Setting \'autoRotationEnabled\' to false without a \'keyVersion\' is not allowed.'))
          vaultBaseUrl: !isHSMManagedCMK
            ? cMKKeyVault!.properties.vaultUri
            : 'https://${last(split((customerManagedKey.?keyVaultResourceId!), '/'))}.managedhsm.azure.net/'
        }
      : null
    purviewConfiguration: !empty(purviewResourceId)
      ? {
          purviewResourceId: purviewResourceId
        }
      : null
  }
}

module dataFactory_managedVirtualNetwork 'managed-virtual-network/main.bicep' = if (!empty(managedVirtualNetworkName)) {
  name: '${uniqueString(deployment().name, location, managedVirtualNetworkName)}-datafactory-managedvnet'
  params: {
    name: managedVirtualNetworkName
    dataFactoryName: dataFactory.name
    managedPrivateEndpoints: managedPrivateEndpoints
  }
}

module dataFactory_integrationRuntimes 'integration-runtime/main.bicep' = [
  for (integrationRuntime, index) in (integrationRuntimes ?? []): {
    name: take(
      '${uniqueString(deployment().name, name, location)}-datafactory-integrationruntime-${index}-${integrationRuntime.?name ?? ''}',
      64
    )
    params: {
      dataFactoryName: dataFactory.name
      name: integrationRuntime.name
      type: integrationRuntime.type
      integrationRuntimeCustomDescription: integrationRuntime.?integrationRuntimeCustomDescription ?? 'Managed Integration Runtime created by amavm-res-datafactory-factories'
      managedVirtualNetworkName: integrationRuntime.?managedVirtualNetworkName ?? ''
      typeProperties: integrationRuntime.?typeProperties ?? {}
    }
    dependsOn: [
      dataFactory_managedVirtualNetwork
    ]
  }
]

module dataFactory_linkedServices 'linked-service/main.bicep' = [
  for (linkedService, index) in (linkedServices ?? []): {
    name: take(
      '${uniqueString(deployment().name, name, location)}-datafactory-linkedservice-${index}-${linkedService.?name ?? ''}',
      64
    )
    params: {
      dataFactoryName: dataFactory.name
      name: linkedService.name
      type: linkedService.type
      typeProperties: linkedService.?typeProperties
      integrationRuntimeName: linkedService.?integrationRuntimeName
      parameters: linkedService.?parameters
      description: linkedService.?description
    }
    dependsOn: [
      dataFactory_integrationRuntimes
    ]
  }
]

resource dataFactory_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: dataFactory
}

#disable-next-line use-recent-api-versions
resource dataFactory_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${uniqueString(deployment().name, location, name)}-diagnosticsettings'
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
    scope: dataFactory
  }
]

resource dataFactory_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(dataFactory.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: dataFactory
  }
]

module dataFactory_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-datafactory-privateendpoint-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(dataFactory.id, '/'))}-pep-${privateEndpoint.?service ?? 'datafactory'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(dataFactory.id, '/'))}-${privateEndpoint.?service ?? 'datafactory'}-${index}'
              properties: {
                privateLinkServiceId: dataFactory.id
                groupIds: [
                  privateEndpoint.?service ?? 'dataFactory'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(dataFactory.id, '/'))}-${privateEndpoint.?service ?? 'datafactory'}-${index}'
              properties: {
                privateLinkServiceId: dataFactory.id
                groupIds: [
                  privateEndpoint.?service ?? 'dataFactory'
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: privateEndpoint.?enableTelemetry ?? enableTelemetry
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      privateDnsZoneGroup: privateEndpoint.?privateDnsZoneGroup
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? finalTags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

// =========== //
// Outputs     //
// =========== //
@description('The Name of the Azure Data Factory instance.')
output name string = dataFactory.name

@description('The Resource ID of the Data factory.')
output resourceId string = dataFactory.id

@description('The name of the Resource Group with the Data factory.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = dataFactory.?identity.?principalId ?? ''

@description('The location the resource was deployed into.')
output location string = dataFactory.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !empty(managedVirtualNetworkName) || !empty(managedPrivateEndpoints) || publicNetworkAccess != 'Disabled' || (!gitConfigureLater && (gitconfiguration.?gitRepoType != gitRepoType || gitconfiguration.?gitAccountName != adoOrgnization)) || !empty(purviewResourceId) || length(filter(integrationRuntimes ?? [], ir => ir.type != 'SelfHosted')) > 0

@description('The private endpoints of the Data Factory.')
output privateEndpoints privateEndpointOutputType[] = [
  for (item, index) in (privateEndpoints ?? []): {
    name: dataFactory_privateEndpoints[index].outputs.name
    resourceId: dataFactory_privateEndpoints[index].outputs.resourceId
    groupId: dataFactory_privateEndpoints[index].outputs.?groupId!
    customDnsConfigs: dataFactory_privateEndpoints[index].outputs.customDnsConfigs
    networkInterfaceResourceIds: dataFactory_privateEndpoints[index].outputs.networkInterfaceResourceIds
  }
]

// ================ //
// Definitions      //
// ================ //

import {
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
  customerManagedKeyType
} from '../../../../bicep-shared/types.bicep'

import {
  integrationRuntimeType
} from 'integration-runtime/main.bicep'

import {
  linkedServiceType
} from 'linked-service/main.bicep'

type gitRepoConfig = {
  @description('''Optional. Repository type - can be \'FactoryVSTSConfiguration\' or \'FactoryGitHubConfiguration\'. Default is \'FactoryVSTSConfiguration\'.

  Setting this parameter to any other than 'FactoryVSTSConfiguration' will make the Data Factory resource non-compliant.
  ''')
  gitRepoType: 'FactoryVSTSConfiguration'

  @description('''Optional. The account name. This name is the ADO organization name.
  Setting this parameter to any other than 'connectdrcpapg1' will make the Data Factory resource non-compliant.
  ''')
  gitAccountName: 'connectdrcpapg1'

  @description('Optional. The project name. Only relevant for \'FactoryVSTSConfiguration\'.')
  gitProjectName: string?

  @description('Optional. The repository name.')
  gitRepositoryName: string?

  @description('Optional. The collaboration branch name. Default is \'main\'.')
  gitCollaborationBranch: string?

  @description('Optional. Disable manual publish operation in ADF studio to favor automated publish.')
  gitDisablePublish: bool

  @description('Optional. The root folder path name. Default is \'/\'.')
  gitRootFolder: string?

  @description('Optional. The GitHub Enterprise Server host (prefixed with \'https://\'). Only relevant for \'FactoryGitHubConfiguration\'.')
  gitHostName: string?

  @description('Optional. Add the last commit id from your git repo.')
  gitLastCommitId: string?

  @description('Optional. Add the tenantId of your Azure subscription.')
  gitTenantId: 'c1f94f0d-9a3d-4854-9288-bb90dcf2a90d'
}?

type privateEndpointOutputType = {
  @description('The name of the private endpoint.')
  name: string

  @description('The resource ID of the private endpoint.')
  resourceId: string

  @description('The group Id for the private endpoint Group.')
  groupId: string?

  @description('The custom DNS configurations of the private endpoint.')
  customDnsConfigs: {
    @description('FQDN that resolves to private endpoint IP address.')
    fqdn: string?

    @description('A list of private IP addresses of the private endpoint.')
    ipAddresses: string[]
  }[]

  @description('The IDs of the network interfaces associated with the private endpoint.')
  networkInterfaceResourceIds: string[]
}
