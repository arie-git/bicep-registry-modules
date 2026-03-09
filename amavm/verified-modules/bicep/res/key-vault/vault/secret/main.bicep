metadata name = 'Azure Key Vault Secret'
metadata description = 'This module deploys an Azure Key Vault Secret.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of this resource requires following parameter values:
- attributesExp: set to a value less than 1 year from the creation.
'''
metadata complianceVersion = '20260309'

@description('Conditional. The name of the parent key vault. Required if the template is used in a standalone deployment.')
param keyVaultName string

@description('Required. The name of the secret (letters (upper and lower case), numbers, -).')
@minLength(1)
@maxLength(127)
param name string

@description('Optional. Resource tags.')
param tags object?

@description('Optional. Determines whether the object (secret) is enabled. Default: true.')
param attributesEnabled bool = true

@description('''Optional. Expiry date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp.
Default is 1 year (dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))).

Not setting the expiry date within 1 year will make the resource non-compliant.
''')
param attributesExp int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

@description('''Optional. Sets when this resource will become active.
This is a date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp. Default: null''')
param attributesNbf int?

@description('Optional. The content type of the secret.')
@secure()
param contentType string?

@description('Required. The value of the secret. NOTE: "value" will never be returned from the service, as APIs using this model are is intended for internal use in ARM deployments. Users should use the data-plane REST service for interaction with vault secrets.')
@secure()
param value string

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Key Vault Administrator': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  )
  'Key Vault Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'f25e0fa2-a7c8-4377-a976-54943a77a395'
  )
  'Key Vault Reader': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '21090545-7ca7-4776-b22c-e363652d74d2'
  )
  'Key Vault Secrets Officer': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  )
  'Key Vault Secrets User': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4633458b-17de-408a-b874-0445c86b69e6'
  )
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

#disable-next-line no-deployments-resources
// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.security-key-vault-secret.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, keyVaultName), 0, 4)}',
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

resource secret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  name: name
  parent: keyVault
  tags: finalTags
  properties: {
    contentType: contentType
    attributes: {
      enabled: attributesEnabled
      exp: attributesExp
      nbf: attributesNbf
    }
    value: value
  }
}

resource secret_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(secret.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: secret
  }
]

// =========== //
// Outputs     //
// =========== //
@description('The name of the secret.')
output name string = secret.name

@description('The resource ID of the secret.')
output resourceId string = secret.id

@description('The name of the resource group the secret was created in.')
output resourceGroupName string = resourceGroup().name

@description('The properties of the secret.')
output properties object = secret.properties

@description('The Uri of the secret.')
output secretUri string = secret.properties.secretUri
@description('The Uri of the secret with version included.')
output secretUriWithVersion string = secret.properties.secretUriWithVersion

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !((attributesExp != null) && ((attributesExp - secret.properties.attributes.updated) <= 366 * 24 * 60 * 60))

// ================ //
// Definitions      //
// ================ //
import {
  roleAssignmentType
} from '../../../../../bicep-shared/types.bicep'

@export()
type secretsType = {
  @description('Required. The name of the secret.')
  name: string

  @description('Optional. Resource tags.')
  tags: object?

  @description('Optional. Contains attributes of the secret.')
  attributes: {
    @description('Optional. Defines whether the secret is enabled or disabled.')
    enabled: bool?

    @description('Optional. Defines when the secret will become invalid. Defined in seconds since 1970-01-01T00:00:00Z.')
    exp: int?

    @description('Optional. If set, defines the date from which onwards the secret becomes valid. Defined in seconds since 1970-01-01T00:00:00Z.')
    nbf: int?
  }?
  @description('Optional. The content type of the secret.')
  contentType: string?

  @description('Required. The value of the secret. NOTE: "value" will never be returned from the service, as APIs using this model are is intended for internal use in ARM deployments. Users should use the data-plane REST service for interaction with vault secrets.')
  @secure()
  value: string

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType?
}[]?
