# Azure Container Registry Cache `[Microsoft.ContainerRegistry/registries/cacheRules]`

Cache for Azure Container Registry (Preview) feature allows users to cache container images in a private container registry. Cache for ACR, is a preview feature available in Basic, Standard, and Premium service tiers ([ref](https://learn.microsoft.com/en-us/azure/container-registry/tutorial-registry-cache)).

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20260309

There are no special compliance requirements for Cache Rules.

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.ContainerRegistry/registries/cacheRules` | 2023-06-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.containerregistry_registries_cacherules.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.ContainerRegistry/2023-06-01-preview/registries/cacheRules)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`credentialSetResourceId`](#parameter-credentialsetresourceid) | string | The resource ID of the credential store which is associated with the cache rule. |
| [`registryName`](#parameter-registryname) | string | The name of the parent registry. Required if the template is used in a standalone deployment. |
| [`sourceRepository`](#parameter-sourcerepository) | string | Source repository pulled from upstream. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`name`](#parameter-name) | string | The name of the cache rule. Will be derived from the source repository name if not defined. |
| [`targetRepository`](#parameter-targetrepository) | string | Target repository specified in docker pull command. E.g.: docker pull myregistry.azurecr.io/{targetRepository}:{tag}. |

### Parameter: `credentialSetResourceId`

The resource ID of the credential store which is associated with the cache rule.

- Required: No
- Type: string

### Parameter: `registryName`

The name of the parent registry. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `sourceRepository`

Source repository pulled from upstream.

- Required: Yes
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `name`

The name of the cache rule. Will be derived from the source repository name if not defined.

- Required: No
- Type: string
- Default: `[replace(replace(replace(parameters('sourceRepository'), '/', '-'), '.', '-'), '*', '')]`

### Parameter: `targetRepository`

Target repository specified in docker pull command. E.g.: docker pull myregistry.azurecr.io/{targetRepository}:{tag}.

- Required: No
- Type: string
- Default: `[parameters('sourceRepository')]`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `name` | string | The Name of the Cache Rule. |
| `resourceGroupName` | string | The name of the Cache Rule. |
| `resourceId` | string | The resource ID of the Cache Rule. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
