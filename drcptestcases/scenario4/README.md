# Scenario 1

Function App, function 1 (write) -> EventHub <- (read) Function App, function 2 (write) -> Storage Account

## How to deploy infra manually

`az login`

`az account set -s AM-CCC-ENV23101-DEV`

`az deployment sub create --location westeurope -f scenario4/infra/main.bicep --name=drcptst0401 --parameters scenario4/infra/main-23101.bicepparam`

## How to remove infra manually

`.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId <environmentId> -resourceFilter drcptst0401`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group

## How to deploy application manually

To deploy applications manually:

`cd src/eventHubFunctionApp`
`func azure functionapp publish <funcappname>` (for example, funcappname: s2c3drcptst0401devweapp)

To test the application:

- endpoint to call `https://<funcappname>.azurewebsites.net/api/generateevents` with some query string parameter
(for example, https://s2c3drcptst0401devweapp.azurewebsites.net/api/generateevents?param=testing21)

- look in function app logs for the output
