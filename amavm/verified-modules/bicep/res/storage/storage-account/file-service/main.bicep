metadata name = 'Storage Account File Share Services'
metadata description = 'This module deploys a Storage Account File Share Service.'
metadata owner = 'AMCCC'
metadata compliance = 'There are no special compliance requirements for this module'
metadata complianceVersion = '20240705'


@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Optional. The name of the file service.')
param name string = 'default'

@description('''Optional. Specifies CORS rules for the File service. You can include up to five CorsRule elements in the request.
If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the File service.''')
param corsRules corsRuleType[]?

@description('Optional. Protocol settings for file service. Default: SMB3.1.1 with AES-256-GCM encryption.')
param protocolSettings protocolSettingsType = {
  smb: {
    versions: 'SMB3.1.1'
    channelEncryption: 'AES-256-GCM'
    authenticationMethods: 'Kerberos'
    kerberosTicketEncryption: 'AES-256'
  }
}

@description('Optional. The service properties for soft delete. Default: enabled with 7 days retention period.')
param shareDeleteRetentionPolicy {
  @description('Required. The service properties to enable.')
  enabled: bool
  @description('Optional. Retention days.')
  days: int?
} = {
  enabled: true
  days: 7
}

@description('''Optional. The diagnostic settings of the service.

Available options for log categories are: 'StorageRead', 'StorageWrite', 'StorageDelete'
''')
param diagnosticSettings diagnosticSettingType?

@description('Optional. File shares to create.')
param shares fileServiceShareType[]?

var defaultShareAccessTier = storageAccount.kind == 'FileStorage' ? 'Premium' : 'TransactionOptimized' // default share accessTier depends on the Storage Account kind: 'Premium' for 'FileStorage' kind, 'TransactionOptimized' otherwise

// When a diagnostic setting is provided without the log category, this array will be used to define defaults
var defaultLogCategoryNames = [
  'StorageRead'
  'StorageWrite'
  'StorageDelete'
]
var defaultLogCategories = [for category in defaultLogCategoryNames ?? []: {
  category: category
}]

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2025-01-01' = {
  name: name
  parent: storageAccount
  properties: {
    cors: !empty(corsRules ?? []) ? {
      corsRules: corsRules
    } : null
    protocolSettings: !empty(protocolSettings.?smb ?? {}) ? protocolSettings : null
    shareDeleteRetentionPolicy: (shareDeleteRetentionPolicy.?enabled ?? false) ? shareDeleteRetentionPolicy : null
  }
}

#disable-next-line use-recent-api-versions
resource fileServices_diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = [
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
        for group in (diagnosticSetting.?logCategoriesAndGroups ?? defaultLogCategories ): {
          categoryGroup: group.?categoryGroup
          category: group.?category
          enabled: group.?enabled ?? true
        }
      ]
      marketplacePartnerId: diagnosticSetting.?marketplacePartnerResourceId
      logAnalyticsDestinationType: diagnosticSetting.?logAnalyticsDestinationType
    }
    scope: fileServices
  }
]

module fileServices_shares 'share/main.bicep' = [
  for (share, index) in (shares ?? []): {
    name: take('${deployment().name}-shares-${index}-${share.name}',64)
    params: {
      storageAccountName: storageAccount.name
      fileServicesName: fileServices.name
      name: share.name
      accessTier: share.?accessTier ?? defaultShareAccessTier
      enabledProtocols: share.?enabledProtocols
      rootSquash: share.?rootSquash
      shareQuota: share.?shareQuota
      roleAssignments: share.?roleAssignments
    }
  }
]

@description('The name of the deployed file share service.')
output name string = fileServices.name

@description('The resource ID of the deployed file share service.')
output resourceId string = fileServices.id

@description('The resource group of the deployed file share service.')
output resourceGroupName string = resourceGroup().name

output evidenceOfNonCompliance bool = false

// =============== //
//   Definitions   //
// =============== //

import {
  diagnosticSettingType
  corsRuleType
} from '../../../../../bicep-shared/types.bicep'

import { fileServiceShareType } from 'share/main.bicep'

@export()
type fileServiceType = {
  @description('Optional. The name of the file service.')
  name: string?

  @description('''Optional. Specifies CORS rules for the File service. You can include up to five CorsRule elements in the request.
  If no CorsRule elements are included in the request body, all CORS rules will be deleted, and CORS will be disabled for the File service.''')
  corsRules: corsRuleType[]?

  @description('Optional. Protocol settings for file service.')
  protocolSettings: protocolSettingsType?

  @description('Optional. The service properties for soft delete.')
  shareDeleteRetentionPolicy: {
    @description('Required. The service properties to enable.')
    enabled: bool
    
    @description('Optional. Retention days.')
    days: int?
  }?

  @description('''Optional. The diagnostic settings of the service.

  Available options for log categories are: 'StorageRead', 'StorageWrite', 'StorageDelete'
  ''')
  diagnosticSettings: diagnosticSettingType?

  @description('Optional. File shares to create.')
  shares: fileServiceShareType[]?
}

type protocolSettingsType = {
  @description('''Optional. SMB protocol settings details.''')
  smb: {
    @description('''Required. SMB protocol versions supported by server. Valid values are SMB2.1, SMB3.0, SMB3.1.1. Should be passed as a string with delimiter ';'.''')
    versions: ('SMB2.1' | 'SMB3.0' | 'SMB3.1.1' | 'SMB2.1;SMB3.0' | 'SMB3.0;SMB3.1.1' | 'SMB2.1;SMB3.1.1' | 'SMB2.1;SMB3.0;SMB3.1.1')

    @description('''Required. SMB channel encryption supported by server. SMB 2.1 does not support encryption. SMB 3.0 only support AES-128-CCM.''')
    channelEncryption: ('' | 'AES-128-CCM' | 'AES-128-GCM' | 'AES-256-GCM' | 'AES-128-CCM;AES-128-GCM' | 'AES-128-GCM;AES-256-GCM' | 'AES-128-CCM;AES-128-GCM;AES-256-GCM')

    @description('''Optional. SMB authentication methods supported by server. Valid values are NTLMv2, Kerberos, and their combination.''')
    authenticationMethods: ('NTLMv2' | 'Kerberos' | 'NTLMv2;Kerberos')?

    @description('''Optional. Kerberos ticket encryption supported by server. Required if authenticationMethods contains Kerberos''')
    kerberosTicketEncryption: ('RC4-HMAC' | 'AES-256' | 'RC4-HMAC;AES-256' | '')?

    @description('Optional. Multichannel setting. Applies to Premium FileStorage only.')
    multichannel: {
      @description('Required. To enable or not.')
      enabled: bool
    }?


  }
}
