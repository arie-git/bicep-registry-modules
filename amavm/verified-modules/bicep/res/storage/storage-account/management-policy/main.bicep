metadata name = 'Storage Account Management Policy'
metadata description = 'This module deploys a Storage Account Management Policy.'
metadata owner = 'AMCCC'
metadata compliance = 'This resource has no special compliance requirements.'
metadata complianceVersion = '20240709'


@maxLength(24)
@description('Conditional. The name of the parent Storage Account. Required if the template is used in a standalone deployment.')
param storageAccountName string

@description('Required. The Storage Account ManagementPolicies Rules.')
param rules storageManagementPolicyRuleType[]

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

// lifecycle policy
resource managementPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-05-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    policy: {
      rules: rules
    }
  }
}

@description('The resource ID of the deployed management policy.')
output resourceId string = managementPolicy.name

@description('The name of the deployed management policy.')
output name string = managementPolicy.name

@description('The resource group of the deployed management policy.')
output resourceGroupName string = resourceGroup().name

@description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = false

// =============== //
//   Definitions   //
// =============== //

@export()
@description('The Storage Account ManagementPolicy, in JSON format. See more details in: https://docs.microsoft.com/azure/storage/common/storage-lifecycle-managment-concepts')
type storageManagementPolicyRuleType = {
  @description('Optional. An object that defines the Lifecycle rule.')
  definition: {
    @description('Optional. An object that defines the action set.')
    actions: {
      @description('Optional. The management policy action for base blob')
      baseBlob: {
        @description('Optional. The function to delete the blob')
        delete: dateAfterModificationType?
        @description('Optional. This property enables auto tiering of a blob from cool to hot on a blob access. This property requires tierToCool.daysAfterLastAccessTimeGreaterThan.')
        enableAutoTierToHotFromCool: bool?
        @description('Optional. The function to tier blobs to archive storage.')
        tierToArchive: dateAfterModificationType?
        @description('Optional. The function to tier blobs to cold storage.')
        tierToCold: dateAfterModificationType?
        @description('Optional. The function to tier blobs to cool storage.')
        tierToCool: dateAfterModificationType?
        @description('Optional. The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts')
        tierToHot: dateAfterModificationType?
      }?

      @description('Optional. The management policy action for snapshot')
      snapshot: {
        @description('Optional. The function to delete the blob snapshot')
        delete: dateAfterCreationType?
        @description('Optional. The function to tier blob snapshot to archive storage.')
        tierToArchive: dateAfterCreationType?
        @description('Optional. The function to tier blobs to cold storage.')
        tierToCold: dateAfterCreationType?
        @description('Optional. The function to tier blob snapshot to cool storage.')
        tierToCool: dateAfterCreationType?
        @description('Optional. The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts')
        tierToHot: dateAfterCreationType?
      }?

      @description('Optional. The management policy action for version')
      version: {
        @description('Optional. The function to delete the blob version')
        delete: dateAfterCreationType?
        @description('Optional. The function to tier blob version to archive storage.')
        tierToArchive: dateAfterCreationType?
        @description('Optional. The function to tier blobs to cold storage.')
        tierToCold: dateAfterCreationType?
        @description('Optional. The function to tier blob version to cool storage.')
        tierToCool: dateAfterCreationType?
        @description('Optional. The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts')
        tierToHot: dateAfterCreationType?
      }?
    }
    @description('Optional. An object that defines the filter set.')
    filters: {
      @maxLength(10)
      @description('Required. An array of blob index tag based filters, there can be at most 10 tag filters')
      blobIndexMatch: [
        {
          @minLength(1)
          @maxLength(128)
          @description('Required. This is the filter tag name.')
          name: string
          @description('Required. This is the comparison operator which is used for object comparison and filtering. Only == (equality operator) is currently supported')
          op: string
          @maxLength(256)
          @description('Required. This is the filter tag value field used for tag based filtering')
          value: string
        }
      ]
      @description('Required. An array of predefined enum values. Currently blockBlob supports all tiering and delete actions. Only delete actions are supported for appendBlob.')
      blobTypes: string[]
      @description('Optional. An array of strings for prefixes to be match.')
      prefixMatch: string[]?
    }?
  }

  @description('Optional. Rule is enabled if set to true.')
  enabled: bool

  @description('Required. A rule name can contain any combination of alpha numeric characters. Rule name is case-sensitive. It must be unique within a policy.')
  name: string

  @description('Optional. The valid value is Lifecycle')
  type: 'Lifecycle'
}

type dateAfterModificationType = {
  @minValue(0)
  @description('Optional. Value indicating the age in days after blob creation.')
  daysAfterCreationGreaterThan: int?
  @minValue(0)
  @description('Optional. Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy')
  daysAfterLastAccessTimeGreaterThan: int?
  @minValue(0)
  @description('Optional. Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied.')
  daysAfterLastTierChangeGreaterThan: int?
  @minValue(0)
  @description('Optional. Value indicating the age in days after last modification')
  daysAfterModificationGreaterThan: int?
}

type dateAfterCreationType = {
  @minValue(0)
  @description('Optional. Value indicating the age in days after creation')
  daysAfterCreationGreaterThan: int
  @minValue(0)
  @description('Optional. Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.')
  daysAfterLastTierChangeGreaterThan: int?
}
