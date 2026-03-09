targetScope = 'subscription'

metadata name = 'Web App (Linux), using large parameter set'
metadata description = 'This instance deploys the module asa Linux Web App with most of its features enabled.'

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
    storageAccountName: 'dep${namePrefix}${serviceShort}sta'
    applicationInsightsName: 'dep-${namePrefix}${serviceShort}appi'
    relayNamespaceName: 'dep-${namePrefix}${serviceShort}ns'
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
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      kind: 'app,linux'
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
      //         roleDefinitionIdOrName: 'Owner'
      //         principalId: nestedDependencies.outputs.managedIdentityPrincipalId
      //         principalType: 'ServicePrincipal'
      //       }
      //       {
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
      linuxFxVersion: 'DOTNETCORE|8.0'
      authSettingApplicationId: 'ClientId-guid-value-from-EntraID'
      // Auth Setting overrides for Web application, using App Service authentication (Easy Auth)
      authSettingV2ConfigurationAdditional: {
        identityProviders: {
          azureActiveDirectory: {
            login: {
              loginParameters: [
                'scope=openid profile email offline_access api://ClientId-guid-value-from-EntraID/user_impersonation'
              ]
            }
          }
        }
      }
      appSettingsKeyValuePairs: {
        WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'true'
        WEBSITE_AUTH_AAD_ALLOWED_TENANTS: tenant().tenantId
        WEBSITE_RUN_FROM_PACKAGE: '1'
        ASPNETCORE_ENVIRONMENT: 'Development'
        DetailedErrors: 'true'
        MICROSOFT_PROVIDER_AUTHENTICATION_SECRET: '@Microsoft.KeyVault(VaultName=keyvaultName;SecretName=secretName)'
        // Linux format with double underscore as config structure level separator
        AzureAd__ClientId: 'ClientId-guid-value-from-EntraID'
        // Overrides appsettings.json parameter DownstreamApis:MyApi:BaseUrl
        DownstreamApis__MyApi__BaseUrl: 'https://www.someapi.com'
      }
      siteConfigurationAdditional: {
        cors: {
          allowedOrigins: [
            'https://portal.azure.com'
            'https://ms.portal.azure.com'
          ]
        }
      }
      appInsightResourceId: nestedDependencies.outputs.applicationInsightsResourceId
      storageAccountResourceId: nestedDependencies.outputs.storageAccountResourceId
      storageAccountUseIdentityAuthentication: true
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      scmSiteAlsoStopped: true
      outboundVnetRouting: {
        allTraffic: true
        contentShareTraffic: true
        imagePullTraffic: true
      }
      publicNetworkAccess: 'Disabled'
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
