# Private Link Scope Scoped Resources `[Microsoft.Insights/privateLinkScopes/scopedResources]`

This module deploys a Private Link Scope Scoped Resource.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Insights/privateLinkScopes/scopedResources` | 2023-06-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_privatelinkscopes_scopedresources.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2023-06-01-preview/privateLinkScopes/scopedResources)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`linkedResourceId`](#parameter-linkedresourceid) | string | The resource ID of the scoped Azure monitor resource. |
| [`name`](#parameter-name) | string | Name of the private link scoped resource. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`privateLinkScopeName`](#parameter-privatelinkscopename) | string | The name of the parent private link scope. Required if the template is used in a standalone deployment. |

### Parameter: `linkedResourceId`

The resource ID of the scoped Azure monitor resource.

- Required: Yes
- Type: string

### Parameter: `name`

Name of the private link scoped resource.

- Required: Yes
- Type: string

### Parameter: `privateLinkScopeName`

The name of the parent private link scope. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The full name of the deployed Scoped Resource. |
| `resourceGroupName` | string | The name of the resource group where the resource has been deployed. |
| `resourceId` | string | The resource ID of the deployed scopedResource. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
