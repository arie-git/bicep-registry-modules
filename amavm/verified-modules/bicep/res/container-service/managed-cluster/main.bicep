metadata name = 'Azure Kubernetes Service (AKS) Managed Cluster'
metadata description = 'This module deploys an Azure Kubernetes Service (AKS) Managed Cluster.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''Compliant usage of this module requires the following parameter values:

- aadProfile.enableAzureRBAC: true, and enableRBAC: true
- addonAzurePolicy.enabled: true
- apiServerAccessProfile.disableRunCommand: true
- apiServerAccessProfile.enablePrivateCluster: true
- diagnosticSettings: 'workspaceResourceId' is not empty and required 'categories' are provided (see parameter description for more details)
- disableLocalAccounts: true
- enableRBAC: true
- kubernetesVersion: null (default) or one of supported versions [Microsoft Learn](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli)
- securityProfileDefender.securityMonitoring.enabled: true
- publicNetworkAccess: 'Disabled'
- networkOutboundType: not 'loadBalancer'
'''

// ----- General parameters -----

@description('Required. Specifies the name of the AKS cluster.')
param name string

@description('Optional. Specifies the location of AKS cluster. It picks up Resource Group\'s location by default.')
param location string = resourceGroup().location

@description('Optional. Name of the resource group containing agent pool nodes.')
param nodeResourceGroup string = 'AKS-Node-${name}-rg'

@description('Optional. Specifies the DNS prefix specified when creating the managed cluster.')
param dnsPrefix string = name

@description('Optional. The managed identity definition for this resource. Only one type of identity is supported: system-assigned or user-assigned, but not both.')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@description('Optional. Tier of a managed cluster SKU.')
@allowed([
  'Free'
  'Premium'
  'Standard'
])
param skuTier string = 'Standard'

@description('Optional. The name of a managed cluster SKU.')
@allowed([
  'Base'
  'Automatic'
])
param skuName string = 'Base'

@allowed([
  'AKSLongTermSupport'
  'KubernetesOfficial'
])
@description('Optional. The support plan for the Managed Cluster.')
param supportPlan string = 'KubernetesOfficial' // TODO: check

@description('''Optional. Version of Kubernetes specified when creating the managed cluster.
By default the latest LTS supported version will be used.

Setting this parameter to a version that is no longer supported by Microsoft will make the resource non-compliant.''')
param kubernetesVersion string?

// ----- Authentication parameters -----

@description('''Optional. Whether to enable Kubernetes Role-Based Access Control. Default: true.

Setting this parameter to 'false' will make the resource non-compliant.''')
param enableRBAC bool = true

@description('''Optional. If set to true, getting static credentials will be disabled for this cluster.
This must only be used on Managed Clusters that are AAD enabled. Default: true.

Setting this parameter to 'false' will make the resource non-compliant.''')
param disableLocalAccounts bool = true

@description('''Optional. The Entra ID (Azure Active Directory) integration configuration.

The default is:
- enableAzureRBAC: value of 'enableRBAC' parameter
- managed: true
- tenantID: subscription().tenantId

Compliant use of this resource requires certain parameter values:
- enableAzureRBAC: true
- managed: true
- tenantID: current tenant
''')
param aadProfile aadProfileType = {
  enableAzureRBAC: enableRBAC
  managed: true
  tenantID: subscription().tenantId
}

// ----- API Server parameters -----

@description('''Optional. The access profile for managed cluster API server.
The default is:
- disableRunCommand: true
- enablePrivateCluster: true
- enablePrivateClusterPublicFQDN: true
// - enableVnetIntegration: false
- privateDNSZone: 'none'

Compliant use of this resource requires certain parameter values:
- apiServerAccessProfile.disableRunCommand: true
- apiServerAccessProfile.enablePrivateCluster: true''')
param apiServerAccessProfile apiServerAccessProfileType = {
  disableRunCommand: true
  enablePrivateCluster: true
  enablePrivateClusterPublicFQDN: true
  // enableVnetIntegration: false
  privateDNSZone: 'none'
}

// ----- Networking parameters -----

@description('''Optional. Allow or deny public network access for AKS. Default: Disabled.

Setting this parameter to any value other than 'Disabled' will make the resource non-compliant.''')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Specifies the network plugin used for building Kubernetes network. Default: azure')
@allowed([
  'azure'
  'kubenet'
  //'none'
])
param networkPlugin string = 'azure'

@description('''Optional. Mode of Azure CNI network plugin for building the Kubernetes network. Default: 'overlay'.

Not used for 'kubenet' network plugin.

See https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview for more information.''')
@allowed([
  'overlay'
  '' // includes 'Azure CNI Node Subnet' and 'Azure CNI Pod Subnet' flavours
])
param networkPluginMode string = (networkPlugin=='kubenet') ? '' : 'overlay'

@description('Optional. Specifies the network policy used for building Kubernetes network. Default: none.')
@allowed([
  'azure'
  'calico'
  'cilium'
  'none'
])
param networkPolicy string = 'none'

@description('Optional. Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param networkPodCidr string?

@description('Optional. A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param networkServiceCidr string?

@description('''Optional. Specifies the IP address assigned to the Kubernetes DNS service.
It must be within the Kubernetes service address range specified in serviceCidr.''')
param networkDnsServiceIP string?

@description('Optional. Network data plane used in the Kubernetes cluster. Not compatible with \'kubenet\' network plugin.')
@allowed([
  'azure'
  'cilium'
])
param networkDataPlane string?

@description('''Optional. Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools. The default is 'standard'.

See Azure Load Balancer SKUs (https://learn.microsoft.com/en-us/azure/load-balancer/skus) for more information about the differences between load balancer SKUs.
''')
@allowed([
  'basic' // TODO: test
  'standard'
])
param networkLoadBalancerSku string = 'standard'

@description('Optional. Configuration of the load balancer used by the virtual machine scale sets used by nodepools.')
param networkLoadBalancerProfile loadBalancerProfileType = (networkOutboundType == 'loadBalancer') ? {
  allocatedOutboundPorts: 0
  backendPoolType: 'NodeIPConfiguration'
  clusterServiceLoadBalancerHealthProbeMode: 'ServiceNodePort'
  idleTimeoutInMinutes: 4
} : {}

@description('''Optional. Specifies outbound (egress) routing method. Default is 'userDefinedRouting'.

Setting this parameter to values other than 'userDefinedRouting' may make the resource non-compliant.

Setting outboundType requires AKS clusters with a vm-set-type of VirtualMachineScaleSets and load-balancer-sku of Standard.

For more information see https://learn.microsoft.com/en-us/azure/aks/egress-outboundtype
''')
@allowed([
  'loadBalancer'
  'userDefinedRouting'
  'managedNATGateway'
  'userAssignedNATGateway'
])
param networkOutboundType string = 'userDefinedRouting'

// @description('Optional. Advanced Network Observability configuration.')
// param networkAdvancedFeatures advancedNetworkingType?

// ----- Storage profile parameters -----

@description('Optional. Whether the AzureBlob CSI Driver for the storage profile is enabled.')
param enableStorageProfileBlobCSIDriver bool = true

@description('Optional. Whether the AzureDisk CSI Driver for the storage profile is enabled.')
param enableStorageProfileDiskCSIDriver bool = true

@description('Optional. Whether the AzureFile CSI Driver for the storage profile is enabled.')
param enableStorageProfileFileCSIDriver bool = true

@description('Optional. Whether the snapshot controller for the storage profile is enabled.')
param enableStorageProfileSnapshotController bool = false

// ----- Nodepools parameters -----

@description('''Conditional. When using defaults in 'primaryAgentPoolProfile', provide here the Subnet resource ID for the primary agent pool in case of using a custom Virtual Network.''')
param primaryAgentPoolSubnetResourceId string? // TODO: make this part of the profile param

// https://learn.microsoft.com/en-gb/azure/aks/quotas-skus-regions#supported-vm-sizes
// https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools
@description('Optional. Properties of the primary agent pool.')
param primaryAgentPoolProfile array = [
  {
    enableNodePublicIP: false
    count: (networkPlugin == 'azure' && networkPluginMode != 'overlay') ? 2 : 3
    enableAutoScaling: false
    maxCount: null
    maxPods: (networkPlugin == 'azure' && networkPluginMode != 'overlay') ? 30 : 110
    minCount: null
    mode: 'System'
    name: 'agentpool'
    osDiskSizeGB: 128
    osDiskType: 'Ephemeral'
    kubeletDiskType: 'OS'
    osType: 'Linux'
    osSKU: 'AzureLinux'
    type: 'VirtualMachineScaleSets'
    vmSize: 'Standard_D4ads_v5'
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    vnetSubnetID: empty(primaryAgentPoolSubnetResourceId) ? null : primaryAgentPoolSubnetResourceId
    upgradeSettings:{
      maxSurge: '33%'
    }
  }
]

// @description('Optional. Define one or more secondary/additional agent pools.')
// param agentPools agentPoolType?

// @description('''Optional. Node provisioning settings that apply to the whole cluster.
// Once the mode it set to 'Auto', it cannot be changed back to 'Manual'.''')
// @allowed([
//   'Auto'
//   'Manual'
// ])
// param nodeProvisioningProfile string = 'Manual'

@description('Optional. Specifies the administrator username of Linux virtual machines.')
param adminUsername string = 'azureuser'

@description('Optional. Specifies the SSH RSA public key string for the Linux nodes.')
param sshPublicKey string?

@description('Optional. The auto upgrade configuration. By default it is set to update the node image to the stable (N-1) version.')
param autoUpgradeProfile autoUpgradeProfileType = {
  upgradeChannel: 'stable'
  nodeOSUpgradeChannel: 'NodeImage'
}

@description('Optional. Configuring AKS automatic upgrades schedules.')
param maintenanceConfigurations maintenanceConfigurationsType = [
  {
    name: 'aksManagedAutoUpgradeSchedule'
    maintenanceConfiguration: {
      maintenanceWindow: {
        schedule: {
          weekly: {
            intervalWeeks: 1
            dayOfWeek: 'Sunday'
          }
        }
        durationHours: 4
        utcOffset: '+01:00'
        startTime: '01:00'
      }
    }
  }
  {
    name: 'aksManagedNodeOSUpgradeSchedule'
    maintenanceConfiguration: {
      maintenanceWindow: {
        durationHours: 4
        schedule: {
          daily: {
            intervalDays: 1
          }
        }
        utcOffset: '+01:00'
        startTime: '04:00'
      }
    }
  }
]

// @description('Optional. Specifies the scan interval of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScanInterval string = '10s'

// @description('Optional. Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

// @description('Optional. Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

// @description('Optional. Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

// @description('Optional. Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownUnneededTime string = '10m'

// @description('Optional. Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
// param autoScalerProfileScaleDownUnreadyTime string = '20m'

// @description('Optional. Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
// param autoScalerProfileUtilizationThreshold string = '0.5'

// @description('Optional. Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
// param autoScalerProfileMaxGracefulTerminationSec string = '600'

// @description('Optional. Specifies the balance of similar node groups for the auto-scaler of the AKS cluster.')
// param autoScalerProfileBalanceSimilarNodeGroups bool = false

// @allowed([
//   'least-waste'
//   'most-pods'
//   'priority'
//   'random'
// ])
// @description('Optional. Specifies the expand strategy for the auto-scaler of the AKS cluster.')
// param autoScalerProfileExpander string = 'random'

// @description('Optional. Specifies the maximum empty bulk delete for the auto-scaler of the AKS cluster.')
// param autoScalerProfileMaxEmptyBulkDelete string = '10'

// @description('Optional. Specifies the maximum node provisioning time for the auto-scaler of the AKS cluster. Values must be an integer followed by an "m". No unit of time other than minutes (m) is supported.')
// param autoScalerProfileMaxNodeProvisionTime string = '15m'

// @description('Optional. Specifies the maximum total unready percentage for the auto-scaler of the AKS cluster. The maximum is 100 and the minimum is 0.')
// param autoScalerProfileMaxTotalUnreadyPercentage string = '45'

// @description('Optional. For scenarios like burst/batch scale where you do not want CA to act before the kubernetes scheduler could schedule all the pods, you can tell CA to ignore unscheduled pods before they are a certain age. Values must be an integer followed by a unit ("s" for seconds, "m" for minutes, "h" for hours, etc).')
// param autoScalerProfileNewPodScaleUpDelay string = '0s'

// @description('Optional. Specifies the OK total unready count for the auto-scaler of the AKS cluster.')
// param autoScalerProfileOkTotalUnreadyCount string = '3'

// @description('Optional. Specifies if nodes with local storage should be skipped for the auto-scaler of the AKS cluster.')
// param autoScalerProfileSkipNodesWithLocalStorage bool = true

// @description('Optional. Specifies if nodes with system pods should be skipped for the auto-scaler of the AKS cluster.')
// param autoScalerProfileSkipNodesWithSystemPods bool = true

// ---- Ingress and DNS -----

// @description('Optional. Specifies whether the httpApplicationRouting add-on is enabled or not.')
// param addonHttpApplicationRoutingEnabled bool = false

// @description('Optional. Specifies whether the webApplicationRoutingEnabled add-on is enabled or not.')
// param webApplicationRoutingEnabled bool = false

// @description('Optional. Specifies the resource ID of connected DNS zone. It will be ignored if `webApplicationRoutingEnabled` is set to `false`.')
// param dnsZoneResourceId string?

// @description('''Optional. Specifies whether assign the DNS zone contributor role to the cluster service principal.
// It will be ignored if `webApplicationRoutingEnabled` is set to `false` or `dnsZoneResourceId` not provided.''')
// param enableDnsZoneContributorRoleAssignment bool = true

// @description('Optional. Specifies whether the ingressApplicationGateway (AGIC) add-on is enabled or not.')
// param addonIngressApplicationGatewayEnabled bool = false

// @description('Conditional. Specifies the resource ID of connected application gateway. Required if `addonIngressApplicationGatewayEnabled` is set to `true`.')
// param appGatewayResourceId string?

// @description('Optional. Specifies whether the aciConnectorLinux add-on is enabled or not.')
// param addonAciConnectorLinuxEnabled bool = false

// ----- Security related ----

// @description('Optional. Running in Kubenet is disabled by default due to the security related nature of AAD Pod Identity and the risks of IP spoofing.')
// param podIdentityProfileAllowNetworkPluginKubenet bool = false

// @description('Optional. Whether the pod identity addon is enabled.')
// param podIdentityProfileEnable bool = false

// @description('Optional. The pod identities to use in the cluster.')
// param podIdentityProfileUserAssignedIdentities array?

// @description('Optional. The pod identity exceptions to allow.')
// param podIdentityProfileUserAssignedIdentityExceptions array?

// @description('Optional. Identities associated with the cluster.')
// param identityProfile object?

@description('Optional. Whether the The OIDC issuer profile of the Managed Cluster is enabled.')
param enableOidcIssuerProfile bool = enableWorkloadIdentity

@description('Optional. Whether to enable Workload Identity. Requires OIDC issuer profile to be enabled.')
param enableWorkloadIdentity bool = false

@description('''Optional. Specifies the configuration of Azure Policy add-on.
Default is enabled=true and config.version=v2.

Compliant use of this resource requires 'enabled' to be true.''')
param addonAzurePolicy addonAzurePolicyType = {
  enabled: true
  config:{
    version: 'v2'
  }
}

@description('''Optional. Azure Defender profile settings. By default the securityMonitoring.enabled is true

Setting securityMonitoring.enabled to a value other than 'true' will make this resource non-compliant.''')
param securityProfileDefender securityProfileDefenderType = !empty(logAnalyticsWorkspaceResourceId) ? {
  securityMonitoring: {
    enabled: true
  }
  logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
} : {
  securityMonitoring: {
    enabled: false
  }
}

@description('Optional. Azure Key Vault key management service settings for the security profile.')
param securityProfileAzureKeyVaultKms securityProfileAzureKeyVaultKmsType = {
  enabled: false
}

@description('''Optional. Whether to enable Image Cleaner for Kubernetes.
By default it is set to 'enabled' wth 168 hours interval.''')
param imageCleaner securityProfileImageCleanerType = {
  enabled: true
  intervalHours: 168
}

// @description('Optional. Whether to enable Kubernetes pod security policy. Requires enabling the pod security policy feature flag on the subscription.')
// param enablePodSecurityPolicy bool = false

// ---- Logging and metrics ----

@description('''Conditional. Specifies whether the cost analysis add-on is enabled or not. Default is false.

If Enabled `enableStorageProfileDiskCSIDriver` is set to true as it is needed.''')
param costAnalysisEnabled bool = false

@description('Optional. Specifies whether the OMS agent is enabled.')
param addonOmsAgentEnabled bool = true

@description('''Optional. The diagnostic settings of the service.

Compliant use of this resource requires diagnostic settings to be configured:
- workspaceResourceId
- logCategoriesAndGroups to include the following categories:
  - 'kube-audit'
  - 'kube-audit-admin'
  - 'kube-apiserver'
  - 'kube-controller-manager'
  - 'kube-scheduler'
''')
param diagnosticSettings diagnosticSettingType

@description('''Conditional. Resource ID of the monitoring log analytics workspace.
Required if: Azure Defender (securityProfile.defender), addon OmsAgent (addonProfiles.omsagent), or azureMonitor is used

Not used for: diagnostic settings.
''')
param logAnalyticsWorkspaceResourceId string? // TODO: think if to move to those two parameters?

@description('''Optional. Configures Azure Monitor profile, including Container Insights, Prometheus and Graphana.

By default, Container Insights are enabled to the Log Analytics workspace specified in logAnalyticsWorkspaceResourceId.
''')
param azureMonitorProfile azureMonitorProfileType = {
  containerInsights: {
    enabled: true
    logAnalyticsWorkspaceResourceId: logAnalyticsWorkspaceResourceId
  }
}

// ---- Other stuff ----

// @description('Optional. The resource ID of the disc encryption set to apply to the cluster. For security reasons, this value should be provided.')
// param diskEncryptionSetResourceId string?

// @description('Optional. The customer managed key definition.')
// param customerManagedKey customerManagedKeyType

// @description('Optional. Configurations for provisioning the cluster with HTTP proxy servers.')
// param httpProxyConfig object?

// @description('Optional. Enables Kubernetes Event-driven Autoscaling (KEDA).')
// param kedaAddon bool = false

// @description('Optional. Settings and configurations for the flux extension.')
// param fluxExtension extensionType

// @description('Optional. Specifies whether the kubeDashboard add-on is enabled or not.')
// param addonKubeDashboardEnabled bool = false

// @description('Optional. Specifies whether the openServiceMesh add-on is enabled or not.')
// param addonOpenServiceMeshEnabled bool = false

@description('''Optional. Specifies the configuration for Azure Key Vault secrets provider add-on.
Default is enabled=true and config.enableSecretRotation=true.''')
#disable-next-line secure-secrets-in-params // Not a secret
param addonAzureKeyvaultSecretsProvider addonAzureKeyvaultSecretsProviderType = {
  enabled: true
  config: {
    enableSecretRotation: 'true'
  }
}

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Tags of the resource.')
param tags object?

// =========== //
// Variables   //
// =========== //

var enablePrivateCluster = apiServerAccessProfile.?enablePrivateCluster ?? true

import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Azure Kubernetes Fleet Manager Contributor Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','63bb64ad-9799-4770-b5c3-24ed299a07bf')
  'Azure Kubernetes Fleet Manager RBAC Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','434fb43a-c01c-447e-9f67-c3ad923cfaba')
  'Azure Kubernetes Fleet Manager RBAC Cluster Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','18ab4d3d-a1bf-4477-8ad9-8359bc988f69')
  'Azure Kubernetes Fleet Manager RBAC Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','30b27cfc-9c84-438e-b0ce-70e35255df80')
  'Azure Kubernetes Fleet Manager RBAC Writer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','5af6afb3-c06c-4fa4-8848-71a8aee05683')
  'Azure Kubernetes Service Cluster Admin Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')
  'Azure Kubernetes Service Cluster Monitoring User': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','1afdec4b-e479-420e-99e7-f82237c7c5e6')
  'Azure Kubernetes Service Cluster User Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','4abbcc35-e782-43d8-92c5-2d3f1bd2253f')
  'Azure Kubernetes Service Contributor Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8')
  'Azure Kubernetes Service RBAC Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','3498e952-d568-435e-9b2c-8d77e338d7f7')
  'Azure Kubernetes Service RBAC Cluster Admin': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b1ff04bb-8a4e-4dc4-8eb5-8693973ce19b')
  'Azure Kubernetes Service RBAC Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','7f6c6a51-bcf8-42ba-9220-52d62157d7db')
  'Azure Kubernetes Service RBAC Writer': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','a7ffa36f-339b-4b5c-8bdf-e2c188b2c0eb')
  'Kubernetes Agentless Operator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','d5a2ae44-610b-4500-93be-660a0c5f5ca6')
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? 'SystemAssigned'
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null)
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

var formattedRoleAssignments = [
  for (roleAssignment, index) in (roleAssignments ?? []): union(roleAssignment, {
    roleDefinitionId: builtInRoleNames[?roleAssignment.roleDefinitionIdOrName] ?? (contains(
        roleAssignment.roleDefinitionIdOrName,
        '/providers/Microsoft.Authorization/roleDefinitions/'
      )
      ? roleAssignment.roleDefinitionIdOrName
      : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName))
  })
]
var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

var requiredLogCategoryNames = [  // required for compliance
'kube-audit'
'kube-audit-admin'
'kube-apiserver'
'kube-controller-manager'
'kube-scheduler'
]
var additionalLogCategoryNames = [
  // best practice
  'cluster-autoscaler'
  'cloud-controller-manager'
  'guard'
]
var defaultLogCategories = [
  for category in union(requiredLogCategoryNames,additionalLogCategoryNames) ?? []: {
    category: category
  }
]
var configuredRequiredLogCategoryNames = intersection(
  requiredLogCategoryNames,
  flatten(map((diagnosticSettings ?? []),
              setting => !empty(setting.?workspaceResourceId)
              ? map((setting.?logCategoriesAndGroups ?? []),
                    logCategory => logCategory.?category ?? '')
              : []
            ))
)
// ============ //
// Dependencies //
// ============ //

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.containerservice-managedcluster.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

// resource cMKKeyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId)) {
//   name: last(split((customerManagedKey.?keyVaultResourceId ?? 'dummyVault'), '/'))
//   scope: resourceGroup(
//     split((customerManagedKey.?keyVaultResourceId ?? '//'), '/')[2],
//     split((customerManagedKey.?keyVaultResourceId ?? '////'), '/')[4]
//   )

//   resource cMKKey 'keys@2023-07-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId) && !empty(customerManagedKey.?keyName)) {
//     name: customerManagedKey.?keyName ?? 'dummyKey'
//   }
// }

// ============== //
// Main Resources //
// ============== //

resource managedCluster 'Microsoft.ContainerService/managedClusters@2025-09-01' = {
  name: name
  location: location
  tags: finalTags
  identity: identity
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    nodeResourceGroup: nodeResourceGroup
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    supportPlan: supportPlan
    enableRBAC: enableRBAC
    disableLocalAccounts: disableLocalAccounts
    publicNetworkAccess: publicNetworkAccess
    // diskEncryptionSetID: diskEncryptionSetResourceId
    // enablePodSecurityPolicy: enablePodSecurityPolicy
    // httpProxyConfig: httpProxyConfig
    apiServerAccessProfile: {
      authorizedIPRanges: apiServerAccessProfile.?authorizedIPRanges ?? [] // TODO: check usage conditions
      disableRunCommand: apiServerAccessProfile.?disableRunCommand ?? true
      enablePrivateCluster: apiServerAccessProfile.?enablePrivateCluster ?? enablePrivateCluster
      enablePrivateClusterPublicFQDN: apiServerAccessProfile.?enablePrivateClusterPublicFQDN ?? (apiServerAccessProfile.?privateDNSZone ?? 'none')=='none'
      privateDNSZone: apiServerAccessProfile.?privateDNSZone ?? 'none'
      // enableVnetIntegration: apiServerAccessProfile.?enableVnetIntegration ?? false // NOT TESTED while in preview
      // subnetId: (apiServerAccessProfile.?enableVnetIntegration ?? false) ? apiServerAccessProfile.?subnetId : null // NOT TESTED while in preview
    }
    // identityProfile: identityProfile
    // servicePrincipalProfile: aksServicePrincipalProfile
    aadProfile: {
      managed: aadProfile.?managed ?? true
      enableAzureRBAC: aadProfile.?enableAzureRBAC ?? true
      adminGroupObjectIDs: aadProfile.?adminGroupObjectIDs ?? []
      tenantID: aadProfile.?tenantID
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: any(addonAzureKeyvaultSecretsProvider)
      azurepolicy: {
        enabled: addonAzurePolicy.enabled
        config: addonAzurePolicy.enabled
          ? {
            version: addonAzurePolicy.?config.?version ?? 'v2'
          } : null
      }
      // httpApplicationRouting: {
      //   enabled: addonHttpApplicationRoutingEnabled
      // }
      omsagent: {
        enabled: addonOmsAgentEnabled && !empty(logAnalyticsWorkspaceResourceId)
        #disable-next-line BCP321 // Value will not be used if null or empty
        config: addonOmsAgentEnabled && !empty(logAnalyticsWorkspaceResourceId)
          ? {
              logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceId
              useAADAuth: 'true'
            }
          : null
      }
      // ingressApplicationGateway: {
      //   enabled: addonIngressApplicationGatewayEnabled && !empty(appGatewayResourceId)
      //   #disable-next-line BCP321 // Value will not be used if null or empty
      //   config: addonIngressApplicationGatewayEnabled && !empty(appGatewayResourceId)
      //     ? {
      //         applicationGatewayId: appGatewayResourceId
      //         effectiveApplicationGatewayId: appGatewayResourceId
      //       }
      //     : null
      // }
      // aciConnectorLinux: {
      //   enabled: addonAciConnectorLinuxEnabled
      // }
      // }
      // openServiceMesh: {
      //   enabled: addonOpenServiceMeshEnabled
      //   config: addonOpenServiceMeshEnabled ? {} : null
      // }
      // kubeDashboard: {
      //   enabled: addonKubeDashboardEnabled
      // }
    }
    oidcIssuerProfile: enableOidcIssuerProfile
      ? {
          enabled: enableOidcIssuerProfile
        }
      : null
    securityProfile: {
      defender: securityProfileDefender.?securityMonitoring.?enabled ?? !empty(securityProfileDefender.?logAnalyticsWorkspaceResourceId)
        ? {
            securityMonitoring: {
              enabled: securityProfileDefender.?securityMonitoring.?enabled ?? true
            }
            #disable-next-line use-resource-id-functions
            logAnalyticsWorkspaceResourceId: securityProfileDefender.?logAnalyticsWorkspaceResourceId ?? logAnalyticsWorkspaceResourceId
          }
        : null
      workloadIdentity: enableWorkloadIdentity
        ? {
            enabled: enableWorkloadIdentity
          }
        : null
      imageCleaner: imageCleaner
      azureKeyVaultKms: !empty(securityProfileAzureKeyVaultKms)
        ? {
            enabled: securityProfileAzureKeyVaultKms.?enabled ?? true
            keyVaultNetworkAccess: securityProfileAzureKeyVaultKms.?keyVaultNetworkAccess ?? 'Private'
            keyVaultResourceId: (securityProfileAzureKeyVaultKms.?keyVaultNetworkAccess ?? 'Private')=='Private' ? securityProfileAzureKeyVaultKms.?keyVaultResourceId : null
            keyId: (securityProfileAzureKeyVaultKms.?enabled ?? true) ? securityProfileAzureKeyVaultKms.?keyId : null
          } : null
    }
    // safeguardsProfile: { // still in preview
    //   level: 'Warning'
    //   version: 'v1.0.0'
    //   excludedNamespaces: [
    //     'kube-system'
    //     'calico-system'
    //     'tigera-system'
    //     'gatekeeper-system'
    //   ]
    // }
    networkProfile: {
      networkPlugin: networkPlugin
      networkPluginMode: (empty(networkPluginMode) || networkPlugin=='kubenet') ? null : networkPluginMode
      networkPolicy: networkPolicy
      networkDataplane: (networkPlugin == 'kubenet') ? null : networkDataPlane
      podCidr: (networkPlugin == 'azure' && networkPluginMode == '' ) ? null : networkPodCidr
      serviceCidr: networkServiceCidr
      dnsServiceIP: networkDnsServiceIP
      loadBalancerSku: networkLoadBalancerSku
      loadBalancerProfile: empty(networkLoadBalancerProfile) ? null : {
        allocatedOutboundPorts: networkLoadBalancerProfile.?allocatedOutboundPorts ?? 0
        backendPoolType: (networkLoadBalancerSku == 'basic') ? 'NodeIPConfiguration' : networkLoadBalancerProfile.?backendPoolType ?? 'NodeIPConfiguration'
        //clusterServiceLoadBalancerHealthProbeMode: networkLoadBalancerProfile.?clusterServiceLoadBalancerHealthProbeMode ?? 'ServiceNodePort'
        effectiveOutboundIPs: []
        enableMultipleStandardLoadBalancers: networkLoadBalancerProfile.?enableMultipleStandardLoadBalancers ?? false // Note: may give error "Check that the field is in the right location, is spelled correctly, and is supported in the API version" depending on API version
        idleTimeoutInMinutes: networkLoadBalancerProfile.?idleTimeoutInMinutes ?? 4
        managedOutboundIPs: networkLoadBalancerProfile.?managedOutboundIPs
        outboundIPPrefixes: networkLoadBalancerProfile.?outboundIPPrefixes
        outboundIPs: networkLoadBalancerProfile.?outboundIPs
      }
      // advancedNetworking: networkAdvancedFeatures
      outboundType: networkOutboundType
    }
    storageProfile: {
      blobCSIDriver: {
        enabled: enableStorageProfileBlobCSIDriver
      }
      diskCSIDriver: {
        enabled: costAnalysisEnabled == true && skuTier != 'free' ? true : enableStorageProfileDiskCSIDriver
      }
      fileCSIDriver: {
        enabled: enableStorageProfileFileCSIDriver
      }
      snapshotController: {
        enabled: enableStorageProfileSnapshotController
      }
    }
    // nodeProvisioningProfile: {
    //   mode: nodeProvisioningProfile
    // }
    agentPoolProfiles: primaryAgentPoolProfile
    linuxProfile: !empty(sshPublicKey)
      ? {
          adminUsername: adminUsername
          ssh: {
            publicKeys: [
              {
                keyData: sshPublicKey ?? ''
              }
            ]
          }
        }
      : null
    autoUpgradeProfile: autoUpgradeProfile
    // autoScalerProfile: {
    //   'balance-similar-node-groups': toLower(string(autoScalerProfileBalanceSimilarNodeGroups))
    //   expander: autoScalerProfileExpander
    //   'max-empty-bulk-delete': autoScalerProfileMaxEmptyBulkDelete
    //   'max-graceful-termination-sec': autoScalerProfileMaxGracefulTerminationSec
    //   'max-node-provision-time': autoScalerProfileMaxNodeProvisionTime
    //   'max-total-unready-percentage': autoScalerProfileMaxTotalUnreadyPercentage
    //   'new-pod-scale-up-delay': autoScalerProfileNewPodScaleUpDelay
    //   'ok-total-unready-count': autoScalerProfileOkTotalUnreadyCount
    //   'scale-down-delay-after-add': autoScalerProfileScaleDownDelayAfterAdd
    //   'scale-down-delay-after-delete': autoScalerProfileScaleDownDelayAfterDelete
    //   'scale-down-delay-after-failure': autoScalerProfileScaleDownDelayAfterFailure
    //   'scale-down-unneeded-time': autoScalerProfileScaleDownUnneededTime
    //   'scale-down-unready-time': autoScalerProfileScaleDownUnreadyTime
    //   'scale-down-utilization-threshold': autoScalerProfileUtilizationThreshold
    //   'scan-interval': autoScalerProfileScanInterval
    //   'skip-nodes-with-local-storage': toLower(string(autoScalerProfileSkipNodesWithLocalStorage))
    //   'skip-nodes-with-system-pods': toLower(string(autoScalerProfileSkipNodesWithSystemPods))
    // }
    // workloadAutoScalerProfile: {
    //   keda: {
    //     enabled: true
    //   }
    //   verticalPodAutoscaler: {
    //     enabled: true
    //     addonAutoscaling: 'Disabled'
    //   }
    // }
    // ingressProfile: {
    //   webAppRouting: {
    //     enabled: webApplicationRoutingEnabled
    //     dnsZoneResourceIds: !empty(dnsZoneResourceId)
    //       ? [
    //           any(dnsZoneResourceId)
    //         ]
    //       : null
    //   }
    // }
    // podIdentityProfile: {
    //   allowNetworkPluginKubenet: podIdentityProfileAllowNetworkPluginKubenet
    //   enabled: podIdentityProfileEnable
    //   userAssignedIdentities: podIdentityProfileUserAssignedIdentities
    //   userAssignedIdentityExceptions: podIdentityProfileUserAssignedIdentityExceptions
    // }
    metricsProfile: {
      costAnalysis: {
        enabled: skuTier == 'free' ? false : costAnalysisEnabled
      }
    }
    azureMonitorProfile: {
      // containerInsights: azureMonitorProfile.?containerInsights
      metrics: azureMonitorProfile.?metrics
      // appMonitoring: azureMonitorProfile.?appMonitoring
    }
  }
}

module managedCluster_maintenanceConfigurations 'maintenance-configurations/main.bicep' = [for (maintenanceConfiguration, index) in maintenanceConfigurations : {
  name: take('${uniqueString(deployment().name, name, location)}-managedcluster-maintenanceconfig-${index}-${maintenanceConfiguration.name}',64)
  params: {
    managedClusterName: managedCluster.name
    name: maintenanceConfiguration.name
    maintenanceWindow: maintenanceConfiguration.maintenanceConfiguration.maintenanceWindow
    timeInWeek: maintenanceConfiguration.maintenanceConfiguration.?timeInWeek
    notAllowedTime: maintenanceConfiguration.maintenanceConfiguration.?notAllowedTime
  }
}]

// module managedCluster_agentPools 'agent-pool/main.bicep' = [
//   for (agentPool, index) in (agentPools ?? []): {
//     name: '${uniqueString(deployment().name, name, location)}-managedcluster-agentpool-${index}'
//     params: {
//       managedClusterName: managedCluster.?name
//       name: agentPool.name
//       availabilityZones: agentPool.?availabilityZones
//       count: agentPool.?count
//       sourceResourceId: agentPool.?sourceResourceId
//       enableAutoScaling: agentPool.?enableAutoScaling
//       enableEncryptionAtHost: agentPool.?enableEncryptionAtHost
//       enableFIPS: agentPool.?enableFIPS
//       enableNodePublicIP: agentPool.?enableNodePublicIP
//       enableUltraSSD: agentPool.?enableUltraSSD
//       gpuInstanceProfile: agentPool.?gpuInstanceProfile
//       kubeletDiskType: agentPool.?kubeletDiskType
//       maxCount: agentPool.?maxCount
//       maxPods: agentPool.?maxPods
//       minCount: agentPool.?minCount
//       mode: agentPool.?mode
//       nodeLabels: agentPool.?nodeLabels
//       nodePublicIpPrefixId: agentPool.?nodePublicIpPrefixId
//       nodeTaints: agentPool.?nodeTaints
//       orchestratorVersion: agentPool.?orchestratorVersion ?? kubernetesVersion
//       osDiskSizeGB: agentPool.?osDiskSizeGB
//       osDiskType: agentPool.?osDiskType
//       osSku: agentPool.?osSku
//       osType: agentPool.?osType
//       podSubnetId: agentPool.?podSubnetId
//       proximityPlacementGroupResourceId: agentPool.?proximityPlacementGroupResourceId
//       scaleDownMode: agentPool.?scaleDownMode
//       scaleSetEvictionPolicy: agentPool.?scaleSetEvictionPolicy
//       scaleSetPriority: agentPool.?scaleSetPriority
//       spotMaxPrice: agentPool.?spotMaxPrice
//       tags: agentPool.?tags ?? finalTags
//       type: agentPool.?type
//       maxSurge: agentPool.?maxSurge
//       vmSize: agentPool.?vmSize
//       vnetSubnetId: agentPool.?vnetSubnetId
//       workloadRuntime: agentPool.?workloadRuntime
//     }
//   }
// ]

// module managedCluster_extension 'br/public:avm/res/kubernetes-configuration/extension:0.2.0' = if (!empty(fluxExtension)) {
//   name: '${uniqueString(deployment().name, location)}-ManagedCluster-FluxExtension'
//   params: {
//     clusterName: managedCluster.name
//     configurationProtectedSettings: fluxExtension.?configurationProtectedSettings
//     configurationSettings: fluxExtension.?configurationSettings
//     enableTelemetry: enableTelemetry
//     extensionType: 'microsoft.flux'
//     fluxConfigurations: fluxExtension.?configurations
//     location: location
//     name: 'flux'
//     releaseNamespace: fluxExtension.?releaseNamespace ?? 'flux-system'
//     releaseTrain: fluxExtension.?releaseTrain ?? 'Stable'
//     version: fluxExtension.?version
//   }
// }

resource managedCluster_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: managedCluster
}

#disable-next-line use-recent-api-versions
resource managedCluster_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? defaultLogCategories): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: managedCluster
  }
]

resource managedCluster_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (formattedRoleAssignments ?? []): {
    name: roleAssignment.?name ?? guid(managedCluster.id, roleAssignment.principalId, roleAssignment.roleDefinitionId)
    properties: {
      roleDefinitionId: roleAssignment.roleDefinitionId
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: managedCluster
  }
]

// resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = if (enableDnsZoneContributorRoleAssignment == true && dnsZoneResourceId != null && webApplicationRoutingEnabled) {
//   name: last(split((!empty(dnsZoneResourceId) ? any(dnsZoneResourceId) : '/dummmyZone'), '/'))!
// }

// resource dnsZone_roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableDnsZoneContributorRoleAssignment == true && dnsZoneResourceId != null && webApplicationRoutingEnabled) {
//   name: guid(
//     dnsZone.id,
//     subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'befefa01-2a29-4197-83a8-272ff33ce314'),
//     'DNS Zone Contributor'
//   )
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions','befefa01-2a29-4197-83a8-272ff33ce314') // 'DNS Zone Contributor'
//     principalId: managedCluster.properties.ingressProfile.webAppRouting.identity.objectId
//     principalType: 'ServicePrincipal'
//   }
//   scope: dnsZone
// }

@description('The resource ID of the managed cluster.')
output resourceId string = managedCluster.id

@description('The resource group the managed cluster was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the managed cluster.')
output name string = managedCluster.name

@description('The control plane FQDN of the managed cluster.')
output controlPlaneFQDN string = enablePrivateCluster
  ? managedCluster.properties.privateFQDN
  : managedCluster.properties.fqdn

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = managedCluster.?identity.?principalId ?? ''

@description('The Client ID of the AKS identity.')
output kubeletIdentityClientId string = managedCluster.properties.?identityProfile.?kubeletidentity.?clientId ?? ''

@description('The Object ID of the AKS identity.')
output kubeletIdentityObjectId string = managedCluster.properties.?identityProfile.?kubeletidentity.?objectId ?? ''

@description('The Resource ID of the AKS identity.')
output kubeletIdentityResourceId string = managedCluster.properties.?identityProfile.?kubeletidentity.?resourceId ?? ''

@description('The Object ID of the OMS agent identity.')
output omsagentIdentityObjectId string = managedCluster.properties.?addonProfiles.?omsagent.?identity.?objectId ?? ''

@description('The Object ID of the Key Vault Secrets Provider identity.')
output keyvaultIdentityObjectId string = managedCluster.properties.?addonProfiles.?azureKeyvaultSecretsProvider.?identity.?objectId ?? ''

@description('The Client ID of the Key Vault Secrets Provider identity.')
output keyvaultIdentityClientId string = managedCluster.properties.?addonProfiles.?azureKeyvaultSecretsProvider.?identity.?clientId ?? ''

@description('The Object ID of Application Gateway Ingress Controller (AGIC) identity.')
output ingressApplicationGatewayIdentityObjectId string = managedCluster.properties.?addonProfiles.?ingressApplicationGateway.?identity.?objectId ?? ''

@description('The location the resource was deployed into.')
output location string = managedCluster.location

@description('The OIDC token issuer URL.')
output oidcIssuerUrl string = managedCluster.properties.?oidcIssuerProfile.?issuerURL ?? ''

@description('The addonProfiles of the Kubernetes cluster.')
output addonProfiles object = managedCluster.properties.?addonProfiles ?? {}

@description('The Object ID of Web Application Routing.')
output webAppRoutingIdentityObjectId string = managedCluster.properties.?ingressProfile.?webAppRouting.?identity.?objectId ?? ''

@description('''Is there evidence of usage in non-compliance with policies? Returns 'true' is a non-compliance is identified.

Note: 'kubernetesVersion' is not analyzed.''')
output evidenceOfNonCompliance bool = (publicNetworkAccess!='Disabled') || !disableLocalAccounts || !enableRBAC || !(apiServerAccessProfile.?disableRunCommand ?? false) || !(apiServerAccessProfile.?enablePrivateCluster ?? false) || !(aadProfile.?enableAzureRBAC ?? false) || !(addonAzurePolicy.?enabled ?? false) || !(securityProfileDefender.?securityMonitoring.?enabled ?? false) || empty(diagnosticSettings[?0].?workspaceResourceId) || length(configuredRequiredLogCategoryNames)!=length(requiredLogCategoryNames) || (networkOutboundType == 'loadBalancer')

@description('The list of diagnostic settings log categories that were configured to log analytics.')
output configuredLogCategoriesLogAnalytics array = flatten(map((diagnosticSettings ?? []),
                                                    setting => !empty(setting.?workspaceResourceId)
                                                    ? map((setting.?logCategoriesAndGroups ?? []),
                                                          logCategory => logCategory.?category ?? '')
                                                    : []
                                                  ))

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
  customerManagedKeyType
} from '../../../../bicep-shared/types.bicep'

import { agentPoolType } from 'agent-pool/main.bicep'
import { maintenanceConfigurationType } from 'maintenance-configurations/main.bicep'

type fluxConfigurationProtectedSettingsType = {
  @description('Optional. The SSH private key to use for Git authentication.')
  sshPrivateKey: string?
}?

type extensionType = {
  @description('Required. The name of the extension.')
  name: string?

  @description('Optional. Namespace where the extension Release must be placed.')
  releaseNamespace: string?

  @description('Optional. Namespace where the extension will be created for an Namespace scoped extension.')
  targetNamespace: string?

  @description('Required. The release train of the extension.')
  releaseTrain: string?

  @description('Optional. The configuration protected settings of the extension.')
  configurationProtectedSettings: fluxConfigurationProtectedSettingsType?

  @description('Optional. The configuration settings of the extension.')
  configurationSettings: object?

  @description('Optional. The version of the extension.')
  version: string?

  @description('Optional. The flux configurations of the extension.')
  configurations: array?
}?

@description('Azure Key Vault secrets provider configuration.')
type addonAzureKeyvaultSecretsProviderType = {
  @description('Required. Should this add-on be enabled?')
  enabled: bool

  @description('Optional. Configuration of the add-on.')
  config: {
    @description('Optional. Whether to enable rotation of secrets.')
    enableSecretRotation: ('true' | 'false')?
  }?
}

type addonAzurePolicyType = {
  @description('Required. Should this add-on be enabled?')
  enabled: bool

  @description('Optional. Configuration of the add-on.')
  config: {
    @description('Optional. Version of the policy. Default: v2')
    version: string?
  }?
}

type securityProfileDefenderType = {
  @description('Required. Security Monitoring settings.')
  securityMonitoring: {
    @description('Required. Whether to enable Azure Defender. Default: true')
    enabled: bool?
  }

  @description('''Optional. Resource ID of the Log Analytics workspace to be associated with Microsoft Defender.
  When Microsoft Defender is enabled, this field is required and must be a valid workspace resource ID.
  When Microsoft Defender is disabled, leave the field empty.''')
  logAnalyticsWorkspaceResourceId: string?
}

@description('Azure Key Vault key management service settings for the security profile')
type securityProfileAzureKeyVaultKmsType = {

  @description('Optional. Whether to enable Azure Key Vault key management service. Default: true')
  enabled: bool?

  @description('''Conditional. Resource ID of key vault. When keyVaultNetworkAccess is Private, this field is required and must be a valid resource ID.
  When keyVaultNetworkAccess is Public, leave the field empty.''')
  keyVaultResourceId: string?

  @description('''Optional. Network access of key vault. The possible values are Public and Private.
  Public means the key vault allows public access from all networks.
  Private means the key vault disables public access and enables private link. The default value is Private.''')
  keyVaultNetworkAccess: ('Private' | 'Public')?

  @description('''Conditional. Identifier of Azure Key Vault key.
  It is provided as a Uri (e.g. 'https://vaultFQDN/keys/key_name/key_version'). See key identifier format for more details.
  When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier.
  When Azure Key Vault key management service is disabled, leave the field empty.''')
  keyId: string?
}

@description('The access profile for managed cluster API server.')
type apiServerAccessProfileType = {
  @description('''Optional. IP ranges are specified in CIDR format, e.g. 137.117.106.88/29.
  This feature is not compatible with clusters that use Public IP Per Node, or clusters that are using a Basic Load Balancer.
  For more information see [API server authorized IP ranges](https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges).
  Default: empty.
  ''')
  authorizedIPRanges: string[]?

  @description('Optional. Whether to disable run command for the cluster or not. Default: true')
  disableRunCommand: bool?

  @description('Optional. For more details, see [Creating a private AKS cluster](https://docs.microsoft.com/azure/aks/private-clusters). Default: true')
  enablePrivateCluster: bool?

  @description('Optional. Whether to create additional public FQDN for private cluster or not. Default: false')
  enablePrivateClusterPublicFQDN: bool?

  @description('''Optional. Allowed values are 'system', 'none', or a resourceId of the private DNS Zone. The default is 'none'.

  For more details see [configure private DNS zone](https://docs.microsoft.com/azure/aks/private-clusters#configure-private-dns-zone).
  ''')
  privateDNSZone: string?

  // @description('Optional. Whether to enable apiserver vnet integration for the cluster or not. Default: false')
  // enableVnetIntegration: bool?

  @description('''Conditional. Resource ID of the subnet.
  It is required when: 1. creating a new cluster with BYO Vnet; 2. updating an existing cluster to enable apiserver vnet integration.''')
  subnetId: string?
}

@description('The Azure Active Directory configuration.')
type aadProfileType = {
  @description('Optional. The list of AAD group object IDs that will have admin role of the cluster. Default: empty.')
  adminGroupObjectIDs: string[]?

  @description('Optional. Specifies whether to enable Azure RBAC for Kubernetes authorization. Default: true.')
  enableAzureRBAC: bool?

  @description('Optional. Specifies whether to enable managed AAD integration. Default: true.')
  managed: bool?

  @description('''Optional. Specifies the tenant ID of the Azure Active Directory used by the AKS cluster for authentication.
  If not specified, will use the tenant of the deployment subscription.''')
  tenantID: string?
}

@description('Profile of the cluster load balancer.')
type loadBalancerProfileType = {
  @description('''Optional. The desired number of allocated SNAT ports per VM. Allowed values are in the range of 0 to 64000 (inclusive).
  The default value is 0 which results in Azure dynamically allocating ports.''')
  allocatedOutboundPorts: int?

  @description('Optional. The type of the managed inbound Load Balancer BackendPool. The default is \'NodeIPConfiguration\'')
  backendPoolType: ('NodeIP' | 'NodeIPConfiguration')?

  @description('Optional. The health probing behavior for External Traffic Policy Cluster services.')
  clusterServiceLoadBalancerHealthProbeMode: ('ServiceNodePort' | 'Shared')?

  // @description('The effective outbound IP resources of the cluster load balancer.')
  // effectiveOutboundIPs: [
  //   {
  //     @description('The fully qualified Azure resource id.')
  //     id: string
  //   }?
  // ]

  @description('Optional. Enable multiple standard load balancers per AKS cluster or not.')
  enableMultipleStandardLoadBalancers: bool?

  @description('''Optional. Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive).
  The default value is 4 minutes.''')
  idleTimeoutInMinutes: int?

  @description('Optional. Desired managed outbound IPs for the cluster load balancer.')
  managedOutboundIPs: {
    @description('''Required. The desired number of IPv4 outbound IPs created/managed by Azure for the cluster load balancer.
    Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.''')
    @minValue(1)
    @maxValue(100)
    count: int

    @description('''Optional. The desired number of IPv6 outbound IPs created/managed by Azure for the cluster load balancer.
    Allowed values must be in the range of 0 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack.''')
    @minValue(0)
    @maxValue(100)
    countIPv6: int?
  }?

  @description('Optional. Desired outbound IP Prefix resources for the cluster load balancer.')
  outboundIPPrefixes: {
    @description('Required. A list of public IP prefix resources.')
    publicIPPrefixes: [
      {
        @description('Required. The fully qualified Azure resource id.')
        id: string
      }
    ]
  }?

  @description('Optional. Desired outbound IP resources for the cluster load balancer.')
  outboundIPs: {
    @description('Required. A list of public IP resources.')
    publicIPs: [
      {
        @description('Required. The fully qualified Azure resource id.')
        id: string
      }
    ]
  }?
}

@description('''Advanced Networking profile for enabling observability on a cluster.
Note that enabling advanced networking features may incur additional costs.
For more information see aka.ms/aksadvancednetworking.''')
type advancedNetworkingType = {
  @description('Required. Observability profile to enable advanced network metrics and flow logs with historical contexts.')
  observability: {
    @description('Required. Indicates the enablement of Advanced Networking observability functionalities on clusters.')
    enabled: true
  }
}

@description('The auto upgrade configuration.')
type autoUpgradeProfileType = {
  @description('''Required. The default is Unmanaged, but may change to either NodeImage or SecurityPatch at GA.
  See https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster?tabs=azure-cli''')
  upgradeChannel: 'node-image' | 'none' | 'patch' | 'rapid' | 'stable'
  @description('''Required. For more information see setting the AKS cluster auto-upgrade channel
  see https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster#set-auto-upgrade-channel.''')
  nodeOSUpgradeChannel: 'NodeImage' | 'None' | 'SecurityPatch' | 'Unmanaged'
}

@description('Image Cleaner settings for the security profile.')
type securityProfileImageCleanerType = {
  @description('Required. Whether to enable Image Cleaner on AKS cluster.')
  enabled: bool

  @description('Required. Image Cleaner scanning interval in hours.  The maximum value is equivalent to three months.')
  @minValue(24)
  @maxValue(2160)
  intervalHours: int
}

type maintenanceConfigurationsType = {
  @description('Required. Type of maintenance configuration - Cluster-level or Node-level.')
  name: 'aksManagedAutoUpgradeSchedule' | 'aksManagedNodeOSUpgradeSchedule'
  @description('Required. Configuration parameters.')
  maintenanceConfiguration: maintenanceConfigurationType
}[]

@description('Addon profile for monitoring the container service cluster.')
type azureMonitorProfileType = {

  @description('''Optional. Application Monitoring Profile for Kubernetes Application Container. Collects application logs,
  metrics and traces through auto-instrumentation of the application using Azure Monitor OpenTelemetry based SDKs.
  See aka.ms/AzureMonitorApplicationMonitoring for an overview.''')
  appMonitoring: {
    @description('''Optional. Application Monitoring Auto Instrumentation for Kubernetes Application Container.
    Deploys web hook to auto-instrument Azure Monitor OpenTelemetry based SDKs to collect OpenTelemetry metrics,
    logs and traces of the application. See aka.ms/AzureMonitorApplicationMonitoring for an overview.''')
    autoInstrumentation: {
      @description('Required. Indicates if Application Monitoring Auto Instrumentation is enabled or not.')
      enabled: bool
    }?
    @description('''Optional. Application Monitoring Open Telemetry Metrics Profile for Kubernetes Application Container Logs and Traces.
    Collects OpenTelemetry logs and traces of the application using Azure Monitor OpenTelemetry based SDKs. See aka.ms/AzureMonitorApplicationMonitoring for an overview.''')
    openTelemetryLogs: {
      @description('Optional. Indicates if Application Monitoring Open Telemetry Logs and traces is enabled or not.')
      enabled: bool
      @description('Optional. The Open Telemetry host port for Open Telemetry logs and traces. If not specified, the default port is 28331.')
      port: int?
    }?
    @description('''Optional. Application Monitoring Open Telemetry Metrics Profile for Kubernetes Application Container Metrics.
    Collects OpenTelemetry metrics of the application using Azure Monitor OpenTelemetry based SDKs. See aka.ms/AzureMonitorApplicationMonitoring for an overview.''')
    openTelemetryMetrics: {
      @description('Required. Indicates if Application Monitoring Open Telemetry Metrics is enabled or not.')
      enabled: bool
      @description('Optional. The Open Telemetry host port for Open Telemetry metrics. If not specified, the default port is 28333.')
      port: int?
    }?
  }?

  @description('''Optional. Azure Monitor Container Insights Profile for Kubernetes Events, Inventory and Container stdout & stderr logs etc.
  See aka.ms/AzureMonitorContainerInsights for an overview.''')
  containerInsights: {
    @description('''Optional. Indicates whether custom metrics collection has to be disabled or not. If not specified the default is false.
    No custom metrics will be emitted if this field is false but the container insights enabled field is false''')
    disableCustomMetrics: bool?
    @description('''Optional. Indicates whether prometheus metrics scraping is disabled or not. If not specified the default is false.
    No prometheus metrics will be emitted if this field is false but the container insights enabled field is false''')
    disablePrometheusMetricsScraping: bool?
    @description('Required. Indicates if Azure Monitor Container Insights Logs Addon is enabled or not.')
    enabled: bool
    @description('Optional. Fully Qualified ARM Resource Id of Azure Log Analytics Workspace for storing Azure Monitor Container Insights Logs.')
    logAnalyticsWorkspaceResourceId: string?
    @description('Optional. The syslog host port. If not specified, the default port is 28330.')
    syslogPort: int?
  }?

  @description('Optional. Metrics profile for the prometheus service addon')
  metrics: {
    @description('Required. Whether to enable the Prometheus collector')
    enabled: bool
    @description('Optional. Kube State Metrics for prometheus addon profile for the container service cluster')
    kubeStateMetrics: {
      @description('Required. Comma-separated list of additional Kubernetes label keys that will be used in the resource\'s labels metric.')
      metricAnnotationsAllowList: string
      @description('Required. Comma-separated list of Kubernetes annotations keys that will be used in the resource\'s labels metric.')
      metricLabelsAllowlist: string
    }?
  }?
}
