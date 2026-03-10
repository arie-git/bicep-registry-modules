# Scenario 8

main: Function App on App Service Plan -> CosmosDb -> Function App on App Service Plan -> Azure Storage Account (blob/file)
extra: KeyVault + Log Analytics + Application Insights

## Source code

Infrastructure - `scenario7\infra\main.bicep`

## Main components

...

## Extra components

Log analytics workspace is used to collect diagnostic logs from all deployed resources. Application Insights is used to collect application logs from the App Service.

Azure Storage and Keyvault: These components are not integrated into the solution and are used only for component testing, and not for integration testing.

## How-to's

### How to deploy manually

`az login`

`az account set -s AM-CCC-ENV23148-DEV`

`az deployment sub create --location westeurope -f scenario8/infra/main.bicep --name=drcptst0801`

OR if not default values
`az deployment sub create --location westeurope -f scenario8/infra/main.bicep --name=drcptst0801 --parameters applicationInstanceCode=0801 environmentId=ENV23148 engineersGroupObjectId='522abf2a-8625-4ceb-9548-3f8e050bfe7a'`

where:
name - is the name of the deployment
applicationSystemCode - is the code for the combination of 'system+instance' within the application
environmentId - is the DRCP environment id as received from service now, used in naming subscriptions and VNets
vnetPrefix - is not a real network prefix, but a string used to compose subnet addresses
engineersGroupObjectId - is the objectId for the Engineers group that will receive RBAC assignments to deployed resources

To deploy applications manually:

- frontend function
    `cd src/frontend-dotnet`
    `func azure functionapp publish s2c3drcptst0801devweapp-fe`
- backend function
    `cd src/backend-dotnet`
    `func azure functionapp publish s2c3drcptst0801devweapp-be`

To test the application:

- endpoint to call https://s2c3drcptst0801devweapp-fe.azurewebsites.net/api/httptrigger1?name=hellopython60
- look for created files in the storage account

### How to remove manually

`.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId ENV23148 -resourceFilter drcptst0801`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group