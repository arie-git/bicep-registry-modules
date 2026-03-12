@description('Optional. Array of role assignments to create.')
param roleAssignments array

@description('Required. The resource id of the file share to assign the roles to.')
param fileShareResourceId string

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'Reader and Data Access': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','c12c1c16-33a1-487b-954d-41c89c60f349')
  'Storage Account Backup Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1')
  'Storage Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','17d1049b-9a84-46fb-8f53-869881c3d3ab')
  'Storage Account Key Operator Service Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','81a9662b-bebf-436f-a333-f67b29880f12')
  'Storage File Data SMB Share Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb')
  'Storage File Data SMB Share Elevated Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','a7264617-510b-434b-a828-9731dc254ea7')
  'Storage File Data SMB Share Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','aba4ae5f-2193-4029-9191-0cb91df5e314')
}
@export()
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

#disable-next-line no-deployments-resources
resource fileShare_roleAssignments 'Microsoft.Resources/deployments@2024-07-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: '${uniqueString(deployment().name)}-share-rbac-${index}'
    properties: {
      mode: 'Incremental'
      expressionEvaluationOptions: {
        scope: 'Outer'
      }
      template: loadJsonContent('nested_inner_roleAssignment.json')
      parameters: {
        scope: {
          value: replace(fileShareResourceId, '/shares/', '/fileShares/')
        }
        name: {
          value: guid(fileShareResourceId, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName, 'tyfa')
        }
        roleDefinitionId: {
          #disable-next-line use-safe-access
          value: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
            ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
            : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
                ? roleAssignment.roleDefinitionIdOrName
                : subscriptionResourceId(
                    'Microsoft.Authorization/roleDefinitions',
                    roleAssignment.roleDefinitionIdOrName
                  )
        }
        principalId: {
          value: roleAssignment.principalId
        }
        principalType: {
          value: roleAssignment.?principalType
        }
        description: {
          value: roleAssignment.?description
        }
        condition: {
          value: roleAssignment.?condition
        }
        conditionVersion: {
          value: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
        }
        delegatedManagedIdentityResourceId: {
          value: roleAssignment.?delegatedManagedIdentityResourceId
        }
      }
    }
  }
]
