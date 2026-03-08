metadata name = 'Virtual Network'
metadata description = 'This module deploys a Virtual Network (vNet).'
metadata owner = 'AMCCC'
metadata compliance = '''Creating Virtual Networks in spokes is not supported.
Peering these custom VNets or establishing any other type of connectivity links would generally be not-compliant.'''
metadata complianceVersion = '20240626'


@description('Required. The name of the Virtual Network (vNet).')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Required. An Array of 1 or more IP Address Prefixes for the Virtual Network.')
param addressPrefixes array

import { subnetType } from 'subnet/main.bicep'  // path to the subnet module

@description('Optional. An array of subnets to deploy to the Virtual Network.')
param subnets subnetType[]?

@description('Optional. DNS Servers associated to the Virtual Network.')
param dnsServers array = []

@description('Optional. Resource ID of the DDoS protection plan to assign the VNET to. If it\'s left blank, DDoS protection will not be configured. If it\'s provided, the VNET created by this template will be attached to the referenced DDoS protection plan. The DDoS protection plan can exist in the same or in a different subscription.')
param ddosProtectionPlanResourceId string = ''

@description('''Optional. Virtual Network Peerings configurations.

Setting this parameter to any value other than empty array ('[]') will make resource non-compliant.''')
param peerings array = []

@description('Optional. Indicates if encryption is enabled on virtual network and if VM without encryption is allowed in encrypted VNet. Requires the EnableVNetEncryption feature to be registered for the subscription and a supported region to use this property.')
param vnetEncryption bool = false

@allowed([
  'AllowUnencrypted'
  'DropUnencrypted'
])
@description('Optional. If the encrypted VNet allows VM that does not support encryption. Can only be used when vnetEncryption is enabled.')
param vnetEncryptionEnforcement string = 'AllowUnencrypted'

@maxValue(30)
@description('Optional. The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes. Default value 0 will set the property to null.')
param flowTimeoutInMinutes int = 0

@description('Optional. The diagnostic settings of the service.')
param diagnosticSettings diagnosticSettingType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType


@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

import { builtInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'

// ============ //
// Dependencies //
// ============ //

resource avmTelemetry 'Microsoft.Resources/deployments@2024-03-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.network-virtualnetwork.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: name
  location: location
  tags: finalTags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    ddosProtectionPlan: !empty(ddosProtectionPlanResourceId)
      ? {
          id: ddosProtectionPlanResourceId
        }
      : null
    dhcpOptions: !empty(dnsServers)
      ? {
          dnsServers: array(dnsServers)
        }
      : null
    enableDdosProtection: !empty(ddosProtectionPlanResourceId)
    encryption: vnetEncryption == true
      ? {
          enabled: vnetEncryption
          enforcement: vnetEncryptionEnforcement
        }
      : null
    flowTimeoutInMinutes: flowTimeoutInMinutes != 0 ? flowTimeoutInMinutes : null
    subnets: [
      for subnet in (subnets ?? []): {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          addressPrefixes: subnet.?addressPrefixes ?? []
          applicationGatewayIPConfigurations: subnet.?applicationGatewayIPConfigurations ?? []
          delegations: subnet.?delegations ?? []
          ipAllocations: subnet.?ipAllocations ?? []
          natGateway: !empty(subnet.?natGatewayResourceId)
            ? {
                id: subnet.natGatewayResourceId
              }
            : null
          networkSecurityGroup: !empty(subnet.?networkSecurityGroupResourceId)
            ? {
                id: subnet.networkSecurityGroupResourceId
              }
            : null
          privateEndpointNetworkPolicies: subnet.?privateEndpointNetworkPolicies
          privateLinkServiceNetworkPolicies: subnet.?privateLinkServiceNetworkPolicies ?? 'Enabled'
          routeTable: !empty(subnet.?routeTableResourceId)
            ? {
                id: subnet.routeTableResourceId
              }
            : null
          serviceEndpoints: subnet.?serviceEndpoints ?? []
          serviceEndpointPolicies: subnet.?serviceEndpointPolicies ?? []
        }
      }
    ]
  }
}

//NOTE Start: ------------------------------------
// The below module (virtualNetwork_subnets) is a duplicate of the child resource (subnets) defined in the parent module (virtualNetwork).
// The reason it exists so that deployment validation tests can be performed on the child module (subnets), in case that module needed to be deployed alone outside of this template.
// The reason for duplication is due to the current design for the (virtualNetworks) resource from Azure, where if the child module (subnets) does not exist within it, causes
//    an issue, where the child resource (subnets) gets all of its properties removed, hence not as 'idempotent' as it should be. See https://github.com/Azure/azure-quickstart-templates/issues/2786 for more details.
// You can safely remove the below child module (virtualNetwork_subnets) in your consumption of the module (virtualNetworks) to reduce the template size and duplication.
//NOTE End  : ------------------------------------

@batchSize(1)
module virtualNetwork_subnets 'subnet/main.bicep' = [
  for (subnet, index) in (subnets ?? []): {
    name: '${uniqueString(deployment().name, location)}-subnet-${index}'
    params: {
        virtualNetworkName: virtualNetwork.name
        ipAllocations: subnet.?ipAllocations ?? []
        subnet: subnet
      }
      }
]

// Local to Remote peering
module virtualNetwork_peering_local 'virtual-network-peering/main.bicep' = [
  for (peering, index) in peerings: {
    name: '${uniqueString(deployment().name, location)}-virtualNetworkPeering-local-${index}'
    params: {
      localVnetName: virtualNetwork.name
      remoteVirtualNetworkId: peering.remoteVirtualNetworkId
      name: peering.?name ?? '${name}-${last(split(peering.remoteVirtualNetworkId, '/'))}'
      allowForwardedTraffic: peering.?allowForwardedTraffic ?? true
      allowGatewayTransit: peering.?allowGatewayTransit ?? false
      allowVirtualNetworkAccess: peering.?allowVirtualNetworkAccess ?? true
      doNotVerifyRemoteGateways: peering.?doNotVerifyRemoteGateways ?? true
      useRemoteGateways: peering.?useRemoteGateways ?? false
    }
  }
]

// Remote to local peering (reverse)
module virtualNetwork_peering_remote 'virtual-network-peering/main.bicep' = [
  for (peering, index) in peerings: if (contains(peering, 'remotePeeringEnabled')
    ? peering.remotePeeringEnabled == true
    : false) {
    name: '${uniqueString(deployment().name, location)}-virtualNetworkPeering-remote-${index}'
    scope: resourceGroup(split(peering.remoteVirtualNetworkId, '/')[2], split(peering.remoteVirtualNetworkId, '/')[4])
    params: {
      localVnetName: last(split(peering.remoteVirtualNetworkId, '/'))!
      remoteVirtualNetworkId: virtualNetwork.id
      name: peering.?remotePeeringName ?? '${last(split(peering.remoteVirtualNetworkId, '/'))}-${name}'
      allowForwardedTraffic: peering.?remotePeeringAllowForwardedTraffic ?? true
      allowGatewayTransit: peering.?remotePeeringAllowGatewayTransit ?? false
      allowVirtualNetworkAccess: peering.?remotePeeringAllowVirtualNetworkAccess ?? true
      doNotVerifyRemoteGateways: peering.?remotePeeringDoNotVerifyRemoteGateways ?? true
      useRemoteGateways: peering.?remotePeeringUseRemoteGateways ?? false
    }
  }
]

resource virtualNetwork_lock 'Microsoft.Authorization/locks@2020-05-01' =
  if (!empty(lock ?? {}) && lock.?kind != 'None') {
    name: lock.?name ?? 'lock-${name}'
    properties: {
      level: lock.?kind ?? ''
      notes: lock.?kind == 'CanNotDelete'
        ? 'Cannot delete resource or child resources.'
        : 'Cannot delete or modify the resource or child resources.'
    }
    scope: virtualNetwork
  }

#disable-next-line use-recent-api-versions
resource virtualNetwork_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      metrics: [
        for group in (diagnosticSetting.?metricCategories ?? [{ category: 'AllMetrics' }]): {
          category: group.category
          enabled: group.?enabled ?? true
          timeGrain: null
        }
      ]
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? []): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: virtualNetwork
  }
]

resource virtualNetwork_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(virtualNetwork.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
    scope: virtualNetwork
  }
]

@description('The resource group the virtual network was deployed into.')
output resourceGroupName string = resourceGroup().name

@description('The resource ID of the virtual network.')
output resourceId string = virtualNetwork.id

@description('The name of the virtual network.')
output name string = virtualNetwork.name

@description('The names of the deployed subnets.')
output subnetNames array = [for subnet in (subnets ?? []): subnet.name]

@description('The resource IDs of the deployed subnets.')
output subnetResourceIds array = [
  for subnet in (subnets ?? []): az.resourceId('Microsoft.Network/virtualNetworks/subnets', name, subnet.name)
]

@description('The location the resource was deployed into.')
output location string = virtualNetwork.location

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = !empty(peerings)


// =============== //
//   Definitions   //
// =============== //

import {diagnosticSettingType, lockType, roleAssignmentType} from '../../../../bicep-shared/types.bicep'
