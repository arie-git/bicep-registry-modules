metadata name = 'User Assigned Identity'
metadata description = 'This module deploys a User Assigned Identity.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = 'There are no special compliance requirements for this module.'

@description('Required. Name of the User Assigned Identity.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('''Optional. The federated identity credentials list to indicate which tokens from the external Identity Providers should be trusted by your application.
Federated identity credentials are supported on applications only. A maximum of 20 federated identity credentials can be added per application object.''')
param federatedIdentityCredentials federatedIdentityCredentialType[]?

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'Managed Identity Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e40ec5ca-96e0-45a2-b4ff-59039f2c2b59')
  'Managed Identity Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','f1a07417-d97a-45cb-824c-7a7467783830')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.managedidentity-userassignedidentity.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: name
  location: location
  tags: finalTags
}

resource userAssignedIdentity_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: userAssignedIdentity
}

@batchSize(1)
module userAssignedIdentity_federatedIdentityCredentials 'federated-identity-credential/main.bicep' = [
  for (federatedIdentityCredential, index) in (federatedIdentityCredentials ?? []): {
    name: take('${uniqueString(deployment().name, name, location)}-usermsi-fedidentitycred-${index}',64)
    params: {
      name: federatedIdentityCredential.name
      userAssignedIdentityName: userAssignedIdentity.name
      audiences: federatedIdentityCredential.audiences
      issuer: federatedIdentityCredential.issuer
      subject: federatedIdentityCredential.subject
    }
  }
]

resource userAssignedIdentity_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(userAssignedIdentity.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: userAssignedIdentity
  }
]

@description('The name of the user assigned identity.')
output name string = userAssignedIdentity.name

@description('The resource ID of the user assigned identity.')
output resourceId string = userAssignedIdentity.id

@description('The principal ID (object ID) of the user assigned identity.')
output principalId string = userAssignedIdentity.properties.principalId

@description('The client ID (application ID) of the user assigned identity.')
output clientId string = userAssignedIdentity.properties.clientId

@description('The resource group the user assigned identity was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = userAssignedIdentity.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false

// =============== //
//   Definitions   //
// =============== //

import {
  lockType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

import { federatedIdentityCredentialType } from 'federated-identity-credential/main.bicep'
