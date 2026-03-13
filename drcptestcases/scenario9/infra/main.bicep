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
param applicationInstanceCode string = '0901' // in case if there are more than 1 application deployments (for example, in multiple environments)
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
param networkAddressSpace string = ''
param engineersGroupObjectId string = ''
#disable-next-line no-unused-params
// param engineersGroupName string = 'F-DRCP-${applicationId}-${environmentId}-Engineer-001-ASG'
param engineersContactEmail string = 'apg-am-ccc-enablement@apg-am.nl'

type extraConfigType = {
  enableAksKms: bool?
  // enableAksApiVnetIntegrations: bool?
  enablePrivateClusterPublicFQDN: bool?
  kubernetesVersion: string?
  privateDNSZone: string?
  aksNetwork: 'kubenet' | 'azure' | 'azureOverlay' //| 'azureOverlayDynamicIP'
  aksNetworkDataPlane: 'azure' | 'cilium'
  aksNetworkPolicy: 'azure' | 'calico' | 'cilium' | 'none'
  aksNetworkPodCidr: string?
  aksNetworkServiceCidr: string?
  aksNetworkDnsServiceIP: string?
  populateAcrCache: bool?
  // nodeProvisioningProfile: 'Auto' | 'Manual'
  enableWorkloadIdentity: bool
}

param extraConfig extraConfigType  = {
  enableAksKms: false
  // enableAksApiVnetIntegrations: false
  enablePrivateClusterPublicFQDN: (environmentType == 'dev')
  kubernetesVersion: '1.30.2'
  privateDNSZone: (environmentType == 'dev') ? 'none' : '/subscriptions/44fc7c46-cf47-4a29-aaa4-3e30f9e4e14b/resourceGroups/h01-p1-infrastructure-azuredns/providers/Microsoft.Network/privateDnsZones/privatelink.swedencentral.azmk8s.io'
  aksNetwork: 'azureOverlay'
  aksNetworkDataPlane: 'cilium'
  aksNetworkPolicy: 'cilium'
  aksNetworkPodCidr: '10.229.0.0/16'
  aksNetworkServiceCidr: '192.168.0.0/16'
  aksNetworkDnsServiceIP: '192.168.0.10'
  // nodeProvisioningProfile: 'Manual' // 'Auto' requires preview feature atm
  populateAcrCache: true
  enableWorkloadIdentity: true
}

@description('Generated. Used internally.')
param timeNow string = utcNow()

// --------------------------------------------------
//
// Variables used across the module
//
// --------------------------------------------------

var mytags = union(tags, {
  environmentId: environmentId
  applicationId: applicationId
  businessUnit: organizationCode
  purpose: '${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}'
  environmentType: environmentType
  contactEmail: engineersContactEmail
  deploymentPipelineId: deploymentId
})

var isDevEnvironment = !(environmentType == 'prd' || environmentType == 'acc' || environmentType == 'tst')

// Specific logic
var enableAksApiVnetIntegrations = enableAksKms ? true : (extraConfig.?enableAksApiVnetIntegrations ?? false)
var enableAksKms = extraConfig.?enableAksKms ?? false


// --------------------------------------------------
//
// Main resource group
//
// --------------------------------------------------

var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: mytags
}

// --------------------------------------------------
//
// Naming
//
// --------------------------------------------------
module names 'br/amavm:utl/amavm/naming:0.1.0' = {
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

var nsgRootName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
var rtRootName = names.outputs.namingConvention['Microsoft.Network/routeTables']
var privateEndpointsRootName = names.outputs.namingConvention['Microsoft.Network/privateEndpoints']
var subnetsRootName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']


// --------------------------------------------------
//
// Networking
//  - NSG
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

// NSG + RT for private endpoints
module networkSecurityGroupPrivateEndpointsMod 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-peps-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${nsgRootName}-peps'
    location: vNet.location
    tags: mytags
    diagnosticSettings:[
      {
        name: 'defaultAMAVM'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
  }
}
module routeTablePrivateEndpointsMod 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-peps-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${rtRootName}-peps'
    location: vNet.location
    disableBgpRoutePropagation: false
    tags: mytags
  }
}

// NSG + RT for private endpoints
module networkSecurityGroupAksInboundMod 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-aks-inbound-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${nsgRootName}-aksinbound'
    location: vNet.location
    tags: mytags
    diagnosticSettings:[
      {
        name: 'defaultAMAVM'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    roleAssignments: [
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}
module routeTableAksInboundMod 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-aks-inbound-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${rtRootName}-aksinbound'
    location: vNet.location
    disableBgpRoutePropagation: false
    tags: mytags
    roleAssignments: [
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// NSG + RT for AKS node pools 1 & 2
module networkSecurityGroupNodePool1Mod 'br/amavm:res/network/network-security-group:0.1.0' = {
  name: '${deployment().name}-pool1-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${nsgRootName}-pool1'
    location: vNet.location
    tags: mytags
    diagnosticSettings:[
      {
        name: 'defaultAMAVM'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
  }
}
module routeTableNodePool1Mod 'br/amavm:res/network/route-table:0.1.0' = {
  name: '${deployment().name}-pool1-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${rtRootName}-pool1'
    disableBgpRoutePropagation: false
    location: vNet.location
    tags: mytags
    roleAssignments: [
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// NSG + RT for AKS API subnet
module networkSecurityGroupAksApiMod 'br/amavm:res/network/network-security-group:0.1.0' = if (enableAksApiVnetIntegrations) {
  name: '${deployment().name}-aksapi-nsg'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${nsgRootName}-aksapi'
    location: vNet.location
    tags: mytags
    diagnosticSettings:[
      {
        name: 'defaultAMAVM'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
  }
}
module routeTableAksApiMod 'br/amavm:res/network/route-table:0.1.0' = if (enableAksApiVnetIntegrations) {
  name: '${deployment().name}-aksapi-rt'
  scope: az.resourceGroup(vnetResourceGroupName)
  params: {
    name: '${rtRootName}-aksapi'
    location: vNet.location
    tags: mytags
    roleAssignments: [
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// define subnets
var subnetsConfig = [
  {
    // subnet for all private endpoints
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 0)
    nameIndex: 'peps'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroupResourceId: networkSecurityGroupPrivateEndpointsMod.outputs.resourceId
    routeTableResourceId: routeTablePrivateEndpointsMod.outputs.resourceId
  }
  {
    // subnet for inbound traffic to AKS nodepools (LB, PLS)
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 28, 1)
    nameIndex: 'aks-inbound'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroupResourceId: networkSecurityGroupAksInboundMod.outputs.resourceId
    routeTableResourceId: routeTableAksInboundMod.outputs.resourceId
    roleAssignments: [
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
  // one more /27 (1) remaining
  {
    // subnet for API server or AKS node pool2
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 26, 1)
    //(extraConfig.aksNetwork == 'kubenet')
    nameIndex: enableAksApiVnetIntegrations ? 'aks-api' : 'aks-pool2'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    delegations: enableAksApiVnetIntegrations ? [
      {
        name: 'Microsoft.ContainerService/managedClusters'
        properties: {
          serviceName: 'Microsoft.ContainerService/managedClusters'
        }
      }
    ] : []
    networkSecurityGroupResourceId: enableAksApiVnetIntegrations
      ? networkSecurityGroupAksApiMod.outputs.resourceId
      : networkSecurityGroupNodePool1Mod.outputs.resourceId
    routeTableResourceId: enableAksApiVnetIntegrations
      ? routeTableAksApiMod.outputs.resourceId
      : routeTableNodePool1Mod.outputs.resourceId
    roleAssignments: [
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
  {
    // subnet for AKS node pool 1
    addressPrefix: cidrSubnet(effectiveNetworkSpace, 25, 1)
    nameIndex: 'aks-pool1'
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
    networkSecurityGroupResourceId: networkSecurityGroupNodePool1Mod.outputs.resourceId
    routeTableResourceId: routeTableNodePool1Mod.outputs.resourceId
    roleAssignments:[
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Network Contributor'
        principalType: 'ServicePrincipal'
      }
    ]
  }
]

@batchSize(1) // makes it run in sequence
module subnetsMod 'br/amavm:res/network/virtual-network/subnet:0.2.0' = [ for index in range(0,4) : {
  scope: az.resourceGroup(vnetResourceGroupName)
  name: '${deployment().name}-subnet${index}'
  params: {
    virtualNetworkName: vnetName
    subnet: {
      name: '${subnetsRootName}-${subnetsConfig[index].nameIndex}'
      addressPrefix: subnetsConfig[index].addressPrefix
      networkSecurityGroupResourceId: subnetsConfig[index].networkSecurityGroupResourceId
      routeTableResourceId: subnetsConfig[index].routeTableResourceId
      privateEndpointNetworkPolicies: subnetsConfig[index].?privateEndpointNetworkPolicies
      privateLinkServiceNetworkPolicies: subnetsConfig[index].?privateLinkServiceNetworkPolicies
      delegations: subnetsConfig[index].?delegations
      #disable-next-line BCP053
      serviceEndpoints: subnetsConfig[index].?serviceEndpoints
      roleAssignments: subnetsConfig[index].?roleAssignments
    }
  }
}]

var subnetPrivateEndpointsMod = subnetsMod[0]
// var subnetAksInboundMod = subnetsMod[1]
// var subnetAksApiOrPool2Mod = subnetsMod[2]
var subnetNodePool1Mod = subnetsMod[3]

// --------------------------------------------------
//
// Logging
//  - LogAnalytics workspace
//  - Application Insights
//
// --------------------------------------------------
var logAnalyticsWorspaceName = names.outputs.namingConvention['Microsoft.OperationalInsights/workspaces']
module logAnalyticsWorkspaceMod 'br/amavm:res/operational-insights/workspace:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-loganalytics'
  params: {
    location: location
    name: logAnalyticsWorspaceName
    tags: mytags
  }
}

// --------------------------------------------------
//
// KeyVault (AKS KMS)
//
// --------------------------------------------------

// create keyvault and assign RBAC to engineering group
var keyVaultRootName = names.outputs.namingConvention['Microsoft.KeyVault/vaults']

// KeyVault for KMS
module keyVaultAksKmsMod 'br/amavm:res/key-vault/vault:0.3.0' = if (enableAksKms) {
  scope: resourceGroup
  name: '${deployment().name}-keyvault'
  params: {
    name: '${keyVaultRootName}-kms'
    enablePurgeProtection: !isDevEnvironment
    softDeleteRetentionInDays: 7
    networkAcls:{
      bypass: 'AzureServices'
    }
    privateEndpoints: [
      {
        name: '${privateEndpointsRootName}-kv'
        location: vNet.location
        service: 'vault'
        subnetResourceId: subnetPrivateEndpointsMod.outputs.resourceId
        tags: tags
      }
    ]
    diagnosticSettings: [
      {
        name: 'defaultAMAVM'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    roleAssignments: union(
      isDevEnvironment ? [
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'Key Vault Administrator'
          principalType: 'Group'
        }
      ] : [],
      [
        {
          principalId: userAssignedManagedIdentityAksMod.outputs.principalId // For AKS to create its own private endpoint to this KeyVault
          roleDefinitionIdOrName: 'Key Vault Contributor'
          principalType: 'ServicePrincipal'
        }
      ]
    )
    tags: mytags
  }
  dependsOn: subnetsMod // wait for all subnets to get created, otherwise there is a Put operation conflict
}

//Create Azure Key Vault key for AKS KMS
// https://learn.microsoft.com/en-gb/azure/aks/use-kms-etcd-encryption
var keyName = 'akskms000${uniqueString(timeNow)}'
module keyvaultKeyMod 'br/amavm:res/key-vault/vault/key:0.3.0' = if (enableAksKms) {
  name: '${deployment().name}-aks-keyvault-key'
  scope: resourceGroup
  params: {
    name: keyName
    keyVaultName: enableAksKms ? keyVaultAksKmsMod.outputs.name : ''
    roleAssignments:[ // TODO: docs propose on the KeyVault level
      {
        principalId: userAssignedManagedIdentityAksMod.outputs.principalId
        roleDefinitionIdOrName: 'Key Vault Crypto User'
        principalType: 'ServicePrincipal'
      }
    ]
  }
}

// --------------------------------------------------
//
// Storage Account (diagnostic logs)
//
// --------------------------------------------------

//  Storage account with blob container
var storageAccountName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts']
var storageAccountRoles = [
  'Storage Blob Data Contributor'
]
var storageBlobContainerName = names.outputs.namingConvention['Microsoft.Storage/storageAccounts/blobServices/containers']
module storageAccountMod 'br/amavm:res/storage/storage-account:0.2.0' = {
  scope: resourceGroup
  name: '${deployment().name}-storageaccount'
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_ZRS'
    accessTier: 'Hot'
    allowSharedKeyAccess: false  // DRCP: RBAC only, no shared keys
    blobServices: {
      containers:[
        {
          name: '${storageBlobContainerName}-aks-logs'
          roleAssignments:[
            {
              principalId: userAssignedManagedIdentityAksMod.outputs.principalId
              roleDefinitionIdOrName: 'Storage Blob Data Contributor'
            }
          ]
        }
      ]
      diagnosticSettings:[
        {
          name: 'defaultAMAVM'
          workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
        }
      ]
    }
    fileServices: {
      shares: [
        {
          name: 'aks'
          shareQuota: 100
        }
      ]
      diagnosticSettings: [
        {
          name: 'defaultAMAVM'
          workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
        }
      ]
    }
    roleAssignments: [ for role in ((isDevEnvironment && !empty(engineersGroupObjectId)) ? storageAccountRoles : [] ): {
      principalId: engineersGroupObjectId
      principalType: 'Group'
      roleDefinitionIdOrName: role
    }]
    privateEndpoints:[
      {
        name: '${privateEndpointsRootName}-sa-blob'
        subnetResourceId: subnetPrivateEndpointsMod.outputs.resourceId
        service: 'blob'
      }
      {
        name: '${privateEndpointsRootName}-sa-file'
        subnetResourceId: subnetPrivateEndpointsMod.outputs.resourceId
        service: 'file'
      }
    ]
    diagnosticSettings:[
      {
        name: 'defaultAMAVM'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    tags: mytags
  }
  dependsOn: subnetsMod
}

// ----------------------------------------------
//
// UAMI + AKS + ACR
//
// ----------------------------------------------

// create a managed identity for AKS Cluster control plane
var managedIdentityRootName = names.outputs.namingConvention['Microsoft.ManagedIdentity/userAssignedIdentities']
module userAssignedManagedIdentityAksMod 'br/amavm:res/managed-identity/user-assigned-identity:0.1.0' = {
  scope: resourceGroup
  name: '${deployment().name}-uami'
  params:{
    name: '${managedIdentityRootName}-aks'
    tags: mytags
  }
}

// Required to configure the IP-based Load Balancer Backend Pools.
// module vNetRBAC '../../modules/infra/security/rbac/role-assignment.bicep' = {
//   scope: az.resourceGroup(vnetResourceGroupName)
//   name:
//   params: {
//     principalIds: userAssignedManagedIdentityAksMod.outputs.principalId
//     roleDefinitionIdOrName: 'Network Contributor'
//     principalType: 'ServicePrincipal'

//   }
// }

//Create AKS Cluster
var aksName = names.outputs.namingConvention['Microsoft.ContainerService/managedClusters']
module aksMod 'br/amavm:res/container-service/managed-cluster:0.3.0' = {
  name: '${deployment().name}-aks'
  scope: resourceGroup
  params: {
    name: aksName
    location: location
    skuTier: 'Standard'
    kubernetesVersion: extraConfig.?kubernetesVersion
    managedIdentities: {
      userAssignedResourceIds: [
        userAssignedManagedIdentityAksMod.outputs.resourceId
      ]
    }
    enableWorkloadIdentity: extraConfig.enableWorkloadIdentity
    networkPlugin: (extraConfig.aksNetwork == 'kubenet') ? 'kubenet' : 'azure'
    networkPluginMode: contains(extraConfig.aksNetwork,'Overlay') ? 'overlay' : ''
    networkDataPlane: extraConfig.aksNetworkDataPlane
    networkPolicy: (extraConfig.aksNetworkDataPlane == 'cilium') ? 'cilium' : extraConfig.aksNetworkPolicy
    networkPodCidr: (extraConfig.aksNetwork == 'kubenet') ? extraConfig.?aksNetworkPodCidr : null
    networkServiceCidr: extraConfig.?aksNetworkServiceCidr
    networkDnsServiceIP: extraConfig.?aksNetworkDnsServiceIP
    networkOutboundType: 'userDefinedRouting' // <----- TEST
    // preview: requires special AMAVM module version
    // nodeProvisioningProfile: extraConfig.nodeProvisioningProfile
    apiServerAccessProfile: {
      enablePrivateClusterPublicFQDN: extraConfig.?enablePrivateClusterPublicFQDN ?? false
      privateDNSZone: extraConfig.?privateDNSZone ?? 'none'
      // preview: requires special AMAVM module version and a feature flag activation on the subscription https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
      // enableVnetIntegration: enableAksApiVnetIntegrations
      // preview: requires special AMAVM module version and a feature flag activation on the subscription https://learn.microsoft.com/en-us/azure/aks/api-server-vnet-integration
      // subnetId: enableAksApiVnetIntegrations ? subnetAksApiOrPool2Mod.outputs.resourceId : null // used with Vnet integration
    }
    securityProfileAzureKeyVaultKms: enableAksKms ? {
      keyVaultResourceId: enableAksKms ? keyVaultAksKmsMod.outputs.resourceId : ''
      keyId: enableAksKms ? keyvaultKeyMod.outputs.keyUriWithVersion : ''
    } : null
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
    primaryAgentPoolSubnetResourceId: subnetNodePool1Mod.outputs.resourceId
    autoUpgradeProfile : {
      upgradeChannel: 'rapid'
      nodeOSUpgradeChannel: 'SecurityPatch'
    }
    diagnosticSettings: [
      {
        name: 'mostLogsAndMetrics'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
        logAnalyticsDestinationType: 'Dedicated'
        logCategoriesAndGroups: [
          {
            category: 'kube-apiserver'
            enabled: true
          }
          {
            category: 'kube-audit'
            enabled: true
          }
          {
            category: 'kube-audit-admin'
            enabled: true
          }
          {
            category: 'kube-controller-manager'
            enabled: true
          }
          {
            category: 'kube-scheduler'
            enabled: true
          }
          {
            category: 'cluster-autoscaler'
            enabled: true
          }
          {
            category: 'cloud-controller-manager'
            enabled: true
          }
          {
            category: 'guard'
            enabled: true
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
      }
      {
        name: 'logsCompliance'
        storageAccountResourceId: storageAccountMod.outputs.resourceId
        logCategoriesAndGroups: [
          {
            category: 'kube-apiserver'
            enabled: true
          }
          {
            category: 'kube-audit'
            enabled: true
          }
          {
            category: 'kube-audit-admin'
            enabled: true
          }
          {
            category: 'kube-controller-manager'
            enabled: true
          }
          {
            category: 'kube-scheduler'
            enabled: true
          }
        ]
        metricCategories: [
          {
            category: 'AllMetrics'
            enabled: true
          }
        ]
      }
    ]
    roleAssignments: isDevEnvironment && !empty(engineersGroupObjectId) ? [
      {
        principalId: engineersGroupObjectId
        roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
      }
    ] : []
    tags: mytags
  }
  dependsOn: subnetsMod
}

// ACR + grants to AKS kubelet to pull images
var acrName = names.outputs.namingConvention['Microsoft.ContainerRegistry/registries']
module containerRegistryMod 'br/amavm:res/container-registry/registry:0.2.0' = {
  name: '${deployment().name}-acr'
  scope: resourceGroup
  params: {
    name: acrName
    cacheRules: (extraConfig.?populateAcrCache ?? false) ? [
      {
        name: 'mcr-dotnet-samples'
        sourceRepository: 'mcr.microsoft.com/dotnet/samples'
        targetRepository: 'dotnet/samples'
      }
      {
        name: 'quay-curl-curl'
        sourceRepository: 'quay.io/curl/curl'
        targetRepository: 'curl/curl'
      }
    ] : []
    privateEndpoints: [
      {
        subnetResourceId: subnetPrivateEndpointsMod.outputs.resourceId
        name: '${privateEndpointsRootName}-acr'
        location: vNet.location
        service: 'registry'
        tags: tags
      }
    ]
    diagnosticSettings: [
      {
        name: 'defaultAMAVM'
        logAnalyticsDestinationType: 'Dedicated'
        workspaceResourceId: logAnalyticsWorkspaceMod.outputs.resourceId
      }
    ]
    roleAssignments: union(
      [
        {
          principalId: aksMod.outputs.kubeletIdentityObjectId
          roleDefinitionIdOrName: 'AcrPull'
          principalType: 'ServicePrincipal'
        }
      ],
      isDevEnvironment && !empty(engineersGroupObjectId) ? [
        {
          principalId: engineersGroupObjectId
          roleDefinitionIdOrName: 'AcrPush'
          principalType: 'Group'
        }
      ] : []
    )
  }
  dependsOn: subnetsMod
}

output keyvaultName string = enableAksKms ? keyVaultAksKmsMod.outputs.name : ''
output storageAccountName string = storageAccountMod.outputs.name
output aksName string = aksMod.outputs.name
output acrName string = containerRegistryMod.outputs.name
output containerRegistryName string = containerRegistryMod.outputs.name
