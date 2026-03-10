@description('Name of the public IP address resource.')
param name string

@description('Azure region for the deployment, resource group and resources.')
param location string = resourceGroup().location

@description('Sku for the resource.')
@allowed([
  'Basic'
  'Standard'
])
param sku string

@description('Domain name label for the resource.')
param domainNameLabel string = ''

@description('Routing Preference for the resource.')
param routingPreference string = ''

@description('Allocation method for the resource.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string

@description('Version for the resource. Default: IPv4')
@allowed([
  'IPv4'
  'IPv6'
])
param publicIpAddressVersion string = 'IPv4'

@description('Idle Timeout for the resource.')
param idleTimeoutInMinutes int = 4

@description('Tier for the resource. Default: Regional')
@allowed([
  'Regional'
  'Global'
])
param tier string = 'Regional'

@description('Zones for the resource. For example: [1, 2, 3]. Default: []')
param zones array = []

@description('Optional tags for the resources.')
param tags object = {}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku
    tier: tier
  }
  zones: zones
  properties: {
    publicIPAllocationMethod: publicIPAllocationMethod
    idleTimeoutInMinutes: idleTimeoutInMinutes
    publicIPAddressVersion: publicIpAddressVersion
    dnsSettings: domainNameLabel == '' ? null : {
      domainNameLabel: domainNameLabel
    }
    ipTags:  empty(routingPreference) ? [] : [
      {
        ipTagType: 'RoutingPreference'
        tag: routingPreference
      }
    ]
  }
}

output id string = publicIpAddress.id
