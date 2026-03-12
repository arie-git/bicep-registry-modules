targetScope = 'subscription'

metadata name = '(NOT VALIDATED) Function App, using large parameter set'
metadata description = 'This instance deploys the module as Function App with most of its features enabled.'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'dep-${namePrefix}-web.sites-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param resourceLocation string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'wsfamax'

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
// For the below test case, please consider the guidelines described here: https://github.com/Azure/ResourceModules/wiki/Getting%20started%20-%20Scenario%202%20Onboard%20module%20library%20and%20CI%20environment#microsoftwebsites
@batchSize(1)
module testDeployment '../../../main.bicep' = [
  for iteration in ['init', 'idem']: {
    scope: resourceGroup
    name: '${uniqueString(deployment().name, resourceLocation)}-test-${serviceShort}-${iteration}'
    params: {
      name: '${namePrefix}${serviceShort}001'
      location: resourceLocation
      kind: 'functionapp'
      serverFarmResourceId: nestedDependencies.outputs.serverFarmResourceId
      appInsightResourceId: nestedDependencies.outputs.applicationInsightsResourceId
      appSettingsKeyValuePairs: {
        AzureFunctionsJobHost__logging__logLevel__default: 'Trace'
        FUNCTIONS_EXTENSION_VERSION: '~4'
        FUNCTIONS_WORKER_RUNTIME: 'dotnet'
        OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID: nestedDependencies.outputs.managedIdentityClientId
      }
      // Uses module default authSettingV2Configuration for function apps:
      // - Return401 for unauthenticated requests (API-style)
      // - FIC (federated identity credentials) — no client secrets
      // - Entra ID identity provider with audience api://<appId>
      authSettingApplicationId: 'd874dd2f-2032-4db1-a053-f0ec243685aa'
      basicPublishingCredentialsPolicies: [
        {
          name: 'ftp'
          allow: false
        }
        {
          name: 'scm'
          allow: false
        }
      ]
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
      keyVaultAccessIdentityResourceId: nestedDependencies.outputs.managedIdentityResourceId
      siteConfiguration: {
        alwaysOn: true
        use32BitWorkerProcess: false
      }
      storageAccountResourceId: nestedDependencies.outputs.storageAccountResourceId
      storageAccountUseIdentityAuthentication: true
      managedIdentities: {
        systemAssigned: true
        userAssignedResourceIds: [
          nestedDependencies.outputs.managedIdentityResourceId
        ]
      }
      hybridConnectionRelays: [
        {
          resourceId: nestedDependencies.outputs.hybridConnectionResourceId
          sendKeyName: 'defaultSender'
        }
      ]
    }
    dependsOn: [
      nestedDependencies
      diagnosticDependencies
    ]
  }
]
