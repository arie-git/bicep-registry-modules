// DataPipeline5 — Medallion architecture: bronze → silver → gold
// ADF orchestrates 3 sequential Databricks notebook activities for each layer.
// Validates UC table writes across the full medallion chain.
//
// Prerequisites:
//   - main.bicep deployed (ADF with ls_databricks + ls_adls_uc linked services)
//   - Unity Catalog setup completed (DataPipeline4 or manual setup-unity-catalog.py)
//   - Medallion notebooks uploaded to Databricks workspace
//
// DRCP compliance:
//   - drcp-adf-04: No inline secrets (MI auth)
//   - drcp-adf-05: AzureDatabricks is whitelisted

param adfName string
param ucStorageAccountName string

@description('Base path for medallion notebooks in the Databricks workspace.')
param notebookBasePath string = '/Workspace/medallion'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: adfName
}

// Pipeline: Bronze → Silver → Gold transformation chain
resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  name: 'PL-Datapipeline5-Medallion'
  parent: adf
  properties: {
    description: 'Medallion architecture pipeline: ingests raw data into bronze, cleanses into silver, aggregates into gold. Each stage is a Databricks notebook using Unity Catalog tables.'
    activities: [
      // Stage 1: Bronze — raw ingestion
      {
        name: 'Bronze Ingest'
        type: 'DatabricksNotebook'
        typeProperties: {
          notebookPath: '${notebookBasePath}/01_bronze_ingest'
          baseParameters: {
            storage_account_name: ucStorageAccountName
            catalog_name: 'drcp_data'
            schema_name: 'bronze'
          }
        }
        linkedServiceName: {
          referenceName: 'ls_databricks'
          type: 'LinkedServiceReference'
        }
        policy: {
          timeout: '0.01:00:00'
          retry: 1
          retryIntervalInSeconds: 60
        }
      }
      // Stage 2: Silver — cleanse and conform (depends on Bronze)
      {
        name: 'Silver Transform'
        type: 'DatabricksNotebook'
        dependsOn: [
          {
            activity: 'Bronze Ingest'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        typeProperties: {
          notebookPath: '${notebookBasePath}/02_silver_transform'
          baseParameters: {
            catalog_name: 'drcp_data'
            source_schema: 'bronze'
            target_schema: 'silver'
          }
        }
        linkedServiceName: {
          referenceName: 'ls_databricks'
          type: 'LinkedServiceReference'
        }
        policy: {
          timeout: '0.01:00:00'
          retry: 1
          retryIntervalInSeconds: 60
        }
      }
      // Stage 3: Gold — business aggregates (depends on Silver)
      {
        name: 'Gold Aggregate'
        type: 'DatabricksNotebook'
        dependsOn: [
          {
            activity: 'Silver Transform'
            dependencyConditions: [
              'Succeeded'
            ]
          }
        ]
        typeProperties: {
          notebookPath: '${notebookBasePath}/03_gold_aggregate'
          baseParameters: {
            catalog_name: 'drcp_data'
            source_schema: 'silver'
            target_schema: 'gold'
          }
        }
        linkedServiceName: {
          referenceName: 'ls_databricks'
          type: 'LinkedServiceReference'
        }
        policy: {
          timeout: '0.01:00:00'
          retry: 1
          retryIntervalInSeconds: 60
        }
      }
    ]
  }
}

output pipelineName string = pipeline.name
