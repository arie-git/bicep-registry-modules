@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of private endpoint according to naming convention.')
param privateEndpointName string

@description('The resource id for which the private link is to be created.')
param privateLinkResource string

@description('The type of subresources e.g. sqlServer/blob/sites/dfs. See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource')
param targetSubResource string

@description('The resource id of subnet where the private link is coupled.')
param subnet string

@description('The name of the private dns zone e.g. privatelink.azurewebsites.net')
param privateDnsZoneName string = ''

@description('The resource id of the private dns zone.')
param privateDnsZoneResourceId string = ''

param tags object = {}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-09-01' = {
  location: location
  name: privateEndpointName
  tags: tags
  properties: {
    subnet: {
      id: subnet
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: privateLinkResource
          groupIds: [
            targetSubResource
          ]
        }
      }
    ]
  }
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-09-01' = if(!empty(privateDnsZoneName) && !empty(privateDnsZoneResourceId)) {
  parent: privateEndpoint
  name: 'customdnsgroup'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: privateDnsZoneName
        properties: {
          privateDnsZoneId: privateDnsZoneResourceId
        }
      }
    ]
  }
}

output id string = privateEndpoint.id
