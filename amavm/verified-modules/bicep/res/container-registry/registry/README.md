# Azure Container Registry `[Microsoft.ContainerRegistry/registries]`

This module deploys Azure Container Registry.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Data Collection](#data-collection)

## Compliance

Version: 20240805

Compliant usage of Azure Container Registry requires:
- sku: 'premium'
- acrAdminUserEnabled: false
- publicNetworkAccess: 'Disabled'
- azureADAuthenticationAsArmPolicyStatus: 'enabled'
- anonymousPullEnabled: false


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.ContainerRegistry/registries` | 2023-01-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-01-01-preview/registries)</li></ul> |
| `Microsoft.ContainerRegistry/registries/cacheRules` | 2023-01-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries_cacherules.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-01-01-preview/registries/cacheRules)</li></ul> |
| `Microsoft.ContainerRegistry/registries/credentialSets` | 2023-01-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries_credentialsets.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-01-01-preview/registries/credentialSets)</li></ul> |
| `Microsoft.ContainerRegistry/registries/replications` | 2023-01-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries_replications.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-01-01-preview/registries/replications)</li></ul> |
| `Microsoft.ContainerRegistry/registries/scopeMaps` | 2023-01-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries_scopemaps.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-01-01-preview/registries/scopeMaps)</li></ul> |
| `Microsoft.ContainerRegistry/registries/webhooks` | 2023-01-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries_webhooks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-01-01-preview/registries/webhooks)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/container-registry/registry:<version>`.

- [Using only defaults](#example-1-using-only-defaults)
- [Using encryption with Customer-Managed-Key](#example-2-using-encryption-with-customer-managed-key)
- [Using large parameter set](#example-3-using-large-parameter-set)
- [Using `scopeMaps` in parameter set](#example-4-using-scopemaps-in-parameter-set)
- [WAF-aligned](#example-5-waf-aligned)

### Example 1: _Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module registryMod 'br/<registry-alias>:res/container-registry/registry:<version>' = {
  name: 'registry-mod'
  params: {
    // Required parameters
    name: 'crrmin001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    location: '<location>'
    sku: 'Standard'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-registry/registry:<version>'

// Required parameters
param name = 'crrmin001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param location = '<location>'
param sku = 'Standard'
```

</details>
<p>

### Example 2: _Using encryption with Customer-Managed-Key_

This instance deploys the module using Customer-Managed-Keys using a User-Assigned Identity to access the Customer-Managed-Key secret.


<details>

<summary>via Bicep module</summary>

```bicep
module registryMod 'br/<registry-alias>:res/container-registry/registry:<version>' = {
  name: 'registry-mod'
  params: {
    // Required parameters
    name: 'crrencr001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    customerManagedKey: {
      keyName: '<keyName>'
      keyVaultResourceId: '<keyVaultResourceId>'
      userAssignedIdentityResourceId: '<userAssignedIdentityResourceId>'
    }
    location: '<location>'
    managedIdentities: {
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    publicNetworkAccess: 'Disabled'
    sku: 'Premium'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-registry/registry:<version>'

// Required parameters
param name = 'crrencr001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param customerManagedKey = {
  keyName: '<keyName>'
  keyVaultResourceId: '<keyVaultResourceId>'
  userAssignedIdentityResourceId: '<userAssignedIdentityResourceId>'
}
param location = '<location>'
param managedIdentities = {
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param publicNetworkAccess = 'Disabled'
param sku = 'Premium'
```

</details>
<p>

### Example 3: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module registryMod 'br/<registry-alias>:res/container-registry/registry:<version>' = {
  name: 'registry-mod'
  params: {
    // Required parameters
    name: 'crrmax001'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
        tags: {
          Environment: 'Non-Prod'
          'hidden-title': 'This is visible in the resource name'
          Role: 'DeploymentValidation'
        }
      }
      {
        privateDnsZoneResourceIds: [
          '<privateDNSZoneResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    acrAdminUserEnabled: false
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    cacheRules: [
      {
        name: 'customRule'
        sourceRepository: 'docker.io/library/hello-world'
        targetRepository: 'cached-docker-hub/hello-world'
      }
      {
        sourceRepository: 'docker.io/library/hello-world'
        targetRepository: 'dummy'
      }
    ]
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        metricCategories: [
          {
            category: 'AllMetrics'
          }
        ]
        name: 'customSetting'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    exportPolicyStatus: 'enabled'
    location: '<location>'
    lock: {
      kind: 'CanNotDelete'
      name: 'myCustomLockName'
    }
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        '<managedIdentityResourceId>'
      ]
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    quarantinePolicyStatus: 'enabled'
    replications: [
      {
        name: '<name>'
        regionEndpointEnabled: true
        zoneRedundancy: 'Enabled'
      }
    ]
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    sku: 'Premium'
    softDeletePolicyDays: 7
    softDeletePolicyStatus: 'disabled'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    trustPolicyStatus: 'enabled'
    webhooks: [
      {
        action: [
          'chart_delete'
        ]
        name: 'acrx001webhook'
        serviceUri: 'https://www.contoso.com/webhook'
        status: 'enabled'
      }
    ]
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-registry/registry:<version>'

// Required parameters
param name = 'crrmax001'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
  {
    privateDnsZoneResourceIds: [
      '<privateDNSZoneResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param acrAdminUserEnabled = false
param azureADAuthenticationAsArmPolicyStatus = 'enabled'
param cacheRules = [
  {
    name: 'customRule'
    sourceRepository: 'docker.io/library/hello-world'
    targetRepository: 'cached-docker-hub/hello-world'
  }
  {
    sourceRepository: 'docker.io/library/hello-world'
    targetRepository: 'dummy'
  }
]
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    metricCategories: [
      {
        category: 'AllMetrics'
      }
    ]
    name: 'customSetting'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param exportPolicyStatus = 'enabled'
param location = '<location>'
param lock = {
  kind: 'CanNotDelete'
  name: 'myCustomLockName'
}
param managedIdentities = {
  systemAssigned: true
  userAssignedResourceIds: [
    '<managedIdentityResourceId>'
  ]
}
param networkAcls = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
}
param quarantinePolicyStatus = 'enabled'
param replications = [
  {
    name: '<name>'
    regionEndpointEnabled: true
    zoneRedundancy: 'Enabled'
  }
]
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param sku = 'Premium'
param softDeletePolicyDays = 7
param softDeletePolicyStatus = 'disabled'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param trustPolicyStatus = 'enabled'
param webhooks = [
  {
    action: [
      'chart_delete'
    ]
    name: 'acrx001webhook'
    serviceUri: 'https://www.contoso.com/webhook'
    status: 'enabled'
  }
]
```

</details>
<p>

### Example 4: _Using `scopeMaps` in parameter set_

This instance deploys the module with the scopeMaps feature.


<details>

<summary>via Bicep module</summary>

```bicep
module registryMod 'br/<registry-alias>:res/container-registry/registry:<version>' = {
  name: 'registry-mod'
  params: {
    // Required parameters
    name: 'crrs001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    location: '<location>'
    scopeMaps: [
      {
        actions: [
          'repositories/*/content/read'
        ]
        description: 'This is a test for scopeMaps feature.'
        name: 'testscopemap'
      }
    ]
    sku: 'Standard'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-registry/registry:<version>'

// Required parameters
param name = 'crrs001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param location = '<location>'
param scopeMaps = [
  {
    actions: [
      'repositories/*/content/read'
    ]
    description: 'This is a test for scopeMaps feature.'
    name: 'testscopemap'
  }
]
param sku = 'Standard'
```

</details>
<p>

### Example 5: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module registryMod 'br/<registry-alias>:res/container-registry/registry:<version>' = {
  name: 'registry-mod'
  params: {
    // Required parameters
    name: 'crrwaf001'
    privateEndpoints: [
      {
        privateDnsZoneResourceIds: [
          '<privateDNSResourceId>'
        ]
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    acrAdminUserEnabled: false
    azureADAuthenticationAsArmPolicyStatus: 'enabled'
    diagnosticSettings: [
      {
        eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
        eventHubName: '<eventHubName>'
        storageAccountResourceId: '<storageAccountResourceId>'
        workspaceResourceId: '<workspaceResourceId>'
      }
    ]
    exportPolicyStatus: 'enabled'
    location: '<location>'
    quarantinePolicyStatus: 'enabled'
    replications: [
      {
        name: '<name>'
        regionEndpointEnabled: true
        zoneRedundancy: 'Enabled'
      }
    ]
    sku: 'Premium'
    softDeletePolicyDays: 7
    softDeletePolicyStatus: 'disabled'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    trustPolicyStatus: 'enabled'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/container-registry/registry:<version>'

// Required parameters
param name = 'crrwaf001'
param privateEndpoints = [
  {
    privateDnsZoneResourceIds: [
      '<privateDNSResourceId>'
    ]
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param acrAdminUserEnabled = false
param azureADAuthenticationAsArmPolicyStatus = 'enabled'
param diagnosticSettings = [
  {
    eventHubAuthorizationRuleResourceId: '<eventHubAuthorizationRuleResourceId>'
    eventHubName: '<eventHubName>'
    storageAccountResourceId: '<storageAccountResourceId>'
    workspaceResourceId: '<workspaceResourceId>'
  }
]
param exportPolicyStatus = 'enabled'
param location = '<location>'
param quarantinePolicyStatus = 'enabled'
param replications = [
  {
    name: '<name>'
    regionEndpointEnabled: true
    zoneRedundancy: 'Enabled'
  }
]
param sku = 'Premium'
param softDeletePolicyDays = 7
param softDeletePolicyStatus = 'disabled'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param trustPolicyStatus = 'enabled'
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | Name of your Azure Container Registry. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`acrAdminUserEnabled`](#parameter-acradminuserenabled) | bool | Enable admin user that have push / pull permission to the registry.<p><p>Setting this parameter to any other than false, will make the Container Registry resource non-compliant. |
| [`anonymousPullEnabled`](#parameter-anonymouspullenabled) | bool | Enables registry-wide pull from unauthenticated clients. It's in preview and available in the Standard and Premium service tiers.<p><p>Setting this parameter to any other than 'false', will make the Container Registry resource non-compliant. |
| [`azureADAuthenticationAsArmPolicyStatus`](#parameter-azureadauthenticationasarmpolicystatus) | string | The value that indicates whether the policy for using ARM audience token for a container registr is enabled or not.<p><p>Setting this parameter to any other than 'Disabled' i.e. without Entra ID (Azure AD) authentication, will make the Container Registry resource non-compliant. |
| [`cacheRules`](#parameter-cacherules) | array | Array of Cache Rules. Note: This is a preview feature ([ref](https://learn.microsoft.com/en-us/azure/container-registry/tutorial-registry-cache#cache-for-acr-preview)). |
| [`credential`](#parameter-credential) | object | Credential object containing details to let you authenticate with public or private repository. |
| [`customerManagedKey`](#parameter-customermanagedkey) | object | The customer managed key definition. |
| [`dataEndpointEnabled`](#parameter-dataendpointenabled) | bool | Enable a single data endpoint per region for serving data. Not relevant in case of disabled public access. Note, requires the 'sku' to be 'Premium'. |
| [`diagnosticSettings`](#parameter-diagnosticsettings) | array | The diagnostic settings of the service. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`exportPolicyStatus`](#parameter-exportpolicystatus) | string | The value that indicates whether the export policy is enabled or not. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. |
| [`networkAcls`](#parameter-networkacls) | object | The IP ACL rules. Note, requires the 'sku' to be 'Premium'. |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.<p>Note, requires the \'sku\' to be \'Premium\'.<p><p>Configuring Container Registry without private endpoint, will make the Container Registry resource non-compliant. |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Whether or not public network access is allowed for this resource. For security reasons it should be disabled.<p>If not specified, it will be disabled by default if private endpoints are set and networkRuleSetIpRules are not set.  Note, requires the \'sku\' to be \'Premium\'.<p><p>Setting this parameter to any other than 'Disabled', will make the Container Registry resource non-compliant. |
| [`quarantinePolicyStatus`](#parameter-quarantinepolicystatus) | string | The value that indicates whether the quarantine policy is enabled or not. Note, requires the 'sku' to be 'Premium'. |
| [`replications`](#parameter-replications) | array | All replications to create. |
| [`retentionPolicyDays`](#parameter-retentionpolicydays) | int | The number of days to retain an untagged manifest after which it gets purged. |
| [`retentionPolicyStatus`](#parameter-retentionpolicystatus) | string | The value that indicates whether the retention policy is enabled or not. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`scopeMaps`](#parameter-scopemaps) | array | Scope maps setting. |
| [`sku`](#parameter-sku) | string | Tier of your Azure container registry.<p><p>Setting this parameter to any other than 'Premium', won't allow to apply the configurations to make this resource compliant. |
| [`softDeletePolicyDays`](#parameter-softdeletepolicydays) | int | The number of days after which a soft-deleted item is permanently deleted. |
| [`softDeletePolicyStatus`](#parameter-softdeletepolicystatus) | string | Soft Delete policy status. Default is disabled.<p><p>Disable Zone redundancy and Remove geo-replications in order to use soft delete. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`trustPolicyStatus`](#parameter-trustpolicystatus) | string | The value that indicates whether the trust policy is enabled or not. Note, requires the 'sku' to be 'Premium'. |
| [`webhooks`](#parameter-webhooks) | array | All webhooks to create. |
| [`zoneRedundancy`](#parameter-zoneredundancy) | string | Whether or not zone redundancy is enabled for this container registry. |

### Parameter: `name`

Name of your Azure Container Registry.

- Required: Yes
- Type: string

### Parameter: `acrAdminUserEnabled`

Enable admin user that have push / pull permission to the registry.<p><p>Setting this parameter to any other than false, will make the Container Registry resource non-compliant.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `anonymousPullEnabled`

Enables registry-wide pull from unauthenticated clients. It's in preview and available in the Standard and Premium service tiers.<p><p>Setting this parameter to any other than 'false', will make the Container Registry resource non-compliant.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `azureADAuthenticationAsArmPolicyStatus`

The value that indicates whether the policy for using ARM audience token for a container registr is enabled or not.<p><p>Setting this parameter to any other than 'Disabled' i.e. without Entra ID (Azure AD) authentication, will make the Container Registry resource non-compliant.

- Required: No
- Type: string
- Default: `'enabled'`
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `cacheRules`

Array of Cache Rules. Note: This is a preview feature ([ref](https://learn.microsoft.com/en-us/azure/container-registry/tutorial-registry-cache#cache-for-acr-preview)).

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`sourceRepository`](#parameter-cacherulessourcerepository) | string | The full repository path of your source repository. For example 'docker.io/library/hello-world' |
| [`targetRepository`](#parameter-cacherulestargetrepository) | string | The repository namespace for your target repository. For example 'hello-world' |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`credentialId`](#parameter-cacherulescredentialid) | string | Resource Id of credential object. |
| [`name`](#parameter-cacherulesname) | string | The name of the cache rule. |

### Parameter: `cacheRules.sourceRepository`

The full repository path of your source repository. For example 'docker.io/library/hello-world'

- Required: Yes
- Type: string

### Parameter: `cacheRules.targetRepository`

The repository namespace for your target repository. For example 'hello-world'

- Required: Yes
- Type: string

### Parameter: `cacheRules.credentialId`

Resource Id of credential object.

- Required: No
- Type: string

### Parameter: `cacheRules.name`

The name of the cache rule.

- Required: No
- Type: string

### Parameter: `credential`

Credential object containing details to let you authenticate with public or private repository.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`loginServer`](#parameter-credentialloginserver) | string | The login server of your source registry. |
| [`name`](#parameter-credentialname) | string | The name of the credential. |
| [`passwordSecretIdentifier`](#parameter-credentialpasswordsecretidentifier) | string | KeyVault Secret URI for accessing the password. |
| [`usernameSecretIdentifier`](#parameter-credentialusernamesecretidentifier) | string | KeyVault Secret URI for accessing the username. |

### Parameter: `credential.loginServer`

The login server of your source registry.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'docker.io'
    'ghcr.io'
    'quay.io'
  ]
  ```

### Parameter: `credential.name`

The name of the credential.

- Required: Yes
- Type: string

### Parameter: `credential.passwordSecretIdentifier`

KeyVault Secret URI for accessing the password.

- Required: Yes
- Type: string

### Parameter: `credential.usernameSecretIdentifier`

KeyVault Secret URI for accessing the username.

- Required: Yes
- Type: string

### Parameter: `customerManagedKey`

The customer managed key definition.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`keyName`](#parameter-customermanagedkeykeyname) | string | The name of the customer managed key to use for encryption. |
| [`keyVaultResourceId`](#parameter-customermanagedkeykeyvaultresourceid) | string | The resource ID of a key vault to reference a customer managed key for encryption from. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`autoRotationEnabled`](#parameter-customermanagedkeyautorotationenabled) | bool | Enable or disable auto-rotating to the latest key version. Default is true. If set to false, the latest key version at the time of the deployment is used. |
| [`keyVersion`](#parameter-customermanagedkeykeyversion) | string | The version of the customer managed key to reference for encryption. If not provided, using 'latest'. |
| [`userAssignedIdentityResourceId`](#parameter-customermanagedkeyuserassignedidentityresourceid) | string | User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use. |

### Parameter: `customerManagedKey.keyName`

The name of the customer managed key to use for encryption.

- Required: Yes
- Type: string

### Parameter: `customerManagedKey.keyVaultResourceId`

The resource ID of a key vault to reference a customer managed key for encryption from.

- Required: Yes
- Type: string

### Parameter: `customerManagedKey.autoRotationEnabled`

Enable or disable auto-rotating to the latest key version. Default is true. If set to false, the latest key version at the time of the deployment is used.

- Required: No
- Type: bool

### Parameter: `customerManagedKey.keyVersion`

The version of the customer managed key to reference for encryption. If not provided, using 'latest'.

- Required: No
- Type: string

### Parameter: `customerManagedKey.userAssignedIdentityResourceId`

User assigned identity to use when fetching the customer managed key. Required if no system assigned identity is available for use.

- Required: No
- Type: string

### Parameter: `dataEndpointEnabled`

Enable a single data endpoint per region for serving data. Not relevant in case of disabled public access. Note, requires the 'sku' to be 'Premium'.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `diagnosticSettings`

The diagnostic settings of the service.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`eventHubAuthorizationRuleResourceId`](#parameter-diagnosticsettingseventhubauthorizationruleresourceid) | string | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| [`eventHubName`](#parameter-diagnosticsettingseventhubname) | string | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`logAnalyticsDestinationType`](#parameter-diagnosticsettingsloganalyticsdestinationtype) | string | A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type. |
| [`logCategoriesAndGroups`](#parameter-diagnosticsettingslogcategoriesandgroups) | array | The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection. |
| [`marketplacePartnerResourceId`](#parameter-diagnosticsettingsmarketplacepartnerresourceid) | string | The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs. |
| [`metricCategories`](#parameter-diagnosticsettingsmetriccategories) | array | The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection. |
| [`name`](#parameter-diagnosticsettingsname) | string | The name of diagnostic setting. |
| [`storageAccountResourceId`](#parameter-diagnosticsettingsstorageaccountresourceid) | string | Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |
| [`workspaceResourceId`](#parameter-diagnosticsettingsworkspaceresourceid) | string | Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub. |

### Parameter: `diagnosticSettings.eventHubAuthorizationRuleResourceId`

Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.eventHubName`

Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logAnalyticsDestinationType`

A string indicating whether the export to Log Analytics should use the default destination type, i.e. AzureDiagnostics, or use a destination type.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureDiagnostics'
    'Dedicated'
  ]
  ```

### Parameter: `diagnosticSettings.logCategoriesAndGroups`

The name of logs that will be streamed ("allLogs" is not supported, see module documentation for the list of supported). Set to `[]` to disable log collection.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingslogcategoriesandgroupscategory) | string | Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here. |
| [`categoryGroup`](#parameter-diagnosticsettingslogcategoriesandgroupscategorygroup) | string | Name of a Diagnostic Log category group for a resource type this setting is applied to. |
| [`enabled`](#parameter-diagnosticsettingslogcategoriesandgroupsenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.logCategoriesAndGroups.category`

Name of a Diagnostic Log category for a resource type this setting is applied to. Set the specific logs to collect here.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.categoryGroup`

Name of a Diagnostic Log category group for a resource type this setting is applied to.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.logCategoriesAndGroups.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.marketplacePartnerResourceId`

The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic Logs.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.metricCategories`

The name of metrics that will be streamed. "allMetrics" includes all possible metrics for the resource. Set to `[]` to disable metric collection.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`category`](#parameter-diagnosticsettingsmetriccategoriescategory) | string | Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enabled`](#parameter-diagnosticsettingsmetriccategoriesenabled) | bool | Enable or disable the category explicitly. Default is `true`. |

### Parameter: `diagnosticSettings.metricCategories.category`

Name of a Diagnostic Metric category for a resource type this setting is applied to. Set to `AllMetrics` to collect all metrics.

- Required: Yes
- Type: string

### Parameter: `diagnosticSettings.metricCategories.enabled`

Enable or disable the category explicitly. Default is `true`.

- Required: No
- Type: bool

### Parameter: `diagnosticSettings.name`

The name of diagnostic setting.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.storageAccountResourceId`

Resource ID of the diagnostic storage account. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `diagnosticSettings.workspaceResourceId`

Resource ID of the diagnostic log analytics workspace. For security reasons, it is recommended to set diagnostic settings to send data to either storage account, log analytics workspace or event hub.

- Required: No
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `exportPolicyStatus`

The value that indicates whether the export policy is enabled or not.

- Required: No
- Type: string
- Default: `'disabled'`
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `location`

Location for all resources.

- Required: No
- Type: string
- Default: `[resourceGroup().location]`

### Parameter: `lock`

The lock settings of the service.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-lockkind) | string | Specify the type of lock. |
| [`name`](#parameter-lockname) | string | Specify the name of lock. |

### Parameter: `lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `managedIdentities`

The managed identity definition for this resource.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      systemAssigned: true
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`systemAssigned`](#parameter-managedidentitiessystemassigned) | bool | Enables system assigned managed identity on the resource. |
| [`userAssignedResourceIds`](#parameter-managedidentitiesuserassignedresourceids) | array | The resource ID(s) to assign to the resource. |

### Parameter: `managedIdentities.systemAssigned`

Enables system assigned managed identity on the resource.

- Required: No
- Type: bool

### Parameter: `managedIdentities.userAssignedResourceIds`

The resource ID(s) to assign to the resource.

- Required: No
- Type: array

### Parameter: `networkAcls`

The IP ACL rules. Note, requires the 'sku' to be 'Premium'.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
  }
  ```

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`bypass`](#parameter-networkaclsbypass) | string | Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics. |
| [`defaultAction`](#parameter-networkaclsdefaultaction) | string | Specifies the default action of allow or deny when no other rules match. |
| [`ipRules`](#parameter-networkaclsiprules) | array | Sets the IP ACL rules. |
| [`resourceAccessRules`](#parameter-networkaclsresourceaccessrules) | array | Sets the resource access rules. Array entries must consist of "tenantId" and "resourceId" fields only. |
| [`virtualNetworkRules`](#parameter-networkaclsvirtualnetworkrules) | array | Sets the virtual network rules. |

### Parameter: `networkAcls.bypass`

Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Possible values are any combination of Logging,Metrics,AzureServices (For example, "Logging, Metrics"), or None to bypass none of those traffics.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureServices'
    'AzureServices, Logging'
    'AzureServices, Logging, Metrics'
    'AzureServices, Metrics'
    'Logging'
    'Logging, Metrics'
    'Metrics'
    'None'
  ]
  ```

### Parameter: `networkAcls.defaultAction`

Specifies the default action of allow or deny when no other rules match.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Allow'
    'Deny'
  ]
  ```

### Parameter: `networkAcls.ipRules`

Sets the IP ACL rules.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`action`](#parameter-networkaclsiprulesaction) | string | The action of IP ACL rule. |
| [`value`](#parameter-networkaclsiprulesvalue) | string | Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. |

### Parameter: `networkAcls.ipRules.action`

The action of IP ACL rule.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Allow'
  ]
  ```

### Parameter: `networkAcls.ipRules.value`

Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed.

- Required: Yes
- Type: string

### Parameter: `networkAcls.resourceAccessRules`

Sets the resource access rules. Array entries must consist of "tenantId" and "resourceId" fields only.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`resourceId`](#parameter-networkaclsresourceaccessrulesresourceid) | string | The resource ID of the target service. Can also contain a * wildcard, if multiple services e.g. in a resource group should be included. For example: /subscriptions/{subscriptionId}/resourceGroups/*/providers/Microsoft.Databricks/accessConnectors/* |
| [`tenantId`](#parameter-networkaclsresourceaccessrulestenantid) | string | The ID of the tenant in which the resource resides in. |

### Parameter: `networkAcls.resourceAccessRules.resourceId`

The resource ID of the target service. Can also contain a * wildcard, if multiple services e.g. in a resource group should be included. For example: /subscriptions/{subscriptionId}/resourceGroups/*/providers/Microsoft.Databricks/accessConnectors/*

- Required: Yes
- Type: string

### Parameter: `networkAcls.resourceAccessRules.tenantId`

The ID of the tenant in which the resource resides in.

- Required: Yes
- Type: string

### Parameter: `networkAcls.virtualNetworkRules`

Sets the virtual network rules.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-networkaclsvirtualnetworkrulesid) | string | Resource ID of a subnet, for example: /subscriptions/{subscriptionId}/resourceGroups/{groupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}.<p> |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`action`](#parameter-networkaclsvirtualnetworkrulesaction) | string | The action of virtual network rule. |
| [`state`](#parameter-networkaclsvirtualnetworkrulesstate) | string | Gets the state of virtual network rule:<p>'Deprovisioning'<p>'Failed'<p>'NetworkSourceDeleted'<p>'Provisioning'<p>'Succeeded' |

### Parameter: `networkAcls.virtualNetworkRules.id`

Resource ID of a subnet, for example: /subscriptions/{subscriptionId}/resourceGroups/{groupName}/providers/Microsoft.Network/virtualNetworks/{vnetName}/subnets/{subnetName}.<p>

- Required: Yes
- Type: string

### Parameter: `networkAcls.virtualNetworkRules.action`

The action of virtual network rule.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Allow'
  ]
  ```

### Parameter: `networkAcls.virtualNetworkRules.state`

Gets the state of virtual network rule:<p>'Deprovisioning'<p>'Failed'<p>'NetworkSourceDeleted'<p>'Provisioning'<p>'Succeeded'

- Required: No
- Type: string

### Parameter: `privateEndpoints`

Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.<p>Note, requires the \'sku\' to be \'Premium\'.<p><p>Configuring Container Registry without private endpoint, will make the Container Registry resource non-compliant.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnetResourceId`](#parameter-privateendpointssubnetresourceid) | string | Resource ID of the subnet where the endpoint needs to be created. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`service`](#parameter-privateendpointsservice) | string | If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationSecurityGroupResourceIds`](#parameter-privateendpointsapplicationsecuritygroupresourceids) | array | Application security groups in which the private endpoint IP configuration is included. |
| [`customDnsConfigs`](#parameter-privateendpointscustomdnsconfigs) | array | Custom DNS configurations. |
| [`customNetworkInterfaceName`](#parameter-privateendpointscustomnetworkinterfacename) | string | The custom name of the network interface attached to the private endpoint. |
| [`enableTelemetry`](#parameter-privateendpointsenabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`ipConfigurations`](#parameter-privateendpointsipconfigurations) | array | A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints. |
| [`isManualConnection`](#parameter-privateendpointsismanualconnection) | bool | If Manual Private Link Connection is required. |
| [`location`](#parameter-privateendpointslocation) | string | The location to deploy the private endpoint to. |
| [`lock`](#parameter-privateendpointslock) | object | Specify the type of lock. |
| [`manualConnectionRequestMessage`](#parameter-privateendpointsmanualconnectionrequestmessage) | string | A message passed to the owner of the remote resource with the manual connection request. |
| [`name`](#parameter-privateendpointsname) | string | The name of the private endpoint. |
| [`privateDnsZoneGroupName`](#parameter-privateendpointsprivatednszonegroupname) | string | The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided. |
| [`privateDnsZoneResourceIds`](#parameter-privateendpointsprivatednszoneresourceids) | array | The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones. |
| [`privateLinkServiceConnectionName`](#parameter-privateendpointsprivatelinkserviceconnectionname) | string | The name of the private link connection to create. |
| [`resourceGroupName`](#parameter-privateendpointsresourcegroupname) | string | Specify if you want to deploy the Private Endpoint into a different resource group than the main resource. |
| [`roleAssignments`](#parameter-privateendpointsroleassignments) | array | Array of role assignments to create. |
| [`tags`](#parameter-privateendpointstags) | object | Tags to be applied on all resources/resource groups in this deployment. |

### Parameter: `privateEndpoints.subnetResourceId`

Resource ID of the subnet where the endpoint needs to be created.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.service`

If the resource supports multiple endpoints, specify the sub-resource to deploy the private endpoint for.<p>For example "blob", "table", "queue" or "file".<p><p>See https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource

- Required: No
- Type: string

### Parameter: `privateEndpoints.applicationSecurityGroupResourceIds`

Application security groups in which the private endpoint IP configuration is included.

- Required: No
- Type: array

### Parameter: `privateEndpoints.customDnsConfigs`

Custom DNS configurations.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`fqdn`](#parameter-privateendpointscustomdnsconfigsfqdn) | string | Fqdn that resolves to private endpoint IP address. |
| [`ipAddresses`](#parameter-privateendpointscustomdnsconfigsipaddresses) | array | A list of private IP addresses of the private endpoint. |

### Parameter: `privateEndpoints.customDnsConfigs.fqdn`

Fqdn that resolves to private endpoint IP address.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.customDnsConfigs.ipAddresses`

A list of private IP addresses of the private endpoint.

- Required: Yes
- Type: array

### Parameter: `privateEndpoints.customNetworkInterfaceName`

The custom name of the network interface attached to the private endpoint.

- Required: No
- Type: string

### Parameter: `privateEndpoints.enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool

### Parameter: `privateEndpoints.ipConfigurations`

A list of IP configurations of the private endpoint. This will be used to map to the First Party Service endpoints.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-privateendpointsipconfigurationsname) | string | The name of the resource that is unique within a resource group. |
| [`properties`](#parameter-privateendpointsipconfigurationsproperties) | object | Properties of private endpoint IP configurations. |

### Parameter: `privateEndpoints.ipConfigurations.name`

The name of the resource that is unique within a resource group.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties`

Properties of private endpoint IP configurations.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`groupId`](#parameter-privateendpointsipconfigurationspropertiesgroupid) | string | The ID of a group obtained from the remote resource that this private endpoint should connect to. |
| [`memberName`](#parameter-privateendpointsipconfigurationspropertiesmembername) | string | The member name of a group obtained from the remote resource that this private endpoint should connect to. |
| [`privateIPAddress`](#parameter-privateendpointsipconfigurationspropertiesprivateipaddress) | string | A private IP address obtained from the private endpoint's subnet. |

### Parameter: `privateEndpoints.ipConfigurations.properties.groupId`

The ID of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties.memberName`

The member name of a group obtained from the remote resource that this private endpoint should connect to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.ipConfigurations.properties.privateIPAddress`

A private IP address obtained from the private endpoint's subnet.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.isManualConnection`

If Manual Private Link Connection is required.

- Required: No
- Type: bool

### Parameter: `privateEndpoints.location`

The location to deploy the private endpoint to.

- Required: No
- Type: string

### Parameter: `privateEndpoints.lock`

Specify the type of lock.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`kind`](#parameter-privateendpointslockkind) | string | Specify the type of lock. |
| [`name`](#parameter-privateendpointslockname) | string | Specify the name of lock. |

### Parameter: `privateEndpoints.lock.kind`

Specify the type of lock.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'CanNotDelete'
    'None'
    'ReadOnly'
  ]
  ```

### Parameter: `privateEndpoints.lock.name`

Specify the name of lock.

- Required: No
- Type: string

### Parameter: `privateEndpoints.manualConnectionRequestMessage`

A message passed to the owner of the remote resource with the manual connection request.

- Required: No
- Type: string

### Parameter: `privateEndpoints.name`

The name of the private endpoint.

- Required: No
- Type: string

### Parameter: `privateEndpoints.privateDnsZoneGroupName`

The name of the private DNS zone group to create if `privateDnsZoneResourceIds` were provided.

- Required: No
- Type: string

### Parameter: `privateEndpoints.privateDnsZoneResourceIds`

The private DNS zone groups to associate the private endpoint with. A DNS zone group can support up to 5 DNS zones.

- Required: No
- Type: array

### Parameter: `privateEndpoints.privateLinkServiceConnectionName`

The name of the private link connection to create.

- Required: No
- Type: string

### Parameter: `privateEndpoints.resourceGroupName`

Specify if you want to deploy the Private Endpoint into a different resource group than the main resource.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'DNS Resolver Contributor'`
  - `'DNS Zone Contributor'`
  - `'Domain Services Contributor'`
  - `'Domain Services Reader'`
  - `'Network Contributor'`
  - `'Private DNS Zone Contributor'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-privateendpointsroleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-privateendpointsroleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-privateendpointsroleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-privateendpointsroleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-privateendpointsroleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-privateendpointsroleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-privateendpointsroleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `privateEndpoints.roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints.roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `privateEndpoints.roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `privateEndpoints.roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `privateEndpoints.tags`

Tags to be applied on all resources/resource groups in this deployment.

- Required: No
- Type: object

### Parameter: `publicNetworkAccess`

Whether or not public network access is allowed for this resource. For security reasons it should be disabled.<p>If not specified, it will be disabled by default if private endpoints are set and networkRuleSetIpRules are not set.  Note, requires the \'sku\' to be \'Premium\'.<p><p>Setting this parameter to any other than 'Disabled', will make the Container Registry resource non-compliant.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `quarantinePolicyStatus`

The value that indicates whether the quarantine policy is enabled or not. Note, requires the 'sku' to be 'Premium'.

- Required: No
- Type: string
- Default: `'disabled'`
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `replications`

All replications to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-replicationsname) | string | Name of the replication. |
| [`regionEndpointEnabled`](#parameter-replicationsregionendpointenabled) | bool | Specifies whether the replication's regional endpoint is enabled. Requests will not be routed to a replication whose regional endpoint is disabled, <p>however its data will continue to be synced with other replications |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`zoneRedundancy`](#parameter-replicationszoneredundancy) | string | Whether or not zone redundancy is enabled for this container registry. |

### Parameter: `replications.name`

Name of the replication.

- Required: Yes
- Type: string

### Parameter: `replications.regionEndpointEnabled`

Specifies whether the replication's regional endpoint is enabled. Requests will not be routed to a replication whose regional endpoint is disabled, <p>however its data will continue to be synced with other replications

- Required: Yes
- Type: bool

### Parameter: `replications.zoneRedundancy`

Whether or not zone redundancy is enabled for this container registry.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `retentionPolicyDays`

The number of days to retain an untagged manifest after which it gets purged.

- Required: No
- Type: int
- Default: `15`

### Parameter: `retentionPolicyStatus`

The value that indicates whether the retention policy is enabled or not.

- Required: No
- Type: string
- Default: `'enabled'`
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'AcrDelete'`
  - `'AcrImageSigner'`
  - `'AcrPull'`
  - `'AcrPush'`
  - `'AcrQuarantineReader'`
  - `'AcrQuarantineWriter'`

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-roleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-roleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-roleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-roleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-roleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-roleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-roleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `roleAssignments.principalType`

The principal type of the assigned principal ID.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Device'
    'ForeignGroup'
    'Group'
    'ServicePrincipal'
    'User'
  ]
  ```

### Parameter: `scopeMaps`

Scope maps setting.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`actions`](#parameter-scopemapsactions) | array | The list of scoped permissions for registry artifacts. Supported format is <resource type>/<resource name>/<resource action>.<p>See https://aka.ms/acr/repo-permissions to find the supported resources and actions. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-scopemapsdescription) | string | The user friendly description of the scope map. |
| [`name`](#parameter-scopemapsname) | string | The name of the scope map. |

### Parameter: `scopeMaps.actions`

The list of scoped permissions for registry artifacts. Supported format is <resource type>/<resource name>/<resource action>.<p>See https://aka.ms/acr/repo-permissions to find the supported resources and actions.

- Required: Yes
- Type: array

### Parameter: `scopeMaps.description`

The user friendly description of the scope map.

- Required: No
- Type: string

### Parameter: `scopeMaps.name`

The name of the scope map.

- Required: No
- Type: string

### Parameter: `sku`

Tier of your Azure container registry.<p><p>Setting this parameter to any other than 'Premium', won't allow to apply the configurations to make this resource compliant.

- Required: No
- Type: string
- Default: `'Premium'`
- Allowed:
  ```Bicep
  [
    'Basic'
    'Premium'
    'Standard'
  ]
  ```

### Parameter: `softDeletePolicyDays`

The number of days after which a soft-deleted item is permanently deleted.

- Required: No
- Type: int
- Default: `7`

### Parameter: `softDeletePolicyStatus`

Soft Delete policy status. Default is disabled.<p><p>Disable Zone redundancy and Remove geo-replications in order to use soft delete.

- Required: No
- Type: string
- Default: `'disabled'`
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `trustPolicyStatus`

The value that indicates whether the trust policy is enabled or not. Note, requires the 'sku' to be 'Premium'.

- Required: No
- Type: string
- Default: `'disabled'`
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `webhooks`

All webhooks to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`action`](#parameter-webhooksaction) | array | Actions that will trigger the webhook to post notifications.<p>Select one or more from 'chart_delete', 'chart_push', 'delete', 'push', 'quarantine' |
| [`name`](#parameter-webhooksname) | string | Name of the webhook. |
| [`serviceUri`](#parameter-webhooksserviceuri) | string | The service URI for the webhook to post notifications. |
| [`status`](#parameter-webhooksstatus) | string | Indicates whether the webhook is activated or deactivated. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`scope`](#parameter-webhooksscope) | string | The scope of repositories where the event can be triggered.<p>For example, 'foo:*' means events for all tags under repository 'foo'. 'foo:bar' means events for 'foo:bar' only. 'foo' is equivalent to 'foo:latest'.<p>Empty means events for all repositories.<p> |

**Optioanl parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`customHeaders`](#parameter-webhookscustomheaders) | object | Custom headers that will be added to the webhook notifications. Specify each header in 'Key:Value' format in each line. |

### Parameter: `webhooks.action`

Actions that will trigger the webhook to post notifications.<p>Select one or more from 'chart_delete', 'chart_push', 'delete', 'push', 'quarantine'

- Required: Yes
- Type: array
- Allowed:
  ```Bicep
  [
    'chart_delete'
    'chart_push'
    'delete'
    'push'
    'quarantine'
  ]
  ```

### Parameter: `webhooks.name`

Name of the webhook.

- Required: Yes
- Type: string

### Parameter: `webhooks.serviceUri`

The service URI for the webhook to post notifications.

- Required: Yes
- Type: string

### Parameter: `webhooks.status`

Indicates whether the webhook is activated or deactivated.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'disabled'
    'enabled'
  ]
  ```

### Parameter: `webhooks.scope`

The scope of repositories where the event can be triggered.<p>For example, 'foo:*' means events for all tags under repository 'foo'. 'foo:bar' means events for 'foo:bar' only. 'foo' is equivalent to 'foo:latest'.<p>Empty means events for all repositories.<p>

- Required: No
- Type: string

### Parameter: `webhooks.customHeaders`

Custom headers that will be added to the webhook notifications. Specify each header in 'Key:Value' format in each line.

- Required: No
- Type: object

### Parameter: `zoneRedundancy`

Whether or not zone redundancy is enabled for this container registry.

- Required: No
- Type: string
- Default: `'Enabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `loginServer` | string | The reference to the Azure container registry. |
| `name` | string | The Name of the Azure container registry. |
| `resourceGroupName` | string | The name of the Azure container registry. |
| `resourceId` | string | The resource ID of the Azure container registry. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
