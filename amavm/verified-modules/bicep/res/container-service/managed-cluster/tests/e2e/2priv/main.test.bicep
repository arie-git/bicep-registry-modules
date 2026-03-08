targetScope = 'subscription'

metadata name = 'Private cluster with a BYO virtual network'
metadata description = 'This instance deploys the module with a private cluster instance, which creates a private cluster connected to a custom Virtual Network.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}${serviceShort}-containerservice.managedclusters-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'privaks001'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

var safeNamePrefix = replace(replace(namePrefix,'#',''),'_','')

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
    managedIdentityName: '${safeNamePrefix}${serviceShort}msi-dep'
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
      apiServerAccessProfile:{
        privateDNSZone: nestedDependencies.outputs.privateDnsZoneResourceId
      }
      primaryAgentPoolSubnetResourceId: '${nestedDependencies.outputs.vNetResourceId}/subnets/defaultSubnet'
      logAnalyticsWorkspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
      diagnosticSettings: [
        {
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
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
