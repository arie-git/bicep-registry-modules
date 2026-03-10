@description('Required. The name of a subnet.')
param name string

@description('Required. The Virtual Network (vNet) name.')
param vnetName string

@description('Required. The ID of the Network Security Group to associate with the subnet.')
param networkSecurityGroupId string

@description('Required. The address prefix to use for the subnet.')
param addressPrefix string

@description('Optional. An array of address prefixes to use for the subnet.')
param addressPrefixes array = []

@description('Optional. Application gateway IP configurations of virtual network resource.')
param applicationGatewayIpConfigurations array = []

@description('Optional. An array of references to the delegations on the subnet..')
param delegations array = []

@description('Optional. Array of IpAllocation which reference this subnet.')
param ipAllocations array = []

@description('Optional. Enable or Disable apply network policies on private link service in the subnet.')
@allowed([
  'Enabled'
  'Disabled'
])
param privateLinkServiceNetworkPolicies string = 'Disabled'

@description('Optional. Enable or Disable apply network policies on private end point in the subnet..')
@allowed([
  'Enabled'
  'Disabled'
])
param privateEndpointNetworkPolicies string = 'Disabled'

@description('Optional. An array of service endpoints.')
param serviceEndpoints array = []

@description('Optional. An array of service endpoint policies.')
param serviceEndpointPolicies array = []

@description('Required. The resource Id of the Route Table to associate with the subnet.')
param routeTableId string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  name: name
  parent: virtualNetwork
  properties: {
    addressPrefix: addressPrefix
    addressPrefixes: addressPrefixes
    applicationGatewayIPConfigurations: applicationGatewayIpConfigurations
    delegations: delegations
    ipAllocations: ipAllocations
    networkSecurityGroup: (networkSecurityGroupId != '') ? { id: networkSecurityGroupId } : null
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: privateLinkServiceNetworkPolicies
    routeTable: (routeTableId != '') ? { id: routeTableId } : null
    serviceEndpoints: serviceEndpoints
    serviceEndpointPolicies: serviceEndpointPolicies
  }
}

output id string = subnet.id
output name string = subnet.name
