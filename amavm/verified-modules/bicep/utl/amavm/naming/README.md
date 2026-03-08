# Naming `[Amavm/Naming]`

This module deploys a Naming Modules.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20250514

Compliant usage of this module requires the following parameter values:



## Resource Types

_None_

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:/:<version>`.

- [default](#example-1-default)

### Example 1: _default_

This example provides an example implementation of the naming module.



<details>

<summary>via Bicep module</summary>

```bicep
targetScope = 'subscription'

metadata name = 'default'
metadata description = '''
This example provides an example implementation of the naming module.
'''


// General parameters
param location string = deployment().location

// Parts used in naming convention
@description('Optional. A token to inject into the name of each resource.')
param namePrefix string = '#_namePrefix_#'
param departmentCode string = 'c3'
param applicationCode string = 'lztst' // short application code we use in naming (not the one in Snow, that one is applicationId)
@maxLength(4)
param applicationInstanceCode string = '1234' // in case if there are more than 1 application deployments (for example, in multiple environments)
@maxLength(2)
param systemInstanceCode string = ''
param systemCode string = ''
param environmentType string = 'dev'

// Dependencies
var resourceGroupName = '${namePrefix}${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}-${environmentType}-${location}-rg'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
}
// Minimal implementation
module names '../../../main.bicep' = {
  scope: resourceGroup
  name: '${deployment().name}-names'
  params: {
    department: departmentCode
    workload: '${applicationCode}${applicationInstanceCode}'
    environment: environmentType
    location: location
  }
}

// Using naming and providing as ouput
var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']
output nsgName string = nsgName
var subnetsName = names.outputs.namingConvention['Microsoft.Network/virtualNetworks/subnets']
output subnetsName string = subnetsName
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`department`](#parameter-department) | string | Code of the department within a business unit. |
| [`environment`](#parameter-environment) | string | Type of SDTAP environment. |
| [`location`](#parameter-location) | string | Location of resources. |
| [`organization`](#parameter-organization) | string | Id of the busines unit. |
| [`workload`](#parameter-workload) | string | Short abbreviation of the application. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`prefix`](#parameter-prefix) | string | Prefix to add before the name. For example in CI: pipelineId, branchName. |
| [`role`](#parameter-role) | string | Name of a system within an application. |
| [`roleIndex`](#parameter-roleindex) | string | An index within a system/purpose if multiple resources are deployed. |
| [`uniqueSuffix`](#parameter-uniquesuffix) | string | Suffix to add after the name. |

### Parameter: `department`

Code of the department within a business unit.

- Required: No
- Type: string
- Default: `''`

### Parameter: `environment`

Type of SDTAP environment.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'acc'
    'dev'
    'prd'
    'sbx'
    'tst'
  ]
  ```

### Parameter: `location`

Location of resources.

- Required: No
- Type: string
- Default: `'swedencentral'`
- Allowed:
  ```Bicep
  [
    'northeurope'
    'swedencentral'
    'westeurope'
  ]
  ```

### Parameter: `organization`

Id of the busines unit.

- Required: No
- Type: string
- Default: `'s2'`
- Allowed:
  ```Bicep
  [
    's1'
    's2'
    's3'
  ]
  ```

### Parameter: `workload`

Short abbreviation of the application.

- Required: Yes
- Type: string

### Parameter: `prefix`

Prefix to add before the name. For example in CI: pipelineId, branchName.

- Required: No
- Type: string
- Default: `''`

### Parameter: `role`

Name of a system within an application.

- Required: No
- Type: string
- Default: `''`

### Parameter: `roleIndex`

An index within a system/purpose if multiple resources are deployed.

- Required: No
- Type: string
- Default: `''`

### Parameter: `uniqueSuffix`

Suffix to add after the name.

- Required: No
- Type: string
- Default: `''`

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `locationShort` | string | Shortened location abbreviation. E.g. we, ne, sec |
| `namingConvention` | object | Formatted name: (prefix)(businessUnit)(department)(workload)(role)(roleIndex)(environment)(locationShort)(resource type suffix)(uniuqeSuffix)<p>Example of use: var nsgName = names.outputs.namingConvention['Microsoft.Network/networkSecurityGroups']<p> |
| `purposeName` | string | Formatted name: (prefix)(businessUnit)(department)(workload)(role)(roleIndex)(environment)(locationShort) |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
