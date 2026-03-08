# Data Ingestion pattern `[Data/Ingestion]`

This module implements a pattern of typical data ingestion with Azure Data Factory and Azure Databricks

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Cross-referenced modules](#cross-referenced-modules)
- [Data Collection](#data-collection)

## Compliance

Version: 20240703

There are no special requirements. The pattern implements a compliant-by-default environment.

## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.Authorization/locks` | 2020-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_locks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks)</li></ul> |
| `Microsoft.Authorization/roleAssignments` | 2022-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.authorization_roleassignments.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments)</li></ul> |
| `Microsoft.Databricks/accessConnectors` | 2024-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.databricks_accessconnectors.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Databricks/2024-05-01/accessConnectors)</li></ul> |
| `Microsoft.Databricks/workspaces` | 2024-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.databricks_workspaces.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Databricks/2024-05-01/workspaces)</li></ul> |
| `Microsoft.DataFactory/factories` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories)</li></ul> |
| `Microsoft.DataFactory/factories/integrationRuntimes` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_integrationruntimes.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/integrationRuntimes)</li></ul> |
| `Microsoft.DataFactory/factories/linkedservices` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_linkedservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/linkedservices)</li></ul> |
| `Microsoft.DataFactory/factories/managedVirtualNetworks` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_managedvirtualnetworks.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/managedVirtualNetworks)</li></ul> |
| `Microsoft.DataFactory/factories/managedVirtualNetworks/managedPrivateEndpoints` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_managedvirtualnetworks_managedprivateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/managedVirtualNetworks/managedPrivateEndpoints)</li></ul> |
| `Microsoft.Insights/diagnosticSettings` | 2021-05-01-preview | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.insights_diagnosticsettings.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings)</li></ul> |
| `Microsoft.KeyVault/vaults` | 2023-07-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2023-07-01/vaults)</li></ul> |
| `Microsoft.KeyVault/vaults/accessPolicies` | 2023-07-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults_accesspolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2023-07-01/vaults/accessPolicies)</li></ul> |
| `Microsoft.KeyVault/vaults/keys` | 2023-07-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults_keys.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2023-07-01/vaults/keys)</li></ul> |
| `Microsoft.KeyVault/vaults/secrets` | 2023-07-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.keyvault_vaults_secrets.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.KeyVault/2023-07-01/vaults/secrets)</li></ul> |
| `Microsoft.Network/networkSecurityGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_networksecuritygroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/networkSecurityGroups)</li></ul> |
| `Microsoft.Network/privateEndpoints` | 2024-01-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2024-01-01/privateEndpoints)</li></ul> |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_privateendpoints_privatednszonegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/privateEndpoints/privateDnsZoneGroups)</li></ul> |
| `Microsoft.Network/routeTables` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_routetables.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/routeTables)</li></ul> |
| `Microsoft.Network/virtualNetworks/subnets` | 2023-11-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.network_virtualnetworks_subnets.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Network/2023-11-01/virtualNetworks/subnets)</li></ul> |
| `Microsoft.OperationalInsights/workspaces` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/dataExports` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_dataexports.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/dataExports)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/dataSources` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_datasources.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/dataSources)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/linkedServices` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_linkedservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/linkedServices)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/linkedStorageAccounts` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_linkedstorageaccounts.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/linkedStorageAccounts)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/savedSearches` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_savedsearches.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/savedSearches)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/storageInsightConfigs` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_storageinsightconfigs.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/storageInsightConfigs)</li></ul> |
| `Microsoft.OperationalInsights/workspaces/tables` | 2023-09-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.operationalinsights_workspaces_tables.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2023-09-01/workspaces/tables)</li></ul> |
| `Microsoft.Resources/resourceGroups` | 2024-03-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.resources_resourcegroups.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Resources/2024-03-01/resourceGroups)</li></ul> |
| `Microsoft.Storage/storageAccounts` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts)</li></ul> |
| `Microsoft.Storage/storageAccounts/blobServices` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_blobservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/blobServices)</li></ul> |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_blobservices_containers.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/blobServices/containers)</li></ul> |
| `Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_blobservices_containers_immutabilitypolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/blobServices/containers/immutabilityPolicies)</li></ul> |
| `Microsoft.Storage/storageAccounts/fileServices` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_fileservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/fileServices)</li></ul> |
| `Microsoft.Storage/storageAccounts/fileServices/shares` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_fileservices_shares.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/fileServices/shares)</li></ul> |
| `Microsoft.Storage/storageAccounts/localUsers` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_localusers.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/localUsers)</li></ul> |
| `Microsoft.Storage/storageAccounts/managementPolicies` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_managementpolicies.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/managementPolicies)</li></ul> |
| `Microsoft.Storage/storageAccounts/queueServices` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_queueservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/queueServices)</li></ul> |
| `Microsoft.Storage/storageAccounts/queueServices/queues` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_queueservices_queues.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/queueServices/queues)</li></ul> |
| `Microsoft.Storage/storageAccounts/tableServices` | 2023-04-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_tableservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-04-01/storageAccounts/tableServices)</li></ul> |
| `Microsoft.Storage/storageAccounts/tableServices/tables` | 2023-05-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.storage_storageaccounts_tableservices_tables.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.Storage/2023-05-01/storageAccounts/tableServices/tables)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`applicationCode`](#parameter-applicationcode) | string | The application code used in naming conventions. |
| [`applicationId`](#parameter-applicationid) | string | The unique application ID used for APG ServiceNow registration. |
| [`applicationInstanceCode`](#parameter-applicationinstancecode) | string | The application instance code used in naming conventions. |
| [`engineersGroupObjectId`](#parameter-engineersgroupobjectid) | string | The Object ID of the group that will be assigned higher privileges in DEV. |
| [`environmentId`](#parameter-environmentid) | string | The environment ID for the deployment. |
| [`environmentType`](#parameter-environmenttype) | string | The environment type such as sbx, dev, tst, acc, or prd. |
| [`location`](#parameter-location) | string | The location where the resources will be deployed. |
| [`networkAddressSpace`](#parameter-networkaddressspace) | string | Network space for the subnets. Needs a /27 prefix. |
| [`organizationCode`](#parameter-organizationcode) | string | The organization code used in naming conventions. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`adfRepoConfig`](#parameter-adfrepoconfig) | object | Repo for adf |
| [`department`](#parameter-department) | string | Code of the department within a business unit. |
| [`deploymentId`](#parameter-deploymentid) | string | The deployment ID to uniquely identify the deployment process. |
| [`engineersContactEmail`](#parameter-engineerscontactemail) | string | The contact email address for engineers involved in the project. |
| [`isDatabricksEnabled`](#parameter-isdatabricksenabled) | bool | Set to enable Azure Databricks deployment. Default is true. |
| [`isDataFactoryEnabled`](#parameter-isdatafactoryenabled) | bool | Set to to Enable Azure Data Factory deployment. Default is true. |
| [`isLogAnalyticsEnabled`](#parameter-isloganalyticsenabled) | bool | Set to Enable log Analytics deployment. Default is true. |
| [`namePrefix`](#parameter-nameprefix) | string | A prefix to use in naming resources. |
| [`systemCode`](#parameter-systemcode) | string | The system code used in naming conventions. |
| [`systemInstanceCode`](#parameter-systeminstancecode) | string | The system instance code used in naming conventions. |
| [`tags`](#parameter-tags) | object | Tags to apply to resources for categorization and management. |

### Parameter: `applicationCode`

The application code used in naming conventions.

- Required: No
- Type: string
- Default: `'drcp'`

### Parameter: `applicationId`

The unique application ID used for APG ServiceNow registration.

- Required: No
- Type: string
- Default: `'AM-CCC'`

### Parameter: `applicationInstanceCode`

The application instance code used in naming conventions.

- Required: No
- Type: string
- Default: `'0101'`

### Parameter: `engineersGroupObjectId`

The Object ID of the group that will be assigned higher privileges in DEV.

- Required: No
- Type: string
- Default: `'9c1f0c78-5ed0-4a97-aecd-4ec20336f626'`

### Parameter: `environmentId`

The environment ID for the deployment.

- Required: No
- Type: string
- Default: `'ENV24643'`

### Parameter: `environmentType`

The environment type such as sbx, dev, tst, acc, or prd.

- Required: No
- Type: string
- Default: `'dev'`
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

The location where the resources will be deployed.

- Required: No
- Type: string
- Default: `[deployment().location]`

### Parameter: `networkAddressSpace`

Network space for the subnets. Needs a /27 prefix.

- Required: No
- Type: string
- Default: `''`

### Parameter: `organizationCode`

The organization code used in naming conventions.

- Required: No
- Type: string
- Default: `'s2'`

### Parameter: `adfRepoConfig`

Repo for adf

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      gitAccountName: 'connectdrcpapg1'
      gitCollaborationBranch: 'main'
      gitDisablePublish: true
      gitProjectName: 'exampleProject'
      gitRepositoryName: 'exampleRepo'
      gitRepoType: 'FactoryVSTSConfiguration'
      gitRootFolder: '/'
      gitTenantId: 'c1f94f0d-9a3d-4854-9288-bb90dcf2a90d'
  }
  ```

### Parameter: `department`

Code of the department within a business unit.

- Required: No
- Type: string
- Default: `''`

### Parameter: `deploymentId`

The deployment ID to uniquely identify the deployment process.

- Required: No
- Type: string
- Default: `''`

### Parameter: `engineersContactEmail`

The contact email address for engineers involved in the project.

- Required: No
- Type: string
- Default: `'apg-am-ccc-enablement@apg-am.nl'`

### Parameter: `isDatabricksEnabled`

Set to enable Azure Databricks deployment. Default is true.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `isDataFactoryEnabled`

Set to to Enable Azure Data Factory deployment. Default is true.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `isLogAnalyticsEnabled`

Set to Enable log Analytics deployment. Default is true.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `namePrefix`

A prefix to use in naming resources.

- Required: No
- Type: string
- Default: `''`

### Parameter: `systemCode`

The system code used in naming conventions.

- Required: No
- Type: string
- Default: `''`

### Parameter: `systemInstanceCode`

The system instance code used in naming conventions.

- Required: No
- Type: string
- Default: `''`

### Parameter: `tags`

Tags to apply to resources for categorization and management.

- Required: No
- Type: object
- Default:
  ```Bicep
  {
      applicationId: '[parameters(\'applicationId\')]'
      businessUnit: '[parameters(\'organizationCode\')]'
      contactEmail: '[parameters(\'engineersContactEmail\')]'
      deploymentPipelineId: '[parameters(\'deploymentId\')]'
      environmentId: '[parameters(\'environmentId\')]'
      environmentType: '[parameters(\'environmentType\')]'
      purpose: '[format(\'{0}{1}{2}{3}\', parameters(\'applicationCode\'), parameters(\'applicationInstanceCode\'), parameters(\'systemCode\'), parameters(\'systemInstanceCode\'))]'
  }
  ```

## Outputs

_None_

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `br/amavm:res/data-factory/factory:0.2.0` | Remote reference |
| `br/amavm:res/data-factory/factory/integration-runtime:0.1.0` | Remote reference |
| `br/amavm:res/data-factory/factory/linked-service:0.2.0` | Remote reference |
| `br/amavm:res/databricks/access-connector:0.2.0` | Remote reference |
| `br/amavm:res/databricks/workspace:0.3.0` | Remote reference |
| `br/amavm:res/key-vault/vault:0.3.0` | Remote reference |
| `br/amavm:res/network/network-security-group:0.1.0` | Remote reference |
| `br/amavm:res/network/route-table:0.1.0` | Remote reference |
| `br/amavm:res/network/virtual-network/subnet:0.2.0` | Remote reference |
| `br/amavm:res/operational-insights/workspace:0.1.0` | Remote reference |
| `br/amavm:res/storage/storage-account:0.2.0` | Remote reference |
| `br/amavm:res/storage/storage-account/blob-service/container:0.1.0` | Remote reference |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
