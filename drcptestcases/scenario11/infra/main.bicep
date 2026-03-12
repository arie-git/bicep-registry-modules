// bicep code to create infra for scenario 1

targetScope = 'subscription'

// general parameters
param location string = deployment().location
param tags object = {}

param deploymentId string = ''
#disable-next-line no-unused-params
param whatIf string = ''

// APG ServiceNow registrations
param applicationId string = 'AM-CCC'
param environmentId string

// Parts used in naming convention
param namePrefix string = ''
@maxLength(2)
param organizationCode string = 's2' //TODO: split the defaults it into a central module ?
@maxLength(3)
param departmentCode string = 'c3'
param applicationCode string = 'lztst' // short application code we use in naming (not the one in Snow, that one is applicationId)
@maxLength(4)
param applicationInstanceCode string = '1101' // in case if there are more than 1 application deployments (for example, in multiple environments)
param systemCode string = ''
@maxLength(2)
param systemInstanceCode string = ''
@allowed([
  'sbx'
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentType string = 'dev'

// System-specific parameters
@description('Network space for the subnets. Needs a /26 prefix.')
param networkAddressSpace string = ''
@description('Object ID of the group that will be assigned higher privileges in DEV.')
param engineersGroupObjectId string = ''
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

param entraApplicationId string = '31678bd3-ddfb-4541-afb1-299d81eec64f'

// var engineersGroupName = 'F-DRCP-${applicationId}-${environmentId}-Engineer-001-ASG'
// resource engineersGroup 'Microsoft.Graph/groups@v1.0' existing = {
//   uniqueName: engineersGroupName
// }
// var engineersGroupObjectId2 = engineersGroup.id

var mytags = union(tags, {
  businessUnit: organizationCode
  purpose: '${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}'
  environmentType: environmentType
  contactEmail: engineersContactEmail
  deploymentPipelineId: deploymentId
})

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

module namesMod 'br/amavm:utl/amavm/naming:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-names'
  params: {
    prefix: namePrefix
    organization: organizationCode
    department: departmentCode
    workload: '${applicationCode}${applicationInstanceCode}'
    role: systemCode
    roleIndex: systemInstanceCode
    environment: environmentType
    location: location
  }
}

// --------------------------------------------------
//
// Logging
//  - LogAnalytics workspace
//  - Application Insights
//
// --------------------------------------------------
var logAnalyticsWorspaceName = namesMod.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspaceMod 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-loganalytics'
  params: {
    name: logAnalyticsWorspaceName
    location: location
    tags: mytags
  }
}
module logAnalyticsWorkspace2Mod 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-loganalytics2'
  params: {
    name: '${logAnalyticsWorspaceName}002'
    location: location
    tags: mytags
  }
}

var applicationInsightsName = namesMod.outputs.namingConvention['Microsoft.Insights/components']
module applicationInsightsMod 'br/amavm:res/insights/component:0.1.0' = { //'../../modules/infra/observability/application-insights/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspace2Mod.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    // appInsightsKind: 'web'
    // appInsightsType: 'web'
    // tagProjectName: applicationInsightsName
    tags: mytags
  }
}

// --------------------------------------------------
//
// Networking
//  - NSG
//  - UDR
//  - Subnets
//
// --------------------------------------------------

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

module nsgMod 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: namesMod.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
    diagnosticSettings:[
      {
        name: 'allCategories'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    location: vNet.location
    tags: mytags
  }
}

module udrMod 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: namesMod.outputs.namingConvention['Microsoft.Network/routeTables']
    location: vNet.location
    tags: mytags
  }
}

var subnetsName = namesMod.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = namesMod.outputs.namingConvention['Microsoft.Network/privateEndpoints']
var subnetsConfig = [
  {
    // subnet for incoming traffic via private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'In'
    delegations: []
  }
  {
    // subnet for outgoing traffic from App
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
    nameIndex: 'frontendOut'
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
  {
    // subnet for outgoing traffic from App 2
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
    nameIndex: 'frontend2Out'
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
]

@batchSize(1) // makes it run in sequence
module subnetsMod 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [for index in range(0, 3): {
    scope: az.resourceGroup(vnetResourceGroupName)
    name: '${deployment().name}-subnet${index}'
    params: {
      virtualNetworkName: vnetName
      subnet: {
        name: '${subnetsName}-${subnetsConfig[index].nameIndex}'
        addressPrefix: subnetsConfig[index].addressPrefix
        networkSecurityGroupResourceId: nsgMod.outputs.resourceId
        routeTableResourceId: udrMod.outputs.resourceId
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Enabled'
        delegations: subnetsConfig[index].delegations
      }
    }
  }
]

var subnetPrivateEndpoints = subnetsMod[0]
// --------------------------------------------------
//
// Shared resources
//  - Keyvault (Use by Function in configuration)
//  - Storage account (used by SQL server for auditing)
//
// --------------------------------------------------

// create keyvault, private endpoint and assign RBAC to engineering group
var keyVaultName = namesMod.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVaultMod 'br/amavm:res/key-vault/vault:0.3.0' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: keyVaultName
    enablePurgeProtection: !isDevEnvironment
    softDeleteRetentionInDays: 7
    networkAcls:{
      bypass: 'AzureServices'
    }
    privateEndpoints: [
      {
        name: '${privateEndpointsName}-kv'
        location: vNet.location
        service: 'vault'
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        tags: mytags
      }
    ]
    diagnosticSettings: [
      {
        name: '${keyVaultName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    roleAssignments: union(
      isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' // KeyVault Secret Officer
          principalType: 'Group'
        }
      ] : [],
      []
      //key vault officer roles removed because of compliancy. In order to insert the secret below manually temp admin access must be requested if not dev env.
    )
  }
}

// Manual action after every deployment - create a secret with this name and store the secret value from app registration
var keyVaultSecret1Name = 'applicationSecret'

module keyVaultSecret1Mod 'br/amavm:res/key-vault/vault/secret:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-keyvault-secret1'
  params:{
    keyVaultName: keyVaultMod.outputs.name
    name: 'applicationSecret'
    value: ''
    tags: mytags
    roleAssignments: [
      {
        principalId: webAppUiMod.outputs.systemAssignedMIPrincipalId
        roleDefinitionIdOrName: 'Key Vault Secrets User'
      }
      {
        principalId: webAppApiMod.outputs.systemAssignedMIPrincipalId
        roleDefinitionIdOrName: 'Key Vault Secrets User'
      }
    ]
  }
}

// create storage account
var storageAccountName = namesMod.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccountMod 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_ZRS'
    accessTier: 'Hot'
    enableHierarchicalNamespace: false
    allowSharedKeyAccess: false // for sql server security alerts
    networkAcls:{
      bypass: 'None'
    }
    blobServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
        }
      ]
    }
    roleAssignments: (isDevEnvironment) ? [
      {
        principalId:engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ] : []
    privateEndpoints:[
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'blob'
      }
    ]
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: tags
  }
  dependsOn: subnetsMod // This prevents conflicting parallel operations on subnets and VNet
}

// --------------------------------------------------
//
// Scenario resources
//  - SQL database (and its server)
//  - Web App (App service plan, Web App)
//
// --------------------------------------------------

//  SQL Server

// create a managed identity for SQL server
var uamiSqlName = namesMod.outputs.namingConvention['Microsoft.ManagedIdentity/userAssignedIdentities']
module uamiSqlMod 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami'
  params:{
    name: uamiSqlName
  }
}

// create SQL server and a database
var sqlServerName = namesMod.outputs.namingConvention['Microsoft.Sql/servers']
var sqlDatabaseName = namesMod.outputs.namingConvention['Microsoft.Sql/servers/databases']
module sqlServerMod 'br/amavm:res/sql/server:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-sqlsrv'
  params: {
    name: sqlServerName
    administrators:{
      principalType: 'Group'
      sid: engineersGroupObjectId
    }
    privateEndpoints:[
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        name: '${privateEndpointsName}-sql'
        location: vNet.location
        tags: mytags
      }
    ]
    outboundFirewallRules:[
      {
        name: replace(replace(storageAccountMod.outputs.primaryBlobEndpoint,'https://',''),'/','')
      }
    ]
    databases:[
      {
        name: sqlDatabaseName
        skuName: 'GP_Gen5_2'
        //maxSizeBytes: 53687091200
        zoneRedundant: true
        diagnosticSettings:[
          {
            workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
          }
        ]
        backupLongTermRetentionPolicy:{
          monthlyRetention: ''
          weeklyRetention: ''
        }
        tags: mytags
      }
    ]
    securityAlertPolicy: {
      emailAddresses:[
        engineersContactEmail
      ]
    }
    auditSettings:{
      state: 'Enabled'
      //storageAccountResourceId: storageAccountMod.outputs.resourceId // requires outbound firewall rules
      isAzureMonitorTargetEnabled: true
      workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
    }
    // vulnerabilityAssessmentsClassic:{ // exclusive: either Express or Classic
    //   storageAccountResourceId: storageAccountMod.outputs.resourceId  // requires outbound firewall rules
    // }
    managedIdentities:{
      userAssignedResourceIds:[
        uamiSqlMod.outputs.resourceId
      ]
    }
    tags: mytags
  }
}

//    Web App

// create a hosting plan (app service plan) for the function app
var hostingPlanName = namesMod.outputs.namingConvention['Microsoft.Web/serverfarms']

module appService1Mod 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan'
  params: {
    name: hostingPlanName
    location: vNet.location
    kind: 'Linux'
    skuName: 'P1V3'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: mytags
  }
}

// create function app
var webAppName = namesMod.outputs.namingConvention['Microsoft.Web/sites']
module webAppUiMod 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-webapp'
  params: {
    name: webAppName
    location: vNet.location
    serverFarmResourceId: appService1Mod.outputs.resourceId
    kind: 'app,linux'
    linuxFxVersion: 'DOTNETCORE|8.0'
    privateEndpoints: [
      {
        subnetResourceId: subnetsMod[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnetsMod[1].outputs.resourceId
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsightsMod.outputs.resourceId
    authSettingApplicationId: entraApplicationId
    authSettingV2ConfigurationAdditional: {
      identityProviders: {
        azureActiveDirectory: {
          login: {
            loginParameters: [
              #disable-next-line no-hardcoded-env-urls
              'scope=openid profile email offline_access api://${entraApplicationId}/user_impersonation'
            ]
          }
        }
      }
    }
    appSettingsKeyValuePairs: {
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
      WEBSITE_RUN_FROM_PACKAGE: '1'
      ASPNETCORE_ENVIRONMENT: 'Development'
      DetailedErrors: 'true'
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=${keyVaultMod.outputs.name};SecretName=${keyVaultSecret1Name})'
      AzureAd__ClientId: entraApplicationId // Linux format with dounble underscore as config structure level separator
      DownstreamApis__MyApi__BaseUrl: 'https://${webAppApiMod.outputs.defaultHostname}'
    }
    siteConfigurationAdditional: {
      cors: (isDevEnvironment) ? {
        allowedOrigins: [
          'https://portal.azure.com'
          'https://ms.portal.azure.com'
        ]
      } : {}
    }
    tags: mytags
  }
}

module appService2Mod 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan2'
  params: {
    name: '${hostingPlanName}002'
    location: vNet.location
    kind: 'Windows'
    skuName: 'S1'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: mytags
  }
}
module webAppApiMod 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-webapp2'
  params: {
    name: '${webAppName}002'
    location: vNet.location
    serverFarmResourceId: appService2Mod.outputs.resourceId
    kind: 'app'
    netFrameworkVersion: 'v9.0'
    privateEndpoints: [
      {
        subnetResourceId: subnetsMod[0].outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnetsMod[2].outputs.resourceId
    outboundVnetRouting: {
      allTraffic: true
      contentShareTraffic: true
      imagePullTraffic: true
    }
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsightsMod.outputs.resourceId
    appSettingsKeyValuePairs: {
      MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=${keyVaultMod.outputs.name};SecretName=${keyVaultSecret1Name})'
      WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
      WEBSITE_RUN_FROM_PACKAGE: '1'
      ASPNETCORE_ENVIRONMENT: 'Development'
      DetailedErrors: 'true'
      'AzureAd:ClientId': entraApplicationId // TODO: check if in Windows it should be 'AzureAd:ClientId'
    }
    authSettingApplicationId: entraApplicationId
    authSettingV2ConfigurationAdditional: {
      enabled: true
      platform: {
        enabled: false // Not using Easy Auth
        runtimeVersion: '~1'
      }
      globalValidation: {
        requireAuthentication: true
        unauthenticatedClientAction: 'Return401' // For API
      }
      identityProviders: {
        azureActiveDirectory: {
          login: {
            loginParameters: [
              'response_type=code id_token'
              #disable-next-line no-hardcoded-env-urls
              'scope=openid profile email offline_access https://graph.microsoft.com/User.Read https://database.windows.net/user_impersonation'
            ]
          }
        }
      }
    }
    connectionStrings: [
      {
        name: 'SqlDbConnection'
        type: 'SQLAzure'
        slotSetting: true
        connectionString: 'server=tcp:${sqlServerMod.outputs.fullyQualifiedDomainName};database=${sqlServerMod.outputs.databases[0].name};Authentication=Active Directory Default;'
      }
    ]
    webSiteConfigurationAdditional: {
      cors: (isDevEnvironment) ? {
        allowedOrigins: [
          // to test functions from the portal
          'https://portal.azure.com'
        ]
        supportCredentials: false
      } : {}
    }
    tags: mytags
  }
}

output keyvaultName string = keyVaultMod.outputs.name
output functionAppName string = webAppUiMod.outputs.name
