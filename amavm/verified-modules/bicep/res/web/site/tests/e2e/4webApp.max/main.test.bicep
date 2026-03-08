targetScope = 'subscription'

metadata name = 'Web App (Windows), using large parameter set'
metadata description = 'This instance deploys the module as Web App with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-web.sites-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'maxwapp'

@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: resourceLocation
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, resourceLocation)}-nestedDependencies'
  params: {
    virtualNetworkName: 'dep-${namePrefix}${serviceShort}vnet'
    managedIdentityName: 'dep-${namePrefix}${serviceShort}msi'
    serverFarmName: 'dep-${namePrefix}${serviceShort}asp'
    applicationInsightsName: 'dep-${namePrefix}${serviceShort}appi'
    relayNamespaceName: 'dep-${namePrefix}${serviceShort}ns'
    storageAccountName: 'dep${namePrefix}${serviceShort}sta'
    hybridConnectionName: 'dep-${namePrefix}${serviceShort}hc'
    location: resourceLocation
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../../../../utils/e2e-template-assets/templates/diagnostic.dependencies.bicep' = {
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
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      // Web App
      kind: 'app'
      serverFarmResourceId: nestedDependencies.outputs.serverFarmResourceId
      virtualNetworkSubnetId: nestedDependencies.outputs.subnet2ResourceId
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
      httpsOnly: true
      lock: {
        kind: 'CanNotDelete'
        name: 'myCustomLockName'
      }
      // slots: [
      //   {
      //     name: 'slot1'
      //     diagnosticSettings: [
      //       {
      //         name: 'customSetting'
      //         eventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
      //         eventHubAuthorizationRuleResourceId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
      //         storageAccountResourceId: diagnosticDependencies.outputs.storageAccountResourceId
      //         workspaceResourceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
      //       }
      //     ]
      //     privateEndpoints: [
      //       {
      //         subnetResourceId: nestedDependencies.outputs.subnetResourceId
      //         privateDnsZoneResourceIds: [
      //           nestedDependencies.outputs.privateDNSZoneResourceId
      //         ]
      //         tags: {
      //           'hidden-title': 'This is visible in the resource name'
      //           Environment: 'Non-Prod'
      //           Role: 'DeploymentValidation'
      //         }
      //         service: 'sites-slot1'
      //       }
      //     ]
      //     basicPublishingCredentialsPolicies: [
      //       {
      //         name: 'ftp'
      //         allow: false
      //       }
      //       {
      //         name: 'scm'
      //         allow: false
      //       }
      //     ]
      //     roleAssignments: [
      //       {
      //         name: '845ed19c-78e7-4422-aa3d-b78b67cd78a2'
      //         roleDefinitionIdOrName: 'Owner'
      //         principalId: nestedDependencies.outputs.managedIdentityPrincipalId
      //         principalType: 'ServicePrincipal'
      //       }
      //       {
      //         name: guid('Custom seed ${namePrefix}${serviceShort}')
      //         roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      //         principalId: nestedDependencies.outputs.managedIdentityPrincipalId
      //         principalType: 'ServicePrincipal'
      //       }
      //       {
      //         roleDefinitionIdOrName: subscriptionResourceId(
      //           'Microsoft.Authorization/roleDefinitions',
      //           'acdd72a7-3385-48ef-bd42-f606fba81ae7'
      //         )
      //         principalId: nestedDependencies.outputs.managedIdentityPrincipalId
      //         principalType: 'ServicePrincipal'
      //       }
      //     ]
      //     siteConfig: {
      //       alwaysOn: true
      //       minTlsVersion: '1.2'
      //       ftpsState: 'Disabled'
      //       http20Enabled: true
      //       cors: null
      //       metadata: [
      //         {
      //           name: 'CURRENT_STACK'
      //           value: 'dotnetcore'
      //         }
      //       ]
      //     }
      //     storageAccountResourceId: nestedDependencies.outputs.storageAccountResourceId
      //     storageAccountUseIdentityAuthentication: true
      //     hybridConnectionRelays: [
      //       {
      //         resourceId: nestedDependencies.outputs.hybridConnectionResourceId
      //         sendKeyName: 'defaultSender'
      //       }
      //     ]
      //   }
      //   {
      //     name: 'slot2'
      //     basicPublishingCredentialsPolicies: [
      //       {
      //         name: 'ftp'
      //       }
      //       {
      //         name: 'scm'
      //       }
      //     ]
      //     storageAccountResourceId: nestedDependencies.outputs.storageAccountResourceId
      //     storageAccountUseIdentityAuthentication: true
      //   }
      // ]
      privateEndpoints: [
        {
          subnetResourceId: nestedDependencies.outputs.subnetResourceId
          tags: {
            'hidden-title': 'This is visible in the resource name'
            Environment: 'Non-Prod'
            Role: 'DeploymentValidation'
          }
        }
        {
          subnetResourceId: nestedDependencies.outputs.subnetResourceId
        }
      ]
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
      netFrameworkVersion: 'v9.0'
      appInsightResourceId: nestedDependencies.outputs.applicationInsightsResourceId
      appSettingsKeyValuePairs: {
        MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=keyvaultName;SecretName=secretName)'
        WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
        WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
        WEBSITE_RUN_FROM_PACKAGE: '1'
        ASPNETCORE_ENVIRONMENT: 'Development'
        DetailedErrors: 'true'
        'AzureAd:ClientId': 'ClientId-guid-value-from-EntraID'
      }
      authSettingApplicationId: 'ClientId-guid-value-from-EntraID'
      // Auth Setting overrides for API application
      authSettingV2ConfigurationAdditional: {
        enabled: true
        platform: {
          // Not using Easy Auth
          enabled: false
          runtimeVersion: '~1'
        }
        globalValidation: {
          requireAuthentication: true
          // For API
          unauthenticatedClientAction: 'Return401'
        }
        identityProviders: {
          azureActiveDirectory: {
            login: {
              loginParameters: [
                'response_type=code id_token'
                'scope=openid profile email offline_access https://graph.microsoft.com/User.Read https://${substring(environment().suffixes.sqlServerHostname,1)}/user_impersonation'
              ]
            }
          }
        }
      }
      connectionStrings: [
        {
          name: 'SqlDbConnection'
          type: 'SQLAzure'
          slotSetting: true
          connectionString: 'server=tcp:sqlserverFQDN;database=databaseName;'
        }
      ]
      webSiteConfigurationAdditional: {
        cors: {
          allowedOrigins: [
            // to test functions from the portal
            'https://portal.azure.com'
          ]
          supportCredentials: false
        }
      }
      storageAccountResourceId: nestedDependencies.outputs.storageAccountResourceId
      storageAccountUseIdentityAuthentication: true
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      scmSiteAlsoStopped: true
      vnetContentShareEnabled: true
      vnetImagePullEnabled: true
      vnetRouteAllEnabled: true
      publicNetworkAccess: 'Disabled'
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
