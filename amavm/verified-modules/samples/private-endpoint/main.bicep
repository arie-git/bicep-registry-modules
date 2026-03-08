targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' existing = {
  name: 'AMSTRM-ENV24338-VirtualNetworks'
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: 'AMSTRM-ENV24338-VirtualNetwork'
  scope: rg
}

module nsgMod 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: 'nsg1mod'
  scope: rg
  params: {
    name: 's2amstrmdevsecnsg'
  }
}

module rtMod 'br/amavm:res/network/route-table:0.1.0' = {
  name: 'rt1mod'
  scope: rg
  params: {
    name: 's2amstrmdevsecrt'
  }
}

module subnet1mod 'br/amavm:res/network/virtual-network/subnet:0.1.0' = {
  name: 'subnet1mod'
  scope: rg
  params: {
    name: 'private-ednpoints'
    addressPrefix: virtualNetwork.properties.addressSpace.addressPrefixes[0]
    virtualNetworkName: virtualNetwork.name
    networkSecurityGroupResourceId: nsgMod.outputs.resourceId
    routeTableResourceId: rtMod.outputs.resourceId
  }
}

module privateEndpoint1mod 'br/amavm:res/network/private-endpoint:0.2.0' = {
  name: 'pep1mod'
  scope: rg
  params: {
    name: 's2amstrmdevsecpep-24338-001'
    subnetResourceId: subnet1mod.outputs.resourceId
    manualPrivateLinkServiceConnections: [
      {
        name: 's2amstrmdevsecpep-24338-001'
        properties: {
          groupIds: []
          privateLinkServiceId: 's-vr525-privatelink-1.3cd13892-13fb-4638-8165-c37314740a29.swedencentral.azure.privatelinkservice'
          requestMessage: 'Testing bicep module'
        }
      }
    ]
  }
}
