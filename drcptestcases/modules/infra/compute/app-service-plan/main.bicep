@description('The name of the app service plan.')
param name string

@description('The location of the app service plan.')
param location string = resourceGroup().location

@description('The tags of the app service plan.')
param tags object = {}


@description('''Plan name specifier of the SKU (E.g. B1, S2, WS1, etc).
See https://azure.microsoft.com/en-us/pricing/details/app-service/''')
@allowed([
  // 'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  // 'P1'
  // 'P2'
  // 'P3'
  // 'P1V2'
  // 'P2V2'
  // 'P3V2'
  'WS1'
  'WS2'
  'WS3'
])
param planSkuName string

// // @description('Plan size of the SKU.')
// param planSkuSize string = ''

// // @description('Family code of the resource SKU.')
// @allowed([
//   'S'
//   'B'
//   'WS'
//   ''
// ])
// param planSkuFamily string = ''

// @allowed([
//   'Basic'
//   'Standard'
//   // 'ElasticPremium'
//   // 'Premium'
//   // 'PremiumV2'
//   // 'PremiumV3'
//   'WorkflowStandard'
//   ''
// ])
// param planSkuTier string = ''

// // @description('Optional. Number of instances to be assigned.')
// param planSkuCapacity int = 1


@description('Optional. If true, apps assigned to this app service plan can be scaled independently. If false, apps assigned to this app service plan will scale to all instances of the plan.')
param perSiteScaling bool = false

@description('Optional. Maximum number of total workers allowed for this ElasticScaleEnabled app service plan. Default is 0')
param maximumElasticWorkerCount int = 0

@description('Optional. Scaling worker count. Default is 1.')
param targetWorkerCount int = 1

@description('Optional. The instance size of the hosting plan (small, medium, or large). Default is 0.')
@allowed([ 0, 1, 2 ])
param targetWorkerSizeId int = 0

@description('Kind of service OS the plan supports. Default is Windows.')
@allowed([ 'Windows', 'Linux' ])
param serverOS string = 'Windows'

@description('Optional. Resource ID of the log analytics workspace which the data will be ingested to, if enableaInsights is false.')
param logAnalyticsWorkspaceId string = ''

var isReserved = serverOS == 'Linux'


@description('Defines App Service Plan.')
resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: name
  location: location
  tags: tags
  kind: isReserved ? 'linux' : 'app' // TODO: add support for Docker on WIndows, with 'windows' kind
  sku: {
    name: planSkuName
    // tier: (planSkuTier!='') ? planSkuTier : null
    // size: (planSkuSize!='') ? planSkuSize : null
    // family: (planSkuFamily!='') ? planSkuFamily : null
    // capacity: (planSkuCapacity>0) ? planSkuCapacity : null
  }
  properties: {
    perSiteScaling: perSiteScaling
    maximumElasticWorkerCount: maximumElasticWorkerCount
    reserved: isReserved
    targetWorkerCount: targetWorkerCount
    targetWorkerSizeId: targetWorkerSizeId
    zoneRedundant: false
  }
}

var diagName = '${hostingPlan.name}diag'

resource service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  name: diagName
  scope: hostingPlan
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

@description('Get resource ID of the app service plan.')
output appPlanId string = hostingPlan.id

@description('Get name of the app service plan.')
output appPlanName string = hostingPlan.name

@description('Get resource ID of the app service plan.')
output id string = hostingPlan.id
output resourceId string = hostingPlan.id

@description('Get name of the app service plan.')
output name string = hostingPlan.name
