metadata name = 'Naming'
metadata description = 'This module deploys a Naming Modules.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20250514'
metadata compliance = '''Compliant usage of this module requires the following parameter values:

'''

@description('Optional. Prefix to add before the name. For example in CI: pipelineId, branchName.')
param prefix string=''

@description('Required. Id of the busines unit.')
@maxLength(2)
@allowed([
  's1'
  's2'
  's3'
])
param organization string = 's2'

@maxLength(3)
@description('Required. Code of the department within a business unit.')
param department string = ''

@description('Required. Short abbreviation of the application.')
param workload string

@description('Optional. Name of a system within an application.')
param role string = ''

@description('Optional. An index within a system/purpose if multiple resources are deployed.')
@maxLength(2)
param roleIndex string=''

@description('Required. Type of SDTAP environment.')
@allowed([
  'sbx'
  'dev'
  'tst'
  'acc'
  'prd'
])
param environment string

@description('Required. Location of resources.')
@allowed([
  'westeurope'
  'northeurope'
  'swedencentral'
])
param location string = 'swedencentral'

@description('Optional. Suffix to add after the name.')
param uniqueSuffix string = ''

// Variables


var locationDict = {
  westeurope: 'we'
  northeurope: 'ne'
  swedencentral: 'sec'
}
var locationShort = locationDict[location]

var rootName = '${prefix}${organization}${department}${workload}${role}${roleIndex}${environment}${locationShort}'
// https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
var namesArray = {
  // AI + Machine Learning
  'Microsoft.CognitiveServices/accounts': '${rootName}csa${uniqueSuffix}'
  'Microsoft.Search/searchServices':'${rootName}srch${uniqueSuffix}'
  // Analytics & IOT
  'Microsoft.Databricks/workspaces': '${rootName}dbw${uniqueSuffix}'
  // Compute and Web
  'Microsoft.Web/hostingEnvironments': '${rootName}ase${uniqueSuffix}' // App Service Environment
  'Microsoft.Web/serverfarms': '${rootName}asp${uniqueSuffix}' // App Service Plan
  'Microsoft.Web/sites': '${rootName}app${uniqueSuffix}' // both Function App and Web App
  'Microsoft.Web/staticSites': '${rootName}stapp${uniqueSuffix}'
  // Containers
  'Microsoft.ContainerService/managedClusters': '${rootName}aks${uniqueSuffix}'
  'Microsoft.App/containerApps': '${rootName}ca${uniqueSuffix}'
  'Microsoft.App/managedEnvironments': '${rootName}cae${uniqueSuffix}'
  'Microsoft.ContainerRegistry/registries': '${rootName}cr${uniqueSuffix}'
  'Microsoft.ContainerRegistry/registries/cacheRules': '${rootName}crcr${uniqueSuffix}'
  'Microsoft.ContainerRegistry/registries/tasks': '${rootName}crtsk${uniqueSuffix}'
  'Microsoft.ContainerInstance/containerGroups': '${rootName}ci${uniqueSuffix}'
  // Databases
  'Microsoft.Sql/servers': '${rootName}sql${uniqueSuffix}'
  'Microsoft.Sql/servers/databases': '${rootName}sqldb${uniqueSuffix}'
  'Microsoft.DocumentDb/databaseAccounts': '${rootName}cosmos${uniqueSuffix}'
  'Microsoft.DocumentDB/databaseAccounts/sqlDatabases': '${rootName}cosmossql${uniqueSuffix}'
  'Microsoft.DBforPostgreSQL/servers': '${rootName}psql${uniqueSuffix}'
  // Developer tools
  'Microsoft.AppConfiguration/configurationStores': '${rootName}appcs${uniqueSuffix}'
  'Microsoft.SignalRService/SignalR': '${rootName}sigr${uniqueSuffix}'
  'Microsoft.SignalRService/webPubSub': '${rootName}wps${uniqueSuffix}'
  // Integration
  'Microsoft.DataFactory/factories': '${rootName}adf${uniqueSuffix}'
  'Microsoft.ApiManagement/service': '${rootName}apim${uniqueSuffix}'
  'Microsoft.Logic/workflows': '${rootName}logic${uniqueSuffix}'
  'Microsoft.ServiceBus/namespaces': '${rootName}sbns${uniqueSuffix}'
  'Microsoft.ServiceBus/namespaces/queues': '${rootName}sbq${uniqueSuffix}'
  'Microsoft.ServiceBus/namespaces/topics': '${rootName}sbt${uniqueSuffix}'
  'Microsoft.ServiceBus/namespaces/topics/subscriptions': '${rootName}sbts${uniqueSuffix}'
  'Microsoft.EventHub/namespaces': '${rootName}evhns${uniqueSuffix}'
  'Microsoft.EventHub/namespaces/eventHubs': '${rootName}evh${uniqueSuffix}'
  // Management and governance
  'Microsoft.OperationalInsights/workspaces': '${rootName}log${uniqueSuffix}'
  'Microsoft.Insights/components': '${rootName}appi${uniqueSuffix}'
  'Microsoft.Insights/actionGroups': '${rootName}ag${uniqueSuffix}'
  'Microsoft.Insights/dataCollectionRules': '${rootName}dcr${uniqueSuffix}'
  'Microsoft.Resources/resourceGroups': '${rootName}-rg${uniqueSuffix}'
  'Microsoft.Resources/templateSpecs': '${rootName}ts${uniqueSuffix}'
  // Networking
  'Microsoft.Network/networkSecurityGroups': '${rootName}nsg${uniqueSuffix}'
  'Microsoft.Network/virtualNetworks/subnets': '${rootName}snet${uniqueSuffix}'
  'Microsoft.Network/privateEndpoints': '${rootName}pep${uniqueSuffix}'
  'Microsoft.Network/applicationGateways': '${rootName}agw${uniqueSuffix}'
  'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies': '${rootName}agfp${uniqueSuffix}'
  'Microsoft.Network/routeTables': '${rootName}rt${uniqueSuffix}'
  'Microsoft.Network/publicIPAddresses': '${rootName}pip${uniqueSuffix}'
  // Security
  'Microsoft.KeyVault/vaults': '${rootName}kv${uniqueSuffix}'
  'Microsoft.ManagedIdentity/userAssignedIdentities': '${rootName}id${uniqueSuffix}'
  'Microsoft.Network/firewallPolicies': '${rootName}waf${uniqueSuffix}'
  'Microsoft.Network/firewallPolicies/ruleGroups': '${rootName}wafrg${uniqueSuffix}'
  // Storage
  'Microsoft.Storage/storageAccounts': '${rootName}sta${uniqueSuffix}'
  'Microsoft.Storage/storageAccounts/blobServices/containers': '${rootName}stbl${uniqueSuffix}'
  'Microsoft.Storage/storageAccounts/fileServices/shares': '${rootName}share${uniqueSuffix}'
}
@description('''Formatted name: (prefix)(businessUnit)(department)(workload)(role)(roleIndex)(environment)(locationShort)(resource type suffix)(uniuqeSuffix)
Example of use: var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
''')
output namingConvention object = namesArray
@description('Formatted name: (prefix)(businessUnit)(department)(workload)(role)(roleIndex)(environment)(locationShort)')
output purposeName string = rootName

@description('Shortened location abbreviation. E.g. we, ne, sec')
output locationShort string = locationShort

