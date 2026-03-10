# Scenario 10 - Azure Data Factory

Scenario 10 focuses on Azure Data Factory (ADF) component which is enabled by DRCP team.
The goal of this scenarion is to successfully deploy the ADF following the guardrails and create basic data pipelines

## Components

Scenarion 10 makes use of following Azure resources

- Azure Data Factory - Orchestrator for data pipelines
- Key Vault - Store for secrets
- Data lake store - Used in data pipeline execution
- Storage account with Blob and File Share - Used in data pipeline execution

It also makes use of on-premises

- Sql server - Used on data pipeline execution
- Windows Server 2019 - Used as Integration Runtime

### Changes to repo

As a part of development of this scenario, following changes are made to source repo

- a new module is created for Azure Data Factory
- a new module is created for ADF Triggers
- a new module is created for ADF linked services which are required for Data pipelines
- a change is made in Key-vault module for allowing access to Resource managers to secrets during deployments

## Source Code

The infrastructure source code is stored under `scenario10\infra\main.bicep`
The data pipeline source code is stored under `scenario10\src`

## Deployment

The scenario 10 can be deployed using following pipelines

- Manual trigger- https://dev.azure.com/connectdrcpapg1/S02-App-AM-CCC/_build?definitionId=269
- Scheduled Trigger - https://dev.azure.com/connectdrcpapg1/S02-App-AM-CCC/_build?definitionId=284

### Local deployment

In order to deploy the scenario from local machine
`az login`

`az account set -s AM-CCC-ENV23455-DEV`

`az deployment sub create --location westeurope -f scenario7/infra/main.bicep --name=drcpdev0801`

`$location = 'westeurope'`

`az deployment sub create --location $location --name drcpdev1002 --template-file scenario10/infra/main.bicep --parameters location=$location --parameters deploymentId=$deploymeId --parameters '.\scenario10\infra\parameters.json'`

### Un-install the infra

#### Azure Pipeline

The infrastrucure can be removed using the `Run Remove stage` switch in manually triggerred pipeline. The scheduled pipeline does it automatically.

#### From Local Machine

execute `.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId ENV23455 -resourceFilter drcpdev1002`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group

## Data pipelines
Once the ADF and other infrastrucutre components are created successfully, following pipelines need to be deployed

 - [Pipeline 1 ](src/DataPipeline1.bicep) to copy from SQL server table into `parquet` on datalake
 - [Pipeline 2](src/DataPipeline2.bicep) to copy from fileshare table `as binary` to datalake
 - [Pipeline 3](src/DataPipeline3.bicep) to test `staging` of data in Storage account blobs

use following syntax to deploy the pipelines -

`az deployment group create --resource-group $resourceGroup --name drcpdev1002 --template-file scenario10/src/datapipeline*.bicep --parameters adfName='<>' --parameters kvName='<>'--parameters adlsName='<>'`

Where-
 - adfName - Name of the ADF
 - kvName - Name of the key vault
 - adlsName - Name of the ADLS