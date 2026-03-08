targetScope = 'subscription'
metadata name = 'Using Azure CNI network plugin with Cilium'
metadata description = 'This instance deploys the module with Azure CNI network plugin in overlay mode, and applies Cilium data plane and network policy.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-containerservice.managedclusters-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'azureaks001'

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
    // Adding base time to make the name unique as purge protection must be enabled (but may not be longer than 24 characters total)
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
      enableWorkloadIdentity: true
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkDataPlane: 'cilium'
      networkPolicy: 'cilium'
      networkPodCidr: null
      apiServerAccessProfile: {
        privateDNSZone: nestedDependencies.outputs.dnsZoneResourceId
      }
      logAnalyticsWorkspaceResourceId: nestedDependencies.outputs.logAnalyticsWorkspaceResourceId
      primaryAgentPoolProfile: [
        {
          enableNodePublicIP: false
          count: 2
          enableAutoScaling: false
          minCount: null
          maxCount: null
          maxPods: 110
          mode: 'System'
          name: 'agentpool'
          osDiskSizeGB: 128
          osDiskType: 'Ephemeral'
          kubeletDiskType: 'OS'
          osType: 'Linux'
          osSKU: 'AzureLinux'
          type: 'VirtualMachineScaleSets'
          vmSize: 'Standard_D4ads_v5'
          vnetSubnetID: nestedDependencies.outputs.subnetResourceIds[0]
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
      //     count: 2
      //     enableAutoScaling: true
      //     maxCount: 3
      //     maxPods: 30
      //     minCount: 1
      //     minPods: 2
      //     mode: 'User'
      //     name: 'userpool1'
      //     nodeLabels: {}
      //     osDiskSizeGB: 128
      //     osType: 'Linux'
      //     scaleSetEvictionPolicy: 'Delete'
      //     scaleSetPriority: 'Regular'
      //     type: 'VirtualMachineScaleSets'
      //     vmSize: 'Standard_DS2_v2'
      //     vnetSubnetID: nestedDependencies.outputs.subnetResourceIds[1]
      //     proximityPlacementGroupResourceId: nestedDependencies.outputs.proximityPlacementGroupResourceId
      //   }
      //   {
      //     availabilityZones: [
      //       '3'
      //     ]
      //     count: 2
      //     enableAutoScaling: true
      //     maxCount: 3
      //     maxPods: 30
      //     minCount: 1
      //     minPods: 2
      //     mode: 'User'
      //     name: 'userpool2'
      //     nodeLabels: {}
      //     osDiskSizeGB: 128
      //     osType: 'Linux'
      //     scaleSetEvictionPolicy: 'Delete'
      //     scaleSetPriority: 'Regular'
      //     type: 'VirtualMachineScaleSets'
      //     vmSize: 'Standard_DS2_v2'
      //     vnetSubnetID: nestedDependencies.outputs.subnetResourceIds[2]
      //   }
      // ]
      diagnosticSettings: [
        {
          name: 'customSetting'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
        }
      ]
      managedIdentities: {
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      roleAssignments: [
        {
          // name: 'ac915208-669e-4665-9792-7e2dc861f569'
          roleDefinitionIdOrName: 'Owner'
          principalId: nestedDependencies.outputs.managedIdentityPrincipalId
          principalType: 'ServicePrincipal'
        }
        {
          // name: guid('Custom seed ${namePrefix}${serviceShort}')
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
