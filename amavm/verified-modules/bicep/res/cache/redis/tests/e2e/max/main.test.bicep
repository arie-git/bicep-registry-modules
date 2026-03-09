targetScope = 'subscription'

metadata name = 'Using large parameter set'
metadata description = 'This instance deploys the module with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-cache.redis-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'crmax'

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
    managedIdentityName: 'dep-${namePrefix}-msi-${serviceShort}'
    virtualNetworkName: 'dep-${namePrefix}-vnet-${serviceShort}'
    location: resourceLocation
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../bicep-shared/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep${namePrefix}diasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-${namePrefix}-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-${namePrefix}-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-${namePrefix}-evhns-${serviceShort}'
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
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      // --- SKU & Capacity ---
      skuName: 'Premium'
      capacity: 2
      redisVersion: '6'
      // --- Replication & Sharding ---
      replicasPerMaster: 3
      replicasPerPrimary: 3
      shardCount: 1
      // --- Zone Redundancy ---
      zoneRedundant: true
      availabilityZones: [1, 2]
      zonalAllocationPolicy: 'UserDefined'
      // --- Security ---
      disableAccessKeyAuthentication: true
      enableNonSslPort: false
      minimumTlsVersion: '1.2'
      publicNetworkAccess: 'Disabled'
      // --- Redis Configuration ---
      redisConfiguration: {
        'maxmemory-policy': 'allkeys-lru'
        'maxmemory-delta': '10'
      }
      // --- Managed Identity ---
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      // --- Tenant Settings ---
      tenantSettings: {
        testKey: 'testValue'
      }
      // --- Access Policies ---
      accessPolicies: [
        {
          name: 'testAccessPolicy'
          permissions: '+get +set +del ~*'
        }
      ]
      accessPolicyAssignments: [
        {
          objectId: nestedDependencies.outputs.managedIdentityPrincipalId
          objectIdAlias: 'testAlias'
          accessPolicyName: 'testAccessPolicy'
        }
      ]
      // --- Firewall Rules ---
      firewallRules: [
        {
          name: 'AllowAllWindowsAzureIps'
          startIP: '0.0.0.0'
          endIP: '0.0.0.0'
        }
        {
          name: 'testrule1'
          startIP: '10.10.10.1'
          endIP: '10.10.10.10'
        }
        {
          name: 'testrule2'
          startIP: '100.100.100.1'
          endIP: '100.100.100.10'
        }
      ]
      // --- Lock ---
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      // --- Diagnostics ---
      diagnosticSettings: [
        {
          name: 'customSetting'
          metricCategories: [
            {
              category: 'AllMetrics'
            }
          ]
          logCategoriesAndGroups: [
            {
              category: 'ConnectedClientList'
            }
          ]
          eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
          eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
          storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
          workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
        }
      ]
      // --- Private Endpoints ---
      privateEndpoints: [
        {
          privateDnsZoneResourceIds: [
            nestedDependencies.outputs.privateDNSZoneResourceId
          ]
          subnetResourceId: nestedDependencies.outputs.subnetResourceId
          roleAssignments: [
            {
              roleDefinitionIdOrName: 'Owner'
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
        {
          privateDnsZoneResourceIds: [
            nestedDependencies.outputs.privateDNSZoneResourceId
          ]
          subnetResourceId: nestedDependencies.outputs.subnetResourceId
        }
      ]
      // --- Role Assignments ---
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
      // --- Tags ---
      tags: {
        'hidden-title': 'This is visible in the resource name'
        resourceType: 'Redis Cache'
        Environment: 'Non-Prod'
      }
    }
  }
]

output resourceId string = testDeployment[0].outputs.resourceId
