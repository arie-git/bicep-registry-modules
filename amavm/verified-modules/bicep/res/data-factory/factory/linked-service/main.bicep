metadata name = 'Azure Data Factory Linked Service'
metadata description = 'This module deploys a Linked Service for Azure Data Factory.'
metadata owner = 'AMCCC'
metadata complianceVersion = '20240722'
metadata compliance = '''Compliant usage of Azure Data Factory requires:
- type : from the allowed list of linked service types
- typeProperties : storing the connection secrets of applicable linked services such as Sql Server, File Server in the Azure Key-Vault
'''

@sys.description('Conditional. The name of the parent Azure Data Factory. Required if the template is used in a standalone deployment.')
param dataFactoryName string

@sys.description('Required. The name of the Linked Service.')
param name string

@allowed([
  // 'AmazonMWS'
  // 'AmazonRdsForOracle'
  // 'AmazonRdsForSqlServer'
  // 'AmazonRedshift'
  // 'AmazonS3'
  // 'AmazonS3Compatible'
  // 'AzureBatch'
  'AzureBlobFS'
  'AzureBlobStorage'
  'AzureDatabricks'
  // 'AzureDatabricksDeltaLake'
  // 'AzureDataExplorer'
  // 'AzureDataLakeAnalytics'
  // 'AzureDataLakeStore'
  // 'AzureFileStorage'
  'AzureFunction'
  'AzureKeyVault'
  // 'AzureMariaDB'
  // 'AzureML'
  // 'AzureMLService'
  // 'AzureMySql'
  // 'AzurePostgreSql'
  // 'AzureSearch'
  'AzureSqlDatabase'
  // 'AzureSqlDW'
  // 'AzureSqlMI'
  // 'AzureStorage'
  // 'AzureSynapseArtifacts'
  // 'AzureTableStorage'
  // 'Cassandra'
  // 'CommonDataServiceForApps'
  // 'CosmosDb'
  // 'CosmosDbMongoDbApi'
  // 'Db2'
  // 'Dynamics'
  // 'DynamicsAX'
  // 'DynamicsCrm'
  'FileServer'
  // 'FtpServer'
  // 'HBase'
  // 'Hdfs'
  // 'HDInsight'
  // 'Hive'
  // 'HttpServer'
  // 'Informix'
  'Jira'
  // 'Kusto'
  // 'MicrosoftAccess'
  // 'MongoDb'
  // 'MongoDbAtlas'
  // 'MongoDbV2'
  // 'MySql'
  // 'Odata'
  // 'Odbc'
  // 'Office365'
  // 'Oracle'
  // 'OracleCloudStorage'
  // 'OracleServiceCloud'
  // 'PostgreSql'
  // 'RestService'
  // 'Salesforce'
  // 'SalesforceMarketingCloud'
  // 'SalesforceServiceCloud'
  // 'SapBw'
  // 'SapCloudForCustomer'
  // 'SapEcc'
  // 'SapHana'
  // 'SapOpenHub'
  // 'SapTable'
  // 'ServiceNow'
  // 'Sftp'
  // 'SharePointOnlineList'
  // 'Snowflake'
  // 'Spark'
  'SqlServer'
  // 'Sybase'
  // 'Teradata'
  // 'Web'
])
@sys.description('''Required. The type of Linked Service. See https://learn.microsoft.com/en-us/azure/templates/microsoft.datafactory/factories/linkedservices?pivots=deployment-language-bicep#linkedservice-objects for more information.

  Setting an  other than one of the allowed values will make the Data Factory resource non-compliant.
  ''')
param type string

@sys.description('Optional. Used to add connection properties for your linked services.')
param typeProperties linkedServiceTypePropertiesType

@sys.description('Optional. The name of the Integration Runtime to use.')
param integrationRuntimeName string?

@sys.description('Optional. Use this to add parameters for a linked service connection string.')
param parameters object = {}

@sys.description('Optional. The description of the Integration Runtime.')
param description string = 'Linked Service created by avm-res-datafactory-factories'

@sys.description('Optional. Enable/Disable usage telemetry for module.')
param enableTelemetry bool = true

// =========== //
// Variables   //
// =========== //

import { telemetryId } from '../../../../../bicep-shared/environments.bicep'

var properties = type == 'AzureKeyVault'
  ? typeProperties.azureKeyVaultLinkedServiceConfig
  : type == 'AzureBlobFS'
      ? typeProperties.azureBlobFSLinkedServiceConfig
      : type == 'AzureBlobStorage'
        ? typeProperties.azureBlobStorageLinkedServiceConfig
        : type == 'AzureSqlDatabase'
            ? typeProperties.azureSqlDatabaseLinkedServiceConfig
            : type == 'AzureFunction'
              ? typeProperties.azureFunctionAppLinkedServiceConfig
              : type == 'AzureDatabricks'
                ? typeProperties.azureDatabricksLinkedServiceConfig
                : type == 'FileServer'
                  ? typeProperties.fileServerLinkedServiceConfig
                  : type == 'SqlServer'
                    ? typeProperties.sqlServerLinkedServiceConfig
                    : type == 'Jira'
                      ? typeProperties.jiraLinkedServiceConfig
                      : {}

// ============ //
// Dependencies //
// ============ //
#disable-next-line no-deployments-resources
resource avmTelemetry 'Microsoft.Resources/deployments@2023-07-01' = if (enableTelemetry) {
  name: take(
    '${telemetryId}.res.data-factory-integration-runtime.${replace('-..--..-', '.', '-')}.${substring(uniqueString(deployment().name, name, dataFactoryName), 0, 4)}',
    64
  )
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
      outputs: {
        telemetry: {
          type: 'String'
          value: 'For more information, see https://aka.ms/avm/TelemetryInfo'
        }
      }
    }
  }
}

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource linkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: name
  parent: dataFactory
  properties: {
    annotations: []
    description: description
    connectVia: empty(integrationRuntimeName)
      ? null
      : {
          parameters: {}
          referenceName: integrationRuntimeName
          type: 'IntegrationRuntimeReference'
        }

    #disable-next-line BCP036 BCP225
    type: type
    typeProperties: properties
    parameters: parameters
  }
}

@sys.description('The name of the Resource Group the Linked Service was created in.')
output resourceGroupName string = resourceGroup().name

@sys.description('The name of the Linked Service.')
output name string = linkedService.name

@sys.description('The resource ID of the Linked Service.')
output resourceId string = linkedService.id

@sys.description('Is there evidence of usage in non-compliance with policies?')
output evidenceOfNonCompliance bool = empty(type)

// ================ //
// Definitions      //
// ================ //

@export()
type keyVaultLinkedServiceReferenceType = {
  @sys.description('Required. The value must be AzureKeyVaultSecret.')
  type: 'AzureKeyVaultSecret'

  @sys.description('Required. Name of the linked service for Azure Key Vault.')
  store: {
    @sys.description('Required. Name of the Key Vault linked service.')
    referenceName: string

    @sys.description('Required. LinkedServiceReference the type.')
    type: 'LinkedServiceReference'
  }

  @sys.description('Required. Name of the Key-Vault secret.')
  secretName: string

  @sys.description('Optional. Value of the secret version. If not mentioned, it will take the most recent active version.')
  secretVersion: string?
}

@export()
type linkedServiceTypePropertiesType = {

  @sys.description('Optional. Details to configure Azure Key-Vault linked service.')
  azureKeyVaultLinkedServiceConfig: {
    @sys.description('Required. The Azure Key-vault URL. Format - https://keyvaultname.vault.azure.net/')
    baseUrl: string
  }?

  @sys.description('Optional. Details to configure Azure storage linked services.')
  azureBlobFSLinkedServiceConfig: {
    @sys.description('''Required. Endpoint for the Azure Data Lake Storage Gen2 service.
    Format - https://accountname.dfs.core.windows.net/ ''')
    url: string

  }?

  @sys.description('Optional. Details to configure Azure storage linked services.')
  azureBlobStorageLinkedServiceConfig: {
    @sys.description('''Required. Blob service endpoint of the Azure Blob Storage resource.
    It is mutually exclusive with connectionString, sasUri property.
    Format - https://accountname.blob.core.windows.net/''')
    serviceEndpoint: string

    @sys.description('Optional. AzureBlobStorage linked service only. The kind of your storage account.')
    accountKind: ('Storage' | 'StorageV2' | 'BlobStorage' | 'BlockBlobStorage')?
  }?

  @sys.description('Optional. Details to configure Azure Databricks linked service.')
  azureDatabricksLinkedServiceConfig: {
    @sys.description('Required. The Databricks Workspace URL, it can be found in Azure portal under workspace overview.')
    domain: string

    @sys.description('Optional. The Databricks authentication mechanism.')
    authentication: 'MSI'

    @sys.description('''Optional. The resource ID of the Databricks workspace. This can be found in the properties of the Databricks workspace, and it should be of the format:
                        /subscriptions/{subscriptionID}/resourceGroups/{resourceGroup}/providers/Microsoft.Databricks/workspaces/{workspaceName} ''')
    workspaceResourceId: string?

    @sys.description('Optional. This is required when using existinng cluster. Exptected value is the existing interactive cluster ID.')
    existingClusterId: string?

    @sys.description('Optional. This is required when creating a new job cluster. Exptected value is the Spark version of the cluster.')
    newClusterVersion: string?

    @sys.description('Optional. This is required when creating a new job cluster or using existing instance pool. This field encodes, through a single value, the resources available to each of the Spark nodes in this cluster.')
    newClusterNodeType: string?

    @sys.description('Optional. This is required when creating a new job cluster. The exptected value is worker options either fixed or autoscaling.')
    clusterOption: ('Fixed' | 'Autoscaling')?

    @sys.description('''Optional. This is required when creating a new job cluster. The exptected value is number of worker nodes that this cluster should have. When cluster option is Autoscaling then
                        provide the number of min and max workers e.g. such as 1:3''')
    newClusterNumOfWorker: string?

    @sys.description('Optional. Optional setting for creating a new job cluster. The exptected value is Unity Catalog Access Mode.')
    dataSecurityMode: ('SINGLE_USER' | 'USER_ISOLATION' | 'NONE')?

    @sys.description('Optional. This is required when using existing instance pool. The expected value is the id of existing cluster pool.')
    instancePoolId: string?
  }?

  @sys.description('Optional. Details to configure Azure Function App linked service.')
  azureFunctionAppLinkedServiceConfig: {
  @sys.description('''Required. Function App endpoint.
    Format - https://functionappname.azurewebsites.net''')
  functionAppUrl: string

  @sys.description('Required. The type used for authentication.')
  authentication: ('MSI' | 'Service principal' | 'Anonymous')

  @sys.description('Required. Specify the key for the function (userName).')
  functionKey: keyVaultLinkedServiceReferenceType
  }?

  @sys.description('Optional. Details to configure Azure SQL Database linked service.')
  azureSqlDatabaseLinkedServiceConfig: {
    @sys.description('Required. The FQDN or network address of the SQL server instance you want to connect to.')
    server: string

    @sys.description('Required. The name of the database.')
    database: string

    @sys.description('Required. The type used for authentication.')
    authenticationType: ('SystemAssignedManagedIdentity' | 'UserAssignedManagedIdentity' | 'ServicePrincipal')

    @sys.description('Optional. Indicate whether TLS encryption is required for all data sent between the client and server.')
    encrypt: bool?

    @sys.description('Optional. Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust.')
    trustServerCertificate: bool?

    @sys.description('Optional. Specify the application client ID.')
    servicePrincipalId: string?

    @sys.description('Optional. The service principal credential, reference a secret stored in Azure Key Vault.')
    servicePrincipalCredential: keyVaultLinkedServiceReferenceType?

    @sys.description('Optional. Specify the tenant information, like the domain name or tenant ID, under which your application resides.')
    tenant: string?

    @sys.description('''Optional. For service principal authentication, specify the type of Azure cloud environment to which your Microsoft Entra application is registered.
                        Allowed value is AzurePublic.''')
    azureCloudType: string?
  }?

  @sys.description('Optional. Details to configure File Server linked service.')
  fileServerLinkedServiceConfig: {
    @sys.description('Required. Specifies the root path of the folder that you want to copy.')
    host: string

    @sys.description('Required. Specify the ID of the user who has access to the server.')
    userId: string

    @sys.description('Required. Specify the password for the user (userId).')
    password: keyVaultLinkedServiceReferenceType
  }?

  @sys.description('Optional. Details to configure (on-premises) SQL Server linked service.')
  sqlServerLinkedServiceConfig: {
    @sys.description('Required. The name or network address of the SQL server instance you want to connect to.')
    server: string

    @sys.description('Required. The name of the database.')
    database: string

    @sys.description('Required. The type used for authentication.')
    authenticationType: ( 'Windows' | 'SQL' )

    @sys.description('Required. Specify the ID of the user who has access to the SQL server database.')
    userName: string

    @sys.description('Required. Specify the password for the user (userName).')
    password: keyVaultLinkedServiceReferenceType

    @sys.description('''Optional. Specify always encryptedsettings information that's needed to enable Always Encrypted to protect sensitive data stored in SQL server
                        by using either managed identity or service principal. Find example here -
                        https://learn.microsoft.com/en-us/azure/data-factory/connector-sql-server?tabs=data-factory#using-always-encrypted''')
    alwaysEncryptedSettings: object?

    @sys.description('Optional. Indicate whether TLS encryption is required for all data sent between the client and server.')
    encrypt: bool?

    @sys.description('Optional. Indicate whether the channel will be encrypted while bypassing the certificate chain to validate trust.')
    trustServerCertificate: bool?
  }?
  @sys.description('Optional. Details to configure JIRA linked service.')
  jiraLinkedServiceConfig: {
    @sys.description('Required. The hostname or IP address of the JIRA server.')
    host: string
    @sys.description('Optional. The port number used to connect to the JIRA server.')
    port: string?

    @sys.description('Required. The username used to authenticate with the JIRA server.')
    username: string

    @sys.description('Required. Specify the password for the user.')
    password: keyVaultLinkedServiceReferenceType

    @sys.description('Optional. Indicates whether encrypted endpoints should be used.')
    useEncryptedEndpoints: bool?

    @sys.description('Optional. Indicates whether to verify the host during SSL handshake.')
    useHostVerification: bool?

    @sys.description('Optional. Indicates whether to verify the peer certificate during SSL handshake.')
    usePeerVerification: bool?
}?

}

@export()
type linkedServiceType = {
  @sys.description('Required. The name of the Linked Service.')
  name: string

  @sys.description('Required. The type of Linked Service.')
  type: ('AzureBlobFS' | 'AzureBlobStorage' | 'AzureDatabricks' | 'AzureFunction' | 'AzureKeyVault' | 'AzureSqlDatabase' | 'FileServer' | 'SqlServer' | 'Jira') 

  @sys.description('Optional. Used to add connection properties for your linked services.')
  typeProperties: linkedServiceTypePropertiesType?

  @sys.description('Optional. The name of the Integration Runtime to use.')
  integrationRuntimeName: string?

  @sys.description('Optional. Use this to add parameters for a linked service connection string.')
  parameters: object?

  @sys.description('Optional. The description of the Linked Service.')
  description: string?
}[]?
