@description('The name of the API Management service.')
@minLength(1)
param name string

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  //'Premium'
  //'Isolated'
])
param sku string = 'Developer'

@description('The instance size of this API Management service.')
@minValue(1)
param skuCount int = 1

@description('The email address of the owner of the service')
@minLength(1)
param contactEmail string

@description('The name of the owner of the service')
@minLength(1)
param contactName string

@description('The id of the subnet to deploy the API Management service to')
param subnetResourceId string

@description('Premium/Isolated sku. Numbers for availability zones, for example, [1,2,3].')
param availabilityZones array = []

@description('''Public Standard SKU IP V4 based IP address to be associated with Virtual Network deployed service in the region.
Supported only for Developer and Premium SKU being deployed in Virtual Network.''')
param publicIpAddressId string

@description('Optional. Resource Id of the log analytics workspace for diagnostic logs.')
param logAnalyticsWorkspaceId string = ''

@description('Optional. Log analytics retention settings. Default: 30 days')
param logsRetentionInDays int = 30

@description('tags to be applied to the resource')
param tags object = {}

resource apiManagementService 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: name
  location: location
  sku: {
    name: sku
    capacity: (sku != 'Developer') ? skuCount : 1
  }
  properties: {
    publisherEmail: contactEmail
    publisherName: contactName
    //publicNetworkAccess: 'Disabled'
    virtualNetworkType: 'Internal'
    virtualNetworkConfiguration: {
      subnetResourceId: subnetResourceId
    }
    publicIpAddressId: publicIpAddressId
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'false'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'false'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  zones: ((length(availabilityZones) == 0 || sku == 'Developer') ? null : availabilityZones)
  tags: tags
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' =  if (!empty(logAnalyticsWorkspaceId)) {
  name: 'service'
  scope: apiManagementService
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'GatewayLogs'
        enabled: true
      }
    ]
  }
}

output resourceId string = apiManagementService.id
output name string = apiManagementService.name
