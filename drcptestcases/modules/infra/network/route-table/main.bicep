param name string

param tags object = {}

@description('''
Example:
[
  {
    name: 'APIM'
    properties: {
      addressPrefix: 'ApiManagement'
      hasBgpOverride: false
      nextHopType: 'Internet'
    }
  }
]
''')
param routes array = []

param location string = resourceGroup().location

resource udr 'Microsoft.Network/routeTables@2021-02-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    disableBgpRoutePropagation: false
    routes: routes
  }
}

output id string = udr.id
