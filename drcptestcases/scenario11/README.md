# Scenario 11 -- Multi-Tier Web Application

Web App (ASP.NET UI) + Web App (ASP.NET API) + KeyVault + SQL db

## How to deploy manually

`az login`

`az account set -s AM-CCC-ENVxxxxx-DEV`

`az deployment sub create --location swedencentral -f scenario11/infra/main.bicep --name=drcptst1101`

OR if not default values
`az deployment sub create --location swedencentral -f scenario11/infra/main.bicep --name=drcptst1101 --parameters applicationInstanceCode=1101 environmentId=ENVxxxxx engineersGroupObjectId='623a26f3-3341-4911-bfe2-0e9da839c26e'`

where:
name - is the name of the deployment
applicationSystemCode - is the code for the combination of 'system+instance' within the application
environmentId - is the DRCP environment id as received from service now, used in naming subscriptions and VNets
vnetPrefix - is not a real network prefix, but a string used to compose subnet addresses
engineersGroupObjectId - is the objectId for the Engineers group that will receive RBAC assignments to deployed resources

## How to remove manually

`.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId ENVxxxxx -resourceFilter drcptst1101`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group