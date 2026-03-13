// DataPipeline4 -- ADF → Databricks → Unity Catalog validation
// Runs the setup-unity-catalog notebook via ADF Databricks notebook activity.
// Validates end-to-end: ADF MI → Databricks linked service → UC → ADLS (Access Connector MI)
//
// Prerequisites:
//   - main.bicep deployed (ADF with ls_databricks + ls_adls_uc linked services)
//   - setup-unity-catalog.py uploaded to Databricks workspace (Repos or Workspace files)
//
// DRCP compliance:
//   - drcp-adf-04: No inline secrets (MI auth on Databricks linked service)
//   - drcp-adf-05: AzureDatabricks is a whitelisted linked service type

param adfName string
param ucStorageAccountName string
param accessConnectorId string

@description('Notebook path in the Databricks workspace. Default assumes Workspace files.')
param notebookPath string = '/Workspace/setup-unity-catalog'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

// Pipeline: Run Unity Catalog setup notebook
resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'PL-Datapipeline4-UC-Setup'
  parent: adf
  properties: {
    description: 'Runs the Unity Catalog setup notebook to create storage credentials, external locations, catalog, schemas, and sample tables. Validates end-to-end RBAC + PE wiring.'
    activities: [
      {
        name: 'Setup Unity Catalog'
        type: 'DatabricksNotebook'
        typeProperties: {
          notebookPath: notebookPath
          baseParameters: {
            storage_account_name: ucStorageAccountName
            access_connector_id: accessConnectorId
          }
        }
        linkedServiceName: {
          referenceName: 'ls_databricks'
          type: 'LinkedServiceReference'
        }
        policy: {
          timeout: '0.01:00:00'
          retry: 0
          retryIntervalInSeconds: 30
        }
      }
    ]
  }
}

output pipelineName string = pipeline.name
