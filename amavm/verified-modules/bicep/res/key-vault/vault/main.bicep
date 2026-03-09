metadata name = 'Azure Key Vault'
metadata description = 'This module deploys an Azure Key Vault.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''Compliant usage of Azure Key-Vault requires:
- skuName: 'premium'
- publicNetworkAccess: 'Disabled'
- enablePurgeProtection: true
- accessPolicies: none / empty
'''

// ================ //
// Parameters       //
// ================ //
@description('Required. Name of the Key Vault. Must be globally unique.')
@maxLength(24)
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('''Optional. All access policies to create.

Configuring Access Policies on key vault will make the key-vault resource non-compliant.
''')
param accessPolicies accessPoliciesType

@description('Optional. All secrets to create.')
param secrets secretsType?

@description('Optional. All keys to create.')
param keys keysType?

@description('Optional. Specifies if the vault is enabled for deployment by script or compute.')
param enableVaultForDeployment bool = true

@description('Optional. Specifies if the vault is enabled for a template deployment.')
param enableVaultForTemplateDeployment bool = true

@description('Optional. Specifies if the azure platform has access to the vault for enabling disk encryption scenarios.')
param enableVaultForDiskEncryption bool = true

@description('''Optional. Switch to enable/disable Key Vault\'s soft delete feature.

Setting this parameter to false is not supported for new Key Vault deployments in Azure anymore.
[Policy: drcp-kv-05]
''')
param enableSoftDelete bool = true

@description('''Optional. softDelete data retention days. It accepts >=7 and <=90.

Setting this parameter value to to less than 7 or greater than 90 or null will make the resource non-compliant.
''')
param softDeleteRetentionInDays int = 90

@description('''Optional. Property that controls how data actions are authorized. When true, the key vault will use Role Based Access Control (RBAC) for authorization of data actions, and the access policies specified in vault properties will be ignored.
When false, the key vault will use the access policies specified in vault properties, and any policy stored on Azure Resource Manager will be ignored. Note that management actions are always authorized with RBAC.

Setting this parameter value to 'false' will make the resource non-compliant.
[Policy: drcp-kv-02]
''')
param enableRbacAuthorization bool = true

@description('Optional. The vault\'s create mode to indicate whether the vault need to be recovered or not.')
@allowed([
  'default'
  'recover'
])
param createMode string = 'default'

@description('''Optional. Provide 'true' to enable Key Vault\'s purge protection feature.

Setting this parameter value to 'false' will make the resource non-compliant.
[Policy: drcp-kv-04]
''')
param enablePurgeProtection bool = true

@description('''Optional. Specifies the SKU for the vault.

Setting this parameter to any other than Premium will make the key-vault resource non-compliant.
''')
@allowed([
  'premium'
  'standard'
])
param sku string = 'premium'

@description('Optional. Rules governing the accessibility of the resource from specific network locations.')
param networkAcls networkAclsType?

@description('''Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set.

Setting this parameter to any other than Disabled will make the key-vault resource non-compliant.
[Policy: drcp-kv-01]
''')
@allowed([
  ''
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. [Policy: drcp-sub-07] [Policy: drcp-kv-11]')
param privateEndpoints privateEndpointType

@description('Optional. Resource tags.')
param tags object?

@description('''Optional. The diagnostic settings of the service.

Currently known available log categories are:
'AuditEvent'
'AzurePolicyEvaluationDetails'
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var formattedAccessPolicies = [
  for accessPolicy in (accessPolicies ?? []): {
    applicationId: accessPolicy.?applicationId ?? ''
    objectId: accessPolicy.objectId
    permissions: accessPolicy.permissions
    tenantId: accessPolicy.?tenantId ?? tenant().tenantId
  }
]

var specificBuiltInRoleNames = {
  'Key Vault Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','00482a5a-887f-4fb3-b363-3b7fe8e74483')
  'Key Vault Certificates Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','a4417e6f-fecd-4de8-b567-7b0420556985')
  'Key Vault Certificate User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','db79e9a7-68ee-4b58-9aeb-b90e7c24fcba')
  'Key Vault Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','f25e0fa2-a7c8-4377-a976-54943a77a395')
  'Key Vault Crypto Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
  'Key Vault Crypto Service Encryption User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e147488a-f6f5-4113-8e2d-b22465e65bf6')
  'Key Vault Crypto Service Release User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','08bbd89e-9f13-488c-ac41-acfcb10c90ab')
  'Key Vault Crypto User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','12338af0-0e69-4776-bea7-57ae8d297424')
  'Key Vault Data Access Administrator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','8b54135c-b56d-4d72-a534-26097cfdc8d8')
  'Key Vault Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','21090545-7ca7-4776-b22c-e363652d74d2')
  'Key Vault Secrets Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b86a8fe4-44ce-4948-aee5-eccb2c155cd7')
  'Key Vault Secrets User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4633458b-17de-408a-b874-0445c86b69e6')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'AuditEvent'
  'AzurePolicyEvaluationDetails'
]

var defaultLogCategories = [for category in defaultLogCategoryNames: {
  category: category
}]

// ============ //
// Dependencies //
// ============ //
#disable-next-line no-deployments-resources
// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.security-key-vault.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: name
  location: location
  tags: finalTags
  properties: {
    enabledForDeployment: enableVaultForDeployment
    enabledForTemplateDeployment: enableVaultForTemplateDeployment
    enabledForDiskEncryption: enableVaultForDiskEncryption
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    createMode: createMode
    enablePurgeProtection: enablePurgeProtection ? enablePurgeProtection : null
    tenantId: subscription().tenantId
    accessPolicies: formattedAccessPolicies
    sku: {
      name: sku
      family: 'A'
    }
    networkAcls: !empty(networkAcls)
      ? union(
          {
            resourceAccessRules: networkAcls.?resourceAccessRules
            defaultAction: networkAcls.?defaultAction ?? 'Deny'
            virtualNetworkRules: networkAcls.?virtualNetworkRules
            ipRules: networkAcls.?ipRules
          },
          (contains(networkAcls!, 'bypass') ? { bypass: networkAcls.?bypass } : {}) // setting `bypass` to `null`is not supported
        )
      : {
          // New default case that enables the firewall by default
          bypass: 'AzureServices'
          defaultAction: 'Deny'
        }
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? publicNetworkAccess
      : ((!empty(privateEndpoints ?? []) && empty(networkAcls ?? {})) ? 'Disabled' : null)
  }
}

resource keyVault_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?notes ?? (lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.')
  }
  scope: keyVault
}

#disable-next-line use-recent-api-versions
resource keyVault_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
    scope: keyVault
  }
]

module keyVault_accessPolicies 'access-policy/main.bicep' = if (!empty(accessPolicies)) {
  name: '${uniqueString(deployment().name, location, name)}-keyvault-accesspolicies'
  params: {
    keyVaultName: keyVault.name
    accessPolicies: accessPolicies
  }
}

module keyVault_secrets 'secret/main.bicep' = [
  for (secret, index) in (secrets ?? []): {
    name: '${uniqueString(deployment().name, location, name)}-keyvault-secret-${index}'
    params: {
      name: secret.name
      value: secret.value
      keyVaultName: keyVault.name
      attributesEnabled: secret.?attributes.?enabled
      attributesExp: secret.?attributes.?exp
      attributesNbf: secret.?attributes.?nbf
      contentType: secret.?contentType
      tags: secret.?finalTags ?? finalTags
      roleAssignments: secret.?roleAssignments
      enableTelemetry: false // primary resource telemetry applies
    }
  }
]

module keyVault_keys 'key/main.bicep' = [
  for (key, index) in (keys ?? []): {
    name: '${uniqueString(deployment().name, location, name)}-keyvault-key-${index}'
    params: {
      name: key.name
      keyVaultName: keyVault.name
      attributesEnabled: key.?attributes.?enabled
      attributesExp: key.?attributes.?exp
      attributesNbf: key.?attributes.?nbf
      curveName: (key.?kty != 'RSA' && key.?kty != 'RSA-HSM') ? (key.?curveName ?? 'P-256') : null
      keyOps: key.?keyOps
      keySize: (key.?kty == 'RSA' || key.?kty == 'RSA-HSM') ? (key.?keySize ?? 4096) : null
      releasePolicy: key.?releasePolicy ?? {}
      kty: key.?kty ?? 'EC'
      tags: key.?finalTags ?? finalTags
      roleAssignments: key.?roleAssignments
      rotationPolicy: key.?rotationPolicy
      enableTelemetry: false // primary resource telemetry applies
    }
  }
]

module keyVault_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (privateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location, name)}-keyvault-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(keyVault.id, '/'))}-pep-${privateEndpoint.?service ?? 'vault'}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
              properties: {
                privateLinkServiceId: keyVault.id
                groupIds: [
                  privateEndpoint.?service ?? 'vault'
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(keyVault.id, '/'))}-${privateEndpoint.?service ?? 'vault'}-${index}'
              properties: {
                privateLinkServiceId: keyVault.id
                groupIds: [
                  privateEndpoint.?service ?? 'vault'
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

resource keyVault_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(keyVault.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: keyVault
  }
]

// =========== //
// Outputs     //
// =========== //
@description('The resource ID of the key vault.')
output resourceId string = keyVault.id

@description('The name of the resource group the key vault was created in.')
output resourceGroupName string = resourceGroup().name

@description('The name of the key vault.')
output name string = keyVault.name

@description('The properties of the Key-Vault.')
output properties object = keyVault.properties

@description('The URI of the key vault.')
output uri string = keyVault.properties.vaultUri

@description('The location the resource was deployed into.')
output location string = keyVault.location

@description('The array of created secrets.')
#disable-next-line outputs-should-not-contain-secrets // this output does not contain secret values, but only metadata
output secrets array = [for (secret, index) in (secrets ?? []): {
  name: keyVault_secrets[index].outputs.name
  resourceId: keyVault_secrets[index].outputs.resourceId
  secretUri: keyVault_secrets[index].outputs.secretUri
  secretUriWithVersion: keyVault_secrets[index].outputs.secretUriWithVersion
  evidenceOfNonCompliance: keyVault_secrets[index].outputs.evidenceOfNonCompliance
}]

@description('The array of created keys.')
output keys array = [for (key, index) in (keys ?? []): {
  name: keyVault_keys[index].outputs.name
  resourceId: keyVault_keys[index].outputs.resourceId
  keyUri: keyVault_keys[index].outputs.keyUri
  keyUriWithVersion: keyVault_keys[index].outputs.keyUriWithVersion
  evidenceOfNonCompliance: keyVault_keys[index].outputs.evidenceOfNonCompliance
}]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (sku != 'premium' || keyVault.properties.publicNetworkAccess != 'Disabled' || !enablePurgeProtection || !enableRbacAuthorization || !enableSoftDelete || !empty(accessPolicies ?? []))

// ================ //
// Definitions      //
// ================ //

import {
  diagnosticSettingType
  lockType
  managedIdentitiesType
  networkAclsType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

import { accessPoliciesType } from 'access-policy/main.bicep'
import { keysType } from 'key/main.bicep'
import { secretsType } from 'secret/main.bicep'
