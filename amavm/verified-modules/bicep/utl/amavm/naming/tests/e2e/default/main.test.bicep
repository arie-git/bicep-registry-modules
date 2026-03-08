targetScope = 'subscription'

metadata name = 'default'
metadata description = '''
This example provides an example implementation of the naming module.
'''


// General parameters
param location string = deployment().location

// Parts used in naming convention
@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'
param departmentCode string = 'c3'
param applicationCode string = 'lztst' // short application code we use in naming (not the one in Snow, that one is applicationId)
@maxLength(4)
param applicationInstanceCode string = '1234' // in case if there are more than 1 application deployments (for example, in multiple environments)
@maxLength(2)
param systemInstanceCode string = ''
param systemCode string = ''
param environmentType string = 'dev'

// Dependencies
var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}
// Minimal implementation
module names '../../../main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-names'
  params: {
    department: departmentCode
    workload: '${applicationCode}${applicationInstanceCode}'
    environment: environmentType
    location: location
  }
}

// Using naming and providing as ouput
var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
output nsgName string = nsgName
var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
output subnetsName string = subnetsName
