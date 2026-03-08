# Storage Account Blob Container `[Microsoft.Storage/storageAccounts/blobServices/containers]`

This module deploys a Storage Account Blob Container.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20240705

Compliant usage of container requires publicAccess set to 'None'

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_blobservices_containers.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/blobServices/containers)</li></ul> |
| `Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_blobservices_containers_immutabilitypolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/blobServices/containers/immutabilityPolicies)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the storage container to deploy. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`storageAccountName`](#parameter-storageaccountname) | string | The name of the parent Storage Account. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`defaultEncryptionScope`](#parameter-defaultencryptionscope) | string | Default the container to use specified encryption scope for all writes. |
| [`denyEncryptionScopeOverride`](#parameter-denyencryptionscopeoverride) | bool | Block override of encryption scope from the container default. |
| [`enableNfsV3AllSquash`](#parameter-enablenfsv3allsquash) | bool | Enable NFSv3 all squash on blob container. |
| [`enableNfsV3RootSquash`](#parameter-enablenfsv3rootsquash) | bool | Enable NFSv3 root squash on blob container. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`immutabilityPolicyName`](#parameter-immutabilitypolicyname) | string | Name of the immutable policy. |
| [`immutabilityPolicyProperties`](#parameter-immutabilitypolicyproperties) | object | Configure immutability policy. |
| [`immutableStorageWithVersioningEnabled`](#parameter-immutablestoragewithversioningenabled) | bool | This is an immutable property, when set to true it enables object level immutability at the container level. The property is immutable and can only be set to true at the container creation time. Existing containers must undergo a migration process. |
| [`metadata`](#parameter-metadata) | object | A name-value pair to associate with the container as metadata. |
| [`publicAccess`](#parameter-publicaccess) | string | Specifies whether data in the container may be accessed publicly and the level of access.<p><p>Setting the value to other than 'None' will make this resource non-compliant.<p> |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |

### Parameter: `name`

The name of the storage container to deploy.

- Required: Yes
- Type: string

### Parameter: `storageAccountName`

The name of the parent Storage Account. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `defaultEncryptionScope`

Default the container to use specified encryption scope for all writes.

- Required: No
- Type: string
- Default: `''`

### Parameter: `denyEncryptionScopeOverride`

Block override of encryption scope from the container default.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableNfsV3AllSquash`

Enable NFSv3 all squash on blob container.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableNfsV3RootSquash`

Enable NFSv3 root squash on blob container.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `immutabilityPolicyName`

Name of the immutable policy.

- Required: No
- Type: string
- Default: `'default'`

### Parameter: `immutabilityPolicyProperties`

Configure immutability policy.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`allowProtectedAppendWrites`](#parameter-immutabilitypolicypropertiesallowprotectedappendwrites) | bool | This property can only be changed for unlocked time-based retention policies. When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. |
| [`allowProtectedAppendWritesAll`](#parameter-immutabilitypolicypropertiesallowprotectedappendwritesall) | bool | This property can only be changed for unlocked time-based retention policies. When enabled, new blocks can be written to both "Append and Block Blobs" while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. The "allowProtectedAppendWrites" and "allowProtectedAppendWritesAll" properties are mutually exclusive. |
| [`immutabilityPeriodSinceCreationInDays`](#parameter-immutabilitypolicypropertiesimmutabilityperiodsincecreationindays) | int | The immutability period for the blobs in the container since the policy creation, in days. |

### Parameter: `immutabilityPolicyProperties.allowProtectedAppendWrites`

This property can only be changed for unlocked time-based retention policies. When enabled, new blocks can be written to an append blob while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API.

- Required: No
- Type: bool

### Parameter: `immutabilityPolicyProperties.allowProtectedAppendWritesAll`

This property can only be changed for unlocked time-based retention policies. When enabled, new blocks can be written to both "Append and Block Blobs" while maintaining immutability protection and compliance. Only new blocks can be added and any existing blocks cannot be modified or deleted. This property cannot be changed with ExtendImmutabilityPolicy API. The "allowProtectedAppendWrites" and "allowProtectedAppendWritesAll" properties are mutually exclusive.

- Required: No
- Type: bool

### Parameter: `immutabilityPolicyProperties.immutabilityPeriodSinceCreationInDays`

The immutability period for the blobs in the container since the policy creation, in days.

- Required: No
- Type: int

### Parameter: `immutableStorageWithVersioningEnabled`

This is an immutable property, when set to true it enables object level immutability at the container level. The property is immutable and can only be set to true at the container creation time. Existing containers must undergo a migration process.

- Required: No
- Type: bool
- Default: `False`

### Parameter: `metadata`

A name-value pair to associate with the container as metadata.

- Required: No
- Type: object
- Default: `{}`

### Parameter: `publicAccess`

Specifies whether data in the container may be accessed publicly and the level of access.<p><p>Setting the value to other than 'None' will make this resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'None'`
- Allowed:
  ```Bicep
  [
    'Blob'
    'Container'
    'None'
  ]
  ```

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Reader and Data Access'`
  - `'Storage Account Backup Contributor'`
  - `'Storage Account Contributor'`
  - `'Storage Account Key Operator Service Role'`
  - `'Storage Blob Data Contributor'`
  - `'Storage Blob Data Owner'`
  - `'Storage Blob Data Reader'`
  - `'Storage Blob Delegator'`

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

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `name` | string | The name of the deployed container. |
| `resourceGroupName` | string | The resource group of the deployed container. |
| `resourceId` | string | The resource ID of the deployed container. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
