metadata name = 'Azure Databricks Workspace'
metadata description = 'This module deploys an Azure Databricks Workspace.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of Databricks requires:

- skuName: 'premium'
- disablePublicIp: true
- publicNetworkAccess: 'Disabled'
- requireInfrastructureEncryption: true
- complianceSecurityProfile: 'Enabled'
- automaticClusterUpdate: 'Enabled'
- enhancedSecurityMonitoring: 'Enabled'
- managedResourceGroupResourceId: if provided, must end with '-adbmanaged-rg''''
metadata complianceVersion = '20260309'

@description('Required. The name of the Azure Databricks workspace to create.')
@minLength(3)
@maxLength(64)
param name string

@description('''Optional. The managed resource group ID. It is created by the module as per the to-be resource ID you provide.
Default: the module calculates this ID using the name of the resource.

To be compliant, the resource group name needs to end with an authorized suffix, e.g. '-adbmanaged-rg'.
[Policy: drcp-adb-w22]
''')
param managedResourceGroupResourceId string = ''

@description('''Optional. The pricing tier of workspace. Default: premium.

Setting this parameter to a value other than 'premium' will make the resource non-compliant.
[Policy: drcp-adb-r02]''')
@allowed([
  'trial'
  'standard'
  'premium'
])
param skuName string = 'premium'

@description('Optional. Location for all Resources.')
param location string = resourceGroup().location

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('''Optional. The diagnostic settings of the service.

Currently known available log categories are:
  'accounts'
  'BrickStoreHttpGateway'
  'capsule8Dataplane'
  'clamAVScan'
  'CloudStorageMetadata'
  'clusterLibraries'
  'clusters'
  'Dashboards'
  'databrickssql'
  'DataMonitoring'
  'dbfs'
  'deltaPipelines'
  'featureStore'
  'genie'
  'gitCredentials'
  'globalInitScripts'
  'iamRole'
  'Ingestion'
  'instancePools'
  'jobs'
  'LineageTracking'
  'MarketplaceConsumer'
  'mlflowAcledArtifact'
  'mlflowExperiment'
  'modelRegistry'
  'notebook'
  'partnerHub'
  'PredictiveOptimization'
  'RemoteHistoryService'
  'repos'
  'secrets'
  'serverlessRealTimeInference'
  'sqlAnalytics'
  'sqlPermissions'
  'ssh'
  'unityCatalog'
  'webTerminal'
  'workspace'
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('''Required. The resource ID of a Virtual Network where Databricks clusters should be created.
[Policy: drcp-adb-r03]''')
param customVirtualNetworkResourceId string

@description('Optional. The resource ID of a Azure Machine Learning workspace to link with Databricks workspace.')
param amlWorkspaceResourceId string = ''

@description('''Required. The name of the 1st Subnet for clusters within the Virtual Network.
[Policy: drcp-adb-r03]''')
param customPrivateSubnetName string

@description('''Required. The name of a 2nd Subnet for clusters within the Virtual Network.
[Policy: drcp-adb-r03]''')
param customPublicSubnetName string

@description('''Optional. Disable Public IP. Default: true

Setting this parameter to false will make the resource non-compliant.
[Policy: drcp-adb-r04]
''')
param disablePublicIp bool = true

@description('Optional. The customer managed key definition to use for the managed service.')
param customerManagedKey customerManagedKeyType

@description('Optional. The customer managed key definition to use for the managed disk.')
param customerManagedKeyManagedDisk customerManagedKeyManagedDiskType

@description('Optional. Name of the outbound Load Balancer Backend Pool for Secure Cluster Connectivity (No Public IP).')
param loadBalancerBackendPoolName string = ''

@description('Optional. Resource ID of Outbound Load balancer for Secure Cluster Connectivity (No Public IP) workspace.')
param loadBalancerResourceId string = ''

@description('Optional. Name of the NAT gateway for Secure Cluster Connectivity (No Public IP) workspace subnets.')
param natGatewayName string = ''

@description('Optional. Prepare the workspace for encryption. Enables the Managed Identity for managed storage account.')
param prepareEncryption bool = false

@description('Optional. Name of the Public IP for No Public IP workspace with managed vNet.')
param publicIpName string = ''

@description('''Optional. A boolean indicating whether or not the DBFS root file system will be enabled with secondary layer of encryption.
Platform managed keys will be used for data at rest.

Setting this parameter to 'false' will make the resource non-compliant.
[Policy: drcp-adb-w10]
''')
param requireInfrastructureEncryption bool = true

@description('''Optional. Name of the default storage account containing DBFS.

If not provided the account name will be generated by the Databricks service.''')
param storageAccountName string = ''

@description('Optional. Default DBFS storage account SKU name. Default: \'Standard_ZRS\'')
@allowed([
  'Standard_GRS'
  'Standard_ZRS'
  'Standard_LRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param storageAccountSkuName string = 'Standard_ZRS'

@description('''Optional. Enables the firewall on the default storage account. Default: Disabled.

For best security practices, set it to 'Enabled' and configure storageAccountPrivateEndpoints.''')
@allowed([
  'Enabled'
  'Disabled'
])
param defaultStorageFirewall string = 'Disabled'

@description('''Optional. Configuration details for private endpoints for the managed storage account.

Default: configures blob and dfs endpoints using subnetResourceId from the privateEndpoints[0].''')
param storageAccountPrivateEndpoints privateEndpointType = [
  {
    subnetResourceId: privateEndpoints[0].subnetResourceId
    service: 'blob'
  }
  {
    subnetResourceId: privateEndpoints[0].subnetResourceId
    service: 'dfs'
  }
]

@description('Optional. Address prefix for Managed virtual network.')
param managedVnetAddressPrefix string = '10.139'

@description('''Optional. The network access type for accessing workspace. Set value to disabled to access workspace only via private link. Default: Disabled

Setting this parameter to 'Enabled' will make the resource non-compliant.
[Policy: drcp-adb-r01]
''')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Disabled'

@description('''Optional. Sets a value indicating which NSG rules should be deployed for data plane (clusters) to control plane communication.
'NoAzureDatabricksRules' are used when the communication happens over private endpoint. Default: \'NoAzureDatabricksRules\'''')
@allowed([
  'AllRules'
  'NoAzureDatabricksRules'
])
param requiredNsgRules string = 'NoAzureDatabricksRules'

@description('''Optional. Set to \'Enabled\' for automatic updates of clusters. Default: Enabled.

Setting this parameter to 'Disabled' will make the resource non-compliant.
''')
@allowed([
  'Disabled'
  'Enabled'
])
param automaticClusterUpdate string = 'Enabled'

@description('''Optional. Set to \'Enabled\' for security monitoring features. Default: Enabled.

Setting this parameter to 'Disabled' will make the resource non-compliant.
''')
@allowed([
  'Disabled'
  'Enabled'
])
param enhancedSecurityMonitoring string = 'Enabled'

@description('''Optional. Set to \'Enabled\' for compliance security profile features. Default: Enabled.

Setting this parameter to 'Disabled' will make the resource non-compliant.
''')
@allowed([
  'Disabled'
  'Enabled'
])
param complianceSecurityProfile string = 'Enabled'

@description('''Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.
Available values for 'service' are: 'databricks_ui_api'.

Default: 'databricks_ui_api' is used if  subnetResourceId is provided but 'service' is not specified.
[Policy: drcp-sub-07]
''')
param privateEndpoints privateEndpointType

@description('''Conditional. The resource ID of the associated access connector for private access to the managed storage account.

Required if defaultStorageFirewall parameter is 'Enabled'''')
param accessConnectorResourceId string = ''

@description('Optional. The default catalog configuration for the Databricks workspace.')
param defaultCatalog defaultCatalogType?

@description('Optional. The compliance standards array for the security profile. Should be a list of compliance standards like "HIPAA", "NONE" or "PCI_DSS".')
param complianceStandards array = (complianceSecurityProfile == 'Enabled') ? ['NONE'] : []

// Variables
import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId, databricksManagedResourceGroupSuffix } from '../../../../bicep-shared/environments.bicep'

var specificBuiltInRoleNames = {}
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res',  telemetryAVMversion: moduleVersion},tags??{})

// When a private endpoint configuration is provided without the service name, this array will be used to lookup default services for each privateEndpoint in the parameters
var privateEndpointDefaultServices = [
  'databricks_ui_api'
]
var privateEndpointStorageDefaultServices = [
  'blob'
  'dfs'
]


// When no log categories specified, use this list as default
var defaultLogCategoryNames = [
  'accounts'
  'BrickStoreHttpGateway'
  'capsule8Dataplane'
  'clamAVScan'
  'CloudStorageMetadata'
  'clusterLibraries'
  'clusters'
  'Dashboards'
  'databrickssql'
  'DataMonitoring'
  'dbfs'
  'deltaPipelines'
  'featureStore'
  'genie'
  'gitCredentials'
  'globalInitScripts'
  'iamRole'
  'Ingestion'
  'instancePools'
  'jobs'
  'LineageTracking'
  'MarketplaceConsumer'
  'mlflowAcledArtifact'
  'mlflowExperiment'
  'modelRegistry'
  'notebook'
  'partnerHub'
  'PredictiveOptimization'
  'RemoteHistoryService'
  'repos'
  'secrets'
  'serverlessRealTimeInference'
  'sqlAnalytics'
  'sqlPermissions'
  'ssh'
  'unityCatalog'
  'webTerminal'
  'workspace'
]

var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]

// Resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.databricks-workspace.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

var isHSMManagedCMK = split(customerManagedKey.?keyVaultResourceId ?? '', '/')[?7] == 'managedHSMs'
module cMKKeyVaultRef 'modules/cmkReferences.bicep' = if (!empty(customerManagedKey) && !isHSMManagedCMK) {
  name: '${uniqueString(deployment().name)}-cmkKeyVault'
  params: {
    keyVaultResourceId: customerManagedKey!.keyVaultResourceId
    keyName: customerManagedKey!.keyName
  }
  scope: resourceGroup(
    split(customerManagedKey.?keyVaultResourceId!, '/')[2],
    split(customerManagedKey.?keyVaultResourceId!, '/')[4]
  )
}

var isHSMManagedCMKDisk = split(customerManagedKeyManagedDisk.?keyVaultResourceId ?? '', '/')[?7] == 'managedHSMs'
module cMKManagedKeyVaultDiskRef 'modules/cmkReferences.bicep' = if (!empty(customerManagedKeyManagedDisk) && !isHSMManagedCMKDisk) {
  name: '${uniqueString(deployment().name)}-cmkDiskKeyVault'
  params: {
    keyVaultResourceId: customerManagedKeyManagedDisk!.keyVaultResourceId
    keyName: customerManagedKeyManagedDisk!.keyName
  }
  scope: resourceGroup(
    split(customerManagedKeyManagedDisk.?keyVaultResourceId!, '/')[2],
    split(customerManagedKeyManagedDisk.?keyVaultResourceId!, '/')[4]
  )
}

resource workspace 'Microsoft.Databricks/workspaces@2024-05-01' = {
  name: name
  location: location
  tags: finalTags
  sku: {
    name: skuName
  }
  properties:union({
      managedResourceGroupId: !empty(managedResourceGroupResourceId)
        ? managedResourceGroupResourceId
        : '${subscription().id}/resourceGroups/${name}${databricksManagedResourceGroupSuffix}'
      enhancedSecurityCompliance: {
        automaticClusterUpdate: {
          value: automaticClusterUpdate
        }
        enhancedSecurityMonitoring: {
          value: enhancedSecurityMonitoring
        }
        complianceSecurityProfile: {
          value: complianceSecurityProfile
          complianceStandards: complianceStandards
        }
      }
      parameters: union(
        // Always added parameters
        {
          enableNoPublicIp: {
            value: disablePublicIp
          }
          prepareEncryption: {
            value: prepareEncryption
          }
          vnetAddressPrefix: {
            value: managedVnetAddressPrefix
          }
          requireInfrastructureEncryption: {
            value: requireInfrastructureEncryption
          }
        },
        // Parameters only added if not empty
        !empty(customVirtualNetworkResourceId)
          ? {
              customVirtualNetworkId: {
                value: customVirtualNetworkResourceId
              }
            }
          : {},
        !empty(amlWorkspaceResourceId)
          ? {
              amlWorkspaceId: {
                value: amlWorkspaceResourceId
              }
            }
          : {},
        !empty(customPrivateSubnetName)
          ? {
              customPrivateSubnetName: {
                value: customPrivateSubnetName
              }
            }
          : {},
        !empty(customPublicSubnetName)
          ? {
              customPublicSubnetName: {
                value: customPublicSubnetName
              }
            }
          : {},
        !empty(loadBalancerBackendPoolName)
          ? {
              loadBalancerBackendPoolName: {
                value: loadBalancerBackendPoolName
              }
            }
          : {},
        !empty(loadBalancerResourceId)
          ? {
              loadBalancerId: {
                value: loadBalancerResourceId
              }
            }
          : {},
        !empty(natGatewayName)
          ? {
              natGatewayName: {
                value: natGatewayName
              }
            }
          : {},
        !empty(publicIpName)
          ? {
              publicIpName: {
                value: publicIpName
              }
            }
          : {},
        !empty(storageAccountName)
          ? {
              storageAccountName: {
                value: storageAccountName
              }
            }
          : {},
        !empty(storageAccountSkuName)
          ? {
              storageAccountSkuName: {
                value: storageAccountSkuName
              }
            }
          : {}
        )
      // createdBy: {} // This is a read-only property
      // managedDiskIdentity: {} // This is a read-only property
      // storageAccountIdentity: {} // This is a read-only property
      // updatedBy: {} // This is a read-only property
      defaultStorageFirewall: defaultStorageFirewall
      publicNetworkAccess: publicNetworkAccess
      requiredNsgRules: requiredNsgRules
      encryption: !empty(customerManagedKey) || !empty(customerManagedKeyManagedDisk)
        ? {
            entities: {
              managedServices: !empty(customerManagedKey)
                ? {
                    keySource: 'Microsoft.Keyvault'
                    keyVaultProperties: {
                      keyVaultUri: !isHSMManagedCMK
                        ? cMKKeyVaultRef!.outputs.vaultUri
                        : 'https://${last(split((customerManagedKey.?keyVaultResourceId!), '/'))}.managedhsm.azure.net/'
                      keyName: customerManagedKey!.keyName
                      keyVersion: !empty(customerManagedKey.?keyVersion)
                        ? customerManagedKey!.?keyVersion!
                        : !isHSMManagedCMK
                            ? cMKKeyVaultRef!.outputs.keyVersion
                            : fail('Managed HSM CMK encryption requires specifying the \'keyVersion\'.')
                    }
                  }
                : null
              managedDisk: !empty(customerManagedKeyManagedDisk)
                ? {
                    keySource: 'Microsoft.Keyvault'
                    keyVaultProperties: {
                      keyVaultUri: !isHSMManagedCMKDisk
                        ? cMKManagedKeyVaultDiskRef!.outputs.vaultUri
                        : 'https://${last(split((customerManagedKeyManagedDisk.?keyVaultResourceId!), '/'))}.managedhsm.azure.net/'
                      keyName: customerManagedKeyManagedDisk!.keyName
                      keyVersion: !empty(customerManagedKeyManagedDisk.?keyVersion)
                        ? customerManagedKeyManagedDisk!.?keyVersion!
                        : (!isHSMManagedCMKDisk
                            ? cMKManagedKeyVaultDiskRef!.outputs.keyVersion
                            : fail('Managed HSM CMK encryption requires specifying the \'keyVersion\'.'))
                    }
                    rotationToLatestKeyVersionEnabled: customerManagedKeyManagedDisk.?rotationToLatestKeyVersionEnabled ?? true
                  }
                : null
            }
          }
        : null
    },
    (!empty(accessConnectorResourceId) && defaultStorageFirewall == 'Enabled') ? {
      accessConnector: {
        id: accessConnectorResourceId
        identityType: 'SystemAssigned'
      }
    } : {},
    !empty(defaultCatalog) ? {
      defaultCatalog: {
        initialName: ''
        initialType: defaultCatalog.?initialType
      }
    } : {}
  )
}

resource workspace_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: workspace
}

// Note: Diagnostic Settings are only supported by the premium tier
#disable-next-line use-recent-api-versions
resource workspace_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
  for (diagnosticSetting, index) in (diagnosticSettings ?? []): {
    name: diagnosticSetting.?name ?? '${name}${index}-diagnosticSettings'
    properties: {
      storageAccountId: diagnosticSetting.?storageAccountResourceId
      workspaceId: diagnosticSetting.?workspaceResourceId
      eventHubAuthorizationRuleId: diagnosticSetting.?eventHubAuthorizationRuleResourceId
      eventHubName: diagnosticSetting.?eventHubName
      logs: [
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? defaultLogCategories): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: workspace
  }
]

resource workspace_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(workspace.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
    properties: {
      #disable-next-line use-safe-access
      roleDefinitionId: contains(builtInRoleNames, roleAssignment.roleDefinitionIdOrName)
        ? builtInRoleNames[roleAssignment.roleDefinitionIdOrName]
        : contains(roleAssignment.roleDefinitionIdOrName, '/providers/Microsoft.Authorization/roleDefinitions/')
            ? roleAssignment.roleDefinitionIdOrName
            : subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignment.roleDefinitionIdOrName)
      principalId: roleAssignment.principalId
      description: roleAssignment.?description
      principalType: roleAssignment.?principalType
      condition: roleAssignment.?condition
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condition is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: workspace
  }
]

var defaultPrivateEndpoints = [for service in privateEndpointDefaultServices ?? []: {
  service: service
  subnetResourceId: !empty(privateEndpoints) ? privateEndpoints[0].subnetResourceId : null
}]
var applyingPrivateEndpoints =  ( empty(privateEndpoints) || (length(privateEndpoints)>=1 && privateEndpoints[0].?service != null) ) ? privateEndpoints : defaultPrivateEndpoints

@batchSize(1)
module workspace_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (applyingPrivateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location)}-workspace-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(workspace.id, '/'))}-pep-${privateEndpoint.service}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(workspace.id, '/'))}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: workspace.id
                groupIds: [
                  privateEndpoint.service
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(workspace.id, '/'))}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: workspace.id
                groupIds: [
                  privateEndpoint.service
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: privateEndpoint.?enableTelemetry ?? enableTelemetry
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? finalTags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

// To reuse at multiple places instead to repeat the same code
var storageAccountNameOutput = workspace.properties.parameters.storageAccountName.value

// resource storageAccountOutput 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
//   name: workspace.properties.parameters.storageAccountName.value //storageAccountNameOutput
// }
//var storageAccountIdOutput = storageAccountOutput.id
// Using the code above gives a runtime error. So, implementing via 'resourceId'
var storageAccountIdOutput = resourceId(
  last(split(workspace.properties.managedResourceGroupId, '/')),
  'microsoft.storage/storageAccounts',
  workspace.properties.parameters.storageAccountName.value
)
var defaultStoragePrivateEndpoints = [for service in privateEndpointStorageDefaultServices ?? []: {
  service: service
  subnetResourceId: !empty(storageAccountPrivateEndpoints) ? storageAccountPrivateEndpoints[0].subnetResourceId : null
}]
var applyingStoragePrivateEndpoints =  ( empty(storageAccountPrivateEndpoints) || (length(storageAccountPrivateEndpoints)>=1 && storageAccountPrivateEndpoints[0].?service != null) ) ? storageAccountPrivateEndpoints : defaultStoragePrivateEndpoints
@batchSize(1)
module storageAccount_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (applyingStoragePrivateEndpoints ?? []): if (defaultStorageFirewall == 'Enabled') {
    name: '${uniqueString(deployment().name, location)}-workspace-storage-pep-${index}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${storageAccountNameOutput}-pep-${privateEndpoint.service}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${storageAccountNameOutput}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: storageAccountIdOutput
                groupIds: [
                  privateEndpoint.service
                ]
              }
            }
          ]
        : null
      manualPrivateLinkServiceConnections: privateEndpoint.?isManualConnection == true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${storageAccountNameOutput}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: storageAccountIdOutput
                groupIds: [
                  privateEndpoint.service
                ]
                requestMessage: privateEndpoint.?manualConnectionRequestMessage ?? 'Manual approval required.'
              }
            }
          ]
        : null
      subnetResourceId: privateEndpoint.subnetResourceId
      enableTelemetry: privateEndpoint.?enableTelemetry ?? enableTelemetry
      location: privateEndpoint.?location ?? reference(
        split(privateEndpoint.subnetResourceId, '/subnets/')[0],
        '2020-06-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      roleAssignments: privateEndpoint.?roleAssignments
      tags: privateEndpoint.?tags ?? finalTags
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
    dependsOn: [
      // Because of use of 'existing' to gather storage properties, there is no implcit dependency during updates
      // So it is safer to add explicit dependency here so that endpoints get deployed only after the workspace and storage are done
      #disable-next-line no-unnecessary-dependson
      workspace
      workspace_privateEndpoints // to avoid network modification conflicts
    ]
  }
]

@description('The name of the deployed databricks workspace.')
output name string = workspace.name

@description('The resource ID of the deployed databricks workspace.')
output resourceId string = workspace.id

@description('The resource group of the deployed databricks workspace.')
output resourceGroupName string = resourceGroup().name

@description('The location the resource was deployed into.')
output location string = workspace.location

@description('The resource ID of the managed resource group.')
output managedResourceGroupId string = workspace.properties.managedResourceGroupId

@description('The name of the managed resource group.')
output managedResourceGroupName string = last(split(workspace.properties.managedResourceGroupId, '/'))

@description('The name of the DBFS storage account.')
output storageAccountName string = storageAccountNameOutput

@description('The resource ID of the DBFS storage account.')
output storageAccountId string = storageAccountIdOutput

@description('The workspace URL which is of the format \'adb-{workspaceId}.{random}.azuredatabricks.net\'.')
output workspaceUrl string = workspace.properties.workspaceUrl

@description('The unique identifier of the databricks workspace in databricks control plane.')
output workspaceId string = workspace.properties.workspaceId

@description('The principal ID of the managed disk identity created by the workspace if CMK for managed disks is enabled.')
output managedDiskIdentityPrincipalId string? = workspace.properties.?managedDiskIdentity.?principalId

@description('The private endpoints for the Databricks Workspace.')
output privateEndpoints array = [
  for (pe, i) in (!empty(applyingPrivateEndpoints) ? applyingPrivateEndpoints : []): {
    name: workspace_privateEndpoints[i].outputs.name
    resourceId: workspace_privateEndpoints[i].outputs.resourceId
  }
]

@description('The private endpoints for the default storage account.')
output privateEndpointsStorage array = [
  for (pe, i) in ((!empty(applyingStoragePrivateEndpoints) && defaultStorageFirewall=='Enabled') ? applyingStoragePrivateEndpoints : []): {
    name: storageAccount_privateEndpoints[i].outputs.name
    resourceId: storageAccount_privateEndpoints[i].outputs.resourceId
  }
]

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = (skuName != 'premium') || !disablePublicIp || !requireInfrastructureEncryption || (complianceSecurityProfile=='Disabled') || (automaticClusterUpdate=='Disabled') || (enhancedSecurityMonitoring=='Disabled') || (publicNetworkAccess=='Enabled') || (!empty(managedResourceGroupResourceId) && !endsWith(managedResourceGroupResourceId, databricksManagedResourceGroupSuffix))

// =============== //
//   Definitions   //
// =============== //

import {
  customerManagedKeyManagedDiskType
  customerManagedKeyType
  diagnosticSettingType
  lockType
  privateEndpointType
  roleAssignmentType
} from '../../../../bicep-shared/types.bicep'

@description('The type for a default catalog configuration.')
type defaultCatalogType = {
  @description('Required. Choose between HiveMetastore or UnityCatalog.')
  initialType: 'HiveMetastore' | 'UnityCatalog'
}
