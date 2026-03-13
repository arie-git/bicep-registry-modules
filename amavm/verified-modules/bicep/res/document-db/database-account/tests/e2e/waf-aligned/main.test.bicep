targetScope = 'subscription'

metadata name = 'Cosmos DB - WAF-aligned'
metadata description = 'This test deploys a Cosmos DB account in alignment with the best practices of the Azure Well-Architected Framework.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-cosmosdb-waf-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'cdbwaf'

// ============ //
// Dependencies //
// ============ //

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    virtualNetworkName: 'dep-vnet-${serviceShort}'
    location: resourceLocation
  }
}

module diagnosticDependencies '../../../../../../../utils/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-diagnosticDependencies'
  params: {
    storageAccountName: 'depdiasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-evhns-${serviceShort}'
    location: resourceLocation
  }
}

// ============== //
// Test Execution //
// ============== //

module testDeployment '../../../main.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}'
  params: {
    name: 'cosmos-${serviceShort}-${substring(uniqueString(deployment().name), 0, 4)}'
    location: resourceLocation
    tags: {
      environment: 'production'
      workload: 'cosmosdb-waf'
    }

    // WAF: Use managed identity (system-assigned)
    managedIdentities: {
      systemAssigned: true
    }

    // WAF: Zone-redundant deployment
    zoneRedundant: true
    enableAutomaticFailover: true

    // WAF: Disable local auth — use Entra ID only
    disableLocalAuthentication: true
    disableKeyBasedMetadataWriteAccess: true

    // WAF: Enforce TLS 1.2
    minimumTlsVersion: 'Tls12'

    // WAF: Disable public network access
    networkRestrictions: {
      ipRules: []
      virtualNetworkRules: []
      publicNetworkAccess: 'Disabled'
      networkAclBypass: 'None'
    }

    // WAF: Continuous backup for point-in-time restore
    backupPolicyType: 'Continuous'
    backupPolicyContinuousTier: 'Continuous30Days'

    // WAF: Enable diagnostics to Log Analytics
    diagnosticSettings: [
      {
        name: 'wafDiagnostics'
        logCategoriesAndGroups: [
          { category: 'DataPlaneRequests' }
          { category: 'QueryRuntimeStatistics' }
          { category: 'PartitionKeyStatistics' }
          { category: 'PartitionKeyRUConsumption' }
          { category: 'ControlPlaneRequests' }
        ]
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

    // WAF: Private endpoint for network isolation
    privateEndpoints: [
      {
        service: 'Sql'
        subnetResourceId: nestedDependencies.outputs.subnetResourceId
        privateDnsZoneResourceIds: [
          nestedDependencies.outputs.privateDNSZoneResourceId
        ]
      }
    ]

    // SQL database
    sqlDatabases: [
      {
        name: 'waf-db'
      }
    ]
  }
  dependsOn: [
    nestedDependencies
    diagnosticDependencies
  ]
}
