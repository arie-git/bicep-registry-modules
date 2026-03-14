metadata name = 'Azure Kubernetes Service (AKS) Managed Cluster'
metadata description = 'This module deploys an Azure Kubernetes Service (AKS) Managed Cluster.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20260309'
metadata compliance = '''Compliant usage of Azure Kubernetes Service requires:
- publicNetworkAccess: 'Disabled', enablePrivateCluster: true, enableNodePublicIP: false (drcp-aks-02)
- disableLocalAccounts: true, enableRBAC: true, aadProfile.enableAzureRBAC: true (drcp-aks-03)
- addonAzurePolicy.enabled: true (drcp-aks-11)
- kubernetesVersion: supported version (drcp-aks-12)
- apiServerAccessProfile.disableRunCommand: true (drcp-aks-16)
- securityProfileDefender.securityMonitoring.enabled: true (drcp-aks-18)
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

@description('''Optional. The managed identity definition for this resource. Only one type of identity is supported: system-assigned or user-assigned, but not both.

[Policy: drcp-aks-03] A managed identity must be used (not a service principal).''')
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

[Policy: drcp-aks-12] Setting this parameter to a version that is no longer supported by Microsoft will make the resource non-compliant.''')
param kubernetesVersion string?

// ----- Authentication parameters -----

@description('''Optional. Whether to enable Kubernetes Role-Based Access Control. Default: true.

[Policy: drcp-aks-03] Setting this parameter to 'false' will make the resource non-compliant.''')
param enableRBAC bool = true

@description('''Optional. If set to true, getting static credentials will be disabled for this cluster.
This must only be used on Managed Clusters that are AAD enabled. Default: true.

[Policy: drcp-aks-03] Setting this parameter to 'false' will make the resource non-compliant.''')
param disableLocalAccounts bool = true

@description('''Optional. The Entra ID (Azure Active Directory) integration configuration.

The default is:
- enableAzureRBAC: value of 'enableRBAC' parameter
- managed: true
- tenantID: subscription().tenantId

[Policy: drcp-aks-03] Compliant use of this resource requires certain parameter values:
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

[Policy: drcp-aks-02] enablePrivateCluster must be true.
[Policy: drcp-aks-16] disableRunCommand must be true.''')
param apiServerAccessProfile apiServerAccessProfileType = {
  disableRunCommand: true
  enablePrivateCluster: true
  enablePrivateClusterPublicFQDN: true
  // enableVnetIntegration: false
  privateDNSZone: 'none'
}

// ----- Networking parameters -----

@description('''Optional. Allow or deny public network access for AKS. Default: Disabled.

[Policy: drcp-aks-02] Setting this parameter to any value other than 'Disabled' will make the resource non-compliant.''')
@allowed([
  'Enabled'
  'Disabled'
  'SecuredByPerimeter'
])
param publicNetworkAccess string = 'Disabled'

@description('Optional. Advanced Networking profile for enabling observability and security feature suite on a cluster. For more information see https://aka.ms/aksadvancednetworking.')
param advancedNetworking advancedNetworkingType?

@description('Optional. The IP families used for the cluster.')
@allowed([
  'IPv4'
  'IPv6'
])
param ipFamilies string[] = [
  'IPv4'
]

@description('Optional. NAT Gateway profile for the cluster.')
param natGatewayProfile object?

@description('Optional. Network mode used for building the Kubernetes network.')
@allowed([
  'bridge'
  'transparent'
])
param networkMode string?

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

@description('Optional. The CIDR notation IP ranges from which to assign pod IPs. One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking.')
param podCidrs string[]?

@description('Optional. A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param networkServiceCidr string?

@description('Optional. The CIDR notation IP ranges from which to assign service cluster IPs. One IPv4 CIDR is expected for single-stack networking. Two CIDRs, one for each IP family (IPv4/IPv6), is expected for dual-stack networking. They must not overlap with any Subnet IP ranges.')
param serviceCidrs string[]?

@description('''Optional. Specifies the IP address assigned to the Kubernetes DNS service.
It must be within the Kubernetes service address range specified in serviceCidr.''')
param networkDnsServiceIP string?

@description('Optional. Static egress gateway profile for the cluster.')
param staticEgressGatewayProfile object?

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

[Policy: drcp-aks-02] Setting this parameter to 'loadBalancer' will make the resource non-compliant.

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

// ----- Storage profile parameters -----

@description('Optional. Whether the AzureBlob CSI Driver for the storage profile is enabled.')
param enableStorageProfileBlobCSIDriver bool = true

@description('Optional. Whether the AzureDisk CSI Driver for the storage profile is enabled.')
param enableStorageProfileDiskCSIDriver bool = true

@description('Optional. Whether the AzureFile CSI Driver for the storage profile is enabled.')
param enableStorageProfileFileCSIDriver bool = true

@description('Optional. Whether the snapshot controller for the storage profile is enabled.')
param enableStorageProfileSnapshotController bool = false

@description('Optional. Node provisioning settings that apply to the whole cluster.')
param nodeProvisioningProfile object?

@description('Optional. The node resource group configuration profile.')
param nodeResourceGroupProfile object?

// ----- Nodepools parameters -----

@description('''Conditional. When using defaults in 'primaryAgentPoolProfile', provide here the Subnet resource ID for the primary agent pool in case of using a custom Virtual Network.''')
param primaryAgentPoolSubnetResourceId string? // TODO: make this part of the profile param

// https://learn.microsoft.com/en-gb/azure/aks/quotas-skus-regions#supported-vm-sizes
// https://learn.microsoft.com/en-us/azure/aks/use-system-pools?tabs=azure-cli#system-and-user-node-pools
@description('''Optional. Properties of the primary agent pool.

[Policy: drcp-aks-02] enableNodePublicIP must be false (or absent) on all agent pools.''')
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

@description('''Optional. Define one or more secondary/additional agent pools.

[Policy: drcp-aks-02] enableNodePublicIP must be false (or absent) on all agent pools.''')
param agentPools agentPoolType?

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

// ---- Ingress and DNS -----

@description('Optional. Specifies whether the httpApplicationRouting add-on is enabled or not.')
param httpApplicationRoutingEnabled bool = false

@description('Optional. Specifies whether the webApplicationRoutingEnabled add-on is enabled or not.')
param webApplicationRoutingEnabled bool = false

@description('Optional. Specifies the resource ID of connected DNS zone. It will be ignored if `webApplicationRoutingEnabled` is set to `false`.')
param dnsZoneResourceId string?

@description('Optional. Ingress type for the default NginxIngressController custom resource. It will be ignored if `webApplicationRoutingEnabled` is set to `false`.')
@allowed([
  'AnnotationControlled'
  'External'
  'Internal'
  'None'
])
param defaultIngressControllerType string?

@description('Optional. Specifies whether assign the DNS zone contributor role to the cluster service principal. It will be ignored if `webApplicationRoutingEnabled` is set to `false` or `dnsZoneResourceId` not provided.')
param enableDnsZoneContributorRoleAssignment bool = true

@description('Optional. Specifies whether the ingressApplicationGateway (AGIC) add-on is enabled or not.')
param ingressApplicationGatewayEnabled bool = false

@description('Conditional. Specifies the resource ID of connected application gateway. Required if `ingressApplicationGatewayEnabled` is set to `true`.')
param appGatewayResourceId string?

@description('Optional. Specifies whether the aciConnectorLinux add-on is enabled or not.')
param aciConnectorLinuxEnabled bool = false

// ----- Security related ----

@description('Optional. The pod identity profile of the Managed Cluster. See [use AAD pod identity](https://learn.microsoft.com/azure/aks/use-azure-ad-pod-identity) for more details on AAD pod identity integration.')
param podIdentityProfile object?

@description('Optional. Identities associated with the cluster.')
param identityProfile object?

@description('Optional. Security profile for the managed cluster. When provided, this overrides the individual security params (securityProfileDefender, securityProfileAzureKeyVaultKms, imageCleaner, enableWorkloadIdentity).')
param securityProfile object?

@description('Optional. Whether the The OIDC issuer profile of the Managed Cluster is enabled.')
param enableOidcIssuerProfile bool = enableWorkloadIdentity

@description('Optional. Whether to enable Workload Identity. Requires OIDC issuer profile to be enabled.')
param enableWorkloadIdentity bool = false

@description('''Optional. Specifies the configuration of Azure Policy add-on.
Default is enabled=true and config.version=v2.

[Policy: drcp-aks-11] Compliant use of this resource requires 'enabled' to be true.''')
param addonAzurePolicy addonAzurePolicyType = {
  enabled: true
  config:{
    version: 'v2'
  }
}

@description('''Optional. Azure Defender profile settings. By default the securityMonitoring.enabled is true

[Policy: drcp-aks-18] Setting securityMonitoring.enabled to a value other than 'true' will make this resource non-compliant.''')
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

@description('''Optional. Configures Azure Monitor profile, including Container Insights, Prometheus and Application Monitoring.

Uses the ARM resource type schema for validation. When not specified, monitoring is handled via the OMS agent addon
(controlled by addonOmsAgentEnabled parameter) which sends logs to the Log Analytics workspace.
''')
param azureMonitorProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-01-02-preview'>.properties.azureMonitorProfile?

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

@description('Optional. The Resource ID of the disk encryption set to use for enabling encryption at rest. For security reasons, this value should be provided.')
param diskEncryptionSetResourceId string?

// @description('Optional. Settings and configurations for the flux extension.')
// param fluxExtension extensionType?
// NOTE: Flux extension is commented out -- the kubernetes-configuration/extension module
// is not in the fork and not built in Azure DevOps. Re-enable when flux is supported.

@description('Optional. Configurations for provisioning the cluster with HTTP proxy servers.')
param httpProxyConfig resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.httpProxyConfig?

@description('''Optional. Workload Auto-scaler profile for the managed cluster.
Default enables KEDA for event-driven autoscaling.''')
param workloadAutoScalerProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.workloadAutoScalerProfile = {
  keda: {
    enabled: true
  }
}

@description('Optional. Service mesh profile for a managed cluster.')
param serviceMeshProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.serviceMeshProfile?

@description('Optional. AI toolchain operator settings that apply to the whole cluster.')
param aiToolchainOperatorProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.aiToolchainOperatorProfile?

@description('Optional. Profile of the cluster bootstrap configuration.')
param bootstrapProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.bootstrapProfile?

@description('Optional. The FQDN subdomain of the private cluster with custom private dns zone. This cannot be updated once the Managed Cluster has been created.')
param fqdnSubdomain string?

@description('Optional. Settings for upgrading the cluster with override options.')
param upgradeSettings resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.upgradeSettings?

@description('Optional. The profile for Windows VMs in the Managed Cluster.')
param windowsProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.windowsProfile?

@description('Optional. Parameters to be applied to the cluster-autoscaler when enabled.')
param autoScalerProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.autoScalerProfile?

@description('Conditional. Information about a service principal identity for the cluster to use for manipulating Azure APIs. Required if no managed identities are assigned to the cluster.')
param aksServicePrincipalProfile resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.servicePrincipalProfile?

@description('Optional. Specifies whether the openServiceMesh add-on is enabled or not.')
param openServiceMeshEnabled bool = false

@description('Optional. Specifies whether the kubeDashboard add-on is enabled or not.')
param kubeDashboardEnabled bool = false

@description('Optional. Specifies whether the OMS agent is using managed identity authentication.')
param omsAgentUseAADAuth bool = true

// =========== //
// Variables   //
// =========== //

var enablePrivateCluster = apiServerAccessProfile.?enablePrivateCluster ?? true

// var enableReferencedModulesTelemetry = false // Only used by flux extension (commented out)

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
    aiToolchainOperatorProfile: aiToolchainOperatorProfile
    bootstrapProfile: bootstrapProfile
    httpProxyConfig: httpProxyConfig
    identityProfile: identityProfile
    diskEncryptionSetID: diskEncryptionSetResourceId
    nodeResourceGroup: nodeResourceGroup
    nodeResourceGroupProfile: nodeResourceGroupProfile
    nodeProvisioningProfile: nodeProvisioningProfile
    dnsPrefix: dnsPrefix
    fqdnSubdomain: fqdnSubdomain
    kubernetesVersion: kubernetesVersion
    supportPlan: supportPlan
    enableRBAC: enableRBAC
    disableLocalAccounts: disableLocalAccounts
    publicNetworkAccess: publicNetworkAccess
    apiServerAccessProfile: {
      authorizedIPRanges: apiServerAccessProfile.?authorizedIPRanges ?? [] // TODO: check usage conditions
      disableRunCommand: apiServerAccessProfile.?disableRunCommand ?? true
      enablePrivateCluster: apiServerAccessProfile.?enablePrivateCluster ?? enablePrivateCluster
      enablePrivateClusterPublicFQDN: apiServerAccessProfile.?enablePrivateClusterPublicFQDN ?? (apiServerAccessProfile.?privateDNSZone ?? 'none')=='none'
      privateDNSZone: apiServerAccessProfile.?privateDNSZone ?? 'none'
    }
    servicePrincipalProfile: aksServicePrincipalProfile
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
      httpApplicationRouting: {
        enabled: httpApplicationRoutingEnabled
      }
      omsagent: {
        enabled: addonOmsAgentEnabled && !empty(logAnalyticsWorkspaceResourceId)
        #disable-next-line BCP321 // Value will not be used if null or empty
        config: addonOmsAgentEnabled && !empty(logAnalyticsWorkspaceResourceId)
          ? {
              logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceResourceId
              ...(omsAgentUseAADAuth
                ? {
                    useAADAuth: 'true'
                  }
                : {})
            }
          : null
      }
      ingressApplicationGateway: {
        enabled: ingressApplicationGatewayEnabled && !empty(appGatewayResourceId)
        #disable-next-line BCP321 // Value will not be used if null or empty
        config: ingressApplicationGatewayEnabled && !empty(appGatewayResourceId)
          ? {
              applicationGatewayId: appGatewayResourceId
              effectiveApplicationGatewayId: appGatewayResourceId
            }
          : null
      }
      aciConnectorLinux: {
        enabled: aciConnectorLinuxEnabled
      }
      openServiceMesh: {
        enabled: openServiceMeshEnabled
        config: openServiceMeshEnabled ? {} : null
      }
      kubeDashboard: {
        enabled: kubeDashboardEnabled
      }
    }
    oidcIssuerProfile: enableOidcIssuerProfile
      ? {
          enabled: enableOidcIssuerProfile
        }
      : null
    securityProfile: securityProfile ?? {
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
    networkProfile: {
      advancedNetworking: advancedNetworking
      ipFamilies: ipFamilies
      natGatewayProfile: natGatewayProfile
      networkMode: networkMode
      podCidrs: podCidrs
      serviceCidrs: serviceCidrs
      staticEgressGatewayProfile: staticEgressGatewayProfile
      networkPlugin: networkPlugin
      networkPluginMode: networkDataPlane == 'cilium' ? 'overlay' : ((empty(networkPluginMode) || networkPlugin=='kubenet') ? null : networkPluginMode)
      networkPolicy: networkDataPlane == 'cilium' ? 'cilium' : networkPolicy
      networkDataplane: (networkPlugin == 'kubenet') ? null : networkDataPlane
      podCidr: (networkPlugin == 'azure' && networkPluginMode == '' ) ? null : networkPodCidr
      serviceCidr: networkServiceCidr
      dnsServiceIP: networkDnsServiceIP
      loadBalancerSku: networkLoadBalancerSku
      loadBalancerProfile: empty(networkLoadBalancerProfile) ? null : {
        allocatedOutboundPorts: networkLoadBalancerProfile.?allocatedOutboundPorts ?? 0
        backendPoolType: (networkLoadBalancerSku == 'basic') ? 'NodeIPConfiguration' : networkLoadBalancerProfile.?backendPoolType ?? 'NodeIPConfiguration'
        effectiveOutboundIPs: []
        enableMultipleStandardLoadBalancers: networkLoadBalancerProfile.?enableMultipleStandardLoadBalancers ?? false
        idleTimeoutInMinutes: networkLoadBalancerProfile.?idleTimeoutInMinutes ?? 4
        managedOutboundIPs: networkLoadBalancerProfile.?managedOutboundIPs
        outboundIPPrefixes: networkLoadBalancerProfile.?outboundIPPrefixes
        outboundIPs: networkLoadBalancerProfile.?outboundIPs
      }
      outboundType: networkOutboundType
    }
    storageProfile: {
      blobCSIDriver: {
        enabled: enableStorageProfileBlobCSIDriver
      }
      diskCSIDriver: {
        enabled: costAnalysisEnabled == true && skuTier != 'Free' ? true : enableStorageProfileDiskCSIDriver
      }
      fileCSIDriver: {
        enabled: enableStorageProfileFileCSIDriver
      }
      snapshotController: {
        enabled: enableStorageProfileSnapshotController
      }
    }
    workloadAutoScalerProfile: workloadAutoScalerProfile
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
    autoScalerProfile: autoScalerProfile
    ingressProfile: {
      webAppRouting: {
        enabled: webApplicationRoutingEnabled
        dnsZoneResourceIds: !empty(dnsZoneResourceId)
          ? [
              any(dnsZoneResourceId)
            ]
          : null
        nginx: !empty(defaultIngressControllerType)
          ? {
              defaultIngressControllerType: any(defaultIngressControllerType)
            }
          : null
      }
    }
    podIdentityProfile: podIdentityProfile
    metricsProfile: {
      costAnalysis: {
        enabled: skuTier == 'Free' ? false : costAnalysisEnabled
      }
    }
    azureMonitorProfile: azureMonitorProfile
    serviceMeshProfile: serviceMeshProfile
    upgradeSettings: upgradeSettings
    windowsProfile: windowsProfile
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

module managedCluster_agentPools 'agent-pool/main.bicep' = [
  for (agentPool, index) in (agentPools ?? []): {
    name: '${uniqueString(deployment().name, name, location)}-managedcluster-agentpool-${index}'
    params: {
      managedClusterName: managedCluster.?name
      name: agentPool.name
      availabilityZones: agentPool.?availabilityZones
      capacityReservationGroupResourceId: agentPool.?capacityReservationGroupResourceId
      count: agentPool.?count
      sourceResourceId: agentPool.?sourceResourceId
      enableAutoScaling: agentPool.?enableAutoScaling
      enableEncryptionAtHost: agentPool.?enableEncryptionAtHost
      enableFIPS: agentPool.?enableFIPS
      enableNodePublicIP: agentPool.?enableNodePublicIP
      enableUltraSSD: agentPool.?enableUltraSSD
      gatewayProfile: agentPool.?gatewayProfile
      gpuInstanceProfile: agentPool.?gpuInstanceProfile
      gpuProfile: agentPool.?gpuProfile
      hostGroupResourceId: agentPool.?hostGroupResourceId
      kubeletConfig: agentPool.?kubeletConfig
      kubeletDiskType: agentPool.?kubeletDiskType
      linuxOSConfig: agentPool.?linuxOSConfig
      localDNSProfile: agentPool.?localDNSProfile
      maxCount: agentPool.?maxCount
      maxPods: agentPool.?maxPods
      messageOfTheDay: agentPool.?messageOfTheDay
      minCount: agentPool.?minCount
      mode: agentPool.?mode
      networkProfile: agentPool.?networkProfile
      nodeLabels: agentPool.?nodeLabels
      nodePublicIpPrefixId: agentPool.?nodePublicIpPrefixId
      nodeTaints: agentPool.?nodeTaints
      orchestratorVersion: agentPool.?orchestratorVersion ?? kubernetesVersion
      osDiskSizeGB: agentPool.?osDiskSizeGB
      osDiskType: agentPool.?osDiskType
      osSku: agentPool.?osSku
      osType: agentPool.?osType
      podIPAllocationMode: agentPool.?podIPAllocationMode
      podSubnetId: agentPool.?podSubnetId
      powerState: agentPool.?powerState
      proximityPlacementGroupResourceId: agentPool.?proximityPlacementGroupResourceId
      scaleDownMode: agentPool.?scaleDownMode
      scaleSetEvictionPolicy: agentPool.?scaleSetEvictionPolicy
      scaleSetPriority: agentPool.?scaleSetPriority
      securityProfile: agentPool.?securityProfile
      spotMaxPrice: agentPool.?spotMaxPrice
      tags: agentPool.?tags ?? tags
      type: agentPool.?type
      upgradeSettings: agentPool.?upgradeSettings
      virtualMachinesProfile: agentPool.?virtualMachinesProfile
      vmSize: agentPool.?vmSize
      vnetSubnetId: agentPool.?vnetSubnetId
      windowsProfile: agentPool.?windowsProfile
      workloadRuntime: agentPool.?workloadRuntime
    }
  }
]

// module managedCluster_extension 'br/amavm:avm/res/kubernetes-configuration/extension:0.3.8' = if (!empty(fluxExtension)) {
//   name: '${uniqueString(deployment().name, location)}-ManagedCluster-FluxExtension'
//   params: {
//     clusterName: managedCluster.name
//     configurationProtectedSettings: fluxExtension.?configurationProtectedSettings
//     configurationSettings: fluxExtension.?configurationSettings
//     enableTelemetry: enableReferencedModulesTelemetry
//     extensionType: 'microsoft.flux'
//     fluxConfigurations: fluxExtension.?fluxConfigurations
//     location: location
//     name: fluxExtension.?name ?? 'flux'
//     releaseNamespace: fluxExtension.?releaseNamespace ?? 'flux-system'
//     releaseTrain: fluxExtension.?releaseTrain ?? 'Stable'
//     version: fluxExtension.?version
//     targetNamespace: fluxExtension.?targetNamespace
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

resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = if (publicNetworkAccess != 'Disabled' && enableDnsZoneContributorRoleAssignment == true && dnsZoneResourceId != null && webApplicationRoutingEnabled) {
  name: last(split((!empty(dnsZoneResourceId) ? any(dnsZoneResourceId) : '/dummmyZone'), '/'))!
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2024-06-01' existing = if (publicNetworkAccess == 'Disabled' && enableDnsZoneContributorRoleAssignment == true && dnsZoneResourceId != null && webApplicationRoutingEnabled) {
  name: last(split((!empty(dnsZoneResourceId) ? any(dnsZoneResourceId) : '/dummmyZone'), '/'))
}

resource dnsZone_roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (publicNetworkAccess != 'Disabled' && enableDnsZoneContributorRoleAssignment == true && dnsZoneResourceId != null && webApplicationRoutingEnabled) {
  name: guid(
    dnsZone.id,
    subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'befefa01-2a29-4197-83a8-272ff33ce314'),
    'DNS Zone Contributor'
  )
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'befefa01-2a29-4197-83a8-272ff33ce314'
    ) // 'DNS Zone Contributor'
    principalId: managedCluster.properties.ingressProfile.webAppRouting.identity.objectId
    principalType: 'ServicePrincipal'
  }
  scope: dnsZone
}

resource privateDnsZone_roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (publicNetworkAccess == 'Disabled' && enableDnsZoneContributorRoleAssignment == true && dnsZoneResourceId != null && webApplicationRoutingEnabled) {
  name: guid(
    privateDnsZone.id,
    subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'befefa01-2a29-4197-83a8-272ff33ce314'),
    'DNS Zone Contributor'
  )
  properties: {
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'befefa01-2a29-4197-83a8-272ff33ce314'
    ) // 'DNS Zone Contributor'
    principalId: managedCluster.properties.ingressProfile.webAppRouting.identity.objectId
    principalType: 'ServicePrincipal'
  }
  scope: privateDnsZone
}

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

@description('''Is there evidence of usage in non-compliance with policies? Returns 'true' if a non-compliance is identified.

Policies checked:
- [drcp-aks-02] publicNetworkAccess must be 'Disabled', enablePrivateCluster must be true, networkOutboundType must not be 'loadBalancer', enableNodePublicIP must be false on all agent pools
- [drcp-aks-03] disableLocalAccounts must be true, enableRBAC must be true, aadProfile.enableAzureRBAC must be true
- [drcp-aks-11] addonAzurePolicy.enabled must be true
- [drcp-aks-16] apiServerAccessProfile.disableRunCommand must be true
- [drcp-aks-18] securityProfileDefender.securityMonitoring.enabled must be true

Note: 'kubernetesVersion' (drcp-aks-12) is not analyzed as it depends on the supported version list at deployment time.''')
output evidenceOfNonCompliance bool = (publicNetworkAccess!='Disabled') || !disableLocalAccounts || !enableRBAC || !(apiServerAccessProfile.?disableRunCommand ?? false) || !(apiServerAccessProfile.?enablePrivateCluster ?? false) || !(aadProfile.?enableAzureRBAC ?? false) || !(addonAzurePolicy.?enabled ?? false) || !(securityProfileDefender.?securityMonitoring.?enabled ?? false) || empty(diagnosticSettings[?0].?workspaceResourceId) || length(configuredRequiredLogCategoryNames)!=length(requiredLogCategoryNames) || (networkOutboundType == 'loadBalancer') || length(filter(primaryAgentPoolProfile, pool => pool.?enableNodePublicIP == true)) > 0 || length(filter(agentPools ?? [], pool => pool.?enableNodePublicIP == true)) > 0

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
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

import { agentPoolType } from 'agent-pool/main.bicep'
import { maintenanceConfigurationType } from 'maintenance-configurations/main.bicep'

// type extensionType = {
//   @description('Optional. The name of the extension.')
//   name: string?
//   @description('Optional. Namespace where the extension Release must be placed.')
//   releaseNamespace: string?
//   @description('Optional. Namespace where the extension will be created for an Namespace scoped extension.')
//   targetNamespace: string?
//   @description('Optional. The release train of the extension.')
//   releaseTrain: string?
//   @description('Optional. The configuration protected settings of the extension.')
//   configurationProtectedSettings: object?
//   @description('Optional. The configuration settings of the extension.')
//   configurationSettings: object?
//   @description('Optional. The version of the extension.')
//   version: string?
//   @description('Optional. The flux configurations of the extension.')
//   fluxConfigurations: array?
// }

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

