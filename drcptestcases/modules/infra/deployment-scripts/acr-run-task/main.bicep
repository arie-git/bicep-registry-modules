
@description('The name of the Azure Container Registry')
param acrName string

@description('The name of the task')
param taskName string

@description('The location to deploy the resources to')
param location string = resourceGroup().location

@description('How the deployment script should be forced to execute')
param forceUpdateTag  string = utcNow()

// @description('Azure RoleId that are required for the DeploymentScript resource to import images')
// param rbacRoleNeeded string = 'b24988ac-6180-42a0-ab88-20f7382dd24c' //Contributor is needed to import ACR

// @description('Does the Managed Identity already exists, or should be created')
// param useExistingManagedIdentity bool = false

// @description('Name of the Managed Identity resource')
// param managedIdentityName string = 'id-ContainerRegistryImport'

// @description('For an existing Managed Identity, the Subscription Id it is located in')
// param existingManagedIdentitySubId string = subscription().subscriptionId

// @description('For an existing Managed Identity, the Resource Group it is located in')
// param existingManagedIdentityResourceGroupName string = resourceGroup().name

param storageAccountName string

@description('A delay before the script import operation starts. Primarily to allow Azure AAD Role Assignments to propagate. Default: 30s')
param initialScriptDelay string = '30s'

@allowed([
  'OnSuccess'
  'OnExpiration'
  'Always'
])
@description('When the script resource is cleaned up')
param cleanupPreference string = 'OnSuccess'

resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}
// resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = if (!empty(rbacRoleNeeded)) {
//   name: guid(acr.id, rbacRoleNeeded, useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id)
//   scope: acr
//   properties: {
//     roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', rbacRoleNeeded)
//     principalId: useExistingManagedIdentity ? existingDepScriptId.properties.principalId : newDepScriptId.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

resource runTask 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: '${deployment().name}-script'
  location: location
  // identity: {
  //   type: 'UserAssigned'
  //   userAssignedIdentities: {
  //     '${useExistingManagedIdentity ? existingDepScriptId.id : newDepScriptId.id}': {}
  //   }
  // }
  kind: 'AzureCLI'
  // dependsOn: [
  //   rbac
  // ]
  properties: {
    storageAccountSettings: {
      storageAccountName: storageAccount.name
      storageAccountKey: storageAccount.listKeys().keys[0].value
    }
    forceUpdateTag: forceUpdateTag
    azCliVersion: '2.30.0'
    timeout: 'PT30M'
    retentionInterval: 'P1D'
    environmentVariables: [
      {
        name: 'acrName'
        value: acr.name
      }
      {
        name: 'taskName'
        value: taskName
      }
      {
        name: 'initialDelay'
        value: initialScriptDelay
      }
      {
        name: 'retryMax'
        value: '2'
      }
      {
        name: 'retrySleep'
        value: '5s'
      }
    ]
    scriptContent: '''
      #!/bin/bash
      set -e

      echo "Waiting for ($initialDelay) seconds before starting ..."
      sleep $initialDelay

      #Retry loop to catch errors (usually RBAC delays, but 'Error copying blobs' is also not unheard of)
      retryLoopCount=0
      until [ $retryLoopCount -ge $retryMax ]
      do
        echo "Running task $taskName in ACR $acrName"
        az acr task run --name $taskName --registry $acrName \
          && break

        sleep $retrySleep
        retryLoopCount=$((retryLoopCount+1))
      done

    '''
    cleanupPreference: cleanupPreference
  }
}

