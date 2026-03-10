# Scenario 1

Function App + KeyVault + SQL db

## How to deploy manually

`az login`

`az account set -s AM-CCC-ENV23109-DEV`

`az deployment sub create --location swedencentral -f scenario1/infra/main.bicep --name=drcptst0113`

OR if not default values
`az deployment sub create --location swedencentral -f scenario1/infra/main.bicep --name=drcptst0113 --parameters applicationInstanceCode=0909 environmentId=ENV24508 engineersGroupObjectId='623a26f3-3341-4911-bfe2-0e9da839c26e'`

where:
name - is the name of the deployment
applicationSystemCode - is the code for the combination of 'system+instance' within the application
environmentId - is the DRCP environment id as received from service now, used in naming subscriptions and VNets
vnetPrefix - is not a real network prefix, but a string used to compose subnet addresses
engineersGroupObjectId - is the objectId for the Engineers group that will receive RBAC assignments to deployed resources

## How to remove manually

`.\modules\scripts\removeApplicationInfra.ps1 -groupName s2-c3-drcptst0104-dev-westeurope-rg -vnetGroupName AM-CCC-ENV23109-VirtualNetworks -vnetName AM-CCC-ENV23109-VirtualNetwork -resourceFilter drcptst0104`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group