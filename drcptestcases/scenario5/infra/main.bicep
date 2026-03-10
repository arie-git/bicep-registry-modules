// bicep code to create infra for scenario 5
targetScope = 'subscription'

@description('Location of resources. Defaults to the location of the deployment.')
param location string = deployment().location

param deploymentId string = ''
#disable-next-line no-unused-params
param whatIf string = ''

// APG ServiceNow registrations
@description('ServiceNow application name for the deployment. E.g. AM-CCC')
param applicationId string = 'AM-CCC'
@description('ServiceNow environment ID for the deployment. E.g. ENV23488.')
param environmentId string

// Parts used in naming convention
param namePrefix string = ''
@maxLength(2)
param organizationCode string = 's2'
@maxLength(3)
param departmentCode string = 'ccc'
param applicationCode string = 'scne5'
@maxLength(4)
param applicationInstanceCode string = '01'
param systemCode string = ''
@maxLength(2)
param systemInstanceCode string = ''
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentType string = 'dev'

@description('CIDR prefix for the virtual network. Needs a /27 prefix')
param networkAddressSpace string = ''

@description('Object ID of the group that should have access to the environment in DEV. Leave empty for non-DEV environments.')
param engineersGroupObjectId string = ''

param tags object = {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${systemCode}'
  environmentType: environmentType
  deploymentId: deploymentId
}

@secure()
param certificate_data string

@secure()
param certificate_password string

// Variables

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')
// To be used in naming private endpoints
var privateEndpointsNameRoot = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

// ---------------------------------------------------------------
//
// Core: standard resource group and naming convention
//
// ---------------------------------------------------------------

// Resource group for app resources
var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module names '../../modules/infra/naming.bicep' = {
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

var locationDict = {
  westeurope: 'we'
  northeurope: 'ne'
  swedencentral: 'sec'
}
var locationShort = locationDict[location]

// ---------------------------------------------------------------
//
// Networking naming and address space
//
// ---------------------------------------------------------------

var vnetResourceGroupName = '${applicationId}-${environmentId}-VirtualNetworks'
var vnetName = '${applicationId}-${environmentId}-VirtualNetwork'

resource vNet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
  scope: az.resourceGroup(vnetResourceGroupName)
}

var effectiveNetworkSpace = (networkAddressSpace != '') ? networkAddressSpace : vNet.properties.addressSpace.addressPrefixes[0]

// ---------------------------------------------------------------
//
// Networking for Private Endpoints
//
// ---------------------------------------------------------------

var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
var privateEndpointsName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']

// Nsg
var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
module nsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-nsg'
  params: {
    name: nsgName
    location: vNet.location
    tags: tags
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
}

// Create Route table
var udrname = names.outputs.namingConvention['Microsoft.Network/routeTables']
module udr 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: udrname
    location: vNet.location
    tags: tags
  }
}

// Subnet for private endpoints
var subnet1Name = '${subnetsName}-private-endpoint'
module subnetPrivateEndpoints 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-pep'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: subnet1Name
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
  dependsOn: []
}

// ---------------------------------------------------------------
//
// Networking for App Gateway
//
// ---------------------------------------------------------------

//var appGwRgName = names.outputs.namingConvention['Microsoft.Resources/resourceGroups']
var appGwRgNameRoot = '${namePrefix}${organizationCode}${departmentCode}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}${environmentType}${locationShort}'
// Resource group
resource appGwRg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${appGwRgNameRoot}-agw-rg'
  location: location
  tags: tags
}

// Nsg
module apGwNsg 'br/amavm:res/network/network-security-group:0.1.0' = {
  scope: az.resourceGroup(appGwRg.name)
  name: '${deployment().name}-nsg01'
  params: {
    name: '${nsgName}01'
    location: location
    securityRules: [
      {
        name: 'AllowAnyCustom65200-65535Inbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '65200-65535'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
      // {below is for public IP access, also attach publicIP to listener
      //   name: 'AllowWebtoAgwsubnet'
      //   properties: {
      //     protocol: 'Tcp'
      //     sourcePortRange: '*'
      //     destinationPortRanges: ['443','80']
      //     sourceAddressPrefix: '*'
      //     destinationAddressPrefix:  '*'
      //     access: 'Allow'
      //     priority: 100
      //     direction: 'Inbound'
      //   }
      //}
    ]
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: tags
  }
}

// Route table for App Gateway with internet as the next hop
module apGwUdr 'br/amavm:res/network/route-table:0.1.0' = {
  scope: az.resourceGroup(appGwRg.name)
  name: '${deployment().name}-rt01'
  params: {
    name: '${udrname}01'
    location: location
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
        }
      }
      {//https://confluence:8453/display/DRCPKB/Networking#Networking-id5
        name: '10.0.0.0-8'
        properties: {
          addressPrefix: '10.0.0.0/8'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: '10.250.4.254'
        }
      }
    ]
    tags: tags
  }
}

// Subnet for egress
var subnet2Name = '${subnetsName}-appservices-egress'
module subnetEgress 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet2'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: subnet2Name
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
      networkSecurityGroupResourceId: nsg.outputs.resourceId
      routeTableResourceId: udr.outputs.resourceId
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
      delegations: [
        {
          name: 'Microsoft.Web.serverFarms'
          type: 'Microsoft.Network/virtualNetworks/subnets/delegation'
          properties: {
            serviceName: 'Microsoft.Web/serverFarms'
          }
        }
      ]
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
  dependsOn: [ subnetPrivateEndpoints ]
}

// Subnet for App Gw
var subnet3Name = '${subnetsName}-appgateway'
module subnetAppGw 'br/amavm:res/network/virtual-network/subnet:0.2.0' = {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet3'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: subnet3Name
      addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 2)
      networkSecurityGroupResourceId: apGwNsg.outputs.resourceId
      routeTableResourceId: apGwUdr.outputs.resourceId
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
    }
  }
  dependsOn: [subnetEgress]
}

var subnets = [
  subnetPrivateEndpoints
  subnetEgress
  subnetAppGw
]

// ---------------------------------------------------------------
//
// Shared resources: KeyVault, Log Analytics, App Insights
//
// ---------------------------------------------------------------

// Log Analytcis
var laName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspace 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-la'
  params: {
    location: resourceGroup.location
    name: laName
    tags: tags
  }
}

// Key-vault
var keyVaultName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']
module keyVault 'br/amavm:res/key-vault/vault:0.3.0' = {
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
        tags: tags
      }
    ]
    diagnosticSettings: [
      {
        name: '${keyVaultName}-diagnostics'
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    roleAssignments: union(
      isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'a4417e6f-fecd-4de8-b567-7b0420556985' // KeyVault Certificate Officer
          principalType: 'Group'
        }
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: '00482a5a-887f-4fb3-b363-3b7fe8e74483' // KeyVault Admin
          principalType: 'Group'
        }
      ] : [],
      [
        {
          principalId: functionApp.outputs.systemAssignedMIPrincipalId
          roleDefinitionIdOrName: '4633458b-17de-408a-b874-0445c86b69e6' //Key Vault Secrets User
          principalType: 'ServicePrincipal'
        }
      ]
    )
  }
}

// Application insights
var applicationInsightsName = names.outputs.namingConvention['Microsoft.Insights/components']
module applicationInsights 'br/amavm:res/insights/component:0.1.0' = { //'../../modules/infra/observability/application-insights/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-appinsights'
  params: {
    location: location
    name: applicationInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    applicationType: 'web'
    kind: 'web'
    // diagnosticSettings: [
    //   {
    //     workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    //   }
    // ]
    // appInsightsKind: 'web'
    // appInsightsType: 'web'
    // tagProjectName: applicationInsightsName
    tags: tags
  }
}

//-----------------------------------------------------------------------
//
//  Create App plan, Function App and Web App
//
//-----------------------------------------------------------------------

// Server farm
var appServicePlanName = names.outputs.namingConvention['Microsoft.Web/serverfarms']
module appServicePlan 'br/amavm:res/web/serverfarm:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-appserviceplan'
  params: {
    name: appServicePlanName
    location: vNet.location
    kind: 'Windows'
    skuName: 'S1'
    skuCapacity: 1
    zoneRedundant: false
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    tags: tags
  }
}

// // Function app
var appName = names.outputs.namingConvention['Microsoft.Web/sites']
module functionApp 'br/amavm:res/web/site:0.1.0' = { //'../../modules/infra/compute/function-app/main.bicep'
  scope: resourceGroup
  name: '${deployment().name}-functionapp'
  params: {
    name: '${appName}01'
    location: vNet.location
    kind: 'functionapp'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnetEgress.outputs.resourceId
    
    diagnosticSettings: [
      {
        name: 'customSetting'
        logCategoriesAndGroups: [
          {
            category: 'FunctionAppLogs'
          }
          {
            category: 'AppServiceAuthenticationLogs'
          }
        ]        
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsights.outputs.resourceId

    netFrameworkVersion:'v6.0'
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'dotnet'
    }
    tags: tags
    
  } 
}

module webApp 'br/amavm:res/web/site:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-wa'
  params: {
    name:'${appName}02'
    location: vNet.location
    serverFarmResourceId: appServicePlan.outputs.resourceId
    kind: 'app'
    authSettingV2Configuration:{}
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
      }
    ]
    virtualNetworkSubnetId: subnetEgress.outputs.resourceId
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    appInsightResourceId: applicationInsights.outputs.resourceId
    appSettingsKeyValuePairs: {
      WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
    }
    vnetRouteAllEnabled: true
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    tags: tags
  }
}

//----------------------------------------------------------------------------
//
// Application Gateway
//
//----------------------------------------------------------------------------

var pipName = names.outputs.namingConvention['Microsoft.Network/publicIPAddresses']
module publicIp '../../modules/infra/network/public-ip-address/main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-pip'
  params: {
    name: pipName
    location: location
    publicIPAllocationMethod: 'Static'
    sku: 'Standard'
  }
}

var appGwName = names.outputs.namingConvention['Microsoft.Network/applicationGateways']

// variables for application gateway. TODO: Script into loops.
var rulePriority = 1
var ipConfigName  = 'appGatewayIpConfig'
var publicFrontendIpName  = 'appGwPublicFrontendIpv4'
var privateFrontendIpName  = 'appGwPrivateFrontendIpv4'
var frontendPortName  = 'appGatewayFrontendPort443'
var backendPoolName  = 'appGatewayBackendPool'
var backendHttpSettingsName = 'appGatewayBackendHttpSettings'
var listenerName = 'appGatewayHttpListener'
var healthProbeName = 'healthProbeHttps'
var ruleName = 'rule1'
var sslCertificateName  = 'gateway'
var port = 443
var duration = 30
var intervalDuration = 30
var protocol = 'https'

module appGw 'br/amavm:res/network/application-gateway:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-agw'
  params: {
    name: appGwName
    location: location
    managedIdentities: {}
    diagnosticSettings: [
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
    backendAddressPools: [
      {
        name: backendPoolName
        properties: {
            backendAddresses: [
              {
              fqdn: webApp.outputs.defaultHostname
              }
            ]
        }
      }
    ]
    frontendPorts: [
      {
        name: frontendPortName
          properties: {
            port: port
          }
        }
    ]
    frontendIPConfigurations: [
      {
        name: publicFrontendIpName
        properties: {
          publicIPAddress: {
            id: publicIp.outputs.id
          }
        }
      }
      {
        name: privateFrontendIpName
        properties: {
          privateIPAddress: cidrHost(cidrSubnet(effectiveNetworkSpace, 28, 2), 3) //Get the first availble ip address from app gateway subnet
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: subnetAppGw.outputs.resourceId
          }
        }
      }
    ]
    gatewayIPConfigurations: [
        {
          name: ipConfigName
          properties: {
            subnet: {
              id: subnetAppGw.outputs.resourceId
            }
          }
        }
    ]
    backendHttpSettingsCollection:[
      {
        name: backendHttpSettingsName
        properties: {
          port: port
          protocol: protocol
          pickHostNameFromBackendAddress: true
          cookieBasedAffinity: 'Enabled'
          probe: {
            id: resourceId(subscription().subscriptionId,
            resourceGroupName,
            'Microsoft.Network/applicationGateways/probes', appGwName, healthProbeName)
          }
          requestTimeout: duration
        }
      }
    ]
    httpListeners: [
      {
        name: listenerName
        properties: {
          frontendIPConfiguration: {
            id: resourceId(subscription().subscriptionId,
            resourceGroupName,
            'Microsoft.Network/applicationGateways/frontendIPConfigurations', appGwName, privateFrontendIpName)
          }
          frontendPort: {
            id: resourceId(subscription().subscriptionId,
            resourceGroupName,
            'Microsoft.Network/applicationGateways/frontendPorts', appGwName, frontendPortName)
          }
          protocol: protocol
          sslCertificate: {
            id: resourceId(subscription().subscriptionId,
            resourceGroupName,
            'Microsoft.Network/applicationGateways/sslCertificates', appGwName, sslCertificateName)
          }
        }
      }
    ]
    probes: [
      {
        name: healthProbeName
        properties: {
          protocol: protocol
          path: '/'
          interval: intervalDuration
          timeout: duration
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
    ]
    requestRoutingRules: [
        {
          name: ruleName
          properties: {
            priority: rulePriority
            ruleType: 'Basic'
            httpListener: {
              id: resourceId(subscription().subscriptionId,
              resourceGroupName,
              'Microsoft.Network/applicationGateways/httpListeners', appGwName, listenerName)
            }
            backendAddressPool: {
              id: resourceId(subscription().subscriptionId,
              resourceGroupName,
              'Microsoft.Network/applicationGateways/backendAddressPools', appGwName, backendPoolName)
            }
            backendHttpSettings: {
              id: resourceId(subscription().subscriptionId,
              resourceGroupName,
              'Microsoft.Network/applicationGateways/backendHttpSettingsCollection', appGwName, backendHttpSettingsName)
            }
          }
        }
      ]
    sslCertificates: [
      {
        name: sslCertificateName
        properties: {
          data: certificate_data
          password: certificate_password
        }
      }
    ]
    tags: tags
    }
}

//----------------------------------------------------------------------------
//  Create Storage account for functions code deployment
//----------------------------------------------------------------------------

var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
module storageAccount 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    location: location
    name: storageAccountName
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    // keyVaultName: keyVault.outputs.name // TODO: check if this was needed.
    roleAssignments: isDevEnvironment ? [
      {
        principalId: engineersGroupObjectId
        principalType: 'Group'
        roleDefinitionIdOrName: 'Storage File Data SMB Share Contributor'
      }
    ] : []
    privateEndpoints:[
      {
        subnetResourceId: subnetPrivateEndpoints.outputs.resourceId
        service: 'blob'
        name: '${privateEndpointsNameRoot}-sta-${storageAccountName}-blob'
      }
    ]
    blobServices:{
      diagnosticSettings:[
        {
          workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
        }
      ]
    }
    diagnosticSettings:[
      {
        workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
      }
    ]
  }
  dependsOn: subnets // This prevents conflicting parallel operations on subnets and VNet
}
