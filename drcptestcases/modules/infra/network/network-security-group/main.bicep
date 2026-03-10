@description('The name of the network security group.')
param name string

@description('The location of the network security group. Defaults to the location of the resource group.')
param location string = resourceGroup().location

@description('''Optional. The security rules of the network security group.
Example:
  [
    {
      name: 'Management_endpoint_for_Azure_portal_and_Powershell'
      properties: {
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '3443'
        sourceAddressPrefix: 'ApiManagement'
        destinationAddressPrefix: 'VirtualNetwork'
        access: 'Allow'
        priority: 120
        direction: 'Inbound'
      }
    }
  ]
''')
param securityRules array = []

param tags object = {}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: name
  location: location
  properties: {
    securityRules: securityRules
  }
  tags: tags
}

output id string = networkSecurityGroup.id
output name string = networkSecurityGroup.name
