# Azure Data Factory Integration Runtime `[Microsoft.DataFactory/factories/integrationRuntimes]`

This module deploys a Managed or Self-Hosted Integration Runtime for Azure Data Factory.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Notes](#notes)
- [Data Collection](#data-collection)

## Compliance

Version: 20240722

Compliant usage of Azure Data Factory requires:
- type: 'SelfHosted'
- managedVirtualNetworkName: empty
- typeProperties: empty


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.DataFactory/factories/integrationRuntimes` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_integrationruntimes.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/integrationRuntimes)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the Integration Runtime. |
| [`type`](#parameter-type) | string | The type of Integration Runtime.<p><p>Setting this parameter to any other than SelfHosted will make the resource non-compliant.<p> |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`dataFactoryName`](#parameter-datafactoryname) | string | The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`integrationRuntimeCustomDescription`](#parameter-integrationruntimecustomdescription) | string | The description of the Integration Runtime. |
| [`managedVirtualNetworkName`](#parameter-managedvirtualnetworkname) | string | The name of the Managed Virtual Network if using type "Managed".<p><p>Setting this paramter value will make the resource non-compliant.<p> |
| [`typeProperties`](#parameter-typeproperties) | object | Integration Runtime type properties. Required if type is "Managed".<p><p>Setting this paramter value will make the resource non-compliant.<p> |

### Parameter: `name`

The name of the Integration Runtime.

- Required: Yes
- Type: string

### Parameter: `type`

The type of Integration Runtime.<p><p>Setting this parameter to any other than SelfHosted will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `'SelfHosted'`
- Allowed:
  ```Bicep
  [
    'Managed'
    'SelfHosted'
  ]
  ```

### Parameter: `dataFactoryName`

The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `integrationRuntimeCustomDescription`

The description of the Integration Runtime.

- Required: No
- Type: string
- Default: `'Managed Integration Runtime created by amavm-res-datafactory-factories'`

### Parameter: `managedVirtualNetworkName`

The name of the Managed Virtual Network if using type "Managed".<p><p>Setting this paramter value will make the resource non-compliant.<p>

- Required: No
- Type: string
- Default: `''`

### Parameter: `typeProperties`

Integration Runtime type properties. Required if type is "Managed".<p><p>Setting this paramter value will make the resource non-compliant.<p>

- Required: No
- Type: object
- Default: `{}`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `name` | string | The name of the Integration Runtime. |
| `resourceGroupName` | string | The name of the Resource Group the Integration Runtime was created in. |
| `resourceId` | string | The resource ID of the Integration Runtime. |

## Notes

### Parameter Usage: `typeProperties`

<details>

<summary>Parameter JSON format</summary>

```json
"typeProperties": {
    "value": {
        "computeProperties": {
            "location": "AutoResolve"
        }
    }
}
```

<details>

<summary>Bicep format</summary>

```bicep
typeProperties: {
    computeProperties: {
        location: 'AutoResolve'
    }
}
```

<details>
<p>

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
