# Azure Kubernetes Service (AKS) Managed Cluster `[Microsoft.ContainerService/managedClusters]`

This module deploys an Azure Kubernetes Service (AKS) Managed Cluster.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Notes](#notes)
- [Data Collection](#data-collection)

## Compliance

Version: 20240829

Compliant usage of this module requires the following parameter values:

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


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.ContainerService/managedClusters` | 2024-08-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerservice_managedclusters.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerService/2024-08-01/managedClusters)</li></ul> |
| `Microsoft.ContainerService/managedClusters/maintenanceConfigurations` | 2024-08-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerservice_managedclusters_maintenanceconfigurations.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerService/2024-08-01/managedClusters/maintenanceConfigurations)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/container-service/managed-cluster:<version>`.

- [Using only required defaults](#example-1-using-only-required-defaults)
- [Private cluster with a BYO virtual network](#example-2-private-cluster-with-a-byo-virtual-network)
- [Using Azure CNI network plugin with Cilium](#example-3-using-azure-cni-network-plugin-with-cilium)
- [WAF-aligned](#example-4-waf-aligned)
- [(NOT YET WORKING) Using only defaults and use AKS Automatic mode](#example-5-not-yet-working-using-only-defaults-and-use-aks-automatic-mode)

### Example 1: _Using only required defaults_

This instance deploys the module with the minimum set of required parameters, which creates a private cluster NOT connected to a custom Virtual Network


<details>

<summary>via Bicep module</summary>

```bicep
module managedClusterMod 'br/<registry-alias>:res/container-service/managed-cluster:<version>' = {
  name: 'managedCluster-mod'
  params: {
    // Required parameters
    name: 'min001aks'
    // Non-required parameters
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-service/managed-cluster:<version>'

// Required parameters
param name = 'min001aks'
// Non-required parameters
param location = '<location>'
```

</details>
<p>

### Example 2: _Private cluster with a BYO virtual network_

This instance deploys the module with a private cluster instance, which creates a private cluster connected to a custom Virtual Network.


<details>

<summary>via Bicep module</summary>

```bicep
module managedClusterMod 'br/<registry-alias>:res/container-service/managed-cluster:<version>' = {
  name: 'managedCluster-mod'
  params: {
    // Required parameters
    name: 'privaks001aks'
    // Non-required parameters
    apiServerAccessProfile: {
      privateDNSZone: '<privateDNSZone>'
    }
    diagnosticSettings: [
      {
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    location: '<location>'
    logAnalyticsWorkspaceResourceId: '<logAnalyticsWorkspaceResourceId>'
    primaryAgentPoolSubnetResourceId: '<primaryAgentPoolSubnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-service/managed-cluster:<version>'

// Required parameters
param name = 'privaks001aks'
// Non-required parameters
param apiServerAccessProfile = {
  privateDNSZone: '<privateDNSZone>'
}
param diagnosticSettings = [
  {
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param location = '<location>'
param logAnalyticsWorkspaceResourceId = '<logAnalyticsWorkspaceResourceId>'
param primaryAgentPoolSubnetResourceId = '<primaryAgentPoolSubnetResourceId>'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 3: _Using Azure CNI network plugin with Cilium_

This instance deploys the module with Azure CNI network plugin in overlay mode, and applies Cilium data plane and network policy.


<details>

<summary>via Bicep module</summary>

```bicep
module managedClusterMod 'br/<registry-alias>:res/container-service/managed-cluster:<version>' = {
  name: 'managedCluster-mod'
  params: {
    // Required parameters
    name: 'azureaks001aks'
    // Non-required parameters
    apiServerAccessProfile: {
      privateDNSZone: '<privateDNSZone>'
    }
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    enableWorkloadIdentity: true
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    logAnalyticsWorkspaceResourceId: '<logAnalyticsWorkspaceResourceId>'
    managedIdentities: {
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    networkDataPlane: 'cilium'
    networkPlugin: 'azure'
    networkPluginMode: 'overlay'
    networkPodCidr: '<networkPodCidr>'
    networkPolicy: 'cilium'
    primaryAgentPoolProfile: [
      {
        count: 2
        enableAutoScaling: false
        enableNodePublicIP: false
        kubeletDiskType: 'OS'
        maxCount: '<maxCount>'
        maxPods: 110
        minCount: '<minCount>'
        mode: 'System'
        name: 'agentpool'
        osDiskSizeGB: 128
        osDiskType: 'Ephemeral'
        osSKU: 'AzureLinux'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        upgradeSettings: {
          maxSurge: '33%'
        }
        vmSize: 'Standard_D4ads_v5'
        vnetSubnetID: '<vnetSubnetID>'
      }
    ]
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-service/managed-cluster:<version>'

// Required parameters
param name = 'azureaks001aks'
// Non-required parameters
param apiServerAccessProfile = {
  privateDNSZone: '<privateDNSZone>'
}
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param enableWorkloadIdentity = true
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param logAnalyticsWorkspaceResourceId = '<logAnalyticsWorkspaceResourceId>'
param managedIdentities = {
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param networkDataPlane = 'cilium'
param networkPlugin = 'azure'
param networkPluginMode = 'overlay'
param networkPodCidr = '<networkPodCidr>'
param networkPolicy = 'cilium'
param primaryAgentPoolProfile = [
  {
    count: 2
    enableAutoScaling: false
    enableNodePublicIP: false
    kubeletDiskType: 'OS'
    maxCount: '<maxCount>'
    maxPods: 110
    minCount: '<minCount>'
    mode: 'System'
    name: 'agentpool'
    osDiskSizeGB: 128
    osDiskType: 'Ephemeral'
    osSKU: 'AzureLinux'
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    upgradeSettings: {
      maxSurge: '33%'
    }
    vmSize: 'Standard_D4ads_v5'
    vnetSubnetID: '<vnetSubnetID>'
  }
]
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 4: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module managedClusterMod 'br/<registry-alias>:res/container-service/managed-cluster:<version>' = {
  name: 'managedCluster-mod'
  params: {
    // Required parameters
    name: 'wafaks001aks'
    // Non-required parameters
    apiServerAccessProfile: {
      enablePrivateCluster: true
      privateDNSZone: '<privateDNSZone>'
    }
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
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
        name: 'mostLogsAndMetrics'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
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
        name: 'logsCompliance'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    location: '<location>'
    logAnalyticsWorkspaceResourceId: '<logAnalyticsWorkspaceResourceId>'
    managedIdentities: {
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    networkDataPlane: 'cilium'
    networkDnsServiceIP: '192.168.0.10'
    networkOutboundType: 'userDefinedRouting'
    networkPlugin: 'azure'
    networkPluginMode: 'overlay'
    networkPodCidr: '172.16.0.0/16'
    networkPolicy: 'cilium'
    networkServiceCidr: '192.168.0.0/16'
    primaryAgentPoolProfile: [
      {
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        count: 3
        enableAutoScaling: true
        maxCount: 4
        maxPods: 110
        minCount: 3
        mode: 'System'
        name: 'agentpool'
        osDiskSizeGB: 0
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        upgradeSettings: {
          maxSurge: '33%'
        }
        vmSize: 'Standard_D4ads_v5'
        vnetSubnetID: '<vnetSubnetID>'
      }
    ]
    roleAssignments: [
      {
        principalId: 'objectId_of_a_user_group'
        principalType: 'Group'
        roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
      }
    ]
    skuTier: 'Standard'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-service/managed-cluster:<version>'

// Required parameters
param name = 'wafaks001aks'
// Non-required parameters
param apiServerAccessProfile = {
  enablePrivateCluster: true
  privateDNSZone: '<privateDNSZone>'
}
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
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
    name: 'mostLogsAndMetrics'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
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
    name: 'logsCompliance'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param location = '<location>'
param logAnalyticsWorkspaceResourceId = '<logAnalyticsWorkspaceResourceId>'
param managedIdentities = {
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param networkDataPlane = 'cilium'
param networkDnsServiceIP = '192.168.0.10'
param networkOutboundType = 'userDefinedRouting'
param networkPlugin = 'azure'
param networkPluginMode = 'overlay'
param networkPodCidr = '172.16.0.0/16'
param networkPolicy = 'cilium'
param networkServiceCidr = '192.168.0.0/16'
param primaryAgentPoolProfile = [
  {
    availabilityZones: [
      '1'
      '2'
      '3'
    ]
    count: 3
    enableAutoScaling: true
    maxCount: 4
    maxPods: 110
    minCount: 3
    mode: 'System'
    name: 'agentpool'
    osDiskSizeGB: 0
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    upgradeSettings: {
      maxSurge: '33%'
    }
    vmSize: 'Standard_D4ads_v5'
    vnetSubnetID: '<vnetSubnetID>'
  }
]
param roleAssignments = [
  {
    principalId: 'objectId_of_a_user_group'
    principalType: 'Group'
    roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
  }
]
param skuTier = 'Standard'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 5: _(NOT YET WORKING) Using only defaults and use AKS Automatic mode_

This instance deploys the module with the set of automatic parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module managedClusterMod 'br/<registry-alias>:res/container-service/managed-cluster:<version>' = {
  name: 'managedCluster-mod'
  params: {
    // Required parameters
    name: 'auto001aks'
    // Non-required parameters
    location: '<location>'
    managedIdentities: {
      systemAssigned: true
    }
    primaryAgentPoolProfile: [
      {
        count: 3
        mode: 'System'
        name: 'systempool'
        vmSize: 'Standard_DS2_v2'
      }
    ]
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-service/managed-cluster:<version>'

// Required parameters
param name = 'auto001aks'
// Non-required parameters
param location = '<location>'
param managedIdentities = {
  systemAssigned: true
}
param primaryAgentPoolProfile = [
  {
    count: 3
    mode: 'System'
    name: 'systempool'
    vmSize: 'Standard_DS2_v2'
  }
]
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | Specifies the name of the AKS cluster. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`costAnalysisEnabled`](#parameter-costanalysisenabled) | bool | Specifies whether the cost analysis add-on is enabled or not. Default is false.<p><p>If Enabled `enableStorageProfileDiskCSIDriver` is set to true as it is needed. |
| [`logAnalyticsWorkspaceResourceId`](#parameter-loganalyticsworkspaceresourceid) | string | Resource ID of the monitoring log analytics workspace.<p>Required if: Azure Defender (securityProfile.defender), addon OmsAgent (addonProfiles.omsagent), or azureMonitor is used<p><p>Not used for: diagnostic settings.<p> |
| [`primaryAgentPoolSubnetResourceId`](#parameter-primaryagentpoolsubnetresourceid) | string | When using defaults in 'primaryAgentPoolProfile', provide here the Subnet resource ID for the primary agent pool in case of using a custom Virtual Network. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`aadProfile`](#parameter-aadprofile) | object | The Entra ID (Azure Active Directory) integration configuration.<p><p>The default is:<li>enableAzureRBAC: value of 'enableRBAC' parameter<li>managed: true<li>tenantID: subscription().tenantId<p><p>Compliant use of this resource requires certain parameter values:<li>enableAzureRBAC: true<li>managed: true<li>tenantID: current tenant<p> |
| [`addonAzureKeyvaultSecretsProvider`](#parameter-addonazurekeyvaultsecretsprovider) | object | Specifies the configuration for Azure Key Vault secrets provider add-on.<p>Default is enabled=true and config.enableSecretRotation=true. |
| [`addonAzurePolicy`](#parameter-addonazurepolicy) | object | Specifies the configuration of Azure Policy add-on.<p>Default is enabled=true and config.version=v2.<p><p>Compliant use of this resource requires 'enabled' to be true. |
| [`addonOmsAgentEnabled`](#parameter-addonomsagentenabled) | bool | Specifies whether the OMS agent is enabled. |
| [`adminUsername`](#parameter-adminusername) | string | Specifies the administrator username of Linux virtual machines. |
| [`apiServerAccessProfile`](#parameter-apiserveraccessprofile) | object | The access profile for managed cluster API server.<p>The default is:<li>disableRunCommand: true<li>enablePrivateCluster: true<li>enablePrivateClusterPublicFQDN: true<p>// - enableVnetIntegration: false<li>privateDNSZone: 'none'<p><p>Compliant use of this resource requires certain parameter values:<li>apiServerAccessProfile.disableRunCommand: true<li>apiServerAccessProfile.enablePrivateCluster: true |
| [`autoUpgradeProfile`](#parameter-autoupgradeprofile) | object | The auto upgrade configuration. By default it is set to update the node image to the stable (N-1) version. |
| [`azureMonitorProfile`](#parameter-azuremonitorprofile) | object | Configures Azure Monitor profile, including Container Insights, Prometheus and Graphana.<p><p>By default, Container Insights are enabled to the Log Analytics workspace specified in logAnalyticsWorkspaceResourceId.<p> |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service.<p><p>Compliant use of this resource requires diagnostic settings to be configured:<li>workspaceResourceId<li>logCategoriesAndGroups to include the following categories:<p>  - 'kube-audit'<p>  - 'kube-audit-admin'<p>  - 'kube-apiserver'<p>  - 'kube-controller-manager'<p>  - 'kube-scheduler'<p> |
| [`disableLocalAccounts`](#parameter-disablelocalaccounts) | bool | If set to true, getting static credentials will be disabled for this cluster.<p>This must only be used on Managed Clusters that are AAD enabled. Default: true.<p><p>Setting this parameter to 'false' will make the resource non-compliant. |
| [`dnsPrefix`](#parameter-dnsprefix) | string | Specifies the DNS prefix specified when creating the managed cluster. |
| [`enableOidcIssuerProfile`](#parameter-enableoidcissuerprofile) | bool | Whether the The OIDC issuer profile of the Managed Cluster is enabled. |
| [`enableRBAC`](#parameter-enablerbac) | bool | Whether to enable Kubernetes Role-Based Access Control. Default: true.<p><p>Setting this parameter to 'false' will make the resource non-compliant. |
| [`enableStorageProfileBlobCSIDriver`](#parameter-enablestorageprofileblobcsidriver) | bool | Whether the AzureBlob CSI Driver for the storage profile is enabled. |
| [`enableStorageProfileDiskCSIDriver`](#parameter-enablestorageprofilediskcsidriver) | bool | Whether the AzureDisk CSI Driver for the storage profile is enabled. |
| [`enableStorageProfileFileCSIDriver`](#parameter-enablestorageprofilefilecsidriver) | bool | Whether the AzureFile CSI Driver for the storage profile is enabled. |
| [`enableStorageProfileSnapshotController`](#parameter-enablestorageprofilesnapshotcontroller) | bool | Whether the snapshot controller for the storage profile is enabled. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`enableWorkloadIdentity`](#parameter-enableworkloadidentity) | bool | Whether to enable Workload Identity. Requires OIDC issuer profile to be enabled. |
| [`imageCleaner`](#parameter-imagecleaner) | object | Whether to enable Image Cleaner for Kubernetes.<p>By default it is set to 'enabled' wth 168 hours interval. |
| [`kubernetesVersion`](#parameter-kubernetesversion) | string | Version of Kubernetes specified when creating the managed cluster.<p>By default the latest LTS supported version will be used.<p><p>Setting this parameter to a version that is no longer supported by Microsoft will make the resource non-compliant. |
| [`location`](#parameter-location) | string | Specifies the location of AKS cluster. It picks up Resource Group's location by default. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`maintenanceConfigurations`](#parameter-maintenanceconfigurations) | array | Configuring AKS automatic upgrades schedules. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. Only one type of identity is supported: system-assigned or user-assigned, but not both. |
| [`networkDataPlane`](#parameter-networkdataplane) | string | Network data plane used in the Kubernetes cluster. Not compatible with 'kubenet' network plugin. |
| [`networkDnsServiceIP`](#parameter-networkdnsserviceip) | string | Specifies the IP address assigned to the Kubernetes DNS service.<p>It must be within the Kubernetes service address range specified in serviceCidr. |
| [`networkLoadBalancerProfile`](#parameter-networkloadbalancerprofile) | object | Configuration of the load balancer used by the virtual machine scale sets used by nodepools. |
| [`networkLoadBalancerSku`](#parameter-networkloadbalancersku) | string | Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools. The default is 'standard'.<p><p>See Azure Load Balancer SKUs (https://learn.microsoft.com/en-us/azure/load-balancer/skus) for more information about the differences between load balancer SKUs.<p> |
| [`networkOutboundType`](#parameter-networkoutboundtype) | string | Specifies outbound (egress) routing method. Default is 'userDefinedRouting'.<p><p>Setting this parameter to values other than 'userDefinedRouting' may make the resource non-compliant.<p><p>Setting outboundType requires AKS clusters with a vm-set-type of VirtualMachineScaleSets and load-balancer-sku of Standard.<p><p>For more information see https://learn.microsoft.com/en-us/azure/aks/egress-outboundtype<p> |
| [`networkPlugin`](#parameter-networkplugin) | string | Specifies the network plugin used for building Kubernetes network. Default: azure |
| [`networkPluginMode`](#parameter-networkpluginmode) | string | Mode of Azure CNI network plugin for building the Kubernetes network. Default: 'overlay'.<p><p>Not used for 'kubenet' network plugin.<p><p>See https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview for more information. |
| [`networkPodCidr`](#parameter-networkpodcidr) | string | Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used. |
| [`networkPolicy`](#parameter-networkpolicy) | string | Specifies the network policy used for building Kubernetes network. Default: none. |
| [`networkServiceCidr`](#parameter-networkservicecidr) | string | A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges. |
| [`nodeResourceGroup`](#parameter-noderesourcegroup) | string | Name of the resource group containing agent pool nodes. |
| [`primaryAgentPoolProfile`](#parameter-primaryagentpoolprofile) | array | Properties of the primary agent pool. |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Allow or deny public network access for AKS. Default: Disabled.<p><p>Setting this parameter to any value other than 'Disabled' will make the resource non-compliant. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`securityProfileAzureKeyVaultKms`](#parameter-securityprofileazurekeyvaultkms) | object | Azure Key Vault key management service settings for the security profile. |
| [`securityProfileDefender`](#parameter-securityprofiledefender) | object | Azure Defender profile settings. By default the securityMonitoring.enabled is true<p><p>Setting securityMonitoring.enabled to a value other than 'true' will make this resource non-compliant. |
| [`skuName`](#parameter-skuname) | string | The name of a managed cluster SKU. |
| [`skuTier`](#parameter-skutier) | string | Tier of a managed cluster SKU. |
| [`sshPublicKey`](#parameter-sshpublickey) | string | Specifies the SSH RSA public key string for the Linux nodes. |
| [`supportPlan`](#parameter-supportplan) | string | The support plan for the Managed Cluster. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |

### Parameter: `name`

Specifies the name of the AKS cluster.

- Required: Yes
- Type: string

### Parameter: `costAnalysisEnabled`

Specifies whether the cost analysis add-on is enabled or not. Default is false.<p><p>If Enabled `enableStorageProfileDiskCSIDriver` is set to true as it is needed.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `logAnalyticsWorkspaceResourceId`

Resource ID of the monitoring log analytics workspace.<p>Required if: Azure Defender (securityProfile.defender), addon OmsAgent (addonProfiles.omsagent), or azureMonitor is used<p><p>Not used for: diagnostic settings.<p>

- Required: No
- Type: string

### Parameter: `primaryAgentPoolSubnetResourceId`

When using defaults in 'primaryAgentPoolProfile', provide here the Subnet resource ID for the primary agent pool in case of using a custom Virtual Network.

- Required: No
- Type: string

### Parameter: `aadProfile`

The Entra ID (Azure Active Directory) integration configuration.<p><p>The default is:<li>enableAzureRBAC: value of 'enableRBAC' parameter<li>managed: true<li>tenantID: subscription().tenantId<p><p>Compliant use of this resource requires certain parameter values:<li>enableAzureRBAC: true<li>managed: true<li>tenantID: current tenant<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      enableAzureRBAC: '[parameters(\'enableRBAC\')]'
      managed: true
      tenantID: '[subscription().tenantId]'
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`adminGroupObjectIDs`](#parameter-aadprofileadmingroupobjectids) | array | The list of AAD group object IDs that will have admin role of the cluster. Default: empty. |
| [`enableAzureRBAC`](#parameter-aadprofileenableazurerbac) | bool | Specifies whether to enable Azure RBAC for Kubernetes authorization. Default: true. |
| [`managed`](#parameter-aadprofilemanaged) | bool | Specifies whether to enable managed AAD integration. Default: true. |
| [`tenantID`](#parameter-aadprofiletenantid) | string | Specifies the tenant ID of the Azure Active Directory used by the AKS cluster for authentication.<p>If not specified, will use the tenant of the deployment subscription. |

### Parameter: `aadProfile.adminGroupObjectIDs`

The list of AAD group object IDs that will have admin role of the cluster. Default: empty.

- Required: No
- Type: array

### Parameter: `aadProfile.enableAzureRBAC`

Specifies whether to enable Azure RBAC for Kubernetes authorization. Default: true.

- Required: No
- Type: bool

### Parameter: `aadProfile.managed`

Specifies whether to enable managed AAD integration. Default: true.

- Required: No
- Type: bool

### Parameter: `aadProfile.tenantID`

Specifies the tenant ID of the Azure Active Directory used by the AKS cluster for authentication.<p>If not specified, will use the tenant of the deployment subscription.

- Required: No
- Type: string

### Parameter: `addonAzureKeyvaultSecretsProvider`

Specifies the configuration for Azure Key Vault secrets provider add-on.<p>Default is enabled=true and config.enableSecretRotation=true.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      config: {
        enableSecretRotation: 'true'
      }
      enabled: true
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-addonazurekeyvaultsecretsproviderenabled) | bool | Should this add-on be enabled? |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`config`](#parameter-addonazurekeyvaultsecretsproviderconfig) | object | Configuration of the add-on. |

### Parameter: `addonAzureKeyvaultSecretsProvider.enabled`

Should this add-on be enabled?

- Required: Yes
- Type: bool

### Parameter: `addonAzureKeyvaultSecretsProvider.config`

Configuration of the add-on.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableSecretRotation`](#parameter-addonazurekeyvaultsecretsproviderconfigenablesecretrotation) | string | Whether to enable rotation of secrets. |

### Parameter: `addonAzureKeyvaultSecretsProvider.config.enableSecretRotation`

Whether to enable rotation of secrets.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'false'
    'true'
  ]
  ```

### Parameter: `addonAzurePolicy`

Specifies the configuration of Azure Policy add-on.<p>Default is enabled=true and config.version=v2.<p><p>Compliant use of this resource requires 'enabled' to be true.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      config: {
        version: 'v2'
      }
      enabled: true
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-addonazurepolicyenabled) | bool | Should this add-on be enabled? |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`config`](#parameter-addonazurepolicyconfig) | object | Configuration of the add-on. |

### Parameter: `addonAzurePolicy.enabled`

Should this add-on be enabled?

- Required: Yes
- Type: bool

### Parameter: `addonAzurePolicy.config`

Configuration of the add-on.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`version`](#parameter-addonazurepolicyconfigversion) | string | Version of the policy. Default: v2 |

### Parameter: `addonAzurePolicy.config.version`

Version of the policy. Default: v2

- Required: No
- Type: string

### Parameter: `addonOmsAgentEnabled`

Specifies whether the OMS agent is enabled.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `adminUsername`

Specifies the administrator username of Linux virtual machines.

- Required: No
- Type: string
- Default: `'azureuser'`

### Parameter: `apiServerAccessProfile`

The access profile for managed cluster API server.<p>The default is:<li>disableRunCommand: true<li>enablePrivateCluster: true<li>enablePrivateClusterPublicFQDN: true<p>// - enableVnetIntegration: false<li>privateDNSZone: 'none'<p><p>Compliant use of this resource requires certain parameter values:<li>apiServerAccessProfile.disableRunCommand: true<li>apiServerAccessProfile.enablePrivateCluster: true

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      disableRunCommand: true
      enablePrivateCluster: true
      enablePrivateClusterPublicFQDN: true
      privateDNSZone: 'none'
  }
  ```

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnetId`](#parameter-apiserveraccessprofilesubnetid) | string | Resource ID of the subnet.<p>It is required when: 1. creating a new cluster with BYO Vnet; 2. updating an existing cluster to enable apiserver vnet integration. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authorizedIPRanges`](#parameter-apiserveraccessprofileauthorizedipranges) | array | IP ranges are specified in CIDR format, e.g. 137.117.106.88/29.<p>This feature is not compatible with clusters that use Public IP Per Node, or clusters that are using a Basic Load Balancer.<p>For more information see [API server authorized IP ranges](https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges).<p>Default: empty.<p> |
| [`disableRunCommand`](#parameter-apiserveraccessprofiledisableruncommand) | bool | Whether to disable run command for the cluster or not. Default: true |
| [`enablePrivateCluster`](#parameter-apiserveraccessprofileenableprivatecluster) | bool | For more details, see [Creating a private AKS cluster](https://docs.microsoft.com/azure/aks/private-clusters). Default: true |
| [`enablePrivateClusterPublicFQDN`](#parameter-apiserveraccessprofileenableprivateclusterpublicfqdn) | bool | Whether to create additional public FQDN for private cluster or not. Default: false |
| [`privateDNSZone`](#parameter-apiserveraccessprofileprivatednszone) | string | Allowed values are 'system', 'none', or a resourceId of the private DNS Zone. The default is 'none'.<p><p>For more details see [configure private DNS zone](https://docs.microsoft.com/azure/aks/private-clusters#configure-private-dns-zone).<p> |

### Parameter: `apiServerAccessProfile.subnetId`

Resource ID of the subnet.<p>It is required when: 1. creating a new cluster with BYO Vnet; 2. updating an existing cluster to enable apiserver vnet integration.

- Required: No
- Type: string

### Parameter: `apiServerAccessProfile.authorizedIPRanges`

IP ranges are specified in CIDR format, e.g. 137.117.106.88/29.<p>This feature is not compatible with clusters that use Public IP Per Node, or clusters that are using a Basic Load Balancer.<p>For more information see [API server authorized IP ranges](https://docs.microsoft.com/azure/aks/api-server-authorized-ip-ranges).<p>Default: empty.<p>

- Required: No
- Type: array

### Parameter: `apiServerAccessProfile.disableRunCommand`

Whether to disable run command for the cluster or not. Default: true

- Required: No
- Type: bool

### Parameter: `apiServerAccessProfile.enablePrivateCluster`

For more details, see [Creating a private AKS cluster](https://docs.microsoft.com/azure/aks/private-clusters). Default: true

- Required: No
- Type: bool

### Parameter: `apiServerAccessProfile.enablePrivateClusterPublicFQDN`

Whether to create additional public FQDN for private cluster or not. Default: false

- Required: No
- Type: bool

### Parameter: `apiServerAccessProfile.privateDNSZone`

Allowed values are 'system', 'none', or a resourceId of the private DNS Zone. The default is 'none'.<p><p>For more details see [configure private DNS zone](https://docs.microsoft.com/azure/aks/private-clusters#configure-private-dns-zone).<p>

- Required: No
- Type: string

### Parameter: `autoUpgradeProfile`

The auto upgrade configuration. By default it is set to update the node image to the stable (N-1) version.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      nodeOSUpgradeChannel: 'NodeImage'
      upgradeChannel: 'stable'
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`nodeOSUpgradeChannel`](#parameter-autoupgradeprofilenodeosupgradechannel) | string | For more information see setting the AKS cluster auto-upgrade channel<p>see https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster#set-auto-upgrade-channel. |
| [`upgradeChannel`](#parameter-autoupgradeprofileupgradechannel) | string | The default is Unmanaged, but may change to either NodeImage or SecurityPatch at GA.<p>See https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster?tabs=azure-cli |

### Parameter: `autoUpgradeProfile.nodeOSUpgradeChannel`

For more information see setting the AKS cluster auto-upgrade channel<p>see https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster#set-auto-upgrade-channel.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'NodeImage'
    'None'
    'SecurityPatch'
    'Unmanaged'
  ]
  ```

### Parameter: `autoUpgradeProfile.upgradeChannel`

The default is Unmanaged, but may change to either NodeImage or SecurityPatch at GA.<p>See https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster?tabs=azure-cli

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'node-image'
    'none'
    'patch'
    'rapid'
    'stable'
  ]
  ```

### Parameter: `azureMonitorProfile`

Configures Azure Monitor profile, including Container Insights, Prometheus and Graphana.<p><p>By default, Container Insights are enabled to the Log Analytics workspace specified in logAnalyticsWorkspaceResourceId.<p>

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      containerInsights: {
        enabled: true
        logAnalyticsWorkspaceResourceId: '[parameters(\'logAnalyticsWorkspaceResourceId\')]'
      }
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`appMonitoring`](#parameter-azuremonitorprofileappmonitoring) | object | Application Monitoring Profile for Kubernetes Application Container. Collects application logs,<p>metrics and traces through auto-instrumentation of the application using Azure Monitor OpenTelemetry based SDKs.<p>See aka.ms/AzureMonitorApplicationMonitoring for an overview. |
| [`containerInsights`](#parameter-azuremonitorprofilecontainerinsights) | object | Azure Monitor Container Insights Profile for Kubernetes Events, Inventory and Container stdout & stderr logs etc.<p>See aka.ms/AzureMonitorContainerInsights for an overview. |
| [`metrics`](#parameter-azuremonitorprofilemetrics) | object | Metrics profile for the prometheus service addon |

### Parameter: `azureMonitorProfile.appMonitoring`

Application Monitoring Profile for Kubernetes Application Container. Collects application logs,<p>metrics and traces through auto-instrumentation of the application using Azure Monitor OpenTelemetry based SDKs.<p>See aka.ms/AzureMonitorApplicationMonitoring for an overview.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoInstrumentation`](#parameter-azuremonitorprofileappmonitoringautoinstrumentation) | object | Application Monitoring Auto Instrumentation for Kubernetes Application Container.<p>Deploys web hook to auto-instrument Azure Monitor OpenTelemetry based SDKs to collect OpenTelemetry metrics,<p>logs and traces of the application. See aka.ms/AzureMonitorApplicationMonitoring for an overview. |
| [`openTelemetryLogs`](#parameter-azuremonitorprofileappmonitoringopentelemetrylogs) | object | Application Monitoring Open Telemetry Metrics Profile for Kubernetes Application Container Logs and Traces.<p>Collects OpenTelemetry logs and traces of the application using Azure Monitor OpenTelemetry based SDKs. See aka.ms/AzureMonitorApplicationMonitoring for an overview. |
| [`openTelemetryMetrics`](#parameter-azuremonitorprofileappmonitoringopentelemetrymetrics) | object | Application Monitoring Open Telemetry Metrics Profile for Kubernetes Application Container Metrics.<p>Collects OpenTelemetry metrics of the application using Azure Monitor OpenTelemetry based SDKs. See aka.ms/AzureMonitorApplicationMonitoring for an overview. |

### Parameter: `azureMonitorProfile.appMonitoring.autoInstrumentation`

Application Monitoring Auto Instrumentation for Kubernetes Application Container.<p>Deploys web hook to auto-instrument Azure Monitor OpenTelemetry based SDKs to collect OpenTelemetry metrics,<p>logs and traces of the application. See aka.ms/AzureMonitorApplicationMonitoring for an overview.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-azuremonitorprofileappmonitoringautoinstrumentationenabled) | bool | Indicates if Application Monitoring Auto Instrumentation is enabled or not. |

### Parameter: `azureMonitorProfile.appMonitoring.autoInstrumentation.enabled`

Indicates if Application Monitoring Auto Instrumentation is enabled or not.

- Required: Yes
- Type: bool

### Parameter: `azureMonitorProfile.appMonitoring.openTelemetryLogs`

Application Monitoring Open Telemetry Metrics Profile for Kubernetes Application Container Logs and Traces.<p>Collects OpenTelemetry logs and traces of the application using Azure Monitor OpenTelemetry based SDKs. See aka.ms/AzureMonitorApplicationMonitoring for an overview.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-azuremonitorprofileappmonitoringopentelemetrylogsenabled) | bool | Indicates if Application Monitoring Open Telemetry Logs and traces is enabled or not. |
| [`port`](#parameter-azuremonitorprofileappmonitoringopentelemetrylogsport) | int | The Open Telemetry host port for Open Telemetry logs and traces. If not specified, the default port is 28331. |

### Parameter: `azureMonitorProfile.appMonitoring.openTelemetryLogs.enabled`

Indicates if Application Monitoring Open Telemetry Logs and traces is enabled or not.

- Required: Yes
- Type: bool

### Parameter: `azureMonitorProfile.appMonitoring.openTelemetryLogs.port`

The Open Telemetry host port for Open Telemetry logs and traces. If not specified, the default port is 28331.

- Required: No
- Type: int

### Parameter: `azureMonitorProfile.appMonitoring.openTelemetryMetrics`

Application Monitoring Open Telemetry Metrics Profile for Kubernetes Application Container Metrics.<p>Collects OpenTelemetry metrics of the application using Azure Monitor OpenTelemetry based SDKs. See aka.ms/AzureMonitorApplicationMonitoring for an overview.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-azuremonitorprofileappmonitoringopentelemetrymetricsenabled) | bool | Indicates if Application Monitoring Open Telemetry Metrics is enabled or not. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`port`](#parameter-azuremonitorprofileappmonitoringopentelemetrymetricsport) | int | The Open Telemetry host port for Open Telemetry metrics. If not specified, the default port is 28333. |

### Parameter: `azureMonitorProfile.appMonitoring.openTelemetryMetrics.enabled`

Indicates if Application Monitoring Open Telemetry Metrics is enabled or not.

- Required: Yes
- Type: bool

### Parameter: `azureMonitorProfile.appMonitoring.openTelemetryMetrics.port`

The Open Telemetry host port for Open Telemetry metrics. If not specified, the default port is 28333.

- Required: No
- Type: int

### Parameter: `azureMonitorProfile.containerInsights`

Azure Monitor Container Insights Profile for Kubernetes Events, Inventory and Container stdout & stderr logs etc.<p>See aka.ms/AzureMonitorContainerInsights for an overview.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-azuremonitorprofilecontainerinsightsenabled) | bool | Indicates if Azure Monitor Container Insights Logs Addon is enabled or not. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`disableCustomMetrics`](#parameter-azuremonitorprofilecontainerinsightsdisablecustommetrics) | bool | Indicates whether custom metrics collection has to be disabled or not. If not specified the default is false.<p>No custom metrics will be emitted if this field is false but the container insights enabled field is false |
| [`disablePrometheusMetricsScraping`](#parameter-azuremonitorprofilecontainerinsightsdisableprometheusmetricsscraping) | bool | Indicates whether prometheus metrics scraping is disabled or not. If not specified the default is false.<p>No prometheus metrics will be emitted if this field is false but the container insights enabled field is false |
| [`logAnalyticsWorkspaceResourceId`](#parameter-azuremonitorprofilecontainerinsightsloganalyticsworkspaceresourceid) | string | Fully Qualified ARM Resource Id of Azure Log Analytics Workspace for storing Azure Monitor Container Insights Logs. |
| [`syslogPort`](#parameter-azuremonitorprofilecontainerinsightssyslogport) | int | The syslog host port. If not specified, the default port is 28330. |

### Parameter: `azureMonitorProfile.containerInsights.enabled`

Indicates if Azure Monitor Container Insights Logs Addon is enabled or not.

- Required: Yes
- Type: bool

### Parameter: `azureMonitorProfile.containerInsights.disableCustomMetrics`

Indicates whether custom metrics collection has to be disabled or not. If not specified the default is false.<p>No custom metrics will be emitted if this field is false but the container insights enabled field is false

- Required: No
- Type: bool

### Parameter: `azureMonitorProfile.containerInsights.disablePrometheusMetricsScraping`

Indicates whether prometheus metrics scraping is disabled or not. If not specified the default is false.<p>No prometheus metrics will be emitted if this field is false but the container insights enabled field is false

- Required: No
- Type: bool

### Parameter: `azureMonitorProfile.containerInsights.logAnalyticsWorkspaceResourceId`

Fully Qualified ARM Resource Id of Azure Log Analytics Workspace for storing Azure Monitor Container Insights Logs.

- Required: No
- Type: string

### Parameter: `azureMonitorProfile.containerInsights.syslogPort`

The syslog host port. If not specified, the default port is 28330.

- Required: No
- Type: int

### Parameter: `azureMonitorProfile.metrics`

Metrics profile for the prometheus service addon

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-azuremonitorprofilemetricsenabled) | bool | Whether to enable the Prometheus collector |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kubeStateMetrics`](#parameter-azuremonitorprofilemetricskubestatemetrics) | object | Kube State Metrics for prometheus addon profile for the container service cluster |

### Parameter: `azureMonitorProfile.metrics.enabled`

Whether to enable the Prometheus collector

- Required: Yes
- Type: bool

### Parameter: `azureMonitorProfile.metrics.kubeStateMetrics`

Kube State Metrics for prometheus addon profile for the container service cluster

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`metricAnnotationsAllowList`](#parameter-azuremonitorprofilemetricskubestatemetricsmetricannotationsallowlist) | string | Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric. |
| [`metricLabelsAllowlist`](#parameter-azuremonitorprofilemetricskubestatemetricsmetriclabelsallowlist) | string | Comma-separated list of Kubernetes annotations keys that will be used in the resource's labels metric. |

### Parameter: `azureMonitorProfile.metrics.kubeStateMetrics.metricAnnotationsAllowList`

Comma-separated list of additional Kubernetes label keys that will be used in the resource's labels metric.

- Required: Yes
- Type: string

### Parameter: `azureMonitorProfile.metrics.kubeStateMetrics.metricLabelsAllowlist`

Comma-separated list of Kubernetes annotations keys that will be used in the resource's labels metric.

- Required: Yes
- Type: string

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.<p><p>Compliant use of this resource requires diagnostic settings to be configured:<li>workspaceResourceId<li>logCategoriesAndGroups to include the following categories:<p>  - 'kube-audit'<p>  - 'kube-audit-admin'<p>  - 'kube-apiserver'<p>  - 'kube-controller-manager'<p>  - 'kube-scheduler'<p>

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`eventHubAuthorizationRuleResourceId`](#parameter-diagnosticsettingseventhubauthorizationruleresourceid) | string | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| [`eventHubName`](#parameter-diagnosticsettingseventhubname) | string | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`logAnalyticsDestinationType`](#parameter-diagnosticsettingsloganalyticsdestinationtype) | string | A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type. |
| [`logCategoriesAndGroups`](#parameter-diagnosticsettingslogcategoriesandgroups) | array | The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection. |
| [`marketplacePartnerResourceId`](#parameter-diagnosticsettingsmarketplacepartnerresourceid) | string | The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. |
| [`metricCategories`](#parameter-diagnosticsettingsmetriccategories) | array | The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection. |
| [`name`](#parameter-diagnosticsettingsname) | string | The name of diagnostic setting. |
| [`storageAccountResourceId`](#parameter-diagnosticsettingsstorageaccountresourceid) | string | Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`workspaceResourceId`](#parameter-diagnosticsettingsworkspaceresourceid) | string | Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |

### Parameter: `diagnosticSettings.eventHubAuthorizationRuleResourceId`

Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.eventHubName`

Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logAnalyticsDestinationType`

A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureDiagnostics'
    'Dedicated'
  ]
  ```

### Parameter: `diagnosticSettings.logCategoriesAndGroups`

The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingslogcategoriesandgroupscategory) | string | Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here. |
| [`categoryGroup`](#parameter-diagnosticsettingslogcategoriesandgroupscategorygroup) | string | Name of a Diagnostic Log category group for a resource type this setting is applied to. |
| [`enabled`](#parameter-diagnosticsettingslogcategoriesandgroupsenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.logCategoriesAndGroups.category`

Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.categoryGroup`

Name of a Diagnostic Log category group for a resource type this setting is applied to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.marketplacePartnerResourceId`

The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.metricCategories`

The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingsmetriccategoriescategory) | string | Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-diagnosticsettingsmetriccategoriesenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.metricCategories.category`

Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.

- Required: Yes
- Type: string

### Parameter: `diagnosticSettings.metricCategories.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.name`

The name of diagnostic setting.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.storageAccountResourceId`

Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.workspaceResourceId`

Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `disableLocalAccounts`

If set to true, getting static credentials will be disabled for this cluster.<p>This must only be used on Managed Clusters that are AAD enabled. Default: true.<p><p>Setting this parameter to 'false' will make the resource non-compliant.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `dnsPrefix`

Specifies the DNS prefix specified when creating the managed cluster.

- Required: No
- Type: string
- Default: `[parameters('name')]`

### Parameter: `enableOidcIssuerProfile`

Whether the The OIDC issuer profile of the Managed Cluster is enabled.

- Required: No
- Type: bool
- Default: `[parameters('enableWorkloadIdentity')]`

### Parameter: `enableRBAC`

Whether to enable Kubernetes Role-Based Access Control. Default: true.<p><p>Setting this parameter to 'false' will make the resource non-compliant.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableStorageProfileBlobCSIDriver`

Whether the AzureBlob CSI Driver for the storage profile is enabled.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableStorageProfileDiskCSIDriver`

Whether the AzureDisk CSI Driver for the storage profile is enabled.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableStorageProfileFileCSIDriver`

Whether the AzureFile CSI Driver for the storage profile is enabled.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableStorageProfileSnapshotController`

Whether the snapshot controller for the storage profile is enabled.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableWorkloadIdentity`

Whether to enable Workload Identity. Requires OIDC issuer profile to be enabled.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `imageCleaner`

Whether to enable Image Cleaner for Kubernetes.<p>By default it is set to 'enabled' wth 168 hours interval.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      enabled: true
      intervalHours: 168
  }
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-imagecleanerenabled) | bool | Whether to enable Image Cleaner on AKS cluster. |
| [`intervalHours`](#parameter-imagecleanerintervalhours) | int | Image Cleaner scanning interval in hours.  The maximum value is equivalent to three months. |

### Parameter: `imageCleaner.enabled`

Whether to enable Image Cleaner on AKS cluster.

- Required: Yes
- Type: bool

### Parameter: `imageCleaner.intervalHours`

Image Cleaner scanning interval in hours.  The maximum value is equivalent to three months.

- Required: Yes
- Type: int
- MinValue: 24
- MaxValue: 2160

### Parameter: `kubernetesVersion`

Version of Kubernetes specified when creating the managed cluster.<p>By default the latest LTS supported version will be used.<p><p>Setting this parameter to a version that is no longer supported by Microsoft will make the resource non-compliant.

- Required: No
- Type: string

### Parameter: `location`

Specifies the location of AKS cluster. It picks up Resource Group's location by default.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `maintenanceConfigurations`

Configuring AKS automatic upgrades schedules.

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    {
      maintenanceConfiguration: {
        maintenanceWindow: {
          durationHours: 4
          schedule: {
            weekly: {
              dayOfWeek: 'Sunday'
              intervalWeeks: 1
            }
          }
          startTime: '01:00'
          utcOffset: '+01:00'
        }
      }
      name: 'aksManagedAutoUpgradeSchedule'
    }
    {
      maintenanceConfiguration: {
        maintenanceWindow: {
          durationHours: 4
          schedule: {
            daily: {
              intervalDays: 1
            }
          }
          startTime: '04:00'
          utcOffset: '+01:00'
        }
      }
      name: 'aksManagedNodeOSUpgradeSchedule'
    }
  ]
  ```

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`maintenanceConfiguration`](#parameter-maintenanceconfigurationsmaintenanceconfiguration) | object | Configuration parameters. |
| [`name`](#parameter-maintenanceconfigurationsname) | string | Type of maintenance configuration - Cluster-level or Node-level. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration`

Configuration parameters.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`maintenanceWindow`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindow) | object | Maintenance window for the maintenance configuration. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`notAllowedTime`](#parameter-maintenanceconfigurationsmaintenanceconfigurationnotallowedtime) | array | Time slots on which upgrade is not allowed. |
| [`timeInWeek`](#parameter-maintenanceconfigurationsmaintenanceconfigurationtimeinweek) | array | If two array entries specify the same day of the week, the applied configuration is the union of times in both entries. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow`

Maintenance window for the maintenance configuration.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`durationHours`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowdurationhours) | int | Length of maintenance window range from 4 to 24 hours. |
| [`schedule`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowschedule) | object | Recurrence schedule for the maintenance window. |
| [`startTime`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowstarttime) | string | The start time of the maintenance window. Accepted values are from '00:00' to '23:59'.<p>'utcOffset' applies to this field. For example: '02:00' with 'utcOffset: +02:00' means UTC time '00:00'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`notAllowedDates`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindownotalloweddates) | array | Date ranges on which upgrade is not allowed. 'utcOffset' applies to this field.<p>For example, with 'utcOffset: +02:00' and 'dateSpan' being '2022-12-23' to '2023-01-03',<p>maintenance will be blocked from '2022-12-22 22:00' to '2023-01-03 22:00' in UTC time. |
| [`startDate`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowstartdate) | string | The date the maintenance window activates.<p>If the current date is before this date, the maintenance window is inactive and will not be used for upgrades.<p>If not specified, the maintenance window will be active right away. |
| [`utcOffset`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowutcoffset) | string | The UTC offset in format +/-HH:mm. For example, '+05:30' for IST and '-07:00' for PST.<p>If not specified, the default is '+00:00'. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.durationHours`

Length of maintenance window range from 4 to 24 hours.

- Required: Yes
- Type: int
- MinValue: 4
- MaxValue: 24

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule`

Recurrence schedule for the maintenance window.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`absoluteMonthly`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduleabsolutemonthly) | object | For schedules like: 'recur every month on the 15th' or 'recur every 3 months on the 20th'. |
| [`daily`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduledaily) | object | For schedules like: 'recur every day' or 'recur every 3 days'. |
| [`relativeMonthly`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowschedulerelativemonthly) | object | For schedules like: 'recur every month on the first Monday' or 'recur every 3 months on last Friday'. |
| [`weekly`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduleweekly) | object | For schedules like: 'recur every Monday' or 'recur every 3 weeks on Wednesday'. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.absoluteMonthly`

For schedules like: 'recur every month on the 15th' or 'recur every 3 months on the 20th'.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`dayOfMonth`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduleabsolutemonthlydayofmonth) | int | The date of the month. |
| [`intervalMonths`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduleabsolutemonthlyintervalmonths) | int | Specifies the number of months between each set of occurrences. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.absoluteMonthly.dayOfMonth`

The date of the month.

- Required: Yes
- Type: int
- MinValue: 1
- MaxValue: 31

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.absoluteMonthly.intervalMonths`

Specifies the number of months between each set of occurrences.

- Required: Yes
- Type: int
- MinValue: 1
- MaxValue: 6

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.daily`

For schedules like: 'recur every day' or 'recur every 3 days'.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`intervalDays`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduledailyintervaldays) | int | Specifies the number of days between each set of occurrences. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.daily.intervalDays`

Specifies the number of days between each set of occurrences.

- Required: Yes
- Type: int
- MinValue: 1
- MaxValue: 7

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.relativeMonthly`

For schedules like: 'recur every month on the first Monday' or 'recur every 3 months on last Friday'.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`dayOfWeek`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowschedulerelativemonthlydayofweek) | string | Specifies on which day of the week the maintenance occurs. |
| [`intervalMonths`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowschedulerelativemonthlyintervalmonths) | int | Specifies the number of months between each set of occurrences. |
| [`weekIndex`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowschedulerelativemonthlyweekindex) | string | Specifies on which instance of the allowed days specified in daysOfWeek the maintenance occurs. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.relativeMonthly.dayOfWeek`

Specifies on which day of the week the maintenance occurs.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Friday'
    'Monday'
    'Saturday'
    'Sunday'
    'Thursday'
    'Tuesday'
    'Wednesday'
  ]
  ```

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.relativeMonthly.intervalMonths`

Specifies the number of months between each set of occurrences.

- Required: Yes
- Type: int
- MinValue: 1
- MaxValue: 6

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.relativeMonthly.weekIndex`

Specifies on which instance of the allowed days specified in daysOfWeek the maintenance occurs.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'First'
    'Fourth'
    'Last'
    'Second'
    'Third'
  ]
  ```

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.weekly`

For schedules like: 'recur every Monday' or 'recur every 3 weeks on Wednesday'.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`dayOfWeek`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduleweeklydayofweek) | string | Specifies on which day of the week the maintenance occurs. |
| [`intervalWeeks`](#parameter-maintenanceconfigurationsmaintenanceconfigurationmaintenancewindowscheduleweeklyintervalweeks) | int | Specifies the number of weeks between each set of occurrences. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.weekly.dayOfWeek`

Specifies on which day of the week the maintenance occurs.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Friday'
    'Monday'
    'Saturday'
    'Sunday'
    'Thursday'
    'Tuesday'
    'Wednesday'
  ]
  ```

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.schedule.weekly.intervalWeeks`

Specifies the number of weeks between each set of occurrences.

- Required: Yes
- Type: int
- MinValue: 1
- MaxValue: 4

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.startTime`

The start time of the maintenance window. Accepted values are from '00:00' to '23:59'.<p>'utcOffset' applies to this field. For example: '02:00' with 'utcOffset: +02:00' means UTC time '00:00'.

- Required: Yes
- Type: string

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.notAllowedDates`

Date ranges on which upgrade is not allowed. 'utcOffset' applies to this field.<p>For example, with 'utcOffset: +02:00' and 'dateSpan' being '2022-12-23' to '2023-01-03',<p>maintenance will be blocked from '2022-12-22 22:00' to '2023-01-03 22:00' in UTC time.

- Required: No
- Type: array

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.startDate`

The date the maintenance window activates.<p>If the current date is before this date, the maintenance window is inactive and will not be used for upgrades.<p>If not specified, the maintenance window will be active right away.

- Required: No
- Type: string

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.maintenanceWindow.utcOffset`

The UTC offset in format +/-HH:mm. For example, '+05:30' for IST and '-07:00' for PST.<p>If not specified, the default is '+00:00'.

- Required: No
- Type: string

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.notAllowedTime`

Time slots on which upgrade is not allowed.

- Required: No
- Type: array
- Allowed:
  ```Bicep
  [
    {
      end: 'string'
      start: 'string'
    }
  ]
  ```

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.timeInWeek`

If two array entries specify the same day of the week, the applied configuration is the union of times in both entries.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`day`](#parameter-maintenanceconfigurationsmaintenanceconfigurationtimeinweekday) | string | The day of the week. |
| [`hourSlots`](#parameter-maintenanceconfigurationsmaintenanceconfigurationtimeinweekhourslots) | array | Each integer hour represents a time range beginning at 0m after the hour ending at the next hour (non-inclusive).<p>0 corresponds to 00:00 UTC, 23 corresponds to 23:00 UTC. Specifying [0, 1] means the 00:00 - 02:00 UTC time range. |

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.timeInWeek.day`

The day of the week.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Friday'
    'Monday'
    'Saturday'
    'Sunday'
    'Thursday'
    'Tuesday'
    'Wednesday'
  ]
  ```

### Parameter: `maintenanceConfigurations.maintenanceConfiguration.timeInWeek.hourSlots`

Each integer hour represents a time range beginning at 0m after the hour ending at the next hour (non-inclusive).<p>0 corresponds to 00:00 UTC, 23 corresponds to 23:00 UTC. Specifying [0, 1] means the 00:00 - 02:00 UTC time range.

- Required: Yes
- Type: array

### Parameter: `maintenanceConfigurations.name`

Type of maintenance configuration - Cluster-level or Node-level.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'aksManagedAutoUpgradeSchedule'
    'aksManagedNodeOSUpgradeSchedule'
  ]
  ```

### Parameter: `managedIdentities`

The managed identity definition for this resource. Only one type of identity is supported: system-assigned or user-assigned, but not both.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      systemAssigned: true
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`systemAssigned`](#parameter-managedidentitiessystemassigned) | bool | Enables system assigned managed identity on the resource. |
| [`userAssignedResourceIds`](#parameter-managedidentitiesuserassignedresourceids) | array | The resource ID(s) to assign to the resource. |

### Parameter: `managedIdentities.systemAssigned`

Enables system assigned managed identity on the resource.

- Required: No
- Type: bool

### Parameter: `managedIdentities.userAssignedResourceIds`

The resource ID(s) to assign to the resource.

- Required: No
- Type: array

### Parameter: `networkDataPlane`

Network data plane used in the Kubernetes cluster. Not compatible with 'kubenet' network plugin.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'azure'
    'cilium'
  ]
  ```

### Parameter: `networkDnsServiceIP`

Specifies the IP address assigned to the Kubernetes DNS service.<p>It must be within the Kubernetes service address range specified in serviceCidr.

- Required: No
- Type: string

### Parameter: `networkLoadBalancerProfile`

Configuration of the load balancer used by the virtual machine scale sets used by nodepools.

- Required: No
- Type: object
- Default: `[if(equals(parameters('networkOutboundType'), 'loadBalancer'), createObject('allocatedOutboundPorts', 0, 'backendPoolType', 'NodeIPConfiguration', 'clusterServiceLoadBalancerHealthProbeMode', 'ServiceNodePort', 'idleTimeoutInMinutes', 4), createObject())]`

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`allocatedOutboundPorts`](#parameter-networkloadbalancerprofileallocatedoutboundports) | int | The desired number of allocated SNAT ports per VM. Allowed values are in the range of 0 to 64000 (inclusive).<p>The default value is 0 which results in Azure dynamically allocating ports. |
| [`backendPoolType`](#parameter-networkloadbalancerprofilebackendpooltype) | string | The type of the managed inbound Load Balancer BackendPool. The default is 'NodeIPConfiguration' |
| [`clusterServiceLoadBalancerHealthProbeMode`](#parameter-networkloadbalancerprofileclusterserviceloadbalancerhealthprobemode) | string | The health probing behavior for External Traffic Policy Cluster services. |
| [`enableMultipleStandardLoadBalancers`](#parameter-networkloadbalancerprofileenablemultiplestandardloadbalancers) | bool | Enable multiple standard load balancers per AKS cluster or not. |
| [`idleTimeoutInMinutes`](#parameter-networkloadbalancerprofileidletimeoutinminutes) | int | Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive).<p>The default value is 4 minutes. |
| [`managedOutboundIPs`](#parameter-networkloadbalancerprofilemanagedoutboundips) | object | Desired managed outbound IPs for the cluster load balancer. |
| [`outboundIPPrefixes`](#parameter-networkloadbalancerprofileoutboundipprefixes) | object | Desired outbound IP Prefix resources for the cluster load balancer. |
| [`outboundIPs`](#parameter-networkloadbalancerprofileoutboundips) | object | Desired outbound IP resources for the cluster load balancer. |

### Parameter: `networkLoadBalancerProfile.allocatedOutboundPorts`

The desired number of allocated SNAT ports per VM. Allowed values are in the range of 0 to 64000 (inclusive).<p>The default value is 0 which results in Azure dynamically allocating ports.

- Required: No
- Type: int

### Parameter: `networkLoadBalancerProfile.backendPoolType`

The type of the managed inbound Load Balancer BackendPool. The default is 'NodeIPConfiguration'

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'NodeIP'
    'NodeIPConfiguration'
  ]
  ```

### Parameter: `networkLoadBalancerProfile.clusterServiceLoadBalancerHealthProbeMode`

The health probing behavior for External Traffic Policy Cluster services.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'ServiceNodePort'
    'Shared'
  ]
  ```

### Parameter: `networkLoadBalancerProfile.enableMultipleStandardLoadBalancers`

Enable multiple standard load balancers per AKS cluster or not.

- Required: No
- Type: bool

### Parameter: `networkLoadBalancerProfile.idleTimeoutInMinutes`

Desired outbound flow idle timeout in minutes. Allowed values are in the range of 4 to 120 (inclusive).<p>The default value is 4 minutes.

- Required: No
- Type: int

### Parameter: `networkLoadBalancerProfile.managedOutboundIPs`

Desired managed outbound IPs for the cluster load balancer.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`count`](#parameter-networkloadbalancerprofilemanagedoutboundipscount) | int | The desired number of IPv4 outbound IPs created/managed by Azure for the cluster load balancer.<p>Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`countIPv6`](#parameter-networkloadbalancerprofilemanagedoutboundipscountipv6) | int | The desired number of IPv6 outbound IPs created/managed by Azure for the cluster load balancer.<p>Allowed values must be in the range of 0 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack. |

### Parameter: `networkLoadBalancerProfile.managedOutboundIPs.count`

The desired number of IPv4 outbound IPs created/managed by Azure for the cluster load balancer.<p>Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.

- Required: Yes
- Type: int
- MinValue: 1
- MaxValue: 100

### Parameter: `networkLoadBalancerProfile.managedOutboundIPs.countIPv6`

The desired number of IPv6 outbound IPs created/managed by Azure for the cluster load balancer.<p>Allowed values must be in the range of 0 to 100 (inclusive). The default value is 0 for single-stack and 1 for dual-stack.

- Required: No
- Type: int
- MinValue: 0
- MaxValue: 100

### Parameter: `networkLoadBalancerProfile.outboundIPPrefixes`

Desired outbound IP Prefix resources for the cluster load balancer.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`publicIPPrefixes`](#parameter-networkloadbalancerprofileoutboundipprefixespublicipprefixes) | array | A list of public IP prefix resources. |

### Parameter: `networkLoadBalancerProfile.outboundIPPrefixes.publicIPPrefixes`

A list of public IP prefix resources.

- Required: Yes
- Type: array

### Parameter: `networkLoadBalancerProfile.outboundIPs`

Desired outbound IP resources for the cluster load balancer.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`publicIPs`](#parameter-networkloadbalancerprofileoutboundipspublicips) | array | A list of public IP resources. |

### Parameter: `networkLoadBalancerProfile.outboundIPs.publicIPs`

A list of public IP resources.

- Required: Yes
- Type: array

### Parameter: `networkLoadBalancerSku`

Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools. The default is 'standard'.<p><p>See Azure Load Balancer SKUs (https://learn.microsoft.com/en-us/azure/load-balancer/skus) for more information about the differences between load balancer SKUs.<p>

- Required: No
- Type: string
- Default: `'standard'`
- Allowed:
  ```Bicep
  [
    'basic'
    'standard'
  ]
  ```

### Parameter: `networkOutboundType`

Specifies outbound (egress) routing method. Default is 'userDefinedRouting'.<p><p>Setting this parameter to values other than 'userDefinedRouting' may make the resource non-compliant.<p><p>Setting outboundType requires AKS clusters with a vm-set-type of VirtualMachineScaleSets and load-balancer-sku of Standard.<p><p>For more information see https://learn.microsoft.com/en-us/azure/aks/egress-outboundtype<p>

- Required: No
- Type: string
- Default: `'userDefinedRouting'`
- Allowed:
  ```Bicep
  [
    'loadBalancer'
    'managedNATGateway'
    'userAssignedNATGateway'
    'userDefinedRouting'
  ]
  ```

### Parameter: `networkPlugin`

Specifies the network plugin used for building Kubernetes network. Default: azure

- Required: No
- Type: string
- Default: `'azure'`
- Allowed:
  ```Bicep
  [
    'azure'
    'kubenet'
  ]
  ```

### Parameter: `networkPluginMode`

Mode of Azure CNI network plugin for building the Kubernetes network. Default: 'overlay'.<p><p>Not used for 'kubenet' network plugin.<p><p>See https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview for more information.

- Required: No
- Type: string
- Default: `[if(equals(parameters('networkPlugin'), 'kubenet'), '', 'overlay')]`
- Allowed:
  ```Bicep
  [
    ''
    'overlay'
  ]
  ```

### Parameter: `networkPodCidr`

Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.

- Required: No
- Type: string

### Parameter: `networkPolicy`

Specifies the network policy used for building Kubernetes network. Default: none.

- Required: No
- Type: string
- Default: `'none'`
- Allowed:
  ```Bicep
  [
    'azure'
    'calico'
    'cilium'
    'none'
  ]
  ```

### Parameter: `networkServiceCidr`

A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.

- Required: No
- Type: string

### Parameter: `nodeResourceGroup`

Name of the resource group containing agent pool nodes.

- Required: No
- Type: string
- Default: `[format('AKS-Node-{0}-rg', parameters('name'))]`

### Parameter: `primaryAgentPoolProfile`

Properties of the primary agent pool.

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    {
      availabilityZones: [
        '1'
        '2'
        '3'
      ]
      count: '[if(and(equals(parameters(\'networkPlugin\'), \'azure\'), not(equals(parameters(\'networkPluginMode\'), \'overlay\'))), 2, 3)]'
      enableAutoScaling: false
      enableNodePublicIP: false
      kubeletDiskType: 'OS'
      maxCount: null
      maxPods: '[if(and(equals(parameters(\'networkPlugin\'), \'azure\'), not(equals(parameters(\'networkPluginMode\'), \'overlay\'))), 30, 110)]'
      minCount: null
      mode: 'System'
      name: 'agentpool'
      osDiskSizeGB: 128
      osDiskType: 'Ephemeral'
      osSKU: 'AzureLinux'
      osType: 'Linux'
      type: 'VirtualMachineScaleSets'
      upgradeSettings: {
        maxSurge: '33%'
      }
      vmSize: 'Standard_D4ads_v5'
      vnetSubnetID: '[if(empty(parameters(\'primaryAgentPoolSubnetResourceId\')), null(), parameters(\'primaryAgentPoolSubnetResourceId\'))]'
    }
  ]
  ```

### Parameter: `publicNetworkAccess`

Allow or deny public network access for AKS. Default: Disabled.<p><p>Setting this parameter to any value other than 'Disabled' will make the resource non-compliant.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
    'SecuredByPerimeter'
  ]
  ```

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Azure Kubernetes Fleet Manager Contributor Role'`
  - `'Azure Kubernetes Fleet Manager RBAC Admin'`
  - `'Azure Kubernetes Fleet Manager RBAC Cluster Admin'`
  - `'Azure Kubernetes Fleet Manager RBAC Reader'`
  - `'Azure Kubernetes Fleet Manager RBAC Writer'`
  - `'Azure Kubernetes Service Cluster Admin Role'`
  - `'Azure Kubernetes Service Cluster Monitoring User'`
  - `'Azure Kubernetes Service Cluster User Role'`
  - `'Azure Kubernetes Service Contributor Role'`
  - `'Azure Kubernetes Service RBAC Admin'`
  - `'Azure Kubernetes Service RBAC Cluster Admin'`
  - `'Azure Kubernetes Service RBAC Reader'`
  - `'Azure Kubernetes Service RBAC Writer'`
  - `'Kubernetes Agentless Operator'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-roleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-roleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `securityProfileAzureKeyVaultKms`

Azure Key Vault key management service settings for the security profile.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      enabled: false
  }
  ```

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`keyId`](#parameter-securityprofileazurekeyvaultkmskeyid) | string | Identifier of Azure Key Vault key.<p>It is provided as a Uri (e.g. 'https://vaultFQDN/keys/key_name/key_version'). See key identifier format for more details.<p>When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier.<p>When Azure Key Vault key management service is disabled, leave the field empty. |
| [`keyVaultResourceId`](#parameter-securityprofileazurekeyvaultkmskeyvaultresourceid) | string | Resource ID of key vault. When keyVaultNetworkAccess is Private, this field is required and must be a valid resource ID.<p>When keyVaultNetworkAccess is Public, leave the field empty. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-securityprofileazurekeyvaultkmsenabled) | bool | Whether to enable Azure Key Vault key management service. Default: true |
| [`keyVaultNetworkAccess`](#parameter-securityprofileazurekeyvaultkmskeyvaultnetworkaccess) | string | Network access of key vault. The possible values are Public and Private.<p>Public means the key vault allows public access from all networks.<p>Private means the key vault disables public access and enables private link. The default value is Private. |

### Parameter: `securityProfileAzureKeyVaultKms.keyId`

Identifier of Azure Key Vault key.<p>It is provided as a Uri (e.g. 'https://vaultFQDN/keys/key_name/key_version'). See key identifier format for more details.<p>When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier.<p>When Azure Key Vault key management service is disabled, leave the field empty.

- Required: No
- Type: string

### Parameter: `securityProfileAzureKeyVaultKms.keyVaultResourceId`

Resource ID of key vault. When keyVaultNetworkAccess is Private, this field is required and must be a valid resource ID.<p>When keyVaultNetworkAccess is Public, leave the field empty.

- Required: No
- Type: string

### Parameter: `securityProfileAzureKeyVaultKms.enabled`

Whether to enable Azure Key Vault key management service. Default: true

- Required: No
- Type: bool

### Parameter: `securityProfileAzureKeyVaultKms.keyVaultNetworkAccess`

Network access of key vault. The possible values are Public and Private.<p>Public means the key vault allows public access from all networks.<p>Private means the key vault disables public access and enables private link. The default value is Private.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Private'
    'Public'
  ]
  ```

### Parameter: `securityProfileDefender`

Azure Defender profile settings. By default the securityMonitoring.enabled is true<p><p>Setting securityMonitoring.enabled to a value other than 'true' will make this resource non-compliant.

- Required: No
- Type: object
- Default: `[if(not(empty(parameters('logAnalyticsWorkspaceResourceId'))), createObject('securityMonitoring', createObject('enabled', true()), 'logAnalyticsWorkspaceResourceId', parameters('logAnalyticsWorkspaceResourceId')), createObject('securityMonitoring', createObject('enabled', false())))]`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`securityMonitoring`](#parameter-securityprofiledefendersecuritymonitoring) | object | Security Monitoring settings. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`logAnalyticsWorkspaceResourceId`](#parameter-securityprofiledefenderloganalyticsworkspaceresourceid) | string | Resource ID of the Log Analytics workspace to be associated with Microsoft Defender.<p>When Microsoft Defender is enabled, this field is required and must be a valid workspace resource ID.<p>When Microsoft Defender is disabled, leave the field empty. |

### Parameter: `securityProfileDefender.securityMonitoring`

Security Monitoring settings.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-securityprofiledefendersecuritymonitoringenabled) | bool | Whether to enable Azure Defender. Default: true |

### Parameter: `securityProfileDefender.securityMonitoring.enabled`

Whether to enable Azure Defender. Default: true

- Required: No
- Type: bool

### Parameter: `securityProfileDefender.logAnalyticsWorkspaceResourceId`

Resource ID of the Log Analytics workspace to be associated with Microsoft Defender.<p>When Microsoft Defender is enabled, this field is required and must be a valid workspace resource ID.<p>When Microsoft Defender is disabled, leave the field empty.

- Required: No
- Type: string

### Parameter: `skuName`

The name of a managed cluster SKU.

- Required: No
- Type: string
- Default: `'Base'`
- Allowed:
  ```Bicep
  [
    'Automatic'
    'Base'
  ]
  ```

### Parameter: `skuTier`

Tier of a managed cluster SKU.

- Required: No
- Type: string
- Default: `'Standard'`
- Allowed:
  ```Bicep
  [
    'Free'
    'Premium'
    'Standard'
  ]
  ```

### Parameter: `sshPublicKey`

Specifies the SSH RSA public key string for the Linux nodes.

- Required: No
- Type: string

### Parameter: `supportPlan`

The support plan for the Managed Cluster.

- Required: No
- Type: string
- Default: `'KubernetesOfficial'`
- Allowed:
  ```Bicep
  [
    'AKSLongTermSupport'
    'KubernetesOfficial'
  ]
  ```

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `addonProfiles` | object | The addonProfiles of the Kubernetes cluster. |
| `configuredLogCategoriesLogAnalytics` | array | The list of diagnostic settings log categories that were configured to log analytics. |
| `controlPlaneFQDN` | string | The control plane FQDN of the managed cluster. |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? Returns 'true' is a non-compliance is identified.<p><p>Note: 'kubernetesVersion' is not analyzed. |
| `ingressApplicationGatewayIdentityObjectId` | string | The Object ID of Application Gateway Ingress Controller (AGIC) identity. |
| `keyvaultIdentityClientId` | string | The Client ID of the Key Vault Secrets Provider identity. |
| `keyvaultIdentityObjectId` | string | The Object ID of the Key Vault Secrets Provider identity. |
| `kubeletIdentityClientId` | string | The Client ID of the AKS identity. |
| `kubeletIdentityObjectId` | string | The Object ID of the AKS identity. |
| `kubeletIdentityResourceId` | string | The Resource ID of the AKS identity. |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the managed cluster. |
| `oidcIssuerUrl` | string | The OIDC token issuer URL. |
| `omsagentIdentityObjectId` | string | The Object ID of the OMS agent identity. |
| `resourceGroupName` | string | The resource group the managed cluster was deployed into. |
| `resourceId` | string | The resource ID of the managed cluster. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |
| `webAppRoutingIdentityObjectId` | string | The Object ID of Web Application Routing. |

## Notes

The module supports several AKS Networking options: 'Azure CNI Overlay' (default), 'Azure CNI Node Subnet', and 'Kubenet'.

Their corresponding module parameters are:

- Azure CNI Overlay
  - networkPlugin: 'azure' (or leave default)
  - networkPluginMode: 'overlay' (or leave default)
- Azure CNI Node Subnet
  - networkPlugin: 'azure' (or leave default)
  - networkPluginMode: ''
  - primaryAgentPoolSubnetResourceId: resource ID of the subnet for AKS Node Pools
- Kubenet
  - networkPlugin: 'kubenet'

When corresponding parameters are not provided the module will default to 'Azure CNI Overlay'.

See [CNI networking overview](https://learn.microsoft.com/en-us/azure/aks/concepts-network-cni-overview) for more information on AKS networking options.

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
