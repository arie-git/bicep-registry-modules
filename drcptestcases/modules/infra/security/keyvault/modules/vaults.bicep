@description('Deployment Location')
param location string

param tags object = {}

@description('Prefix of Cosmos DB Resource Name')
param prefix string = 'kv'

@description('Name of the Key Vault')
param name string = take('${prefix}-${uniqueString(resourceGroup().id)}', 24)

@allowed([ 'new', 'existing' ])
@description('Whether to create a new Key Vault or use an existing one')
param newOrExisting string = 'new'

@description('Enable VNet Service Endpoints for Key Vault')
param enableVNet bool = false

@description('Subnet ID for the Key Vault')
param subnetID string = ''

@description('The tenant ID where the Key Vault is deployed')
param tenantId string = subscription().tenantId

@description('Specifies whether soft delete should be enabled for the Key Vault.')
param enableSoftDelete bool = true

@description('The number of days to retain deleted data in the Key Vault.')
param softDeleteRetentionInDays int = 7

@allowed([ 'standard', 'premium' ])
@description('The SKU name of the Key Vault.')
param skuName string = 'standard'

@allowed([ 'A', 'B' ])
@description('The SKU family of the Key Vault.')
param skuFamily string = 'A'

@description('Specifies whether RBAC authorization should be enabled for the Key Vault.')
param enableRbacAuthorization bool = true

@description('Specifies whether purge protection should be enabled for the Key Vault.')
param enablePurgeProtection bool = true

@description('Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault.')
param enableForTemplateDeployment bool = false

@description('Specifies if the trusted Azure services are allowed to bypass the firewall.')
param allowAzureServices bool = false


param logAnalyticsWorkspaceId string = ''

var networkAcls = enableVNet ? {
  defaultAction: 'Deny'
  bypass: 'None'
  virtualNetworkRules: [
    {
      action: 'Allow'
      id: subnetID
    }
  ]
} : {
  defaultAction: 'Deny'
  bypass: enableForTemplateDeployment || allowAzureServices ? 'AzureServices' : 'None'
}

resource newKeyVault 'Microsoft.KeyVault/vaults@2022-11-01' = if (newOrExisting == 'new') {
  name: name
  location: location
  properties: {
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection ? enablePurgeProtection : null
    sku: {
      family: skuFamily
      name: skuName
    }
    publicNetworkAccess: 'Disabled'
    enableRbacAuthorization: enableRbacAuthorization
    tenantId: tenantId
    networkAcls: networkAcls
    enabledForTemplateDeployment: enableForTemplateDeployment
  }
  tags: tags
}

resource keyVault 'Microsoft.KeyVault/vaults@2022-11-01' existing = if (newOrExisting == 'existing') {
  name: name
}

var kvDiagName = '${newKeyVault.name}diag'

resource service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: kvDiagName
  scope: newKeyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Key Vault Id')
output id string = newOrExisting == 'new' ? newKeyVault.id : keyVault.id

@description('Key Vault Name')
output name string = name
