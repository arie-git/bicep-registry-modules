targetScope = 'subscription'

metadata name = 'WAF-aligned'
metadata description = 'This instance deploys the module in alignment with the best-practices of the Well-Architected Framework.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
// e.g., for a module 'network/private-endpoint' you could use 'dep-dev-network.privateendpoints-${serviceShort}-rg'
param resourceGroupName string = 'dep-${namePrefix}${serviceShort}-containerservice.managedclusters-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
// e.g., for a module 'network/private-endpoint' you could use 'npe' as a prefix and then 'waf' as a suffix for the waf-aligned test
param serviceShort string = 'wafaks001'

@description('Optional. A token to inject into the name of each resource. This value can be automatically injected by the CI.')
param namePrefix string = '#_namePrefix_#'

var safeNamePrefix = replace(replace(namePrefix,'#',''),'_','')

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

// ============ //
// Dependencies //
// ============ //


module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    managedIdentityName: '${namePrefix}${serviceShort}msi-dep'
    privateDnsZoneName: 'privatelink.${resourceLocation}.azmk8s.io'
    virtualNetworkName: '${namePrefix}${serviceShort}vnet-dep'
    location: resourceLocation
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../bicep-shared/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: '${safeNamePrefix}${serviceShort}diasasta01dep'
    logAnalyticsWorkspaceName: '${safeNamePrefix}${serviceShort}log01dep'
    eventHubNamespaceEventHubName: '${safeNamePrefix}${serviceShort}evh01dep'
    eventHubNamespaceName: '${safeNamePrefix}${serviceShort}evhns01dep'
    location: resourceLocation
  }
}


// ============== //
// Test Execution //
// ============== //

@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}aks'
      location: resourceLocation
      skuTier: 'Standard'
       // to be incremented when willing to upgrade -OR- use auto-upgrade TODO check in WAF
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'cilium'
      networkDataPlane: 'cilium'
      networkOutboundType: 'userDefinedRouting'
      networkPodCidr: '172.16.0.0/16'
      networkServiceCidr: '192.168.0.0/16'
      networkDnsServiceIP: '192.168.0.10'
      apiServerAccessProfile: {
        enablePrivateCluster: true
        privateDNSZone: nestedDependencies.outputs.privateDnsZoneResourceId
      }
      primaryAgentPoolProfile: [
        {
          availabilityZones: [
            '1'
            '2'
            '3'
          ]
          count: 3
          enableAutoScaling: true
          minCount: 3
          maxCount: 4
          maxPods: 110
          mode: 'System'
          name: 'agentpool'
          // nodeTaints: [
          //   'CriticalAddonsOnly=true:NoSchedule' // TODO: Uncomment when application agent pools are added
          // ]
          osDiskSizeGB: 0
          osType: 'Linux'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_D4ads_v5'
          vnetSubnetID: '${nestedDependencies.outputs.vNetResourceId}/subnets/defaultSubnet'
          upgradeSettings:{
            maxSurge: '33%'
          }
        }
      ]
      // agentPools: [
      //   {
      //     availabilityZones: [
      //       '3'
      //     ]
      //     count: 3
      //     enableAutoScaling: true
      //     maxCount: 3
      //     maxPods: 50
      //     minCount: 3
      //     minPods: 2
      //     mode: 'User'
      //     name: 'userpool1'
      //     nodeLabels: {}
      //     osDiskType: 'Ephemeral'
      //     osDiskSizeGB: 60
      //     osType: 'Linux'
      //     scaleSetEvictionPolicy: 'Delete'
      //     scaleSetPriority: 'Regular'
      //     type: 'VirtualMachineScaleSets'
      //     vmSize: 'Standard_DS2_v2'
      //     vnetSubnetID: '${nestedDependencies.outputs.vNetResourceId}/subnets/defaultSubnet'
      //   }
      //   {
      //     availabilityZones: [
      //       '3'
      //     ]
      //     count: 3
      //     enableAutoScaling: true
      //     maxCount: 3
      //     maxPods: 50
      //     minCount: 3
      //     minPods: 2
      //     mode: 'User'
      //     name: 'userpool2'
      //     nodeLabels: {}
      //     osDiskType: 'Ephemeral'
      //     osDiskSizeGB: 60
      //     osType: 'Linux'
      //     scaleSetEvictionPolicy: 'Delete'
      //     scaleSetPriority: 'Regular'
      //     type: 'VirtualMachineScaleSets'
      //     vmSize: 'Standard_DS2_v2'
      //   }
      // ]
      // omsAgentEnabled: true
      logAnalyticsWorkspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
      diagnosticSettings: [
        {
          name: 'mostLogsAndMetrics'
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
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
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
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
      roleAssignments: [
        {
          roleDefinitionIdOrName: 'Azure Kubernetes Service RBAC Cluster Admin'
          principalId: 'objectId_of_a_user_group'
          principalType: 'Group'
        }
      ]
      managedIdentities: {
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      tags: {
        'hidden-title': 'This is visible in the resource name'
        Environment: 'Non-Prod'
        Role: 'DeploymentValidation'
      }
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
