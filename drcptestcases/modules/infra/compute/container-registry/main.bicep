@minLength(5)
@maxLength(50)
@description('The name of the Azure Container Registry.')
param name string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tags for all resource(s).')
param tags object = {}

@description('The SKU of the Azure Container Registry.')
@allowed([
  'Premium'
])
param skuName string = 'Premium'

@description('Toggle the Azure Container Registry admin user.')
param adminUserEnabled bool = false

@description('Toggle public network access to Azure Container Registry.')
@allowed([
  false
])
param publicNetworkAccessEnabled bool = false

@description('When public network access is disabled, toggle this to allow Azure services to bypass the public network access rule.')
// @allowed([
//   false
// ])
param azureServicesBypassEnabled bool = false

@description('A list of IP or IP ranges in CIDR format, that should be allowed access to Azure Container Registry.')
param networkAllowedIpRanges array = []

@description('The default action to take when no network rule match is found for accessing Azure Container Registry.')
@allowed([
  //'Allow'
  'Deny'
])
param networkDefaultAction string = 'Deny'

@description('''
Array of role assignment objects that contain the \'roleDefinitionIdOrName\', and an inside array of 'principals' (with fields \'principalType\' and \'objectId\'), to define RBAC role assignments on this resource.
In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or the GUID ID of the role (See See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles').
roleDefinitionIdOrName : value
principals : [
  objectId: \<object Id from the AAD\>
  principalType: \<one of: 'Device' | 'ForeignGroup' | 'Group' | 'ServicePrincipal' | 'User'\>
]
''')
param roleAssignments array = []

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Specify the type of lock.')
param lock string = 'NotSpecified'

@description('Toggle if Zone Redundancy should be enabled on Azure Container Registry.')
param zoneRedundancyEnabled bool = false

@description('Array of Azure Location configurations that this Azure Container Registry should replicate too.')
param replicationLocations array = []

@description('Toggle if a single data endpoint per region for serving data from Azure Container Registry should be enabled.')
param dataEndpointEnabled bool = false

@description('Toggle if encryption should be enabled on Azure Container Registry.')
param encryptionEnabled bool = false

@description('Toggle if export policy should be enabled on Azure Container Registry.')
param exportPolicyEnabled bool = false

@description('Toggle if quarantine policy should be enabled on Azure Container Registry.')
param quarantinePolicyEnabled bool = false

@description('Toggle if retention policy should be enabled on Azure Container Registry.')
param retentionPolicyEnabled bool = false

@description('Configure the retention policy in days for Azure Container Registry. Only effective is \'retentionPolicyEnabled\' is \'true\'.')
param retentionPolicyInDays int = 10

@description('Toggle if trust policy should be enabled on Azure Container Registry.')
param trustPolicyEnabled bool = false

@description('The client ID of the identity which will be used to access Key Vault.')
param encryptionKeyVaultIdentity string = ''

@description('The Key Vault URI to access the encryption key.')
param encryptionKeyVaultKeyIdentifier string = ''

@description('Resource ID of the diagnostic storage account.')
param diagnosticStorageAccountId string = ''

@description('Resource ID of the diagnostic log analytics workspace.')
param logAnalyticsWorkspaceId string = ''

@description('Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.')
param diagnosticEventHubName string = ''

@description('The name of logs that will be streamed.')
@allowed([
  'ContainerRegistryRepositoryEvents'
  'ContainerRegistryLoginEvents'
])
param logsToEnable array = [
  'ContainerRegistryRepositoryEvents'
  'ContainerRegistryLoginEvents'
]

@description('The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param metricsToEnable array = [
  'AllMetrics'
]

param virtualNetworkSubnetResourceId string = ''

@description('Optional. If to create an agent pool for ACR tasks. Default: true.')
param doCreateDefaultPool bool = true

var diagnosticsLogs = [for log in logsToEnable: {
  category: log
  enabled: true
}]

var diagnosticsMetrics = [for metric in metricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
}]

var varNetworkAllowedIpRanges = [for item in networkAllowedIpRanges: {
  value: item
  action: 'Allow'
}]

var IS_PREMIUM_SKU = skuName == 'Premium'

var varReplicationLocations = [for replicationLocation in replicationLocations: {
  location: replicationLocation.location
  regionEndpointEnabled: contains(replicationLocation, 'regionEndpointEnabled') ? replicationLocation.regionEndpointEnabled : false
  zoneRedundancy: contains(replicationLocation, 'zoneRedundancy') ? replicationLocation.zoneRedundancy : false
}]

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: IS_PREMIUM_SKU ? publicNetworkAccessEnabled ? 'Enabled' : 'Disabled' : null
    networkRuleBypassOptions: IS_PREMIUM_SKU ? azureServicesBypassEnabled ? 'AzureServices' : 'None' : null
    networkRuleSet: IS_PREMIUM_SKU ? {
      defaultAction: networkDefaultAction
      ipRules: varNetworkAllowedIpRanges
    } : null
    dataEndpointEnabled: dataEndpointEnabled
    encryption: IS_PREMIUM_SKU ? encryptionEnabled ? {
      keyVaultProperties: {
        identity: encryptionKeyVaultIdentity
        keyIdentifier: encryptionKeyVaultKeyIdentifier
      }
      status: 'enabled'
    } : null : null
    zoneRedundancy: IS_PREMIUM_SKU ? zoneRedundancyEnabled ? 'Enabled' : 'Disabled' : null
    policies: {
      exportPolicy: azureServicesBypassEnabled == 'false' ? {
        status: exportPolicyEnabled ? 'enabled' : 'disabled'
      } : null
      quarantinePolicy: {
        status: quarantinePolicyEnabled ? 'enabled' : 'disabled'
      }
      retentionPolicy: IS_PREMIUM_SKU ? retentionPolicyEnabled ? {
        days: retentionPolicyInDays
        status: 'enabled'
      } : null : null
      trustPolicy: IS_PREMIUM_SKU ? trustPolicyEnabled ? {
        status: 'enabled'
        type: 'Notary'
      } : null : null
    }
  }
}

module agentPool 'agent-pool.bicep' = if (doCreateDefaultPool && virtualNetworkSubnetResourceId != '') {
  name: '${deployment().name}-pool'
  params: {
    acrName: containerRegistry.name
    location: location
    virtualNetworkSubnetResourceId: virtualNetworkSubnetResourceId != '' ? virtualNetworkSubnetResourceId : ''
    tags: tags
  }
}

resource replications 'Microsoft.ContainerRegistry/registries/replications@2021-09-01' = [for replicationLocation in varReplicationLocations: if (IS_PREMIUM_SKU) {
  name: replicationLocation.location
  parent: containerRegistry
  location: replicationLocation.location
  tags: tags
  properties: {
    regionEndpointEnabled: replicationLocation.regionEndpointEnabled
    zoneRedundancy: replicationLocation.zoneRedundancy ? 'Enabled' : 'Disabled'
  }
}]

resource containerRegistryLock 'Microsoft.Authorization/locks@2020-05-01' = if (lock != 'NotSpecified') {
  name: '${containerRegistry.name}-${lock}-lock'
  properties: {
    level: lock
    notes: lock == 'CanNotDelete' ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
  scope: containerRegistry
}

resource containerRegistryDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(diagnosticStorageAccountId) || !empty(logAnalyticsWorkspaceId) || !empty(diagnosticEventHubAuthorizationRuleId) || !empty(diagnosticEventHubName)) {
  name: '${containerRegistry.name}-diagnosticSettings'
  properties: {
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    workspaceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    eventHubAuthorizationRuleId: !empty(diagnosticEventHubAuthorizationRuleId) ? diagnosticEventHubAuthorizationRuleId : null
    eventHubName: !empty(diagnosticEventHubName) ? diagnosticEventHubName : null
    metrics: diagnosticsMetrics
    logs: diagnosticsLogs
  }
  scope: containerRegistry
}



module containerRegistryRBAC 'modules/role-assignment.bicep' = [for (roleAssignment, index) in roleAssignments: {
  name: '${uniqueString(deployment().name, location)}-acr-rbac-${index}'
  params: {
    description: contains(roleAssignment, 'description') ? roleAssignment.description : ''
    principals: roleAssignment.principals
    roleDefinitionIdOrName: roleAssignment.roleDefinitionIdOrName
    resourceId: containerRegistry.id
  }
}]

@description('The resource group the Azure Container Registry was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the Azure Container Registry.')
output id string = containerRegistry.id

@description('The name of the Azure Container Registry.')
output name string = containerRegistry.name

@description('The login server URL of the Azure Container Registry.')
output loginServer string = containerRegistry.properties.loginServer

output dataUrls array = containerRegistry.properties.dataEndpointHostNames

output principalId string = containerRegistry.identity.principalId

output acrPoolName string = (doCreateDefaultPool && virtualNetworkSubnetResourceId != '') ? agentPool.outputs.name : ''

output location string = containerRegistry.location
