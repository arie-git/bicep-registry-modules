metadata name = 'Virtual Network Subnet'
metadata description = 'This module deploys a Virtual Network Subnet.'
metadata owner = 'AMCCC'
metadata compliance = '''
A compliant subnet requires:
- 'routeTableResourceId' parameter must be not empty
- 'networkSecurityGroupResourceId' parameter must be not empty
- 'privateEndpointNetworkPolicies' parameter must be either 'Enabled' or 'RouteTableEnabled'.'''
metadata complianceVersion = '20260309'

@description('Optional. Array of IpAllocation which reference this subnet.')
param ipAllocations {
  @description('Optional. Resource ID.')
  id: string
}[] = []

@description('Required. Subnet configuration object of type `subnetType`.')
param subnet subnetType

@description('Required. The name of the parent virtual network. Required if the template is used in a standalone deployment.')
param virtualNetworkName string

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

import { builtInRoleNames as minimalBuiltInRoleNames } from '../../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {
  'Network Contributor': subscriptionResourceId(
    'Microsoft.Authorization/roleDefinitions',
    '4d97b98b-1d4f-4787-a291-c67834d212e7'
  )
}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

#disable-next-line prefer-interpolation
var concatUniqueIds = concat(virtualNetworkName, subnet.?networkSecurityGroupResourceId ?? '', subnet.?routeTableResourceId ?? '')
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    'amavm1.res.network-subnet.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, concatUniqueIds), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' existing = {
  name: virtualNetworkName
}

resource subnetRes 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  name: subnet.name
  parent: virtualNetwork
  properties: {
    addressPrefix: subnet.?addressPrefix
    ipamPoolPrefixAllocations: subnet.?ipamPoolPrefixAllocations
    networkSecurityGroup: !empty(subnet.?networkSecurityGroupResourceId)
      ? {
          id: subnet.networkSecurityGroupResourceId
        }
      : null
    routeTable: !empty(subnet.?routeTableResourceId)
      ? {
          id: subnet.routeTableResourceId
        }
      : null
    natGateway: !empty(subnet.?natGatewayResourceId)
      ? {
          id: subnet.natGatewayResourceId
        }
      : null
    serviceEndpoints: subnet.?serviceEndpoints ?? []
    delegations: subnet.?delegations ?? []
    privateEndpointNetworkPolicies: !empty(subnet.?privateEndpointNetworkPolicies) ? any(subnet.?privateEndpointNetworkPolicies) : null
    privateLinkServiceNetworkPolicies: !empty(subnet.?privateLinkServiceNetworkPolicies)
      ? any(subnet.?privateLinkServiceNetworkPolicies)
      : null
    addressPrefixes: subnet.?addressPrefixes ?? []
    applicationGatewayIPConfigurations: subnet.?applicationGatewayIPConfigurations ?? []
    ipAllocations: ipAllocations ?? []
    serviceEndpointPolicies: subnet.?serviceEndpointPolicies ?? []
    defaultOutboundAccess: subnet.?defaultOutboundAccess
    sharingScope: subnet.?sharingScope
  }
}

resource subnet_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (subnet.?roleAssignments ?? []): {
    name: guid(subnetRes.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      #disable-next-line use-safe-access
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : roleAssignment.roleDefinitionIdOrName
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: subnetRes
  }
]

@description('The resource group the subnet was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The name of the subnet.')
output name string = subnetRes.name

@description('The resource ID of the subnet.')
output resourceId string = subnetRes.id

@description('The address prefix for the subnet.')
output subnetAddressPrefix string = subnetRes.properties.?addressPrefix ?? ''

@description('List of address prefixes for the subnet.')
output subnetAddressPrefixes array = !empty(subnet.?addressPrefixes) ? subnetRes.properties.?addressPrefixes : []

@description('The IPAM pool prefix allocations for the subnet.')
output ipamPoolPrefixAllocations array = subnetRes.properties.?ipamPoolPrefixAllocations ?? []

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = empty(subnet.?networkSecurityGroupResourceId) || empty(subnet.?routeTableResourceId) || !contains(['Enabled', 'RouteTableEnabled'], subnet.?privateEndpointNetworkPolicies)

// =============== //
//   Definitions   //
// =============== //

import { roleAssignmentType } from '../../../../../bicep-shared/types.bicep'

@export()
type delegationType = {
  @description('''Required. The name of the delegation resource that is unique within a subnet.
  This name can be used to access the resource. (e.g. Microsoft.Web.serverFarms)''')
  name: string

  @description('Optional. Resource type (e.g. Microsoft.Network/virtualNetworks/subnets/delegation)')
  type: string?

  @description('Required. Contains the name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms).')
  properties: {
    @description('Required. The name of the service to which the subnet should be delegated (e.g. Microsoft.Web/serverFarms).')
    serviceName: string
  }
}

@export()
type serviceEndpointType = {
  @description('Optional. A list of locations.')
  locations: string[]?

  @description('''Required. The type of the endpoint service (e.g. Microsoft.Storage).
  See `az network service-endpoint list --location <region> --query "[].name"` for available values.''')
  service: string
}

@export()
type applicationGatewayIPConfiguration = {
  @description('Required. Name of the IP configuration that is unique within an Application Gateway.')
  name: string

  @description('Required. Properties of the application gateway IP configuration.')
  properties: {
    @description('Required. Reference to the subnet resource. A subnet from where application gateway gets its private address.')
    subnet: {
      @description('Required. esource ID.')
      id: string
    }
  }
}

@export()
type serviceEndpointPolicy = {
  @description('Optional. Resource ID.')
  id: string?

  @description('Optional. Resource location.')
  location: string?

  @description('Optional. Properties of the service end point policy.')
  properties: {
    @description('Optional. A collection of contextual service endpoint policy.')
    contextualServiceEndpointPolicies: string[]?

    @description('Required. The alias indicating if the policy belongs to a service')
    serviceAlias: string

    @description('Required. A collection of service endpoint policy definitions of the service endpoint policy.')
    serviceEndpointPolicyDefinitions: [
      {
        @description('Required. The name of the resource that is unique within a resource group. This name can be used to access the resource.')
        name: string

        @description('Required. Properties of the service endpoint policy definition.')
        properties: {
          @maxLength(140)
          @description('Optional. A description for this rule. Restricted to 140 chars.')
          description: string?

          @description('Required. Service endpoint name, e.g. Microsoft.Storage, Global')
          service: 'Microsoft.Storage' | 'Global'

          @description('Required. An allow-list of resources IDs (storage account or resopurce group or subscription) or service aliases (e.g. /services/Azure/DataFactory).')
          serviceResources: string[]
        }

        @description('Optional. The type of the resource, e.g. Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions')
        type: 'Microsoft.Network/serviceEndpointPolicies/serviceEndpointPolicyDefinitions'
      }
    ]
  }?

  @description('Optional. Resource tags.')
  tags: {}?
}
@export()
type subnetType = {
  @description('Required. The Name of the subnet resource.')
  name: string

  @description('Conditional. The address prefix for the subnet. Required if `addressPrefixes` is empty.')
  addressPrefix: string?

  @description('Conditional. List of address prefixes for the subnet. Required if `addressPrefix` is empty.')
  addressPrefixes: string[]?

  @description('Conditional. The address space for the subnet, deployed from IPAM Pool. Required if `addressPrefixes` and `addressPrefix` is empty and the VNet address space configured to use IPAM Pool.')
  ipamPoolPrefixAllocations: [
    {
      @description('Required. The Resource ID of the IPAM pool.')
      pool: {
        @description('Required. The Resource ID of the IPAM pool.')
        id: string
      }
      @description('Required. Number of IP addresses allocated from the pool.')
      numberOfIpAddresses: string
    }
  ]?

  @description('Optional. Application gateway IP configurations of virtual network resource.')
  applicationGatewayIPConfigurations: applicationGatewayIPConfiguration[]?

  @description('Optional. The delegation to enable on the subnet.')
  delegations: delegationType[]?

  @description('Optional. The resource ID of the NAT Gateway to use for the subnet.')
  natGatewayResourceId: string?

  @description('''Optional. The resource ID of the network security group to assign to the subnet.

  For policy compliance must be not empty.
  ''')  
  networkSecurityGroupResourceId: string?

  @description('''Optional. Enable or disable apply network policies on private endpoint in the subnet. Default is 'Enabled'.

  For policy compliance must be either 'Enabled' or 'RouteTableEnabled'.
  ''')  
  privateEndpointNetworkPolicies: ('Disabled' | 'Enabled' | 'NetworkSecurityGroupEnabled' | 'RouteTableEnabled')?

  @description('Optional. enable or disable apply network policies on private link service in the subnet.')
  privateLinkServiceNetworkPolicies: ('Disabled' | 'Enabled')?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType?

  @description('''Optional. The resource ID of the route table to assign to the subnet.

  For policy compliance must be not empty.
  ''')  
  routeTableResourceId: string?

  @description('Optional. An array of service endpoint policies.')
  serviceEndpointPolicies: serviceEndpointPolicy[]?

  @description('Optional. The service endpoints to enable on the subnet.')
  serviceEndpoints: object[]?

  @description('Optional. Set this property to false to disable default outbound connectivity for all VMs in the subnet. This property can only be set at the time of subnet creation and cannot be updated for an existing subnet.')
  defaultOutboundAccess: bool?

  @description('Optional. Set this property to Tenant to allow sharing subnet with other subscriptions in your AAD tenant. This property can only be set if defaultOutboundAccess is set to false, both properties can only be set if subnet is empty.')
  sharingScope: ('DelegatedServices' | 'Tenant')?
}
