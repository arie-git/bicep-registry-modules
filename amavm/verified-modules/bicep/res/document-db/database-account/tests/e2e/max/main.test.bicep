targetScope = 'subscription'

metadata name = 'Cosmos DB - Maximum'
metadata description = 'This test deploys a Cosmos DB account exercising the maximum number of parameters.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-cosmosdb-max-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'cdbmax'

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
    managedIdentityName: 'dep-msi-${serviceShort}'
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
      'hidden-title': 'This is visible in the resource name'
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }

    // Identity
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        nestedDependencies.outputs.managedIdentityResourceId
      ]
    }

    // Consistency
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: 100000
    maxIntervalInSeconds: 300

    // Failover & availability
    failoverLocations: [
      {
        failoverPriority: 0
        isZoneRedundant: true
        locationName: resourceLocation
      }
    ]
    enableAutomaticFailover: true
    enableMultipleWriteLocations: false

    // Security
    disableLocalAuthentication: true
    disableKeyBasedMetadataWriteAccess: true
    minimumTlsVersion: 'Tls12'

    // Network
    networkRestrictions: {
      ipRules: []
      virtualNetworkRules: []
      publicNetworkAccess: 'Disabled'
      networkAclBypass: 'None'
    }

    // Capabilities
    capabilitiesToAdd: [
      'EnableNoSQLVectorSearch'
      'EnableNoSQLFullTextSearch'
    ]

    // Backup
    backupPolicyType: 'Continuous'
    backupPolicyContinuousTier: 'Continuous30Days'

    // Feature flags
    enableAnalyticalStorage: true
    enableFreeTier: false
    enableBurstCapacity: true
    enablePartitionMerge: false
    enablePerRegionPerPartitionAutoscale: false
    totalThroughputLimit: -1

    // SQL databases with containers
    sqlDatabases: [
      {
        name: 'db-with-containers'
        containers: [
          {
            kind: 'Hash'
            name: 'container-001'
            indexingPolicy: {
              automatic: true
            }
            paths: [
              '/myPartitionKey'
            ]
            analyticalStorageTtl: 0
            conflictResolutionPolicy: {
              conflictResolutionPath: '/myCustomId'
              mode: 'LastWriterWins'
            }
            defaultTtl: 1000
            uniqueKeyPolicyKeys: [
              {
                paths: [
                  '/firstName'
                ]
              }
              {
                paths: [
                  '/lastName'
                ]
              }
            ]
            throughput: 600
          }
          {
            name: 'container-002'
            kind: 'MultiHash'
            paths: [
              '/partKey1'
              '/partKey2'
            ]
          }
        ]
      }
      {
        name: 'db-autoscale'
        autoscaleSettingsMaxThroughput: 1000
        containers: [
          {
            name: 'container-autoscale'
            paths: [
              '/id'
            ]
            autoscaleSettingsMaxThroughput: 1000
          }
        ]
      }
      {
        name: 'db-no-containers'
      }
    ]

    // SQL role definitions
    sqlRoleDefinitions: [
      {
        roleName: 'custom-read-role'
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/executeQuery'
        ]
      }
    ]

    // Diagnostics
    diagnosticSettings: [
      {
        name: 'customSetting'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        logCategoriesAndGroups: [
          { category: 'DataPlaneRequests' }
          { category: 'QueryRuntimeStatistics' }
          { category: 'PartitionKeyStatistics' }
          { category: 'PartitionKeyRUConsumption' }
          { category: 'ControlPlaneRequests' }
        ]
        eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
        eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
        storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
        workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
      }
    ]

    // Lock
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }

    // Role assignments
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Cosmos DB Account Reader Role'
        principalId: nestedDependencies.outputs.managedIdentityPrincipalId
        principalType: 'ServicePrincipal'
      }
      {
        roleDefinitionIdOrName: 'DocumentDB Account Contributor'
        principalId: nestedDependencies.outputs.managedIdentityPrincipalId
        principalType: 'ServicePrincipal'
      }
    ]

    // Private endpoints
    privateEndpoints: [
      {
        name: 'pe-cosmos-sql'
        service: 'Sql'
        subnetResourceId: nestedDependencies.outputs.subnetResourceId
        privateDnsZoneResourceIds: [
          nestedDependencies.outputs.privateDNSZoneResourceId
        ]
      }
    ]

    // CORS
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            'https://www.example.com'
          ]
          allowedMethods: [
            'GET'
            'POST'
          ]
          allowedHeaders: [
            '*'
          ]
          exposedHeaders: [
            '*'
          ]
          maxAgeInSeconds: 3600
        }
      ]
    }
  }
  dependsOn: [
    nestedDependencies
    diagnosticDependencies
  ]
}
