metadata name = 'Storage Account File Share'
metadata description = 'This module deploys a Storage Account File Share.'
metadata owner = 'AMCCC'
metadata compliance = 'This resource does not have special compliance requirements'
metadata complianceVersion = '20240708'

@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Conditional. The name of the parent file service. Required if the template is used in a standalone deployment.')
param fileServicesName string = 'default'

@description('Required. The name of the file share to create.')
param name string

@allowed([
  'Premium'
  'Hot'
  'Cool'
  'TransactionOptimized'
])
@description('Conditional. Access tier for specific share. Required if the Storage Account kind is set to FileStorage (should be set to "Premium"). GpV2 account can choose between TransactionOptimized (default), Hot, and Cool.')
param accessTier string = 'TransactionOptimized'

@description('Optional. The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5120 (5TB). For Large File Shares, the maximum size is 102400 (100TB).')
param shareQuota int = 5120

@allowed([
  'NFS'
  'SMB'
])
@description('Optional. The authentication protocol that is used for the file share. Can only be specified when creating a share.')
param enabledProtocols string = 'SMB'

@allowed([
  'AllSquash'
  'NoRootSquash'
  'RootSquash'
])
@description('Optional. Permissions for NFS file shares are enforced by the client OS rather than the Azure Files service. Toggling the root squash behavior reduces the rights of the root user for NFS shares.')
param rootSquash string = 'NoRootSquash'

@description('Optional. Array of role assignments to create.')
param roleAssignments roleAssignmentType

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName

  resource fileService 'fileServices@2025-01-01' existing = {
    name: fileServicesName
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2025-01-01' = {
  name: name
  parent: storageAccount::fileService
  properties: {
    accessTier: accessTier
    shareQuota: shareQuota
    rootSquash: enabledProtocols == 'NFS' ? rootSquash : null
    enabledProtocols: enabledProtocols
  }
}

// NOTE: This is a workaround for a bug of the resource provider. Ref: https://github.com/Azure/bicep-types-az/issues/1532
module fileShare_roleAssignments 'modules/nested_roleAssignment.bicep' = if (!empty(roleAssignments ?? [])) {
  name: '${uniqueString(deployment().name)}-share-rbac'
  params: {
    fileShareResourceId: fileShare.id
    roleAssignments: roleAssignments!
  }
}

@description('The name of the deployed file share.')
output name string = fileShare.name

@description('The resource ID of the deployed file share.')
output resourceId string = fileShare.id

@description('The resource group of the deployed file share.')
output resourceGroupName string = resourceGroup().name

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false


// =============== //
//   Definitions   //
// =============== //

import {
  roleAssignmentType
} from '../../../../../../bicep-shared/types.bicep'

@export()
type fileServiceShareType = {
  @description('Required. The name of the file share to create.')
  name: string

  @description('Optional. Access tier for specific share. Required if the Storage Account kind is set to FileStorage (should be set to "Premium"). GpV2 account can choose between TransactionOptimized (default), Hot, and Cool.')
  accessTier: ('Premium' | 'Hot' | 'Cool' | 'TransactionOptimized')?

  @description('Optional. The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5120 (5TB). For Large File Shares, the maximum size is 102400 (100TB).')
  shareQuota: int

  @description('Optional. The authentication protocol that is used for the file share. Can only be specified when creating a share.')
  enabledProtocols: ('SMB' | 'NFS')?

  @description('Optional. Permissions for NFS file shares are enforced by the client OS rather than the Azure Files service. Toggling the root squash behavior reduces the rights of the root user for NFS shares.')
  rootSquash: ('NoRootSquash' | 'AllSquash' | 'RootSquash')?

  @description('Optional. Array of role assignments to create.')
  roleAssignments: roleAssignmentType
}
