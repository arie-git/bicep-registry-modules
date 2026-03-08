# DBforPostgreSQL Flexible Server Configurations `[Microsoft.DBforPostgreSQL/flexibleServers/configurations]`

This module deploys a DBforPostgreSQL Flexible Server Configuration.

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
| `Microsoft.DBforPostgreSQL/flexibleServers/configurations` | 2024-08-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.dbforpostgresql_flexibleservers_configurations.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DBforPostgreSQL/2024-08-01/flexibleServers/configurations)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the configuration. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`flexibleServerName`](#parameter-flexibleservername) | string | The name of the parent PostgreSQL flexible server. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`source`](#parameter-source) | string | Source of the configuration. |
| [`value`](#parameter-value) | string | Value of the configuration. |

### Parameter: `name`

The name of the configuration.

- Required: Yes
- Type: string

### Parameter: `flexibleServerName`

The name of the parent PostgreSQL flexible server. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `source`

Source of the configuration.

- Required: No
- Type: string

### Parameter: `value`

Value of the configuration.

- Required: No
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed configuration. |
| `resourceGroupName` | string | The resource group name of the deployed configuration. |
| `resourceId` | string | The resource ID of the deployed configuration. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
