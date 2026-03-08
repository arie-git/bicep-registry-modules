# DBforPostgreSQL Flexible Server Advanced Threat Protection `[Microsoft.DBforPostgreSQL/flexibleServers/advancedThreatProtectionSettings]`

This module deploys a DBforPostgreSQL Advanced Threat Protection.

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
| `Microsoft.DBforPostgreSQL/flexibleServers/advancedThreatProtectionSettings` | 2024-08-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.dbforpostgresql_flexibleservers_advancedthreatprotectionsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DBforPostgreSQL/2024-08-01/flexibleServers/advancedThreatProtectionSettings)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serverThreatProtection`](#parameter-serverthreatprotection) | string | Specifies the state of the Threat Protection, whether it is enabled or disabled or a state has not been applied yet on the specific server. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`flexibleServerName`](#parameter-flexibleservername) | string | The name of the parent PostgreSQL flexible server. Required if the template is used in a standalone deployment. |

### Parameter: `serverThreatProtection`

Specifies the state of the Threat Protection, whether it is enabled or disabled or a state has not been applied yet on the specific server.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Disabled'
    'Enabled'
  ]
  ```

### Parameter: `flexibleServerName`

The name of the parent PostgreSQL flexible server. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `advancedTreatProtectionState` | string | The advanced threat protection state for the flexible server. |
| `name` | string | The resource id of the advanced threat protection state for the flexible server. |
| `resourceGroupName` | string | The resource group of the deployed administrator. |
| `resourceId` | string | The resource id of the advanced threat protection state for the flexible server. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
