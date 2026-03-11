metadata name = 'Storage Account'
metadata description = 'This module deploys a Storage Account.'
metadata owner = 'AMCCC'
metadata compliance = '''Compliant usage of Storage account requires:
- allowCrossTenantReplication: false
- allowBlobPublicAccess: false
- allowSharedKeyAccess: false
- enableSftp: false
- isLocalUserEnabled: false
- localUsers: empty
- minimumTlsVersion: TLS1_2
- publicNetworkAccess: 'Disabled'
- requireInfrastructureEncryption: true
- supportsHttpsTrafficOnly: true
'''
metadata complianceVersion = '20260309'

@minLength(3)
@maxLength(24)
@description('Required. Name of the Storage Account. Must be lower-case.')
param name string

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

@description('''Optional. The managed identity definition for this resource. Default: { systemAssigned: true }.

To disable creating a system-assigned identity, provide an empty object {} or null.''')
param managedIdentities managedIdentitiesType = {
  systemAssigned: true
}

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
@description('Optional. Type of Storage Account to create.')
param kind string = 'StorageV2'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
  'StandardV2_LRS'
  'StandardV2_ZRS'
  'StandardV2_GRS'
  'StandardV2_GZRS'
  'PremiumV2_LRS'
  'PremiumV2_ZRS'
])
@description('Optional. Storage Account Sku Name. Default: "Standard_ZRS"')
param skuName string = 'Standard_ZRS'

@allowed([
  'Premium'
  'Hot'
  'Cool'
  'Cold'
])
@description('''Conditional. Required if the Storage Account kind is set to BlobStorage. The access tier is used for billing. Default: "Hot".

The "Premium" access tier is the default value for premium block blobs storage account type and it cannot be changed for the premium block blobs storage account type.''')
param accessTier string = 'Hot'

@allowed([
  'Disabled'
  'Enabled'
])
@description('''Optional. Allow large file shares if set to 'Enabled'. Default: 'Disabled'.
Only supported on locally redundant and zone redundant file shares.
It cannot be disabled once it is enabled. It cannot be set on FileStorage storage accounts (storage accounts for premium file shares).''')
param largeFileSharesState string = 'Disabled'

@description('Optional. Provides the identity based authentication settings for Azure Files.')
param azureFilesIdentityBasedAuthentication object = {}

@description('Optional. A boolean flag which indicates whether the default authentication is OAuth or not. Default: true.')
param defaultToOAuthAuthentication bool = true

@description('''Optional. Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Default: false.

Setting this parameter to 'true' will make the resource non-compliant. [Policy: drcp-st-04]
''')
param allowSharedKeyAccess bool = false

@description('''Optional. Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible.
Available values for 'service' are:
- Blob (blob, blob_secondary)
- Dfs (dfs, dfs_secondary)
- Table (table, table_secondary)
- Queue (queue, queue_secondary)
- File (file, file_secondary)
- Web (web, web_secondary)

Default: 'blob' and 'dfs' are used if at least one subnetResourceId is provided but 'service' is not specified. [Policy: drcp-st-10, drcp-sub-07]
''')
param privateEndpoints privateEndpointType

@description('Optional. The Storage Account ManagementPolicies Rules.')
param managementPolicyRules storageManagementPolicyRuleType[]?

@description('''Optional. Networks ACLs, this value contains IPs to whitelist and/or Subnet information. If in use, bypass needs to be supplied. For security reasons, it is recommended to set the DefaultAction Deny. By default, bypass is 'AzureServices' and defaultAction is 'Deny'.

Setting defaultAction to 'Allow' will make the resource non-compliant. [Policy: drcp-st-15]
''')
param networkAcls networkAclsType = { //maybe in the future the baseline will be updated to prohibit ipRules and networkRules
  bypass: 'None'
  defaultAction: 'Deny'
}

@description('''Optional. A Boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true. Default: true.

Setting this parameter to 'false' will make the resource non-compliant. [Policy: drcp-st-05]
''')
param requireInfrastructureEncryption bool = true

@description('''Optional. Allow or disallow cross AAD tenant object replication. Default: false.

Setting this paramter to 'true' will make the resource non-compliant. [Policy: drcp-st-07]
''')
param allowCrossTenantReplication bool = false

@description('Optional. Sets the custom domain name assigned to the storage account. Name is the CNAME source.')
param customDomainName string = ''

@description('Optional. Indicates whether indirect CName validation is enabled. This should only be set on updates.')
param customDomainUseSubDomainName bool = false

@description('Optional. Allows you to specify the type of endpoint. Set this to AzureDNSZone to create a large number of accounts in a single subscription, which creates accounts in an Azure DNS Zone and the endpoint URL will have an alphanumeric DNS Zone identifier.')
@allowed([
  ''
  'AzureDnsZone'
  'Standard'
])
param dnsEndpointType string = ''

@description('Optional. Blob service and containers to deploy.')
param blobServices blobServiceType = (kind != 'FileStorage')
  ? {
      containerDeleteRetentionPolicyEnabled: true
      containerDeleteRetentionPolicyDays: 7
      deleteRetentionPolicyEnabled: true
      deleteRetentionPolicyDays: 6
    }
  : {}

@description('Optional. File service and shares to deploy.')
param fileServices fileServiceType = (kind == 'FileStorage' || kind == 'StorageV2' || kind == 'Storage')
  ? {
      name: 'default' // need to provide at least this parameter to have not empty, so that the file service is provisioned by default
    }
  : {}


@description('Optional. Queue service and queues to create.')
param queueServices queueServiceType?

@description('Optional. Table service and tables to create.')
param tableServices tableServiceType?

@description('Optional. Enable static website.')
param enableStaticWebsite bool = false

@description('''Optional. Indicates whether public access is enabled for all blobs or containers in the storage account. For security reasons, it is recommended to set it to false. Default: false

Setting this parameter to 'true' will make the resource non-compliant. [Policy: drcp-st-02]
''')
param allowBlobPublicAccess bool = false

@allowed([
  'TLS1_2'
  'TLS1_3'
])
@description('''Optional. Set the minimum TLS version on request to storage. Default: "TLS1_2".

Setting this parameter to values lower than "TLS1_2" will make the resource non-compliant. [Policy: drcp-st-06]
''')
param minimumTlsVersion string = 'TLS1_2'

@description('''Conditional. Also known as \'Data Lake Gen2\'. If true, enables Hierarchical Namespace for the storage account.  Default: false

Required if enableSftp or enableNfsV3 is set to true.''')
param enableHierarchicalNamespace bool = false

@description('''Optional. If true, enables Secure File Transfer Protocol for the storage account. Requires enableHierarchicalNamespace to be true. Default: false.

Setting this parameter to 'true' will make the resource non-compliant. [Policy: drcp-st-09]
''')
param enableSftp bool = false

@description('''Optional. Local users to deploy for SFTP authentication.

Specifying local users will make this resource non-compliant. [Policy: drcp-st-09]
''')
param localUsers array = []

@description('''Optional. Enables local users feature, if set to true. Default: false.

Setting this parameter to 'true' will make the resource non-compliant. [Policy: drcp-st-09]
''')
param isLocalUserEnabled bool = false

@description('Optional. If true, enables NFS 3.0 support for the storage account. Requires enableHierarchicalNamespace to be true.')
param enableNfsV3 bool = false

@description('''Optional. The diagnostic settings of the service.

Available log categories: 'Transaction'
''')
param diagnosticSettings diagnosticSettingType

@description('Optional. The lock settings of the service.')
param lock lockType

@description('Optional. Tags of the resource.')
param tags object?

@description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

@description('''Optional. Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Default: AAD.

- '' or (null) or (default): Allow copying from any storage account to the destination account.
- AAD: Microsoft Entra ID. Permits copying only from accounts within the same Microsoft Entra tenant as the destination account.
- PrivateLink: Permits copying only from storage accounts that have private links to the same virtual network as the destination account.
''')
@allowed([
  ''
  'AAD'
  'PrivateLink'
])
param allowedCopyScope string = 'AAD'

@description('''Optional. Whether or not public network access is allowed for this resource. For security reasons it should be disabled. Default: Disabled.

Setting this parameter to 'Enabled' will make the resource non-compliant. [Policy: drcp-st-01]
''')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Disabled'

@description('''Optional. Allows only the HTTPS traffic to reach storage service, if set to true. Default: true.

Setting this parameter to 'false' will make the resource non-compliant. [Policy: drcp-st-03]
''')
param supportsHttpsTrafficOnly bool = true

@description('Optional. The customer managed key definition.')
param customerManagedKey customerManagedKeyType

@description('Optional. The SAS expiration period. Format: DD.HH:MM:SS. Default: \'01.00:00:00\'')
param sasExpirationPeriod string = '01.00:00:00'

@description('Optional. The SAS expiration action. Can only be Log.')
@allowed([
  'Block'
  'Log'
])
param sasExpirationAction string = 'Log'

@description('Optional. The keyType to use with Queue & Table services. Default: \'Account\'. [Policy: drcp-st-08]')
@allowed([
  'Account'
  'Service'
  ''
])
param keyType string = 'Account'

@description('Optional. The property is immutable and can only be set to true at the account creation time. When set to true, it enables object level immutability for all the new containers in the account by default. Cannot be enabled for ADLS Gen2 storage accounts.')
param immutableStorageWithVersioning object?

@description('Optional. Configuration for exporting storage account keys and connection strings to a Key Vault.')
param secretsExportConfiguration secretsExportConfigurationType?

import { objectReplicationPolicyRuleType } from 'object-replication-policy/policy/main.bicep'
@description('Optional. Object replication policies to configure on this storage account.')
param objectReplicationPolicies objectReplicationPolicyType[]?

// ------------------------------------------------------------------------------------------------------------------------------

#disable-next-line no-unused-vars
var immutabilityValidation = enableHierarchicalNamespace == true && !empty(immutableStorageWithVersioning)
  ? fail('Configuration error: Immutable storage with versioning cannot be enabled when hierarchical namespace is enabled.')
  : null

var supportsBlobService = kind == 'BlockBlobStorage' || kind == 'BlobStorage' || kind == 'StorageV2' || kind == 'Storage'
var supportsFileService = kind == 'FileStorage' || kind == 'StorageV2' || kind == 'Storage'

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

var identity = !empty(managedIdentities)
  ? {
      type: (managedIdentities.?systemAssigned ?? false)
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : 'None')
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null


import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'
var specificBuiltInRoleNames = {
  'Reader and Data Access': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','c12c1c16-33a1-487b-954d-41c89c60f349')
  'Storage Account Backup Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','e5e2a7ff-d759-4cd2-bb51-3152d37e2eb1')
  'Storage Account Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','17d1049b-9a84-46fb-8f53-869881c3d3ab')
  'Storage Account Key Operator Service Role': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','81a9662b-bebf-436f-a333-f67b29880f12')
  'Storage Blob Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  'Storage Blob Data Owner': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b7e6dc6d-f1e8-4753-8033-0f276bb0955b')
  'Storage Blob Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','2a2b9908-6ea1-4ae2-8e65-a410df84e7d1')
  'Storage Blob Delegator': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','db58b8e5-c6ad-4a2a-8342-4190687cbf4a')
  'Storage File Data Privileged Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','69566ab7-960f-475b-8e7c-b3118f30c6bd')
  'Storage File Data Privileged Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','b8eda974-7b85-4f76-af95-65846b26df6d')
  'Storage File Data SMB Share Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb')
  'Storage File Data SMB Share Elevated Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','a7264617-510b-434b-a828-9731dc254ea7')
  'Storage File Data SMB Share Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','aba4ae5f-2193-4029-9191-0cb91df5e314')
  'Storage Queue Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','974c5e8b-45b9-4653-ba55-5f855dd0fb88')
  'Storage Queue Data Message Processor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','8a0f0c08-91a1-4084-bc3d-661d67233fed')
  'Storage Queue Data Message Sender': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','c6a89b2d-59bc-44d0-9896-0f6e12d7b80a')
  'Storage Queue Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','19e7f393-937e-4f77-808e-94535e297925')
  'Storage Table Data Contributor': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
  'Storage Table Data Reader': subscriptionResourceId('Microsoft.Authorization/roleDefinitions','76199698-9eea-4c19-bc75-cec21354c6b6')
}
@export()
var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)

// When a private endpoint configuration is provided without the service name, this array will be used to define default services that should be deployed a provate endpoint
var privateEndpointDefaultServices = union(
  (supportsBlobService) ? ['blob'] : [],
  (kind=='StorageV2' && enableHierarchicalNamespace) ? ['dfs'] : [],
  (supportsFileService) ? ['file'] : [],
  !empty(queueServices) ? ['queue'] : [],
  !empty(tableServices) ? ['table'] : [],
  enableStaticWebsite ? ['web']:[]
)

var versionInfo = loadJsonContent('version.json')
var moduleVersion = versionInfo.version
var finalTags = union(tags ?? {}, {telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion})

#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2024-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.storage-storageaccount.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, location), 0, 4)}',
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

resource cMKKeyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId)) {
  name: last(split((customerManagedKey.?keyVaultResourceId ?? 'dummyVault'), '/'))
  scope: resourceGroup(
    split((customerManagedKey.?keyVaultResourceId ?? '//'), '/')[2],
    split((customerManagedKey.?keyVaultResourceId ?? '////'), '/')[4]
  )

  resource cMKKey 'keys@2024-11-01' existing = if (!empty(customerManagedKey.?keyVaultResourceId) && !empty(customerManagedKey.?keyName)) {
    name: customerManagedKey.?keyName ?? 'dummyKey'
  }
}

resource cMKUserAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = if (!empty(customerManagedKey.?userAssignedIdentityResourceId)) {
  name: last(split(customerManagedKey.?userAssignedIdentityResourceId ?? 'dummyMsi', '/'))
  scope: resourceGroup(
    split((customerManagedKey.?userAssignedIdentityResourceId ?? '//'), '/')[2],
    split((customerManagedKey.?userAssignedIdentityResourceId ?? '////'), '/')[4]
  )
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: name
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  identity: identity
  tags: finalTags
  properties: {
    allowSharedKeyAccess: allowSharedKeyAccess
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    allowCrossTenantReplication: allowCrossTenantReplication
    allowedCopyScope: !empty(allowedCopyScope) ? allowedCopyScope : null
    customDomain: {
      name: customDomainName
      useSubDomainName: customDomainUseSubDomainName
    }
    dnsEndpointType: !empty(dnsEndpointType) ? dnsEndpointType : null
    isLocalUserEnabled: isLocalUserEnabled
    encryption: union(
      {
        keySource: !empty(customerManagedKey) ? 'Microsoft.Keyvault' : 'Microsoft.Storage'
        services: {
          blob: supportsBlobService
            ? {
                enabled: true
              }
            : null
          file: supportsFileService
            ? {
                enabled: true
              }
            : null
          table: {
            enabled: true
            keyType: keyType
          }
          queue: {
            enabled: true
            keyType: keyType
          }
        }
        keyvaultproperties: !empty(customerManagedKey)
          ? {
              keyname: customerManagedKey!.keyName
              keyvaulturi: cMKKeyVault.properties.vaultUri
              keyversion: !empty(customerManagedKey.?keyVersion ?? '')
                ? customerManagedKey!.keyVersion
                : last(split(cMKKeyVault::cMKKey.properties.keyUriWithVersion, '/'))
            }
          : null
        identity: {
          userAssignedIdentity: !empty(customerManagedKey.?userAssignedIdentityResourceId)
            ? cMKUserAssignedIdentity.id
            : null
        }
      },
      (requireInfrastructureEncryption
        ? {
            requireInfrastructureEncryption: kind != 'Storage' ? requireInfrastructureEncryption : null
          }
        : {})
    )
    accessTier: (kind != 'Storage' && kind != 'BlockBlobStorage') ? accessTier : null
    sasPolicy: !empty(sasExpirationPeriod)
      ? {
          expirationAction: sasExpirationAction
          sasExpirationPeriod: sasExpirationPeriod
        }
      : null
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    isHnsEnabled: enableHierarchicalNamespace ? enableHierarchicalNamespace : null
    isSftpEnabled: enableSftp
    isNfsV3Enabled: enableNfsV3 ? enableNfsV3 : any('')
    largeFileSharesState: (skuName == 'Standard_LRS') || (skuName == 'Standard_ZRS') ? largeFileSharesState : null
    minimumTlsVersion: minimumTlsVersion
    networkAcls: !empty(networkAcls)
      ? union(
          {
            resourceAccessRules: networkAcls.?resourceAccessRules
            defaultAction: networkAcls.?defaultAction ?? 'Deny'
            virtualNetworkRules: networkAcls.?virtualNetworkRules
            ipRules: networkAcls.?ipRules
          },
          (contains(networkAcls!, 'bypass') ? { bypass: networkAcls.?bypass } : {}) // setting `bypass` to `null`is not supported
        )
      : {
          // New default case that enables the firewall by default
          bypass: 'AzureServices'
          defaultAction: 'Deny'
        }
    allowBlobPublicAccess: allowBlobPublicAccess
    publicNetworkAccess: !empty(publicNetworkAccess)
      ? any(publicNetworkAccess)
      : (!empty(privateEndpoints) && empty(networkAcls) ? 'Disabled' : null)
    azureFilesIdentityBasedAuthentication: !empty(azureFilesIdentityBasedAuthentication)
      ? azureFilesIdentityBasedAuthentication
      : null
    immutableStorageWithVersioning: immutableStorageWithVersioning
  }
}

#disable-next-line use-recent-api-versions
resource storageAccount_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: storageAccount
  }
]

resource storageAccount_lock 'Microsoft.Authorization/locks@2020-05-01' = if (!empty(lock ?? {}) && lock.?kind != 'None') {
  name: lock.?name ?? 'lock-${name}'
  properties: {
    level: lock.?kind ?? ''
    notes: lock.?kind == 'CanNotDelete'
      ? 'Cannot delete resource or child resources.'
      : 'Cannot delete or modify the resource or child resources.'
  }
  scope: storageAccount
}

resource storageAccount_roleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for (roleAssignment, index) in (roleAssignments ?? []): {
    name: guid(storageAccount.id, roleAssignment.principalId, roleAssignment.roleDefinitionIdOrName)
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
      conditionVersion: !empty(roleAssignment.?condition) ? (roleAssignment.?conditionVersion ?? '2.0') : null // Must only be set if condtion is set
      delegatedManagedIdentityResourceId: roleAssignment.?delegatedManagedIdentityResourceId
    }
    scope: storageAccount
  }
]


var defaultPrivateEndpoints = [for service in privateEndpointDefaultServices ?? []: {
  service: service
  subnetResourceId: !empty(privateEndpoints) ? privateEndpoints[0].subnetResourceId : null
}]
var applyingPrivateEndpoints =  ( empty(privateEndpoints) || (length(privateEndpoints)==1 && privateEndpoints[0].?service != null) ) ? privateEndpoints : defaultPrivateEndpoints

@batchSize(1)
module storageAccount_privateEndpoints 'br/amavm:res/network/private-endpoint:0.2.0' = [
  for (privateEndpoint, index) in (applyingPrivateEndpoints ?? []): {
    name: '${uniqueString(deployment().name, location, name)}-storageaccount-pep-${index}-${privateEndpoint.service}'
    scope: resourceGroup(privateEndpoint.?resourceGroupName ?? '')
    params: {
      name: privateEndpoint.?name ?? '${last(split(storageAccount.id, '/'))}-pep-${privateEndpoint.service}-${index}'
      privateLinkServiceConnections: privateEndpoint.?isManualConnection != true
        ? [
            {
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(storageAccount.id, '/'))}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: storageAccount.id
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
              name: privateEndpoint.?privateLinkServiceConnectionName ?? '${last(split(storageAccount.id, '/'))}-${privateEndpoint.service}-${index}'
              properties: {
                privateLinkServiceId: storageAccount.id
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
        '2024-05-01',
        'Full'
      ).location
      lock: privateEndpoint.?lock ?? lock
      privateDnsZoneGroup: !empty(privateEndpoint.?privateDnsZoneResourceIds) ? {
        privateDnsZoneGroupConfigs: [
          {
            privateDnsZoneResourceId: privateEndpoint.?privateDnsZoneResourceIds
            name: privateEndpoint.?privateDnsZoneGroupName
          }
        ]
      } : null
      roleAssignments: privateEndpoint.?roleAssignments
      tags: union(privateEndpoint.?tags ?? {}, finalTags)
      customDnsConfigs: privateEndpoint.?customDnsConfigs
      ipConfigurations: privateEndpoint.?ipConfigurations
      applicationSecurityGroupResourceIds: privateEndpoint.?applicationSecurityGroupResourceIds
      customNetworkInterfaceName: privateEndpoint.?customNetworkInterfaceName
    }
  }
]

// Lifecycle Policy
module storageAccount_managementPolicies 'management-policy/main.bicep' = if (!empty(managementPolicyRules ?? []) && !empty(blobServices)) {
  name: '${uniqueString(deployment().name, location)}-storageaccount-managementpolicies'
  params: {
    storageAccountName: storageAccount.name
    rules: managementPolicyRules ?? []
  }
  dependsOn: [
    storageAccount_blobServices // To ensure the lastAccessTimeTrackingPolicy is set first (if used in rule)
  ]
}

// SFTP user settings
module storageAccount_localUsers 'local-user/main.bicep' = [
  for (localUser, index) in localUsers: {
    name: '${uniqueString(deployment().name, location)}-storageaccount-localusers-${index}'
    params: {
      storageAccountName: storageAccount.name
      name: localUser.name
      hasSshKey: localUser.hasSshKey
      hasSshPassword: localUser.hasSshPassword
      permissionScopes: localUser.permissionScopes
      hasSharedKey: localUser.?hasSharedKey
      homeDirectory: localUser.?homeDirectory
      sshAuthorizedKeys: localUser.?sshAuthorizedKeys
    }
  }
]

// Containers
module storageAccount_blobServices 'blob-service/main.bicep' = if (!empty(blobServices)) {
  name: '${uniqueString(deployment().name, location, name)}-storageaccount-blobservices'
  params: {
    storageAccountName: storageAccount.name
    containers: blobServices.?containers
    automaticSnapshotPolicyEnabled: blobServices.?automaticSnapshotPolicyEnabled
    changeFeedEnabled: blobServices.?changeFeedEnabled
    changeFeedRetentionInDays: blobServices.?changeFeedRetentionInDays
    containerDeleteRetentionPolicyEnabled: blobServices.?containerDeleteRetentionPolicyEnabled
    containerDeleteRetentionPolicyDays: blobServices.?containerDeleteRetentionPolicyDays
    containerDeleteRetentionPolicyAllowPermanentDelete: blobServices.?containerDeleteRetentionPolicyAllowPermanentDelete
    corsRules: blobServices.?corsRules
    defaultServiceVersion: blobServices.?defaultServiceVersion
    deleteRetentionPolicyAllowPermanentDelete: blobServices.?deleteRetentionPolicyAllowPermanentDelete
    deleteRetentionPolicyEnabled: blobServices.?deleteRetentionPolicyEnabled
    deleteRetentionPolicyDays: blobServices.?deleteRetentionPolicyDays
    isVersioningEnabled: blobServices.?isVersioningEnabled
    lastAccessTimeTrackingPolicyEnabled: blobServices.?lastAccessTimeTrackingPolicyEnabled
    restorePolicyEnabled: blobServices.?restorePolicyEnabled
    restorePolicyDays: blobServices.?restorePolicyDays
    diagnosticSettings: blobServices.?diagnosticSettings
  }
}

// File Shares
module storageAccount_fileServices 'file-service/main.bicep' = if (!empty(fileServices)) {
  name: '${uniqueString(deployment().name, location, name)}-storageaccount-fileservices'
  params: {
    storageAccountName: storageAccount.name
    corsRules: fileServices.?corsRules
    diagnosticSettings: fileServices.?diagnosticSettings
    protocolSettings: fileServices.?protocolSettings
    shareDeleteRetentionPolicy: fileServices.?shareDeleteRetentionPolicy
    shares: fileServices.?shares
  }
}

// Queue
module storageAccount_queueServices 'queue-service/main.bicep' = if (!empty(queueServices)) {
  name: '${uniqueString(deployment().name, location, name)}-storageaccount-queueservices'
  params: {
    storageAccountName: storageAccount.name
    corsRules: queueServices.?corsRules
    diagnosticSettings: queueServices.?diagnosticSettings
    queues: queueServices.?queues
  }
}

// Table
module storageAccount_tableServices 'table-service/main.bicep' = if (!empty(tableServices)) {
  name: '${uniqueString(deployment().name, location, name)}-storageaccount-tableservices'
  params: {
    storageAccountName: storageAccount.name
    corsRules: tableServices.?corsRules
    diagnosticSettings: tableServices.?diagnosticSettings
    tables: tableServices.?tables
  }
}

// Secrets Export
module secretsExport 'modules/keyVaultExport.bicep' = if (secretsExportConfiguration != null) {
  name: '${uniqueString(deployment().name, location)}-secrets-kv'
  scope: resourceGroup(
    split(secretsExportConfiguration.?keyVaultResourceId!, '/')[2],
    split(secretsExportConfiguration.?keyVaultResourceId!, '/')[4]
  )
  params: {
    keyVaultName: last(split(secretsExportConfiguration.?keyVaultResourceId!, '/'))
    secretsToSet: union(
      [],
      contains(secretsExportConfiguration!, 'accessKey1Name')
        ? [
            {
              name: secretsExportConfiguration!.?accessKey1Name
              value: storageAccount.listKeys().keys[0].value
            }
          ]
        : [],
      contains(secretsExportConfiguration!, 'connectionString1Name')
        ? [
            {
              name: secretsExportConfiguration!.?connectionString1Name
              value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
            }
          ]
        : [],
      contains(secretsExportConfiguration!, 'accessKey2Name')
        ? [
            {
              name: secretsExportConfiguration!.?accessKey2Name
              value: storageAccount.listKeys().keys[1].value
            }
          ]
        : [],
      contains(secretsExportConfiguration!, 'connectionString2Name')
        ? [
            {
              name: secretsExportConfiguration!.?connectionString2Name
              value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[1].value};EndpointSuffix=${environment().suffixes.storage}'
            }
          ]
        : []
    )
  }
}

// Object Replication Policies
module storageAccount_objectReplicationPolicies 'object-replication-policy/main.bicep' = [
  for (policy, index) in (objectReplicationPolicies ?? []): {
    name: '${uniqueString(deployment().name, location)}-Storage-ObjRepPolicy-${index}'
    params: {
      storageAccountName: storageAccount.name
      destinationAccountResourceId: policy.destinationStorageAccountResourceId
      enableMetrics: policy.?enableMetrics ?? false
      rules: policy.?rules
    }
    dependsOn: [
      storageAccount_blobServices
    ]
  }
]

@description('The resource ID of the deployed storage account.')
output resourceId string = storageAccount.id

@description('The name of the deployed storage account.')
output name string = storageAccount.name

@description('The resource group of the deployed storage account.')
output resourceGroupName string = resourceGroup().name

@description('The primary blob endpoint reference if blob services are deployed.')
output primaryBlobEndpoint string = (supportsBlobService && !empty(blobServices))
  ? storageAccount.properties.primaryEndpoints.blob
  : ''

@description('The primary dfs endpoint reference if blob services are deployed and HNS is enabled.')
output primaryDfsEndpoint string = (kind=='StorageV2' && enableHierarchicalNamespace && !empty(blobServices))
  ? storageAccount.properties.primaryEndpoints.dfs
  : ''

@description('The primary file endpoint reference if file services are deployed.')
output primaryFileEndpoint string = (supportsFileService && !empty(fileServices))
  ? storageAccount.properties.primaryEndpoints.file
  : ''

@description('The primary table endpoint reference if table services are deployed.')
output primaryTableEndpoint string = (!empty(tableServices))
  ? storageAccount.properties.primaryEndpoints.table
  : ''

@description('The primary queue endpoint reference if queue services are deployed.')
output primaryQueueEndpoint string = (!empty(queueServices))
  ? storageAccount.properties.primaryEndpoints.queue
  : ''

@description('The primary endpoint references, if supported.')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('The secondary endpoint references, if supported.')
output secondaryEndpoints object = (skuName == 'Standard_RAGRS') ? storageAccount.properties.secondaryEndpoints : {}

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string = storageAccount.?identity.?principalId ?? ''

@description('The location the resource was deployed into.')
output location string = storageAccount.location

@description('A hashtable of references to the secrets exported to the provided Key Vault. The key of each reference is each secret\'s name.')
output exportedSecrets object = (secretsExportConfiguration != null)
  ? toObject(secretsExport!.outputs.secretsSet, secret => last(split(secret.secretResourceId, '/')), secret => secret)
  : {}

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = allowSharedKeyAccess /* drcp-st-04 */ || !requireInfrastructureEncryption /* drcp-st-05 */ || allowBlobPublicAccess /* drcp-st-02 */ || contains(['TLS1_0','TLS1_1'],minimumTlsVersion) /* drcp-st-06 */ || (publicNetworkAccess!='Disabled') /* drcp-st-01 */ || !supportsHttpsTrafficOnly /* drcp-st-03 */ || !empty(localUsers) /* drcp-st-09 */ || isLocalUserEnabled /* drcp-st-09 */ || allowCrossTenantReplication /* drcp-st-07 */ || enableSftp /* drcp-st-09 */ || (!empty(networkAcls) && ((networkAcls.?defaultAction ?? 'Deny') != 'Deny')) /* drcp-st-15 */ || (keyType != 'Account' && keyType != '') /* drcp-st-08 */ || (!empty(networkAcls) && ((networkAcls.?bypass ?? 'None') != 'None')) /* drcp-st-15 */


// =============== //
//   Definitions   //
// =============== //

import {
  customerManagedKeyType
  diagnosticSettingType
  lockType
  managedIdentitiesType
  privateEndpointType
  roleAssignmentType
  networkAclsType
} from '../../../../bicep-shared/types.bicep'

import { blobServiceType } from 'blob-service/main.bicep'
import { fileServiceType } from 'file-service/main.bicep'
import { queueServiceType } from 'queue-service/main.bicep'
import { tableServiceType } from 'table-service/main.bicep'
import { storageManagementPolicyRuleType } from 'management-policy/main.bicep'

@description('Configuration for exporting storage account keys and connection strings to a Key Vault.')
type secretsExportConfigurationType = {
  @description('Required. The resource ID of the Key Vault where to store the keys and connection strings.')
  keyVaultResourceId: string

  @description('Optional. The accessKey1 secret name to create.')
  accessKey1Name: string?

  @description('Optional. The connectionString1 secret name to create.')
  connectionString1Name: string?

  @description('Optional. The accessKey2 secret name to create.')
  accessKey2Name: string?

  @description('Optional. The connectionString2 secret name to create.')
  connectionString2Name: string?
}

@export()
@description('The type of an object replication policy.')
type objectReplicationPolicyType = {
  @description('Optional. The name of the object replication policy. If not provided, a GUID will be generated.')
  name: string?

  @description('Required. The resource ID of the destination storage account.')
  destinationStorageAccountResourceId: string

  @description('Optional. Indicates whether metrics are enabled for the object replication policy.')
  enableMetrics: bool?

  @description('Required. The storage account object replication rules.')
  rules: objectReplicationPolicyRuleType[]
}
