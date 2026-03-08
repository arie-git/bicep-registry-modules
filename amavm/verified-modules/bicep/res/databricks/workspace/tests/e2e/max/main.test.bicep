targetScope = 'subscription'

metadata name = 'Using large parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-databricks.workspaces-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'max001'

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
    managedIdentityName: 'dep-${namePrefix}-${serviceShort}-msi'
    location: resourceLocation
    amlWorkspaceName: 'dep-${namePrefix}-${serviceShort}-aml'
    applicationInsightsName: 'dep-${namePrefix}-${serviceShort}-appi'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-${serviceShort}-log'
    loadBalancerName: 'dep-${namePrefix}-${serviceShort}-lb'
    storageAccountName: 'dep${namePrefix}${serviceShort}sta'
    virtualNetworkName: 'dep-${namePrefix}-${serviceShort}-vnet'
    networkSecurityGroupName: 'dep-${namePrefix}-${serviceShort}-nsg'
    databricksApplicationObjectId: '22f4b211-bccf-4640-abfc-7835797f9294' // Tenant-specific 'AzureDatabricks' Enterprise Application Object Id
    keyVaultDiskName: 'dep-${namePrefix}-${serviceShort}-kve-${substring(uniqueString(baseTime), 0, 3)}'
    // Adding base time to make the name unique as purge protection must be enabled (but may not be longer than 24 characters total)
    keyVaultName: 'dep-${namePrefix}-${serviceShort}-kv-${substring(uniqueString(baseTime), 0, 3)}'
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../bicep-shared/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}${serviceShort}diasta01'
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
      name: '${namePrefix}${serviceShort}dbw'
      location: resourceLocation
      automaticClusterUpdate: 'Enabled'
      complianceSecurityProfile: 'Enabled'
      enhancedSecurityMonitoring: 'Enabled'
      enableTelemetry: true
      diagnosticSettings: [
        {
          name: 'customSetting'
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
          logCategoriesAndGroups: [
            {
              category: 'jobs'
            }
            {
              category: 'notebook'
            }
          ]
        }
      ]
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
      customerManagedKey: {
        keyName: nestedDependencies.outputs.keyVaultKeyName
        keyVaultResourceId: nestedDependencies.outputs.keyVaultResourceId
      }
      customerManagedKeyManagedDisk: {
        keyName: nestedDependencies.outputs.keyVaultDiskKeyName
        keyVaultResourceId: nestedDependencies.outputs.keyVaultDiskResourceId
        rotationToLatestKeyVersionEnabled: true
      }
      storageAccountName: '${namePrefix}${serviceShort}sta'
      storageAccountSkuName: 'Standard_ZRS'
      publicIpName: 'nat-gw-public-ip'
      natGatewayName: 'nat-gateway'
      prepareEncryption: true
      requiredNsgRules: 'NoAzureDatabricksRules'
      skuName: 'premium'
      amlWorkspaceResourceId: nestedDependencies.outputs.machineLearningWorkspaceResourceId
      customPrivateSubnetName: nestedDependencies.outputs.customPrivateSubnetName
      customPublicSubnetName: nestedDependencies.outputs.customPublicSubnetName
      publicNetworkAccess: 'Disabled'
      disablePublicIp: true
      loadBalancerResourceId: nestedDependencies.outputs.loadBalancerResourceId
      loadBalancerBackendPoolName: nestedDependencies.outputs.loadBalancerBackendPoolName
      customVirtualNetworkResourceId: nestedDependencies.outputs.virtualNetworkResourceId
      privateEndpoints: [
        {
          service: 'databricks_ui_api'
          subnetResourceId: nestedDependencies.outputs.primarySubnetResourceId
          tags: {
            Environment: 'Non-Prod'
            Role: 'DeploymentValidation'
          }
        }
        {
          subnetResourceId: nestedDependencies.outputs.secondarySubnetResourceId
          service: 'browser_authentication'
        }
      ]
      // Please do not change the name of the managed resource group as the CI's removal logic relies on it
      managedResourceGroupResourceId: '${subscription().id}/resourceGroups/${resourceGroupName}-adbmanaged-rg'
      requireInfrastructureEncryption: true
      managedVnetAddressPrefix: '10.100'
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
