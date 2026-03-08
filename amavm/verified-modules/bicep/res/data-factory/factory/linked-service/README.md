# Azure Data Factory Linked Service `[Microsoft.DataFactory/factories/linkedservices]`

This module deploys a Linked Service for Azure Data Factory.

## Navigation

- [Compliance](#compliance)
- [Resource Types](#resource-types)
- [Parameters](#parameters)
- [Outputs](#outputs)
- [Data Collection](#data-collection)

## Compliance

Version: 20240722

Compliant usage of Azure Data Factory requires:
- type : from the allowed list of linked service types
- typeProperties : storing the connection secrets of applicable linked services such as Sql Server, File Server in the Azure Key-Vault


## Resource Types

| Resource Type | API Version | References |
| :-- | :-- | :-- |
| `Microsoft.DataFactory/factories/linkedservices` | 2018-06-01 | <ul style="padding-left: 0px;"><li>[AzAdvertizer](https://www.azadvertizer.net/azresourcetypes/microsoft.datafactory_factories_linkedservices.html)</li><li>[Template reference](https://learn.microsoft.com/en-us/azure/templates/Microsoft.DataFactory/2018-06-01/factories/linkedservices)</li></ul> |

## Parameters

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`name`](#parameter-name) | string | The name of the Linked Service. |
| [`type`](#parameter-type) | string | The type of Linked Service. See https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects for more information.<p><p>Setting an  other than one of the allowed values will make the Data Factory resource non-compliant.<p> |

**Conditional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`dataFactoryName`](#parameter-datafactoryname) | string | The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`description`](#parameter-description) | string | The description of the Integration Runtime. |
| [`enableTelemetry`](#parameter-enabletelemetry) | bool | Enable/Disable usage telemetry for module. |
| [`integrationRuntimeName`](#parameter-integrationruntimename) | string | The name of the Integration Runtime to use. |
| [`parameters`](#parameter-parameters) | object | Use this to add parameters for a linked service connection string. |
| [`typeProperties`](#parameter-typeproperties) | object | Used to add connection properties for your linked services. |

### Parameter: `name`

The name of the Linked Service.

- Required: Yes
- Type: string

### Parameter: `type`

The type of Linked Service. See https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects for more information.<p><p>Setting an  other than one of the allowed values will make the Data Factory resource non-compliant.<p>

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureBlobFS'
    'AzureBlobStorage'
    'AzureDatabricks'
    'AzureFunction'
    'AzureKeyVault'
    'AzureSqlDatabase'
    'FileServer'
    'Jira'
    'SqlServer'
  ]
  ```

### Parameter: `dataFactoryName`

The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.

- Required: Yes
- Type: string

### Parameter: `description`

The description of the Integration Runtime.

- Required: No
- Type: string
- Default: `'Linked Service created by avm-res-datafactory-factories'`

### Parameter: `enableTelemetry`

Enable/Disable usage telemetry for module.

- Required: No
- Type: bool
- Default: `True`

### Parameter: `integrationRuntimeName`

The name of the Integration Runtime to use.

- Required: No
- Type: string

### Parameter: `parameters`

Use this to add parameters for a linked service connection string.

- Required: No
- Type: object
- Default: `{}`

### Parameter: `typeProperties`

Used to add connection properties for your linked services.

- Required: Yes
- Type: object

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`azureBlobFSLinkedServiceConfig`](#parameter-typepropertiesazureblobfslinkedserviceconfig) | object | Details to configure Azure storage linked services. |
| [`azureBlobStorageLinkedServiceConfig`](#parameter-typepropertiesazureblobstoragelinkedserviceconfig) | object | Details to configure Azure storage linked services. |
| [`azureDatabricksLinkedServiceConfig`](#parameter-typepropertiesazuredatabrickslinkedserviceconfig) | object | Details to configure Azure Databricks linked service. |
| [`azureFunctionAppLinkedServiceConfig`](#parameter-typepropertiesazurefunctionapplinkedserviceconfig) | object | Details to configure Azure Function App linked service. |
| [`azureKeyVaultLinkedServiceConfig`](#parameter-typepropertiesazurekeyvaultlinkedserviceconfig) | object | Details to configure Azure Key-Vault linked service. |
| [`azureSqlDatabaseLinkedServiceConfig`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfig) | object | Details to configure Azure SQL Database linked service. |
| [`fileServerLinkedServiceConfig`](#parameter-typepropertiesfileserverlinkedserviceconfig) | object | Details to configure File Server linked service. |
| [`jiraLinkedServiceConfig`](#parameter-typepropertiesjiralinkedserviceconfig) | object | Details to configure JIRA linked service. |
| [`sqlServerLinkedServiceConfig`](#parameter-typepropertiessqlserverlinkedserviceconfig) | object | Details to configure (on-premises) SQL Server linked service. |

### Parameter: `typeProperties.azureBlobFSLinkedServiceConfig`

Details to configure Azure storage linked services.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`url`](#parameter-typepropertiesazureblobfslinkedserviceconfigurl) | string | Endpoint for the Azure Data Lake Storage Gen2 service.<p>Format - https://accountname.dfs.core.windows.net/  |

### Parameter: `typeProperties.azureBlobFSLinkedServiceConfig.url`

Endpoint for the Azure Data Lake Storage Gen2 service.<p>Format - https://accountname.dfs.core.windows.net/ 

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureBlobStorageLinkedServiceConfig`

Details to configure Azure storage linked services.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`serviceEndpoint`](#parameter-typepropertiesazureblobstoragelinkedserviceconfigserviceendpoint) | string | Blob service endpoint of the Azure Blob Storage resource.<p>It is mutually exclusive with connectionString, sasUri property.<p>Format - https://accountname.blob.core.windows.net/ |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`accountKind`](#parameter-typepropertiesazureblobstoragelinkedserviceconfigaccountkind) | string | AzureBlobStorage linked service only. The kind of your storage account. |

### Parameter: `typeProperties.azureBlobStorageLinkedServiceConfig.serviceEndpoint`

Blob service endpoint of the Azure Blob Storage resource.<p>It is mutually exclusive with connectionString, sasUri property.<p>Format - https://accountname.blob.core.windows.net/

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureBlobStorageLinkedServiceConfig.accountKind`

AzureBlobStorage linked service only. The kind of your storage account.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'BlobStorage'
    'BlockBlobStorage'
    'Storage'
    'StorageV2'
  ]
  ```

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig`

Details to configure Azure Databricks linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`domain`](#parameter-typepropertiesazuredatabrickslinkedserviceconfigdomain) | string | The Databricks Workspace URL, it can be found in Azure portal under workspace overview. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authentication`](#parameter-typepropertiesazuredatabrickslinkedserviceconfigauthentication) | string | The Databricks authentication mechanism. |
| [`clusterOption`](#parameter-typepropertiesazuredatabrickslinkedserviceconfigclusteroption) | string | This is required when creating a new job cluster. The exptected value is worker options either fixed or autoscaling. |
| [`dataSecurityMode`](#parameter-typepropertiesazuredatabrickslinkedserviceconfigdatasecuritymode) | string | Optional setting for creating a new job cluster. The exptected value is Unity Catalog Access Mode. |
| [`existingClusterId`](#parameter-typepropertiesazuredatabrickslinkedserviceconfigexistingclusterid) | string | This is required when using existinng cluster. Exptected value is the existing interactive cluster ID. |
| [`instancePoolId`](#parameter-typepropertiesazuredatabrickslinkedserviceconfiginstancepoolid) | string | This is required when using existing instance pool. The expected value is the id of existing cluster pool. |
| [`newClusterNodeType`](#parameter-typepropertiesazuredatabrickslinkedserviceconfignewclusternodetype) | string | This is required when creating a new job cluster or using existing instance pool. This field encodes, through a single value, the resources available to each of the Spark nodes in this cluster. |
| [`newClusterNumOfWorker`](#parameter-typepropertiesazuredatabrickslinkedserviceconfignewclusternumofworker) | string | This is required when creating a new job cluster. The exptected value is number of worker nodes that this cluster should have. When cluster option is Autoscaling then<p>provide the number of min and max workers e.g. such as 1:3 |
| [`newClusterVersion`](#parameter-typepropertiesazuredatabrickslinkedserviceconfignewclusterversion) | string | This is required when creating a new job cluster. Exptected value is the Spark version of the cluster. |
| [`workspaceResourceId`](#parameter-typepropertiesazuredatabrickslinkedserviceconfigworkspaceresourceid) | string | The resource ID of the Databricks workspace. This can be found in the properties of the Databricks workspace, and it should be of the format:<p>/subscriptions/{subscriptionID}/resourceGroups/{resourceGroup}/providers/Microsoft.Databricks/workspaces/{workspaceName}  |

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.domain`

The Databricks Workspace URL, it can be found in Azure portal under workspace overview.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.authentication`

The Databricks authentication mechanism.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'MSI'
  ]
  ```

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.clusterOption`

This is required when creating a new job cluster. The exptected value is worker options either fixed or autoscaling.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'Autoscaling'
    'Fixed'
  ]
  ```

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.dataSecurityMode`

Optional setting for creating a new job cluster. The exptected value is Unity Catalog Access Mode.

- Required: No
- Type: string
- Allowed:
  ```Bicep
  [
    'NONE'
    'SINGLE_USER'
    'USER_ISOLATION'
  ]
  ```

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.existingClusterId`

This is required when using existinng cluster. Exptected value is the existing interactive cluster ID.

- Required: No
- Type: string

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.instancePoolId`

This is required when using existing instance pool. The expected value is the id of existing cluster pool.

- Required: No
- Type: string

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.newClusterNodeType`

This is required when creating a new job cluster or using existing instance pool. This field encodes, through a single value, the resources available to each of the Spark nodes in this cluster.

- Required: No
- Type: string

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.newClusterNumOfWorker`

This is required when creating a new job cluster. The exptected value is number of worker nodes that this cluster should have. When cluster option is Autoscaling then<p>provide the number of min and max workers e.g. such as 1:3

- Required: No
- Type: string

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.newClusterVersion`

This is required when creating a new job cluster. Exptected value is the Spark version of the cluster.

- Required: No
- Type: string

### Parameter: `typeProperties.azureDatabricksLinkedServiceConfig.workspaceResourceId`

The resource ID of the Databricks workspace. This can be found in the properties of the Databricks workspace, and it should be of the format:<p>/subscriptions/{subscriptionID}/resourceGroups/{resourceGroup}/providers/Microsoft.Databricks/workspaces/{workspaceName} 

- Required: No
- Type: string

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig`

Details to configure Azure Function App linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authentication`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigauthentication) | string | The type used for authentication. |
| [`functionAppUrl`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionappurl) | string | Function App endpoint.<p>Format - https://functionappname.azurewebsites.net |
| [`functionKey`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkey) | object | Specify the key for the function (userName). |

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.authentication`

The type used for authentication.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'Anonymous'
    'MSI'
    'Service principal'
  ]
  ```

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionAppUrl`

Function App endpoint.<p>Format - https://functionappname.azurewebsites.net

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey`

Specify the key for the function (userName).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkeysecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkeystore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkeytype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkeysecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkeystorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-typepropertiesazurefunctionapplinkedserviceconfigfunctionkeystoretype) | string | LinkedServiceReference the type. |

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `typeProperties.azureFunctionAppLinkedServiceConfig.functionKey.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `typeProperties.azureKeyVaultLinkedServiceConfig`

Details to configure Azure Key-Vault linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`baseUrl`](#parameter-typepropertiesazurekeyvaultlinkedserviceconfigbaseurl) | string | The Azure Key-vault URL. Format - https://keyvaultname.vault.azure.net/ |

### Parameter: `typeProperties.azureKeyVaultLinkedServiceConfig.baseUrl`

The Azure Key-vault URL. Format - https://keyvaultname.vault.azure.net/

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig`

Details to configure Azure SQL Database linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authenticationType`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigauthenticationtype) | string | The type used for authentication. |
| [`database`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigdatabase) | string | The name of the database. |
| [`server`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserver) | string | The FQDN or network address of the SQL server instance you want to connect to. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`azureCloudType`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigazurecloudtype) | string | For service principal authentication, specify the type of Azure cloud environment to which your Microsoft Entra application is registered.<p>Allowed value is AzurePublic. |
| [`encrypt`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigencrypt) | bool | Indicate whether TLS encryption is required for all data sent between the client and server. |
| [`servicePrincipalCredential`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredential) | object | The service principal credential, reference a secret stored in Azure Key Vault. |
| [`servicePrincipalId`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalid) | string | Specify the application client ID. |
| [`tenant`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigtenant) | string | Specify the tenant information, like the domain name or tenant ID, under which your application resides. |
| [`trustServerCertificate`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigtrustservercertificate) | bool | Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust. |

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.authenticationType`

The type used for authentication.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'ServicePrincipal'
    'SystemAssignedManagedIdentity'
    'UserAssignedManagedIdentity'
  ]
  ```

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.database`

The name of the database.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.server`

The FQDN or network address of the SQL server instance you want to connect to.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.azureCloudType`

For service principal authentication, specify the type of Azure cloud environment to which your Microsoft Entra application is registered.<p>Allowed value is AzurePublic.

- Required: No
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.encrypt`

Indicate whether TLS encryption is required for all data sent between the client and server.

- Required: No
- Type: bool

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential`

The service principal credential, reference a secret stored in Azure Key Vault.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-typepropertiesazuresqldatabaselinkedserviceconfigserviceprincipalcredentialstoretype) | string | LinkedServiceReference the type. |

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalCredential.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.servicePrincipalId`

Specify the application client ID.

- Required: No
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.tenant`

Specify the tenant information, like the domain name or tenant ID, under which your application resides.

- Required: No
- Type: string

### Parameter: `typeProperties.azureSqlDatabaseLinkedServiceConfig.trustServerCertificate`

Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust.

- Required: No
- Type: bool

### Parameter: `typeProperties.fileServerLinkedServiceConfig`

Details to configure File Server linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`host`](#parameter-typepropertiesfileserverlinkedserviceconfighost) | string | Specifies the root path of the folder that you want to copy. |
| [`password`](#parameter-typepropertiesfileserverlinkedserviceconfigpassword) | object | Specify the password for the user (userId). |
| [`userId`](#parameter-typepropertiesfileserverlinkedserviceconfiguserid) | string | Specify the ID of the user who has access to the server. |

### Parameter: `typeProperties.fileServerLinkedServiceConfig.host`

Specifies the root path of the folder that you want to copy.

- Required: Yes
- Type: string

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password`

Specify the password for the user (userId).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-typepropertiesfileserverlinkedserviceconfigpasswordsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-typepropertiesfileserverlinkedserviceconfigpasswordstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-typepropertiesfileserverlinkedserviceconfigpasswordtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-typepropertiesfileserverlinkedserviceconfigpasswordsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-typepropertiesfileserverlinkedserviceconfigpasswordstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-typepropertiesfileserverlinkedserviceconfigpasswordstoretype) | string | LinkedServiceReference the type. |

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `typeProperties.fileServerLinkedServiceConfig.password.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `typeProperties.fileServerLinkedServiceConfig.userId`

Specify the ID of the user who has access to the server.

- Required: Yes
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig`

Details to configure JIRA linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`host`](#parameter-typepropertiesjiralinkedserviceconfighost) | string | The hostname or IP address of the JIRA server. |
| [`password`](#parameter-typepropertiesjiralinkedserviceconfigpassword) | object | Specify the password for the user. |
| [`username`](#parameter-typepropertiesjiralinkedserviceconfigusername) | string | The username used to authenticate with the JIRA server. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`port`](#parameter-typepropertiesjiralinkedserviceconfigport) | string | The port number used to connect to the JIRA server. |
| [`useEncryptedEndpoints`](#parameter-typepropertiesjiralinkedserviceconfiguseencryptedendpoints) | bool | Indicates whether encrypted endpoints should be used. |
| [`useHostVerification`](#parameter-typepropertiesjiralinkedserviceconfigusehostverification) | bool | Indicates whether to verify the host during SSL handshake. |
| [`usePeerVerification`](#parameter-typepropertiesjiralinkedserviceconfigusepeerverification) | bool | Indicates whether to verify the peer certificate during SSL handshake. |

### Parameter: `typeProperties.jiraLinkedServiceConfig.host`

The hostname or IP address of the JIRA server.

- Required: Yes
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig.password`

Specify the password for the user.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-typepropertiesjiralinkedserviceconfigpasswordsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-typepropertiesjiralinkedserviceconfigpasswordstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-typepropertiesjiralinkedserviceconfigpasswordtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-typepropertiesjiralinkedserviceconfigpasswordsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `typeProperties.jiraLinkedServiceConfig.password.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig.password.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-typepropertiesjiralinkedserviceconfigpasswordstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-typepropertiesjiralinkedserviceconfigpasswordstoretype) | string | LinkedServiceReference the type. |

### Parameter: `typeProperties.jiraLinkedServiceConfig.password.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig.password.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `typeProperties.jiraLinkedServiceConfig.password.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `typeProperties.jiraLinkedServiceConfig.password.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig.username`

The username used to authenticate with the JIRA server.

- Required: Yes
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig.port`

The port number used to connect to the JIRA server.

- Required: No
- Type: string

### Parameter: `typeProperties.jiraLinkedServiceConfig.useEncryptedEndpoints`

Indicates whether encrypted endpoints should be used.

- Required: No
- Type: bool

### Parameter: `typeProperties.jiraLinkedServiceConfig.useHostVerification`

Indicates whether to verify the host during SSL handshake.

- Required: No
- Type: bool

### Parameter: `typeProperties.jiraLinkedServiceConfig.usePeerVerification`

Indicates whether to verify the peer certificate during SSL handshake.

- Required: No
- Type: bool

### Parameter: `typeProperties.sqlServerLinkedServiceConfig`

Details to configure (on-premises) SQL Server linked service.

- Required: No
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`authenticationType`](#parameter-typepropertiessqlserverlinkedserviceconfigauthenticationtype) | string | The type used for authentication. |
| [`database`](#parameter-typepropertiessqlserverlinkedserviceconfigdatabase) | string | The name of the database. |
| [`password`](#parameter-typepropertiessqlserverlinkedserviceconfigpassword) | object | Specify the password for the user (userName). |
| [`server`](#parameter-typepropertiessqlserverlinkedserviceconfigserver) | string | The name or network address of the SQL server instance you want to connect to. |
| [`userName`](#parameter-typepropertiessqlserverlinkedserviceconfigusername) | string | Specify the ID of the user who has access to the SQL server database. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`alwaysEncryptedSettings`](#parameter-typepropertiessqlserverlinkedserviceconfigalwaysencryptedsettings) | object | Specify always encryptedsettings information that's needed to enable Always Encrypted to protect sensitive data stored in SQL server<p>by using either managed identity or service principal. Find example here -<p>https://learn.microsoft.com/en-us/azure/data-factory/connector-sql-server?tabs=data-factory#using-always-encrypted |
| [`encrypt`](#parameter-typepropertiessqlserverlinkedserviceconfigencrypt) | bool | Indicate whether TLS encryption is required for all data sent between the client and server. |
| [`trustServerCertificate`](#parameter-typepropertiessqlserverlinkedserviceconfigtrustservercertificate) | bool | Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust. |

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.authenticationType`

The type used for authentication.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'SQL'
    'Windows'
  ]
  ```

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.database`

The name of the database.

- Required: Yes
- Type: string

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password`

Specify the password for the user (userName).

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretName`](#parameter-typepropertiessqlserverlinkedserviceconfigpasswordsecretname) | string | Name of the Key-Vault secret. |
| [`store`](#parameter-typepropertiessqlserverlinkedserviceconfigpasswordstore) | object | Name of the linked service for Azure Key Vault. |
| [`type`](#parameter-typepropertiessqlserverlinkedserviceconfigpasswordtype) | string | The value must be AzureKeyVaultSecret. |

**Optional parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`secretVersion`](#parameter-typepropertiessqlserverlinkedserviceconfigpasswordsecretversion) | string | Value of the secret version. If not mentioned, it will take the most recent active version. |

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password.secretName`

Name of the Key-Vault secret.

- Required: Yes
- Type: string

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password.store`

Name of the linked service for Azure Key Vault.

- Required: Yes
- Type: object

**Required parameters**

| Parameter | Type | Description |
| :-- | :-- | :-- |
| [`referenceName`](#parameter-typepropertiessqlserverlinkedserviceconfigpasswordstorereferencename) | string | Name of the Key Vault linked service. |
| [`type`](#parameter-typepropertiessqlserverlinkedserviceconfigpasswordstoretype) | string | LinkedServiceReference the type. |

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password.store.referenceName`

Name of the Key Vault linked service.

- Required: Yes
- Type: string

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password.store.type`

LinkedServiceReference the type.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'LinkedServiceReference'
  ]
  ```

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password.type`

The value must be AzureKeyVaultSecret.

- Required: Yes
- Type: string
- Allowed:
  ```Bicep
  [
    'AzureKeyVaultSecret'
  ]
  ```

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.password.secretVersion`

Value of the secret version. If not mentioned, it will take the most recent active version.

- Required: No
- Type: string

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.server`

The name or network address of the SQL server instance you want to connect to.

- Required: Yes
- Type: string

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.userName`

Specify the ID of the user who has access to the SQL server database.

- Required: Yes
- Type: string

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.alwaysEncryptedSettings`

Specify always encryptedsettings information that's needed to enable Always Encrypted to protect sensitive data stored in SQL server<p>by using either managed identity or service principal. Find example here -<p>https://learn.microsoft.com/en-us/azure/data-factory/connector-sql-server?tabs=data-factory#using-always-encrypted

- Required: No
- Type: object

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.encrypt`

Indicate whether TLS encryption is required for all data sent between the client and server.

- Required: No
- Type: bool

### Parameter: `typeProperties.sqlServerLinkedServiceConfig.trustServerCertificate`

Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust.

- Required: No
- Type: bool

## Outputs

| Output | Type | Description |
| :-- | :-- | :-- |
| `evidenceOfNonCompliance` | bool | Is there evidence of usage in non-compliance with policies? |
| `name` | string | The name of the Linked Service. |
| `resourceGroupName` | string | The name of the Resource Group the Linked Service was created in. |
| `resourceId` | string | The resource ID of the Linked Service. |

## Data Collection

The software may collect information about you and your use of the software and send it to APG Asset Management Cloud Competence Center (AMCCC). AMCCC may use this information to provide services and improve our products and services. You may turn off the telemetry. There are also some features in the software, including but not limited to the diagnostic logging and application traces, that may enable you and AMCCC to collect data from users of your applications. Your use of the software operates as your consent to these practices.
