# Azure Key Vault Key `[Microsoft.KeyVault/vaults/keys]`

This module deploys an Azure Key Vault Key.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20240719

Compliant usage of this resource requires following parameter values:
- attributesExp: set to a value less than 1 year from the creation.


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.KeyVault/vaults/keys` | 2023-07-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults_keys.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2023-07-01/vaults/keys)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the key. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`keyVaultName`](#parameter-keyvaultname) | string | The name of the parent key vault. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`attributesEnabled`](#parameter-attributesenabled) | bool | Determines whether the object (key) is enabled. Default: true. |
| [`attributesExp`](#parameter-attributesexp) | int | Expiry date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp.<p>Default is 1 year (dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))).<p><p>Not setting the expiry date within 1 year will make the resource non-compliant.<p> |
| [`attributesNbf`](#parameter-attributesnbf) | int | Sets when this resource will become active.<p>This is a date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp. Default: null |
| [`curveName`](#parameter-curvename) | string | The elliptic curve name. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`keyOps`](#parameter-keyops) | array | Array of JsonWebKeyOperation. |
| [`keySize`](#parameter-keysize) | int | The key size in bits. For example: 2048, 3072, or 4096 for RSA. |
| [`kty`](#parameter-kty) | string | The type of the key. |
| [`releasePolicy`](#parameter-releasepolicy) | object | Key release policy. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`rotationPolicy`](#parameter-rotationpolicy) | object | Key rotation policy properties object. |
| [`tags`](#parameter-tags) | object | Resource tags. |

### Parameter: `name`

The name of the key.

- Required: Yes
- Type: string

### Parameter: `keyVaultName`

The name of the parent key vault. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `attributesEnabled`

Determines whether the object (key) is enabled. Default: true.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `attributesExp`

Expiry date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp.<p>Default is 1 year (dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))).<p><p>Not setting the expiry date within 1 year will make the resource non-compliant.<p>

- Required: No
- Type: int
- Default: `[dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))]`

### Parameter: `attributesNbf`

Sets when this resource will become active.<p>This is a date in seconds since 1970-01-01T00:00:00Z. Use Epoch Unix Timestamp. Default: null

- Required: No
- Type: int

### Parameter: `curveName`

The elliptic curve name.

- Required: No
- Type: string
- Default: `'P-256'`
- Allowed:
  ```Bicep
  [
    'P-256'
    'P-256K'
    'P-384'
    'P-521'
  ]
  ```

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `keyOps`

Array of JsonWebKeyOperation.

- Required: No
- Type: array
- Allowed:
  ```Bicep
  [
    'decrypt'
    'encrypt'
    'import'
    'sign'
    'unwrapKey'
    'verify'
    'wrapKey'
  ]
  ```

### Parameter: `keySize`

The key size in bits. For example: 2048, 3072, or 4096 for RSA.

- Required: No
- Type: int

### Parameter: `kty`

The type of the key.

- Required: No
- Type: string
- Default: `'EC'`
- Allowed:
  ```Bicep
  [
    'EC'
    'EC-HSM'
    'RSA'
    'RSA-HSM'
  ]
  ```

### Parameter: `releasePolicy`

Key release policy.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`contentType`](#parameter-releasepolicycontenttype) | string | Content type and version of key release policy. |
| [`data`](#parameter-releasepolicydata) | string | Blob encoding the policy rules under which the key can be released. |

### Parameter: `releasePolicy.contentType`

Content type and version of key release policy.

- Required: No
- Type: string

### Parameter: `releasePolicy.data`

Blob encoding the policy rules under which the key can be released.

- Required: No
- Type: string

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array
- Roles configurable by name:
  - `'Key Vault Crypto Officer'`
  - `'Key Vault Crypto User'`
  - `'Key Vault Crypto Service Encryption User'`
  - `'Key Vault Crypto Service Release User'`

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

### Parameter: `rotationPolicy`

Key rotation policy properties object.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`attributes`](#parameter-rotationpolicyattributes) | object | The attributes of key rotation policy. |
| [`lifetimeActions`](#parameter-rotationpolicylifetimeactions) | array | The lifetimeActions for key rotation action. |

### Parameter: `rotationPolicy.attributes`

The attributes of key rotation policy.

- Required: No
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`expiryTime`](#parameter-rotationpolicyattributesexpirytime) | string | The expiration time for the new key version. It should be in ISO8601 format. Eg: "P90D", "P1Y". |

### Parameter: `rotationPolicy.attributes.expiryTime`

The expiration time for the new key version. It should be in ISO8601 format. Eg: "P90D", "P1Y".

- Required: No
- Type: string

### Parameter: `rotationPolicy.lifetimeActions`

The lifetimeActions for key rotation action.

- Required: Yes
- Type: array

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`action`](#parameter-rotationpolicylifetimeactionsaction) | object | The action of key rotation policy lifetimeAction. |
| [`trigger`](#parameter-rotationpolicylifetimeactionstrigger) | object | The trigger of key rotation policy lifetimeAction. |

### Parameter: `rotationPolicy.lifetimeActions.action`

The action of key rotation policy lifetimeAction.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`type`](#parameter-rotationpolicylifetimeactionsactiontype) | string | The type of action. |

### Parameter: `rotationPolicy.lifetimeActions.action.type`

The type of action.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'notify'
    'rotate'
  ]
  ```

### Parameter: `rotationPolicy.lifetimeActions.trigger`

The trigger of key rotation policy lifetimeAction.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`timeAfterCreate`](#parameter-rotationpolicylifetimeactionstriggertimeaftercreate) | string | The time duration after key creation to rotate the key. It only applies to rotate. It will be in ISO 8601 duration format. Eg: "P90D", "P1Y". |
| [`timeBeforeExpiry`](#parameter-rotationpolicylifetimeactionstriggertimebeforeexpiry) | string | The time duration before key expiring to rotate or notify. It will be in ISO 8601 duration format. Eg: "P90D", "P1Y". |

### Parameter: `rotationPolicy.lifetimeActions.trigger.timeAfterCreate`

The time duration after key creation to rotate the key. It only applies to rotate. It will be in ISO 8601 duration format. Eg: "P90D", "P1Y".

- Required: No
- Type: string

### Parameter: `rotationPolicy.lifetimeActions.trigger.timeBeforeExpiry`

The time duration before key expiring to rotate or notify. It will be in ISO 8601 duration format. Eg: "P90D", "P1Y".

- Required: No
- Type: string

### Parameter: `tags`

Resource tags.

- Required: No
- Type: object

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `keyUri` | string | The Uri of the key. |
| `keyUriWithVersion` | string | The Uri of the key with version included. |
| `name` | string | The name of the key. |
| `properties` | object | The properties of the key. |
| `resourceGroupName` | string | The name of the resource group the key was created in. |
| `resourceId` | string | The resource ID of the key. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
