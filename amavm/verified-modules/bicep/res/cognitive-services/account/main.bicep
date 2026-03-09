metadata name = 'Cognitive Services'
metadata description = 'This module deploys a Cognitive Service.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''Compliant usage of this module requires the following parameter values:
- kind: 'AIServices', 'OpenAI', or 'TextAnalytics' (per drcp-ai-04)
- disableLocalAuth: true
- publicNetworkAccess: 'Disabled'
- managedIdentities: not empty
'''

@description('Required. The name of Cognitive Services account.')
param name string

@description('Required. Kind of the Cognitive Services account. Restricted to policy-approved kinds per drcp-ai-04 (AIServicesAllowSupportedKinds).')
@allowed([
  'AIServices'
  'OpenAI'
  'TextAnalytics'
])
param kind string

@description('Optional. SKU of the Cognitive Services account. Use \'Get-AzCognitiveServicesAccountSku\' to determine a valid combinations of \'kind\' and \'SKU\' for your Azure region.')
@allowed([
  'C2'
  'C3'
  'C4'
  'F0'
  'F1'
  'S'
  'S0'
  'S1'
  'S10'
  'S2'
  'S3'
  'S4'
  'S5'
  'S6'
  'S7'
  'S8'
  'S9'
  'DC0'
])
param sku string = 'S0'

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType


@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('''Optional. The diagnostic settings of the service.

Currently known available log categories are:
  'Audit'
  'RequestResponse'
  'AzureOpenAIRequestUsage'
  'Trace'
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('''Optional. Whether or not public network access is allowed for this resource. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.

Setting this parameter to 'Enabled' will make the resource non-compliant.
''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Conditional. Subdomain name used for token-based authentication. Required if \'networkAcls\' or \'privateEndpoints\' are set.')
param customSubDomainName string?

@description('''Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny. By default, bypass is 'None' and defaultAction is 'Deny'.

Changing bypass to value other than 'None' will make the resource non-compliant.
''')
param networkAcls object?

@description('Optional. List of allowed FQDN.')
param allowedFqdnList array?

@description('Optional. The API properties for special APIs.')
param apiProperties object?

@description('Optional. Specifies in AI Foundry where virtual network injection occurs to secure scenarios like Agents entirely within a private network.')
param networkInjections networkInjectionType?

@description('Optional. Enable/Disable project management feature for AI Foundry.')
param allowProjectManagement bool?

@description('Optional. Commitment plans to deploy for the cognitive services account.')
param commitmentPlans commitmentPlanType[]?

@description('''Optional. Allow only Azure AD authentication. Should be enabled for security reasons.

Setting this parameter to 'False' will make the resource non-compliant. Default: true
''')
param disableLocalAuth bool = true

@description('Optional. The customer managed key definition to use for the managed service.')
param customerManagedKey customerManagedKeyType

@description('Optional. The flag to enable dynamic throttling. Default: false')
param dynamicThrottlingEnabled bool = false

@secure()
@description('Optional. Resource migration token.')
param migrationToken string?

@description('Optional. Restore a soft-deleted cognitive service at deployment time. Will fail if no such soft-deleted resource exists.')
param restore bool = false

@description('Optional. Restrict outbound network access. Default: true')
param restrictOutboundNetworkAccess bool = true

@description('Optional. The storage accounts for this resource.')
param userOwnedStorage array?

@description('Optional. Array of deployments about cognitive service accounts to create.')
param deployments deploymentsType

@description('''Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.
Available values for 'service' are: 'account'.

Default: 'account' is used if  subnetResourceId is provided but 'service' is not specified.
''')
param privateEndpoints privateEndpointType

@description('Optional. The managed identity definition for this resource. Default: { systemAssigned: true }.')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

// Variables
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId} from '../../../../bicep-shared/environments.bicep'

var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version

var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }
var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null)
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var specificBuiltInRoleNames = {
  'Cognitive Services Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
  )
  'Cognitive Services Custom Vision Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'c1ff6cc2-c111-46fe-8896-e0ef812ad9f3'
  )
  'Cognitive Services Custom Vision Deployment': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '5c4089e1-6d96-4d2f-b296-c1bc7137275f'
  )
  'Cognitive Services Custom Vision Labeler': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '88424f51-ebe7-446f-bc41-7fa16989e96c'
  )
  'Cognitive Services Custom Vision Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '93586559-c37d-4a6b-ba08-b9f0940c2d73'
  )
  'Cognitive Services Custom Vision Trainer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0a5ae4ab-0d65-4eeb-be61-29fc9b54394b'
  )
  'Cognitive Services Data Reader (Preview)': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b59867f0-fa02-499b-be73-45a86b5b3e1c'
  )
  'Cognitive Services Face Recognizer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '9894cab4-e18a-44aa-828b-cb588cd6f2d7'
  )
  'Cognitive Services Immersive Reader User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b2de6794-95db-4659-8781-7e080d3f2b9d'
  )
  'Cognitive Services Language Owner': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f07febfe-79bc-46b1-8b37-790e26e6e498'
  )
  'Cognitive Services Language Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '7628b7b8-a8b2-4cdc-b46f-e9b35248918e'
  )
  'Cognitive Services Language Writer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f2310ca1-dc64-4889-bb49-c8e0fa3d47a8'
  )
  'Cognitive Services LUIS Owner': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f72c8140-2111-481c-87ff-72b910f6e3f8'
  )
  'Cognitive Services LUIS Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '18e81cdc-4e98-4e29-a639-e7d10c5a6226'
  )
  'Cognitive Services LUIS Writer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '6322a993-d5c9-4bed-b113-e49bbea25b27'
  )
  'Cognitive Services Metrics Advisor Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'cb43c632-a144-4ec5-977c-e80c4affc34a'
  )
  'Cognitive Services Metrics Advisor User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '3b20f47b-3825-43cb-8114-4bd2201156a8'
  )
  'Cognitive Services OpenAI Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a001fd3d-188f-4b5d-821b-7da978bf7442'
  )
  'Cognitive Services OpenAI User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  )
  'Cognitive Services QnA Maker Editor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f4cc2bf9-21be-47a1-bdf1-5c5804381025'
  )
  'Cognitive Services QnA Maker Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '466ccd10-b268-4a11-b098-b4849f024126'
  )
  'Cognitive Services Speech Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '0e75ca1e-0464-4b4d-8b93-68208a576181'
  )
  'Cognitive Services Speech User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f2dc8367-1007-4938-bd23-fe263f013447'
  )
  'Cognitive Services User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'a97b65f3-24c7-4388-baec-2e87135dc908'
  )
}

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

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'Audit'
  'RequestResponse'
  'AzureOpenAIRequestUsage'
  'Trace'
]

var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]

// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.cognitiveservices-account.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

var isHSMManagedCMK = split(customerManagedKey.?keyVaultResourceId ?? '', '/')[?7] == 'managedHSMs'

resource cMKKeyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
  name: last(split(customerManagedKey.?keyVaultResourceId!, '/'))
  scope: resourceGroup(
    split(customerManagedKey.?keyVaultResourceId!, '/')[2],
    split(customerManagedKey.?keyVaultResourceId!, '/')[4]
  )

  resource cMKKey 'keys@2025-05-01' existing = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
    name: customerManagedKey.?keyName!
  }
}

resource cMKUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' existing = if (!empty(customerManagedKey.?userAssignedIdentityResourceId)) {
  name: last(split(customerManagedKey.?userAssignedIdentityResourceId!, '/'))
  scope: resourceGroup(
    split(customerManagedKey.?userAssignedIdentityResourceId!, '/')[2],
    split(customerManagedKey.?userAssignedIdentityResourceId!, '/')[4]
  )
}

resource cognitiveService 'Microsoft.CognitiveServices/accounts@2025-06-01' = {
  name: name
  kind: kind
  identity: identity
  location: location
  tags: finalTags
  sku: {
    name: sku
  }
  properties: {
    allowProjectManagement: allowProjectManagement
    customSubDomainName: customSubDomainName
    networkAcls: !empty(networkAcls ?? {})
      ? {
          defaultAction: networkAcls.?defaultAction
          virtualNetworkRules: networkAcls.?virtualNetworkRules ?? []
          ipRules: networkAcls.?ipRules ?? []
        }
      : null
    #disable-next-line BCP036
    networkInjections: !empty(networkInjections)
      ? [
          {
            scenario: networkInjections.?scenario
            subnetArmId: networkInjections.?subnetResourceId
            useMicrosoftManagedNetwork: networkInjections.?useMicrosoftManagedNetwork ?? false
          }
        ]
      : null
    publicNetworkAccess: publicNetworkAccess != null
      ? publicNetworkAccess
      : (!empty(networkAcls) ? 'Enabled' : 'Disabled')
    allowedFqdnList: allowedFqdnList
    apiProperties: apiProperties
    disableLocalAuth: disableLocalAuth
    encryption: !empty(customerManagedKey)
      ? {
          keySource: 'Microsoft.KeyVault'
          keyVaultProperties: {
            identityClientId: !empty(customerManagedKey.?userAssignedIdentityResourceId ?? '')
              ? cMKUserAssignedIdentity!.properties.clientId
              : null
            keyVaultUri: !isHSMManagedCMK
              ? cMKKeyVault!.properties.vaultUri
              : 'https://${last(split((customerManagedKey!.keyVaultResourceId), '/'))}.managedhsm.azure.net/'
            keyName: customerManagedKey!.keyName
            keyVersion: !empty(customerManagedKey.?keyVersion)
              ? customerManagedKey!.keyVersion!
              : (!isHSMManagedCMK
                  ? last(split(cMKKeyVault::cMKKey!.properties.keyUriWithVersion, '/'))
                  : fail('Managed HSM CMK encryption requires specifying the \'keyVersion\'.'))
          }
        }
      : null
    migrationToken: migrationToken
    restore: restore
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    userOwnedStorage: userOwnedStorage
    dynamicThrottlingEnabled: dynamicThrottlingEnabled
  }
}

@batchSize(1)
resource cognitiveService_deployments 'Microsoft.CognitiveServices/accounts/deployments@2025-06-01' = [
  for (deployment, index) in (deployments ?? []): {
    parent: cognitiveService
    name: deployment.?name ?? '${name}-deployments'
    properties: {
      model: deployment.model
      raiPolicyName: deployment.?raiPolicyName
      versionUpgradeOption: deployment.?versionUpgradeOption
    }
    sku: deployment.?sku ?? {
      name: sku
    }
  }
]

resource cognitiveService_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: cognitiveService
}

resource cognitiveService_commitmentPlans 'Microsoft.CognitiveServices/accounts/commitmentPlans@2025-06-01' = [
  for plan in (commitmentPlans ?? []): {
    parent: cognitiveService
    name: '${plan.hostingModel}-${plan.planType}'
    properties: plan
  }
]

resource cognitiveService_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
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
    scope: cognitiveService
  }
]

module cognitiveService_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-cognitiveService-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? 'pep-${last(split(cognitiveService.id, '/'))}-${privateEndpoint.?service ?? 'account'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(cognitiveService.id, '/'))}-${privateEndpoint.?service ?? 'account'}-${index}'
              properties: {
                privateLinkServiceId: cognitiveService.id
                groupIds: [
                  privateEndpoint.?service ?? 'account'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(cognitiveService.id, '/'))}-${privateEndpoint.?service ?? 'account'}-${index}'
              properties: {
                privateLinkServiceId: cognitiveService.id
                groupIds: [
                  privateEndpoint.?service ?? 'account'
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

resource cognitiveService_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(cognitiveService.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: cognitiveService
  }
]

@description('The name of the cognitive services account.')
output name string = cognitiveService.name

@description('The resource ID of the cognitive services account.')
output resourceId string = cognitiveService.id

@description('The resource group the cognitive services account was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The service endpoint of the cognitive services account.')
output endpoint string = cognitiveService.properties.endpoint

@description('All endpoints available for the cognitive services account, types depends on the cognitive service kind.')
output endpoints endpointsType = cognitiveService.properties.endpoints

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = cognitiveService.?identity.?principalId

@description('The location the resource was deployed into.')
output location string = cognitiveService.location

@description('The private endpoints of the congitive services account.')
output privateEndpoints array = [
  for (pe, i) in (!empty(privateEndpoints) ? array(privateEndpoints) : []): {
    name: cognitiveService_privateEndpoints[i].outputs.name
    resourceId: cognitiveService_privateEndpoints[i].outputs.resourceId
    groupId: cognitiveService_privateEndpoints[i].outputs.groupId
    customDnsConfigs: cognitiveService_privateEndpoints[i].outputs.customDnsConfigs
    networkInterfaceResourceIds: cognitiveService_privateEndpoints[i].outputs.networkInterfaceResourceIds
  }
]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (!disableLocalAuth) || (publicNetworkAccess=='Enabled' || empty(managedIdentities))

// ================ //
// Definitions      //
// ================ //

@export()
type deploymentsType = {
  @description('Optional. Specify the name of cognitive service account deployment.')
  name: string?

  @description('Required. Properties of Cognitive Services account deployment model.')
  model: {
    @description('Required. The name of Cognitive Services account deployment model.')
    name: string

    @description('Required. The format of Cognitive Services account deployment model.')
    format: string

    @description('Required. The version of Cognitive Services account deployment model.')
    version: string
  }

  @description('Optional. The resource model definition representing SKU.')
  sku: {
    @description('Required. The name of the resource model definition representing SKU.')
    name: string

    @description('Optional. The capacity of the resource model definition representing SKU.')
    capacity: int?

    @description('Optional. The tier of the resource model definition representing SKU.')
    tier: string?

    @description('Optional. The size of the resource model definition representing SKU.')
    size: string?

    @description('Optional. The family of the resource model definition representing SKU.')
    family: string?
  }?

  @description('Optional. The name of RAI policy.')
  raiPolicyName: string?

  @description('Optional. The version upgrade option.')
  versionUpgradeOption: string?
}[]?

@export()
type endpointsType = {
  @description('Type of the endpoint.')
  name: string?
  @description('The endpoint URI.')
  endpoint: string?
}?

@export()
@description('The type for a disconnected container commitment plan.')
type commitmentPlanType = {
  @description('Required. Whether the plan should auto-renew at the end of the current commitment period.')
  autoRenew: bool

  @description('Required. The current commitment configuration.')
  current: {
    @description('Required. The number of committed instances (e.g., number of containers or cores).')
    count: int

    @description('Required. The tier of the commitment plan (e.g., T1, T2).')
    tier: string
  }

  @description('Required. The hosting model for the commitment plan. (e.g., DisconnectedContainer, ConnectedContainer, ProvisionedWeb, Web).')
  hostingModel: string

  @description('Required. The plan type indicating which capability the plan applies to (e.g., NTTS, STT, CUSTOMSTT, ADDON).')
  planType: string

  @description('Optional. The unique identifier of an existing commitment plan to update. Set to null to create a new plan.')
  commitmentPlanGuid: string?

  @description('Optional. The configuration of the next commitment period, if scheduled.')
  next: {
    @description('Required. The number of committed instances for the next period.')
    count: int

    @description('Required. The tier for the next commitment period.')
    tier: string
  }?
}

@export()
@description('Type for network configuration in AI Foundry where virtual network injection occurs to secure scenarios like Agents entirely within a private network.')
type networkInjectionType = {
  @description('Required. The scenario for the network injection.')
  scenario: 'agent' | 'none'

  @description('Required. The Resource ID of the subnet on the Virtual Network on which to inject.')
  subnetResourceId: string

  @description('Optional. Whether to use Microsoft Managed Network. Defaults to false.')
  useMicrosoftManagedNetwork: bool?
}

import {
  customerManagedKeyType
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

