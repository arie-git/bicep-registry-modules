targetScope = 'resourceGroup'

@sys.description('Required. You can provide either the display name of the role definition, or its fully qualified ID in the following format: \'/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11\'')
param roleDefinitionIdOrName string

@sys.description('Required. The Principal or Object ID of the Security Principal (User, Group, Service Principal, Managed Identity)')
param principalIds array

@sys.description('Optional. Resource Group Name to apply Role Assignment too')
param resourceGroupName string = resourceGroup().name

@sys.description('Optional. Description of role assignment')
param description string = ''

param resourceName string

@allowed([
  'integrationRuntimes'
])
param resourceType string

@sys.description('Optional. The principal type of the assigned principal ID.')
@allowed([
  'ServicePrincipal'
  'Group'
  'User'
  'ForeignGroup'
  'Device'
  ''
])
param principalType string =  ''

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var builtInRoleNames = {
  Contributor: '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
  Owner: '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Reader: '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
  'Data Factory Contributor': '/providers/Microsoft.Authorization/roleDefinitions/673868aa-7521-48a0-acc6-0f60742d39f5'
}

var customRoleNames = {
  'APG Custom - DRCP - Contributor (FP-MG) - DEV': '/providers/Microsoft.Authorization/roleDefinitions/02e707b7-8e34-4dc8-9b4d-768a0821f205'
  'APG Custom - DRCP - Contributor (FP-MG) - TST': '/providers/Microsoft.Authorization/roleDefinitions/f41b3eb4-eaa8-48f2-b979-7a04b7dd2841'
}

// Combine built-in roles and custom roles into a single map
var roleDefinitionMap = union(builtInRoleNames, customRoleNames)
resource res1 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' existing = if(resourceType == 'integrationRuntimes') {
  name: resourceName
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for principalId in principalIds: {
  name: guid(resourceGroupName, principalId, roleDefinitionIdOrName)
  scope: (resourceType == 'integrationRuntimes') ? res1 : resourceGroup()
  properties: {
    description: description
    roleDefinitionId: contains(roleDefinitionMap, roleDefinitionIdOrName) ? roleDefinitionMap[roleDefinitionIdOrName] : roleDefinitionIdOrName
    principalId: principalId
    principalType: any(principalType)
  }
}]

output result bool = true
