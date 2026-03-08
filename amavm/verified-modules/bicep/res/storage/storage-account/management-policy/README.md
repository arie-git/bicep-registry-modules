# Storage Account Management Policy `[Microsoft.Storage/storageAccounts/managementPolicies]`

This module deploys a Storage Account Management Policy.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20240709

This resource has no special compliance requirements.

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Storage/storageAccounts/managementPolicies` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_managementpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/managementPolicies)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`rules`](#parameter-rules) | array | The Storage Account ManagementPolicies Rules. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`storageAccountName`](#parameter-storageaccountname) | string | The name of the parent Storage Account. Required if the template is used in a standalone deployment. |

### Parameter: `rules`

The Storage Account ManagementPolicies Rules.

- Required: Yes
- Type: array

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-rulesname) | string | A rule name can contain any combination of alpha numeric characters. Rule name is case-sensitive. It must be unique within a policy. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`definition`](#parameter-rulesdefinition) | object | An object that defines the Lifecycle rule. |
| [`enabled`](#parameter-rulesenabled) | bool | Rule is enabled if set to true. |
| [`type`](#parameter-rulestype) | string | The valid value is Lifecycle |

### Parameter: `rules.name`

A rule name can contain any combination of alpha numeric characters. Rule name is case-sensitive. It must be unique within a policy.

- Required: Yes
- Type: string

### Parameter: `rules.definition`

An object that defines the Lifecycle rule.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`actions`](#parameter-rulesdefinitionactions) | object | An object that defines the action set. |
| [`filters`](#parameter-rulesdefinitionfilters) | object | An object that defines the filter set. |

### Parameter: `rules.definition.actions`

An object that defines the action set.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`baseBlob`](#parameter-rulesdefinitionactionsbaseblob) | object | The management policy action for base blob |
| [`snapshot`](#parameter-rulesdefinitionactionssnapshot) | object | The management policy action for snapshot |
| [`version`](#parameter-rulesdefinitionactionsversion) | object | The management policy action for version |

### Parameter: `rules.definition.actions.baseBlob`

The management policy action for base blob

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`delete`](#parameter-rulesdefinitionactionsbaseblobdelete) | object | The function to delete the blob |
| [`enableAutoTierToHotFromCool`](#parameter-rulesdefinitionactionsbaseblobenableautotiertohotfromcool) | bool | This property enables auto tiering of a blob from cool to hot on a blob access. This property requires tierToCool.daysAfterLastAccessTimeGreaterThan. |
| [`tierToArchive`](#parameter-rulesdefinitionactionsbaseblobtiertoarchive) | object | The function to tier blobs to archive storage. |
| [`tierToCold`](#parameter-rulesdefinitionactionsbaseblobtiertocold) | object | The function to tier blobs to cold storage. |
| [`tierToCool`](#parameter-rulesdefinitionactionsbaseblobtiertocool) | object | The function to tier blobs to cool storage. |
| [`tierToHot`](#parameter-rulesdefinitionactionsbaseblobtiertohot) | object | The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts |

### Parameter: `rules.definition.actions.baseBlob.delete`

The function to delete the blob

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobdeletedaysaftercreationgreaterthan) | int | Value indicating the age in days after blob creation. |
| [`daysAfterLastAccessTimeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobdeletedaysafterlastaccesstimegreaterthan) | int | Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobdeletedaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied. |
| [`daysAfterModificationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobdeletedaysaftermodificationgreaterthan) | int | Value indicating the age in days after last modification |

### Parameter: `rules.definition.actions.baseBlob.delete.daysAfterCreationGreaterThan`

Value indicating the age in days after blob creation.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.delete.daysAfterLastAccessTimeGreaterThan`

Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.delete.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.delete.daysAfterModificationGreaterThan`

Value indicating the age in days after last modification

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.enableAutoTierToHotFromCool`

This property enables auto tiering of a blob from cool to hot on a blob access. This property requires tierToCool.daysAfterLastAccessTimeGreaterThan.

- Required: No
- Type: bool

### Parameter: `rules.definition.actions.baseBlob.tierToArchive`

The function to tier blobs to archive storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertoarchivedaysaftercreationgreaterthan) | int | Value indicating the age in days after blob creation. |
| [`daysAfterLastAccessTimeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertoarchivedaysafterlastaccesstimegreaterthan) | int | Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertoarchivedaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied. |
| [`daysAfterModificationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertoarchivedaysaftermodificationgreaterthan) | int | Value indicating the age in days after last modification |

### Parameter: `rules.definition.actions.baseBlob.tierToArchive.daysAfterCreationGreaterThan`

Value indicating the age in days after blob creation.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToArchive.daysAfterLastAccessTimeGreaterThan`

Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToArchive.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToArchive.daysAfterModificationGreaterThan`

Value indicating the age in days after last modification

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCold`

The function to tier blobs to cold storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocolddaysaftercreationgreaterthan) | int | Value indicating the age in days after blob creation. |
| [`daysAfterLastAccessTimeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocolddaysafterlastaccesstimegreaterthan) | int | Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocolddaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied. |
| [`daysAfterModificationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocolddaysaftermodificationgreaterthan) | int | Value indicating the age in days after last modification |

### Parameter: `rules.definition.actions.baseBlob.tierToCold.daysAfterCreationGreaterThan`

Value indicating the age in days after blob creation.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCold.daysAfterLastAccessTimeGreaterThan`

Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCold.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCold.daysAfterModificationGreaterThan`

Value indicating the age in days after last modification

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCool`

The function to tier blobs to cool storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocooldaysaftercreationgreaterthan) | int | Value indicating the age in days after blob creation. |
| [`daysAfterLastAccessTimeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocooldaysafterlastaccesstimegreaterthan) | int | Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocooldaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied. |
| [`daysAfterModificationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertocooldaysaftermodificationgreaterthan) | int | Value indicating the age in days after last modification |

### Parameter: `rules.definition.actions.baseBlob.tierToCool.daysAfterCreationGreaterThan`

Value indicating the age in days after blob creation.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCool.daysAfterLastAccessTimeGreaterThan`

Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCool.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToCool.daysAfterModificationGreaterThan`

Value indicating the age in days after last modification

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToHot`

The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertohotdaysaftercreationgreaterthan) | int | Value indicating the age in days after blob creation. |
| [`daysAfterLastAccessTimeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertohotdaysafterlastaccesstimegreaterthan) | int | Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertohotdaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied. |
| [`daysAfterModificationGreaterThan`](#parameter-rulesdefinitionactionsbaseblobtiertohotdaysaftermodificationgreaterthan) | int | Value indicating the age in days after last modification |

### Parameter: `rules.definition.actions.baseBlob.tierToHot.daysAfterCreationGreaterThan`

Value indicating the age in days after blob creation.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToHot.daysAfterLastAccessTimeGreaterThan`

Value indicating the age in days after last blob access. This property can only be used in conjunction with last access time tracking policy

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToHot.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterModificationGreaterThan to be set for baseBlobs based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.baseBlob.tierToHot.daysAfterModificationGreaterThan`

Value indicating the age in days after last modification

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot`

The management policy action for snapshot

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`delete`](#parameter-rulesdefinitionactionssnapshotdelete) | object | The function to delete the blob snapshot |
| [`tierToArchive`](#parameter-rulesdefinitionactionssnapshottiertoarchive) | object | The function to tier blob snapshot to archive storage. |
| [`tierToCold`](#parameter-rulesdefinitionactionssnapshottiertocold) | object | The function to tier blobs to cold storage. |
| [`tierToCool`](#parameter-rulesdefinitionactionssnapshottiertocool) | object | The function to tier blob snapshot to cool storage. |
| [`tierToHot`](#parameter-rulesdefinitionactionssnapshottiertohot) | object | The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts |

### Parameter: `rules.definition.actions.snapshot.delete`

The function to delete the blob snapshot

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionssnapshotdeletedaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionssnapshotdeletedaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.snapshot.delete.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.delete.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToArchive`

The function to tier blob snapshot to archive storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertoarchivedaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertoarchivedaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.snapshot.tierToArchive.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToArchive.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToCold`

The function to tier blobs to cold storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertocolddaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertocolddaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.snapshot.tierToCold.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToCold.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToCool`

The function to tier blob snapshot to cool storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertocooldaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertocooldaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.snapshot.tierToCool.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToCool.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToHot`

The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertohotdaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionssnapshottiertohotdaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.snapshot.tierToHot.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.snapshot.tierToHot.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version`

The management policy action for version

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`delete`](#parameter-rulesdefinitionactionsversiondelete) | object | The function to delete the blob version |
| [`tierToArchive`](#parameter-rulesdefinitionactionsversiontiertoarchive) | object | The function to tier blob version to archive storage. |
| [`tierToCold`](#parameter-rulesdefinitionactionsversiontiertocold) | object | The function to tier blobs to cold storage. |
| [`tierToCool`](#parameter-rulesdefinitionactionsversiontiertocool) | object | The function to tier blob version to cool storage. |
| [`tierToHot`](#parameter-rulesdefinitionactionsversiontiertohot) | object | The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts |

### Parameter: `rules.definition.actions.version.delete`

The function to delete the blob version

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsversiondeletedaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsversiondeletedaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.version.delete.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.delete.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToArchive`

The function to tier blob version to archive storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsversiontiertoarchivedaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsversiontiertoarchivedaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.version.tierToArchive.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToArchive.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToCold`

The function to tier blobs to cold storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsversiontiertocolddaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsversiontiertocolddaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.version.tierToCold.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToCold.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToCool`

The function to tier blob version to cool storage.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsversiontiertocooldaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsversiontiertocooldaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.version.tierToCool.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToCool.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToHot`

The function to tier blobs to hot storage. This action can only be used with Premium Block Blob Storage Accounts

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`daysAfterCreationGreaterThan`](#parameter-rulesdefinitionactionsversiontiertohotdaysaftercreationgreaterthan) | int | Value indicating the age in days after creation |
| [`daysAfterLastTierChangeGreaterThan`](#parameter-rulesdefinitionactionsversiontiertohotdaysafterlasttierchangegreaterthan) | int | Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied. |

### Parameter: `rules.definition.actions.version.tierToHot.daysAfterCreationGreaterThan`

Value indicating the age in days after creation

- Required: Yes
- Type: int
- MinValue: 0

### Parameter: `rules.definition.actions.version.tierToHot.daysAfterLastTierChangeGreaterThan`

Value indicating the age in days after last blob tier change time. This property is only applicable for tierToArchive actions and requires daysAfterCreationGreaterThan to be set for snapshots and blob version based actions. The blob will be archived if both the conditions are satisfied.

- Required: No
- Type: int
- MinValue: 0

### Parameter: `rules.definition.filters`

An object that defines the filter set.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`blobIndexMatch`](#parameter-rulesdefinitionfiltersblobindexmatch) | array | An array of blob index tag based filters, there can be at most 10 tag filters |
| [`blobTypes`](#parameter-rulesdefinitionfiltersblobtypes) | array | An array of predefined enum values. Currently blockBlob supports all tiering and delete actions. Only delete actions are supported for appendBlob. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`prefixMatch`](#parameter-rulesdefinitionfiltersprefixmatch) | array | An array of strings for prefixes to be match. |

### Parameter: `rules.definition.filters.blobIndexMatch`

An array of blob index tag based filters, there can be at most 10 tag filters

- Required: Yes
- Type: array

### Parameter: `rules.definition.filters.blobTypes`

An array of predefined enum values. Currently blockBlob supports all tiering and delete actions. Only delete actions are supported for appendBlob.

- Required: Yes
- Type: array

### Parameter: `rules.definition.filters.prefixMatch`

An array of strings for prefixes to be match.

- Required: No
- Type: array

### Parameter: `rules.enabled`

Rule is enabled if set to true.

- Required: Yes
- Type: bool

### Parameter: `rules.type`

The valid value is Lifecycle

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Lifecycle'
  ]
  ```

### Parameter: `storageAccountName`

The name of the parent Storage Account. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `name` | string | The name of the deployed management policy. |
| `resourceGroupName` | string | The resource group of the deployed management policy. |
| `resourceId` | string | The resource ID of the deployed management policy. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
