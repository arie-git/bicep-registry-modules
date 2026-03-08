# Static Web Apps (early preview) `[Microsoft.Web/staticSites]`

This module deploys a Static Web App.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Data Collection](#data-collection)

## Compliance

Version: 20241111

Compliant usage of Static Web App requires:

- publicNetworkAccess: 'Disabled'


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |
| `Microsoft.Web/staticSites` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_staticsites.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/staticSites)</li></ul> |
| `Microsoft.Web/staticSites/config` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_staticsites_config.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/staticSites/config)</li></ul> |
| `Microsoft.Web/staticSites/customDomains` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_staticsites_customdomains.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/staticSites/customDomains)</li></ul> |
| `Microsoft.Web/staticSites/linkedBackends` | 2024-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.web_staticsites_linkedbackends.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Web/2024-04-01/staticSites/linkedBackends)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/web/static-site:<version>`.

- [(Not working) Using only defaults](#example-1-not-working-using-only-defaults)
- [(Not working) Using large parameter set](#example-2-not-working-using-large-parameter-set)
- [(Not working) WAF-aligned](#example-3-not-working-waf-aligned)

### Example 1: _(Not working) Using only defaults_

This instance deploys the module with the minimum set of required parameters.


<details>

<summary>via Bicep module</summary>

```bicep
module staticSiteMod 'br/<registry-alias>:res/web/static-site:<version>' = {
  name: 'staticSite-mod'
  params: {
    // Required parameters
    buildProperties: {
      appLocation: '/'
    }
    name: 'defwss001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/static-site:<version>'

// Required parameters
param buildProperties = {
  appLocation: '/'
}
param name = 'defwss001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param location = '<location>'
```

</details>
<p>

### Example 2: _(Not working) Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module staticSiteMod 'br/<registry-alias>:res/web/static-site:<version>' = {
  name: 'staticSite-mod'
  params: {
    // Required parameters
    buildProperties: {
      appLocation: '/'
      skipGithubActionWorkflowGeneration: true
    }
    name: 'wssmax001'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    allowConfigFileUpdates: true
    appSettings: {
      foo: 'bar'
      setting: 1
    }
    enterpriseGradeCdnStatus: 'Disabled'
    functionAppSettings: {
      foo: 'bar'
      setting: 1
    }
    linkedBackend: {
      backendResourceId: '<backendResourceId>'
      name: 'somename'
    }
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
    sku: 'Standard'
    stagingEnvironmentPolicy: 'Enabled'
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/static-site:<version>'

// Required parameters
param buildProperties = {
  appLocation: '/'
  skipGithubActionWorkflowGeneration: true
}
param name = 'wssmax001'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param allowConfigFileUpdates = true
param appSettings = {
  foo: 'bar'
  setting: 1
}
param enterpriseGradeCdnStatus = 'Disabled'
param functionAppSettings = {
  foo: 'bar'
  setting: 1
}
param linkedBackend = {
  backendResourceId: '<backendResourceId>'
  name: 'somename'
}
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
param sku = 'Standard'
param stagingEnvironmentPolicy = 'Enabled'
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
```

</details>
<p>

### Example 3: _(Not working) WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module staticSiteMod 'br/<registry-alias>:res/web/static-site:<version>' = {
  name: 'staticSite-mod'
  params: {
    // Required parameters
    buildProperties: {
      appLocation: '/'
    }
    name: 'wafwss01'
    privateEndpoints: [
      {
        subnetResourceId: '<subnetResourceId>'
      }
    ]
    // Non-required parameters
    location: '<location>'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/web/static-site:<version>'

// Required parameters
param buildProperties = {
  appLocation: '/'
}
param name = 'wafwss01'
param privateEndpoints = [
  {
    subnetResourceId: '<subnetResourceId>'
  }
]
// Non-required parameters
param location = '<location>'
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the static site. |
| [`privateEndpoints`](#parameter-privateendpoints) | array | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.<p>Note, requires the 'sku' to be 'Standard'.<p><p>Available values for 'service' are:<li>staticSites<p><p>Default: staticSites is used if at least one subnetResourceId is provided but 'service' is not specified.<p> |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`allowConfigFileUpdates`](#parameter-allowconfigfileupdates) | bool | False if config file is locked for this static web app; otherwise, true. |
| [`appSettings`](#parameter-appsettings) | object | Static site app settings. |
| [`branch`](#parameter-branch) | string | The branch name of the GitHub repository. |
| [`buildProperties`](#parameter-buildproperties) | object | Build properties for the static site. |
| [`customDomains`](#parameter-customdomains) | array | The custom domains associated with this static site. The deployment will fail as long as the validation records are not present. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`enterpriseGradeCdnStatus`](#parameter-enterprisegradecdnstatus) | string | State indicating the status of the enterprise grade CDN serving traffic to the static web app. |
| [`functionAppSettings`](#parameter-functionappsettings) | object | Function app settings. |
| [`linkedBackend`](#parameter-linkedbackend) | object | Object with "resourceId" and "location" of the a user defined function app. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`lock`](#parameter-lock) | object | The lock settings of the service. |
| [`managedIdentities`](#parameter-managedidentities) | object | The managed identity definition for this resource. |
| [`provider`](#parameter-provider) | string | The provider that submitted the last deployment to the primary environment of the static site. |
| [`publicNetworkAccess`](#parameter-publicnetworkaccess) | string | Property to enable or disable public traffic for the Static Web App.<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.<p> |
| [`repositoryToken`](#parameter-repositorytoken) | securestring | The Personal Access Token for accessing the GitHub repository. |
| [`repositoryUrl`](#parameter-repositoryurl) | string | The name of the GitHub repository. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`sku`](#parameter-sku) | string | The service tier and name of the resource SKU.<p><p>Setting any other value than Standard will make the resource noncompliant.<p> |
| [`stagingEnvironmentPolicy`](#parameter-stagingenvironmentpolicy) | string | State indicating whether staging environments are allowed or not allowed for a static web app. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`templateProperties`](#parameter-templateproperties) | object | Template Options for the static site. |

### Parameter: `name`

The name of the static site.

- Required: Yes
- Type: string

### Parameter: `privateEndpoints`

Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.<p>Note, requires the 'sku' to be 'Standard'.<p><p>Available values for 'service' are:<li>staticSites<p><p>Default: staticSites is used if at least one subnetResourceId is provided but 'service' is not specified.<p>

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

### Parameter: `allowConfigFileUpdates`

False if config file is locked for this static web app; otherwise, true.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `appSettings`

Static site app settings.

- Required: No
- Type: object
- Default: `{}`

### Parameter: `branch`

The branch name of the GitHub repository.

- Required: No
- Type: string

### Parameter: `buildProperties`

Build properties for the static site.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`appLocation`](#parameter-buildpropertiesapplocation) | string | Location of your application code. For example, '/' represents the root of your app, while '/app' represents a directory called 'app'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`apiBuildCommand`](#parameter-buildpropertiesapibuildcommand) | string | Command preset for API build action. |
| [`apiLocation`](#parameter-buildpropertiesapilocation) | string | Location of your application code. For example, '/' represents the root of your app, while '/app' represents a directory called 'app'. |
| [`appBuildCommand`](#parameter-buildpropertiesappbuildcommand) | string | Command preset for APP build action. |
| [`githubActionSecretNameOverride`](#parameter-buildpropertiesgithubactionsecretnameoverride) | string | Github Action secret name override. |
| [`outputLocation`](#parameter-buildpropertiesoutputlocation) | string | The path of your build output relative to your apps location.<p>For example, setting a value of 'build' when your app location is set to '/app' will cause the content at '/app/build' to be served.<p> |
| [`skipGithubActionWorkflowGeneration`](#parameter-buildpropertiesskipgithubactionworkflowgeneration) | bool | Whether to skip Github Action Workflow generation. |

### Parameter: `buildProperties.appLocation`

Location of your application code. For example, '/' represents the root of your app, while '/app' represents a directory called 'app'.

- Required: Yes
- Type: string

### Parameter: `buildProperties.apiBuildCommand`

Command preset for API build action.

- Required: No
- Type: string

### Parameter: `buildProperties.apiLocation`

Location of your application code. For example, '/' represents the root of your app, while '/app' represents a directory called 'app'.

- Required: No
- Type: string

### Parameter: `buildProperties.appBuildCommand`

Command preset for APP build action.

- Required: No
- Type: string

### Parameter: `buildProperties.githubActionSecretNameOverride`

Github Action secret name override.

- Required: No
- Type: string

### Parameter: `buildProperties.outputLocation`

The path of your build output relative to your apps location.<p>For example, setting a value of 'build' when your app location is set to '/app' will cause the content at '/app/build' to be served.<p>

- Required: No
- Type: string

### Parameter: `buildProperties.skipGithubActionWorkflowGeneration`

Whether to skip Github Action Workflow generation.

- Required: No
- Type: bool
- Allowed:
  ```Bicep
  [
    true
  ]
  ```

### Parameter: `customDomains`

The custom domains associated with this static site. The deployment will fail as long as the validation records are not present.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enterpriseGradeCdnStatus`

State indicating the status of the enterprise grade CDN serving traffic to the static web app.

- Required: No
- Type: string
- Default: `'Disabled'`
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Disabling'
    'Enabled'
    'Enabling'
  ]
  ```

### Parameter: `functionAppSettings`

Function app settings.

- Required: No
- Type: object
- Default: `{}`

### Parameter: `linkedBackend`

Object with "resourceId" and "location" of the a user defined function app.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`backendResourceId`](#parameter-linkedbackendbackendresourceid) | string | The resource ID of the backend linked to the static site. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-linkedbackendname) | string | Name of the backend to link to the static site. |
| [`region`](#parameter-linkedbackendregion) | string | The region of the backend linked to the static site. |

### Parameter: `linkedBackend.backendResourceId`

The resource ID of the backend linked to the static site.

- Required: No
- Type: string

### Parameter: `linkedBackend.name`

Name of the backend to link to the static site.

- Required: No
- Type: string

### Parameter: `linkedBackend.region`

The region of the backend linked to the static site.

- Required: No
- Type: string

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

### Parameter: `provider`

The provider that submitted the last deployment to the primary environment of the static site.

- Required: No
- Type: string
- Default: `'None'`

### Parameter: `publicNetworkAccess`

Property to enable or disable public traffic for the Static Web App.<p><p>Setting this parameter to 'Enabled' will make the resource non-compliant.<p>

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

### Parameter: `repositoryToken`

The Personal Access Token for accessing the GitHub repository.

- Required: No
- Type: securestring

### Parameter: `repositoryUrl`

The name of the GitHub repository.

- Required: No
- Type: string

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Web Plan Contributor'`
  - `'Website Contributor'`

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

### Parameter: `sku`

The service tier and name of the resource SKU.<p><p>Setting any other value than Standard will make the resource noncompliant.<p>

- Required: No
- Type: string
- Default: `'Standard'`
- Allowed:
  ```Bicep
  [
    'Free'
    'Standard'
  ]
  ```

### Parameter: `stagingEnvironmentPolicy`

State indicating whether staging environments are allowed or not allowed for a static web app.

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

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `templateProperties`

Template Options for the static site.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-templatepropertiesdescription) | string | Description of the newly generated repository. |
| [`isPrivate`](#parameter-templatepropertiesisprivate) | bool | Whether or not the newly generated repository is a private repository. Defaults to false (i.e. public). |
| [`owner`](#parameter-templatepropertiesowner) | string | Owner of the newly generated repository. |
| [`repositoryName`](#parameter-templatepropertiesrepositoryname) | string | Name of the newly generated repository. |
| [`templateRepositoryUrl`](#parameter-templatepropertiestemplaterepositoryurl) | string | URL of the template repository. The newly generated repository will be based on this one. |

### Parameter: `templateProperties.description`

Description of the newly generated repository.

- Required: No
- Type: string

### Parameter: `templateProperties.isPrivate`

Whether or not the newly generated repository is a private repository. Defaults to false (i.e. public).

- Required: No
- Type: bool

### Parameter: `templateProperties.owner`

Owner of the newly generated repository.

- Required: No
- Type: string

### Parameter: `templateProperties.repositoryName`

Name of the newly generated repository.

- Required: No
- Type: string

### Parameter: `templateProperties.templateRepositoryUrl`

URL of the template repository. The newly generated repository will be based on this one.

- Required: No
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `defaultHostname` | string | The default autogenerated hostname for the static site. |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the static site. |
| `privateEndpoints` | array | The private endpoints of the static site. |
| `resourceGroupName` | string | The resource group the static site was deployed into. |
| `resourceId` | string | The resource ID of the static site. |
| `systemAssignedMIPrincipalId` | string | The principal ID of the system assigned identity. |

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/network/private-endpoint:0.2.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
