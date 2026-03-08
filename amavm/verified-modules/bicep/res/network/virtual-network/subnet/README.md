# Virtual Network Subnet `[Microsoft.Network/virtualNetworks/subnets]`

This module deploys a Virtual Network Subnet.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Notes](#notes)
- [Data Collection](#data-collection)

## Compliance

Version: 20240626

A compliant subnet requires:
- 'routeTableResourceId' parameter must be not empty
- 'networkSecurityGroupResourceId' parameter must be not empty
- 'privateEndpointNetworkPolicies' parameter must be either 'Enabled' or 'RouteTableEnabled'.

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Network/virtualNetworks/subnets` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks_subnets.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/virtualNetworks/subnets)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnet`](#parameter-subnet) | object | Subnet configuration object of type `subnetType`. |
| [`virtualNetworkName`](#parameter-virtualnetworkname) | string | The name of the parent virtual network. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`ipAllocations`](#parameter-ipallocations) | array | Array of IpAllocation which reference this subnet. |

### Parameter: `subnet`

Subnet configuration object of type `subnetType`.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-subnetname) | string | The Name of the subnet resource. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`addressPrefix`](#parameter-subnetaddressprefix) | string | The address prefix for the subnet. Required if `addressPrefixes` is empty. |
| [`addressPrefixes`](#parameter-subnetaddressprefixes) | array | List of address prefixes for the subnet. Required if `addressPrefix` is empty. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationGatewayIPConfigurations`](#parameter-subnetapplicationgatewayipconfigurations) | array | Application gateway IP configurations of virtual network resource. |
| [`delegations`](#parameter-subnetdelegations) | array | The delegation to enable on the subnet. |
| [`natGatewayResourceId`](#parameter-subnetnatgatewayresourceid) | string | The resource ID of the NAT Gateway to use for the subnet. |
| [`networkSecurityGroupResourceId`](#parameter-subnetnetworksecuritygroupresourceid) | string | The resource ID of the network security group to assign to the subnet.<p><p>For policy compliance must be not empty.<p> |
| [`privateEndpointNetworkPolicies`](#parameter-subnetprivateendpointnetworkpolicies) | string | Enable or disable apply network policies on private endpoint in the subnet. Default is 'Enabled'.<p><p>For policy compliance must be either 'Enabled' or 'RouteTableEnabled'.<p> |
| [`privateLinkServiceNetworkPolicies`](#parameter-subnetprivatelinkservicenetworkpolicies) | string | enable or disable apply network policies on private link service in the subnet. |
| [`roleAssignments`](#parameter-subnetroleassignments) | array | Array of role assignments to create. |
| [`routeTableResourceId`](#parameter-subnetroutetableresourceid) | string | The resource ID of the route table to assign to the subnet.<p><p>For policy compliance must be not empty.<p> |
| [`serviceEndpointPolicies`](#parameter-subnetserviceendpointpolicies) | array | An array of service endpoint policies. |
| [`serviceEndpoints`](#parameter-subnetserviceendpoints) | array | The service endpoints to enable on the subnet. |

### Parameter: `subnet.name`

The Name of the subnet resource.

- Required: Yes
- Type: string

### Parameter: `subnet.addressPrefix`

The address prefix for the subnet. Required if `addressPrefixes` is empty.

- Required: No
- Type: string

### Parameter: `subnet.addressPrefixes`

List of address prefixes for the subnet. Required if `addressPrefix` is empty.

- Required: No
- Type: array

### Parameter: `subnet.applicationGatewayIPConfigurations`

Application gateway IP configurations of virtual network resource.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-subnetapplicationgatewayipconfigurationsname) | string | Name of the IP configuration that is unique within an Application Gateway. |
| [`properties`](#parameter-subnetapplicationgatewayipconfigurationsproperties) | object | Properties of the application gateway IP configuration. |

### Parameter: `subnet.applicationGatewayIPConfigurations.name`

Name of the IP configuration that is unique within an Application Gateway.

- Required: Yes
- Type: string

### Parameter: `subnet.applicationGatewayIPConfigurations.properties`

Properties of the application gateway IP configuration.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`subnet`](#parameter-subnetapplicationgatewayipconfigurationspropertiessubnet) | object | Reference to the subnet resource. A subnet from where application gateway gets its private address. |

### Parameter: `subnet.applicationGatewayIPConfigurations.properties.subnet`

Reference to the subnet resource. A subnet from where application gateway gets its private address.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-subnetapplicationgatewayipconfigurationspropertiessubnetid) | string | esource ID. |

### Parameter: `subnet.applicationGatewayIPConfigurations.properties.subnet.id`

esource ID.

- Required: Yes
- Type: string

### Parameter: `subnet.delegations`

The delegation to enable on the subnet.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-subnetdelegationsname) | string | The name of the delegation resource that is unique within a subnet.<p>This name can be used to access the resource. (e.g. Microsoft.Web.serverFarms) |
| [`properties`](#parameter-subnetdelegationsproperties) | object | Contains the name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms). |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`type`](#parameter-subnetdelegationstype) | string | Resource type (e.g. Microsoft.Network/virtualNetworks/subnets/delegation) |

### Parameter: `subnet.delegations.name`

The name of the delegation resource that is unique within a subnet.<p>This name can be used to access the resource. (e.g. Microsoft.Web.serverFarms)

- Required: Yes
- Type: string

### Parameter: `subnet.delegations.properties`

Contains the name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serviceName`](#parameter-subnetdelegationspropertiesservicename) | string | The name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms). |

### Parameter: `subnet.delegations.properties.serviceName`

The name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms).

- Required: Yes
- Type: string

### Parameter: `subnet.delegations.type`

Resource type (e.g. Microsoft.Network/virtualNetworks/subnets/delegation)

- Required: No
- Type: string

### Parameter: `subnet.natGatewayResourceId`

The resource ID of the NAT Gateway to use for the subnet.

- Required: No
- Type: string

### Parameter: `subnet.networkSecurityGroupResourceId`

The resource ID of the network security group to assign to the subnet.<p><p>For policy compliance must be not empty.<p>

- Required: No
- Type: string

### Parameter: `subnet.privateEndpointNetworkPolicies`

Enable or disable apply network policies on private endpoint in the subnet. Default is 'Enabled'.<p><p>For policy compliance must be either 'Enabled' or 'RouteTableEnabled'.<p>

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
    'NetworkSecurityGroupEnabled'
    'RouteTableEnabled'
  ]
  ```

### Parameter: `subnet.privateLinkServiceNetworkPolicies`

enable or disable apply network policies on private link service in the subnet.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `subnet.roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`principalId`](#parameter-subnetroleassignmentsprincipalid) | string | The principal ID of the principal (user/group/identity) to assign the role to. |
| [`roleDefinitionIdOrName`](#parameter-subnetroleassignmentsroledefinitionidorname) | string | The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`condition`](#parameter-subnetroleassignmentscondition) | string | The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container". |
| [`conditionVersion`](#parameter-subnetroleassignmentsconditionversion) | string | Version of the condition. |
| [`delegatedManagedIdentityResourceId`](#parameter-subnetroleassignmentsdelegatedmanagedidentityresourceid) | string | The Resource Id of the delegated managed identity resource. |
| [`description`](#parameter-subnetroleassignmentsdescription) | string | The description of the role assignment. |
| [`principalType`](#parameter-subnetroleassignmentsprincipaltype) | string | The principal type of the assigned principal ID. |

### Parameter: `subnet.roleAssignments.principalId`

The principal ID of the principal (user/group/identity) to assign the role to.

- Required: Yes
- Type: string

### Parameter: `subnet.roleAssignments.roleDefinitionIdOrName`

The role to assign. You can provide either the display name of the role definition, the role definition GUID, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'.

- Required: Yes
- Type: string

### Parameter: `subnet.roleAssignments.condition`

The conditions on the role assignment. This limits the resources it can be assigned to. e.g.: @Resource[Microsoft.Storage/storageAccounts/blobServices/containers:ContainerName] StringEqualsIgnoreCase "foo_storage_container".

- Required: No
- Type: string

### Parameter: `subnet.roleAssignments.conditionVersion`

Version of the condition.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    '2.0'
  ]
  ```

### Parameter: `subnet.roleAssignments.delegatedManagedIdentityResourceId`

The Resource Id of the delegated managed identity resource.

- Required: No
- Type: string

### Parameter: `subnet.roleAssignments.description`

The description of the role assignment.

- Required: No
- Type: string

### Parameter: `subnet.roleAssignments.principalType`

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

### Parameter: `subnet.routeTableResourceId`

The resource ID of the route table to assign to the subnet.<p><p>For policy compliance must be not empty.<p>

- Required: No
- Type: string

### Parameter: `subnet.serviceEndpointPolicies`

An array of service endpoint policies.

- Required: No
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-subnetserviceendpointpoliciesid) | string | Resource ID. |
| [`location`](#parameter-subnetserviceendpointpolicieslocation) | string | Resource location. |
| [`properties`](#parameter-subnetserviceendpointpoliciesproperties) | object | Properties of the service end point policy. |
| [`tags`](#parameter-subnetserviceendpointpoliciestags) | object | Resource tags. |

### Parameter: `subnet.serviceEndpointPolicies.id`

Resource ID.

- Required: No
- Type: string

### Parameter: `subnet.serviceEndpointPolicies.location`

Resource location.

- Required: No
- Type: string

### Parameter: `subnet.serviceEndpointPolicies.properties`

Properties of the service end point policy.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serviceAlias`](#parameter-subnetserviceendpointpoliciespropertiesservicealias) | string | The alias indicating if the policy belongs to a service |
| [`serviceEndpointPolicyDefinitions`](#parameter-subnetserviceendpointpoliciespropertiesserviceendpointpolicydefinitions) | array | A collection of service endpoint policy definitions of the service endpoint policy. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`contextualServiceEndpointPolicies`](#parameter-subnetserviceendpointpoliciespropertiescontextualserviceendpointpolicies) | array | A collection of contextual service endpoint policy. |

### Parameter: `subnet.serviceEndpointPolicies.properties.serviceAlias`

The alias indicating if the policy belongs to a service

- Required: Yes
- Type: string

### Parameter: `subnet.serviceEndpointPolicies.properties.serviceEndpointPolicyDefinitions`

A collection of service endpoint policy definitions of the service endpoint policy.

- Required: Yes
- Type: array

### Parameter: `subnet.serviceEndpointPolicies.properties.contextualServiceEndpointPolicies`

A collection of contextual service endpoint policy.

- Required: No
- Type: array

### Parameter: `subnet.serviceEndpointPolicies.tags`

Resource tags.

- Required: No
- Type: object

### Parameter: `subnet.serviceEndpoints`

The service endpoints to enable on the subnet.

- Required: No
- Type: array

### Parameter: `virtualNetworkName`

The name of the parent virtual network. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `ipAllocations`

Array of IpAllocation which reference this subnet.

- Required: No
- Type: array
- Default: `[]`

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`id`](#parameter-ipallocationsid) | string | Resource ID. |

### Parameter: `ipAllocations.id`

Resource ID.

- Required: Yes
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `name` | string | The name of the subnet. |
| `resourceGroupName` | string | The resource group the subnet was deployed into. |
| `resourceId` | string | The resource ID of the subnet. |
| `subnetAddressPrefix` | string | The address prefix for the subnet. |
| `subnetAddressPrefixes` | array | List of address prefixes for the subnet. |

## Notes

N/A

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
