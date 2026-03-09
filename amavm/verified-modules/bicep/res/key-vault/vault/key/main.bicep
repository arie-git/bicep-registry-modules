metadata name = 'Azure Key Vault Key'
metadata description = 'This module deploys an Azure Key Vault Key.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of this resource requires following parameter values:
- attributesExp: set to a value less than 1 year from the creation.
'''
metadata complianceVersion = '20260309'

// ================ //
// Parameters       //
// ================ //
@description('Conditional. The name of the parent key vault. Required if the template is used in a standalone deployment.')
param keyVaultName string

@description('Required. The name of the key.')
param name string

@description('Optional. Resource tags.')
param tags object?

@description('Optional. Determines whether the object (key) is enabled. Default: true.')
param attributesEnabled bool = true

@description('''Optional. Expiry date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp.
Default is 1 year (dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))).

Not setting the expiry date within 1 year will make the resource non-compliant.
''')
param attributesExp int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

@description('''Optional. Sets when this resource will become active.
This is a date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp. Default: null''')
param attributesNbf int?

@description('Optional. The elliptic curve name.')
@allowed([
  'P-256'
  'P-256K'
  'P-384'
  'P-521'
])
param curveName string = 'P-256'

@description('Optional. Array of JsonWebKeyOperation.')
@allowed([
  'decrypt'
  'encrypt'
  'import'
  'release'
  'sign'
  'unwrapKey'
  'verify'
  'wrapKey'
])
param keyOps string[]?

@description('Optional. The key size in bits. For example: 2048, 3072, or 4096 for RSA.')
param keySize int?

@description('Optional. The type of the key.')
@allowed([
  'EC'
  'EC-HSM'
  'RSA'
  'RSA-HSM'
])
param kty string = 'EC'

@description('Optional. Key release policy.')
param releasePolicy {
  @description('Optional. Content type and version of key release policy.')
  contentType: string?

  @description('Optional. Blob encoding the policy rules under which the key can be released.')
  data: string?
}?

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Key rotation policy properties object.')
param rotationPolicy rotationPolicyType?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Key Vault Crypto Officer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','14b46e9e-c2b7-41b4-b07b-48a6ebf60603')
  'Key Vault Crypto User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','12338af0-0e69-4776-bea7-57ae8d297424')
  'Key Vault Crypto Service Encryption User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e147488a-f6f5-4113-8e2d-b22465e65bf6')
  'Key Vault Crypto Service Release User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','08bbd89e-9f13-488c-ac41-acfcb10c90ab')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

#disable-next-line no-deployments-resources
// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.security-key-vault-key.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, keyVaultName), 0, 4)}',
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

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource key 'Microsoft.KeyVault/vaults/keys@2024-11-01' = {
  name: name
  parent: keyVault
  tags: finalTags
  properties: {
    attributes: {
      enabled: attributesEnabled
      exp: attributesExp
      nbf: attributesNbf
    }
    curveName: curveName
    keyOps: keyOps
    keySize: keySize
    kty: kty
    release_policy: releasePolicy ?? {}
    ...(!empty(rotationPolicy)
      ? {
          rotationPolicy: rotationPolicy
        }
      : {})
  }
}

resource key_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(key.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: key
  }
]

// =========== //
// Outputs     //
// =========== //
@description('The name of the key.')
output name string = key.name

@description('The resource ID of the key.')
output resourceId string = key.id

@description('The name of the resource group the key was created in.')
output resourceGroupName string = resourceGroup().name

@description('The properties of the key.')
output properties object = key.properties

@description('The Uri of the key.')
output keyUri string = key.properties.keyUri

@description('The Uri of the key with version included.')
output keyUriWithVersion string = key.properties.keyUriWithVersion


@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !((attributesExp != null) && ((attributesExp - key.properties.attributes.updated) <= 366 * 24 * 60 * 60))

// ================ //
// Definitions      //
// ================ //
import {
  roleAssignmentType
} from '../../../../../bicep-shared/types.bicep'

type rotationPolicyType = {
  @description('Optional. The attributes of key rotation policy.')
  attributes: {
    @description('Optional. The expiration time for the new key version. It should be in ISO8601 format. Eg: "P90D", "P1Y".')
    expiryTime: string?
  }?

  @description('Optional. The key rotation policy lifetime actions.')
  lifetimeActions: {
    @description('Optional. The type of the action.')
    action: {
      @description('Optional. The type of the action.')
      type: ('rotate' | 'notify')?
    }?

    @description('Optional. The time duration for rotating the key.')
    trigger: {
      @description('Optional. The time duration after key creation to rotate the key. It only applies to rotate. It will be in ISO 8601 duration format. Eg: "P90D", "P1Y".')
      timeAfterCreate: string?

      @description('Optional. The time duration before key expiring to rotate or notify. It will be in ISO 8601 duration format. Eg: "P90D", "P1Y".')
      timeBeforeExpiry: string?
    }?
  }[]?
}?

@export()
type keysType = {
  @description('Required. The name of the key.')
  name: string

  @description('Optional. Resource tags.')
  tags: object?

  @description('Optional. Contains attributes of the key.')
  attributes: {
    @description('Optional. Defines whether the key is enabled or disabled.')
    enabled: bool?

    @description('Optional. Defines when the key will become invalid. Defined in seconds since 1970-01-01T00:00:00Z.')
    exp: int?

    @description('Optional. If set, defines the date from which onwards the key becomes valid. Defined in seconds since 1970-01-01T00:00:00Z.')
    nbf: int?
  }?
  @description('Optional. The elliptic curve name. Only works if "keySize" equals "EC" or "EC-HSM". Default is "P-256".')
  curveName: ('P-256' | 'P-256K' | 'P-384' | 'P-521')?

  @description('Optional. The allowed operations on this key.')
  keyOps: ('decrypt' | 'encrypt' | 'import' | 'release' | 'sign' | 'unwrapKey' | 'verify' | 'wrapKey')[]?

  @description('Optional. The key size in bits. Only works if "keySize" equals "RSA" or "RSA-HSM". Default is "4096".')
  keySize: (2048 | 3072 | 4096)?

  @description('Optional. The type of the key. Default is "EC".')
  kty: ('EC' | 'EC-HSM' | 'RSA' | 'RSA-HSM')?

  @description('Optional. Key release policy.')
  releasePolicy: {
    @description('Optional. Content type and version of key release policy.')
    contentType: string?

    @description('Optional. Blob encoding the policy rules under which the key can be released.')
    data: string?
  }?

  @description('Optional. Key rotation policy.')
  rotationPolicy: rotationPolicyType?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType?
}[]?
