targetScope = 'subscription'
metadata name = 'Max - comprehensive parameter coverage'
metadata description = 'This instance deploys the module with the maximum set of parameters to validate comprehensive coverage including agent pools, security, networking, diagnostics, and add-ons.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-containerservice.managedclusters-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'maxaks001'

@description('Generated. Used as a basis for unique resource names.')
param baseTime string = utcNow('u')

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    virtualNetworkName: 'dep-${namePrefix}${serviceShort}vnet'
    managedIdentityName: 'dep-${namePrefix}${serviceShort}uami'
    managedIdentityKubeletIdentityName: 'dep-${namePrefix}${serviceShort}uamiki'
    diskEncryptionSetName: 'dep-${namePrefix}${serviceShort}des'
    proximityPlacementGroupName: 'dep-${namePrefix}${serviceShort}ppg'
    keyVaultName: 'dep-${namePrefix}${serviceShort}kv-${substring(uniqueString(baseTime), 0, 3)}'
    dnsZoneName: 'dep-${namePrefix}${serviceShort}dns.com'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}${serviceShort}log'
    location: resourceLocation
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../bicep-shared/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}${serviceShort}sta01dia'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}${serviceShort}log'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}${serviceShort}evh'
    eventHubNamespaceName: 'dep-${namePrefix}${serviceShort}evhns'
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
      location: resourceLocation
      name: '${namePrefix}${serviceShort}aks'

      // --- Identity ---
      enableWorkloadIdentity: true
      managedIdentities: {
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      disableLocalAccounts: true
      enableRBAC: true
      aadProfile: {
        enableAzureRBAC: true
        managed: true
        tenantID: subscription().tenantId
      }

      // --- Networking ---
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataPlane: 'cilium'
      networkPolicy: 'cilium'
      networkPodCidr: null
      networkOutboundType: 'userDefinedRouting'
      publicNetworkAccess: 'Disabled'

      // --- API Server ---
      apiServerAccessProfile: {
        disableRunCommand: true
        enablePrivateCluster: true
        privateDNSZone: nestedDependencies.outputs.dnsZoneResourceId
      }

      // --- SKU ---
      skuTier: 'Standard'

      // --- Primary agent pool ---
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
          maxCount: 5
          maxPods: 110
          mode: 'System'
          name: 'agentpool'
          nodeTaints: [
            'CriticalAddonsOnly=true:NoSchedule'
          ]
          osDiskSizeGB: 128
          osDiskType: 'Ephemeral'
          kubeletDiskType: 'OS'
          osType: 'Linux'
          osSKU: 'AzureLinux'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_D4ads_v5'
          vnetSubnetID: nestedDependencies.outputs.subnetResourceIds[0]
          upgradeSettings: {
            maxSurge: '33%'
          }
        }
      ]

      // --- Secondary agent pools (tests new synced params) ---
      agentPools: [
        {
          availabilityZones: [
            '1'
            '2'
            '3'
          ]
          count: 2
          enableAutoScaling: true
          maxCount: 4
          maxPods: 50
          minCount: 2
          mode: 'User'
          name: 'userpool1'
          nodeLabels: {
            environment: 'test'
            workload: 'general'
          }
          osDiskSizeGB: 128
          osDiskType: 'Ephemeral'
          osSku: 'AzureLinux'
          osType: 'Linux'
          scaleDownMode: 'Delete'
          scaleSetEvictionPolicy: 'Delete'
          scaleSetPriority: 'Regular'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_D4ads_v5'
          vnetSubnetId: nestedDependencies.outputs.subnetResourceIds[1]
          proximityPlacementGroupResourceId: nestedDependencies.outputs.proximityPlacementGroupResourceId
          upgradeSettings: {
            maxSurge: '33%'
          }
        }
        {
          availabilityZones: [
            '1'
            '2'
            '3'
          ]
          count: 2
          enableAutoScaling: true
          enableEncryptionAtHost: true
          maxCount: 4
          maxPods: 50
          minCount: 2
          mode: 'User'
          name: 'userpool2'
          nodeLabels: {
            environment: 'test'
            workload: 'compute'
          }
          nodeTaints: [
            'workload=compute:NoSchedule'
          ]
          osDiskSizeGB: 128
          osDiskType: 'Ephemeral'
          osSku: 'AzureLinux'
          osType: 'Linux'
          scaleDownMode: 'Delete'
          scaleSetEvictionPolicy: 'Delete'
          scaleSetPriority: 'Regular'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_D4ads_v5'
          vnetSubnetId: nestedDependencies.outputs.subnetResourceIds[2]
          upgradeSettings: {
            maxSurge: '33%'
          }
        }
      ]

      // --- Storage profile ---
      enableStorageProfileBlobCSIDriver: true
      enableStorageProfileDiskCSIDriver: true
      enableStorageProfileFileCSIDriver: true
      enableStorageProfileSnapshotController: true

      // --- Security ---
      diskEncryptionSetResourceId: nestedDependencies.outputs.diskEncryptionSetResourceId
      addonAzurePolicy: {
        enabled: true
        config: {
          version: 'v2'
        }
      }
      addonAzureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
      imageCleaner: {
        enabled: true
        intervalHours: 168
      }

      // --- Logging/monitoring ---
      logAnalyticsWorkspaceResourceId: nestedDependencies.outputs.logAnalyticsWorkspaceResourceId
      addonOmsAgentEnabled: true
      diagnosticSettings: [
        {
          name: 'maxDiagnosticSettings'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          logCategoriesAndGroups: [
            { category: 'kube-apiserver', enabled: true }
            { category: 'kube-audit', enabled: true }
            { category: 'kube-audit-admin', enabled: true }
            { category: 'kube-controller-manager', enabled: true }
            { category: 'kube-scheduler', enabled: true }
            { category: 'cluster-autoscaler', enabled: true }
            { category: 'cloud-controller-manager', enabled: true }
            { category: 'guard', enabled: true }
          ]
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
        }
      ]

      // --- Workload autoscaler (KEDA) ---
      workloadAutoScalerProfile: {
        keda: {
          enabled: true
        }
      }

      // --- Auto-upgrade and maintenance ---
      autoUpgradeProfile: {
        upgradeChannel: 'stable'
        nodeOSUpgradeChannel: 'NodeImage'
      }
      maintenanceConfigurations: [
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

      // --- RBAC ---
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      roleAssignments: [
        {
          roleDefinitionIdOrName: 'Owner'
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
        {
          roleDefinitionIdOrName: subscriptionResourceId(
            'Microsoft.Authorization/roleDefinitions',
            'acdd72a7-3385-48ef-bd42-f606fba81ae7'
          )
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
      ]
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
