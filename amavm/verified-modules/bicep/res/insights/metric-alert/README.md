# Metric Alerts `[Microsoft.Insights/metricAlerts]`

This module deploys a Metric Alert.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Usage examples](#usage-examples)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20250328


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Insights/metricAlerts` | 2018-03-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_metricalerts.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2018-03-01/metricAlerts)</li></ul> |

## Usage examples

The following section provides usage examples for the module, which were used to validate and deploy the module successfully. For a full reference, please review the module's test folder in its repository.

>**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

>**Note**: To reference the module, please use the following syntax `br/<registry-alias>:res/insights/metric-alert:<version>`.

- [Using large parameter set](#example-1-using-large-parameter-set)
- [WAF-aligned](#example-2-waf-aligned)

### Example 1: _Using large parameter set_

This instance deploys the module with most of its features enabled.


<details>

<summary>via Bicep module</summary>

```bicep
module metricAlertMod 'br/<registry-alias>:res/insights/metric-alert:<version>' = {
  name: 'metricAlert-mod'
  params: {
    // Required parameters
    criteria: {
      allof: [
        {
          criterionType: 'StaticThresholdCriterion'
          metricName: 'Percentage CPU'
          metricNamespace: 'microsoft.compute/virtualmachines'
          name: 'HighCPU'
          operator: 'GreaterThan'
          threshold: '90'
          timeAggregation: 'Average'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    name: 'imamax001'
    // Non-required parameters
    actions: [
      '<actionGroupResourceId>'
    ]
    location: 'Global'
    roleAssignments: [
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Owner'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
      }
      {
        principalId: '<principalId>'
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
      }
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    targetResourceRegion: 'westeurope'
    targetResourceType: 'microsoft.compute/virtualmachines'
    windowSize: 'PT15M'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/insights/metric-alert:<version>'

// Required parameters
param criteria = {
  allof: [
    {
      criterionType: 'StaticThresholdCriterion'
      metricName: 'Percentage CPU'
      metricNamespace: 'microsoft.compute/virtualmachines'
      name: 'HighCPU'
      operator: 'GreaterThan'
      threshold: '90'
      timeAggregation: 'Average'
    }
  ]
  'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
}
param name = 'imamax001'
// Non-required parameters
param actions = [
  '<actionGroupResourceId>'
]
param location = 'Global'
param roleAssignments = [
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'Owner'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
  {
    principalId: '<principalId>'
    principalType: 'ServicePrincipal'
    roleDefinitionIdOrName: '<roleDefinitionIdOrName>'
  }
]
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param targetResourceRegion = 'westeurope'
param targetResourceType = 'microsoft.compute/virtualmachines'
param windowSize = 'PT15M'
```

</details>
<p>

### Example 2: _WAF-aligned_

This instance deploys the module in alignment with the best-practices of the Azure Well-Architected Framework.


<details>

<summary>via Bicep module</summary>

```bicep
module metricAlertMod 'br/<registry-alias>:res/insights/metric-alert:<version>' = {
  name: 'metricAlert-mod'
  params: {
    // Required parameters
    criteria: {
      componentResourceId: '<componentResourceId>'
      failedLocationCount: 3
      'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
      webTestResourceId: '<webTestResourceId>'
    }
    name: 'imawaf001'
    // Non-required parameters
    actions: [
      '<actionGroupResourceId>'
    ]
    evaluationFrequency: 'PT5M'
    scopes: [
      '<appInsightsResourceId>'
      '<pingTestResourceId>'
    ]
    tags: {
      Environment: 'Non-Prod'
      'hidden-title': 'This is visible in the resource name'
      Role: 'DeploymentValidation'
    }
    windowSize: 'PT5M'
  }
}
```

</details>
<p>

<details>

<summary>via Bicep parameters file</summary>

```bicep-params
using 'br/public:res/insights/metric-alert:<version>'

// Required parameters
param criteria = {
  componentResourceId: '<componentResourceId>'
  failedLocationCount: 3
  'odata.type': 'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
  webTestResourceId: '<webTestResourceId>'
}
param name = 'imawaf001'
// Non-required parameters
param actions = [
  '<actionGroupResourceId>'
]
param evaluationFrequency = 'PT5M'
param scopes = [
  '<appInsightsResourceId>'
  '<pingTestResourceId>'
]
param tags = {
  Environment: 'Non-Prod'
  'hidden-title': 'This is visible in the resource name'
  Role: 'DeploymentValidation'
}
param windowSize = 'PT5M'
```

</details>
<p>

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`criteria`](#parameter-criteria) | object | Maps to the 'odata.type' field. Specifies the type of the alert criteria. |
| [`name`](#parameter-name) | string | The name of the alert. |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`targetResourceRegion`](#parameter-targetresourceregion) | string | The region of the target resource(s) on which the alert is created/updated. Required if alertCriteriaType is MultipleResourceMultipleMetricCriteria. |
| [`targetResourceType`](#parameter-targetresourcetype) | string | The resource type of the target resource(s) on which the alert is created/updated. Required if alertCriteriaType is MultipleResourceMultipleMetricCriteria. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`actions`](#parameter-actions) | array | The list of actions to take when alert triggers. |
| [`alertDescription`](#parameter-alertdescription) | string | Description of the alert. |
| [`autoMitigate`](#parameter-automitigate) | bool | The flag that indicates whether the alert should be auto resolved or not. |
| [`enabled`](#parameter-enabled) | bool | Indicates whether this alert is enabled. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`evaluationFrequency`](#parameter-evaluationfrequency) | string | how often the metric alert is evaluated represented in ISO 8601 duration format. |
| [`location`](#parameter-location) | string | Location for all resources. |
| [`roleAssignments`](#parameter-roleassignments) | array | Array of role assignments to create. |
| [`scopes`](#parameter-scopes) | array | the list of resource IDs that this metric alert is scoped to. |
| [`severity`](#parameter-severity) | int | The severity of the alert. |
| [`tags`](#parameter-tags) | object | Tags of the resource. |
| [`windowSize`](#parameter-windowsize) | string | the period of time (in ISO 8601 duration format) that is used to monitor alert activity based on the threshold. |

### Parameter: `criteria`

Maps to the 'odata.type' field. Specifies the type of the alert criteria.

- Required: Yes
- Type: object
- Discriminator: `odata.type`

<h4>The available variants are:</h4>

| Variant | Description |
| :-- | :-- |
| [`Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria`](#variant-criteriaodatatype-microsoftazuremonitorwebtestlocationavailabilitycriteria) | The alert type for a web test scenario. |
| [`Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria`](#variant-criteriaodatatype-microsoftazuremonitorsingleresourcemultiplemetriccriteria) | The alert type for a single resource scenario. |
| [`Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria`](#variant-criteriaodatatype-microsoftazuremonitormultipleresourcemultiplemetriccriteria) | The alert type for multiple resources scenario. |

### Variant: `criteria.odata.type-Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria`
The alert type for a web test scenario.

To use this variant, set the property `odata.type` to `Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria`.

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`componentResourceId`](#parameter-criteriaodatatype-microsoftazuremonitorwebtestlocationavailabilitycriteriacomponentresourceid) | string | The Application Insights resource ID. |
| [`failedLocationCount`](#parameter-criteriaodatatype-microsoftazuremonitorwebtestlocationavailabilitycriteriafailedlocationcount) | int | The number of failed locations. |
| [`odata.type`](#parameter-criteriaodatatype-microsoftazuremonitorwebtestlocationavailabilitycriteriaodatatype) | string | The type of the alert criteria. |
| [`webTestResourceId`](#parameter-criteriaodatatype-microsoftazuremonitorwebtestlocationavailabilitycriteriawebtestresourceid) | string | The Application Insights web test resource ID. |

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria.componentResourceId`

The Application Insights resource ID.

- Required: Yes
- Type: string

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria.failedLocationCount`

The number of failed locations.

- Required: Yes
- Type: int

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria.odata.type`

The type of the alert criteria.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  'odata.type': [
    'Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria'
  ]
  ```

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.WebtestLocationAvailabilityCriteria.webTestResourceId`

The Application Insights web test resource ID.

- Required: Yes
- Type: string

### Variant: `criteria.odata.type-Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria`
The alert type for a single resource scenario.

To use this variant, set the property `odata.type` to `Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria`.

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`allof`](#parameter-criteriaodatatype-microsoftazuremonitorsingleresourcemultiplemetriccriteriaallof) | array | The list of metric criteria for this 'all of' operation. |
| [`odata.type`](#parameter-criteriaodatatype-microsoftazuremonitorsingleresourcemultiplemetriccriteriaodatatype) | string | The type of the alert criteria. |

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria.allof`

The list of metric criteria for this 'all of' operation.

- Required: Yes
- Type: array

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria.odata.type`

The type of the alert criteria.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  'odata.type': [
    'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
  ]
  ```

### Variant: `criteria.odata.type-Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria`
The alert type for multiple resources scenario.

To use this variant, set the property `odata.type` to `Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria`.

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`allof`](#parameter-criteriaodatatype-microsoftazuremonitormultipleresourcemultiplemetriccriteriaallof) | array | The list of multiple metric criteria for this 'all of' operation. |
| [`odata.type`](#parameter-criteriaodatatype-microsoftazuremonitormultipleresourcemultiplemetriccriteriaodatatype) | string | The type of the alert criteria. |

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.allof`

The list of multiple metric criteria for this 'all of' operation.

- Required: Yes
- Type: array

### Parameter: `criteria.odata.type-Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria.odata.type`

The type of the alert criteria.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  'odata.type': [
    'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
  ]
  ```

### Parameter: `name`

The name of the alert.

- Required: Yes
- Type: string

### Parameter: `targetResourceRegion`

The region of the target resource(s) on which the alert is created/updated. Required if alertCriteriaType is MultipleResourceMultipleMetricCriteria.

- Required: No
- Type: string

### Parameter: `targetResourceType`

The resource type of the target resource(s) on which the alert is created/updated. Required if alertCriteriaType is MultipleResourceMultipleMetricCriteria.

- Required: No
- Type: string

### Parameter: `actions`

The list of actions to take when alert triggers.

- Required: No
- Type: array
- Default: `[]`

### Parameter: `alertDescription`

Description of the alert.

- Required: No
- Type: string
- Default: `''`

### Parameter: `autoMitigate`

The flag that indicates whether the alert should be auto resolved or not.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enabled`

Indicates whether this alert is enabled.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `evaluationFrequency`

how often the metric alert is evaluated represented in ISO 8601 duration format.

- Required: No
- Type: string
- Default: `'PT5M'`
- Allowed:
  ```Bicep
  [
    'PT15M'
    'PT1H'
    'PT1M'
    'PT30M'
    'PT5M'
  ]
  ```

### Parameter: `location`

Location for all resources.

- Required: No
- Type: string
- Default: `'global'`

### Parameter: `roleAssignments`

Array of role assignments to create.

- Required: No
- Type: array

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

### Parameter: `scopes`

the list of resource IDs that this metric alert is scoped to.

- Required: No
- Type: array
- Default:
  ```Bicep
  [
    '[subscription().id]'
  ]
  ```

### Parameter: `severity`

The severity of the alert.

- Required: No
- Type: int
- Default: `3`
- Allowed:
  ```Bicep
  [
    0
    1
    2
    3
    4
  ]
  ```

### Parameter: `tags`

Tags of the resource.

- Required: No
- Type: object

### Parameter: `windowSize`

the period of time (in ISO 8601 duration format) that is used to monitor alert activity based on the threshold.

- Required: No
- Type: string
- Default: `'PT15M'`
- Allowed:
  ```Bicep
  [
    'P1D'
    'PT12H'
    'PT15M'
    'PT1H'
    'PT1M'
    'PT30M'
    'PT5M'
    'PT6H'
  ]
  ```

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the metric alert. |
| `resourceGroupName` | string | The resource group the metric alert was deployed into. |
| `resourceId` | string | The resource ID of the metric alert. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
