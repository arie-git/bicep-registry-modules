# Scenario 7

main: App Service with Docker + Azure Container Registry + Azure Storage Account (blob/file) + LogicApp
extra: KeyVault + Log Analytics + Application Insights

## Source code

Infrastructure - `scenario7\infra\main.bicep`

Application - repo `https://github.com/microsoft/CloudAdoptionFramework` folder `ready/AzNamingTool`

## Azure Container Registry

Azure Container Registry has two functions: building the image from the source code and serving the image to the App Service.

To build the image, ACR Tasks are used with a trigger scheduled to run 10 minutes after the task deployment started (to solve the delay problem in private endpoints' DNS registration), and when running tasks are using custom agent pool that is integrated with the VNet. The source of the code to build the image is the AzNamingTool in the CAF repository of Microsoft.

To serve the image the ACR is provisioned with a private endpoint and the authentication is RBAC-based.

## App Service with Docker

App Service is configured to run the container from the ACR. It is integrated with VNet and is configured to use VNet to pull the image and for all outbound traffic.

The system-assigned managed identity of the App Service is assigned RBAC to access the ACR, the KeyVault, and the Storage Account.

Docker App is provisioned with a private endpoint and the authentication is anonymous.

## Log Analytics + Application Insights

Log analytics workspace is used to collect diagnostic logs from all deployed resources. Application Insights is used to collect application logs from the App Service.

## Azure Storage and Keyvault

These components are not integrated into the solution and are used only for component testing, and not for integration testing.

## How-to's

### How to deploy manually

`az login`

`az account set -s AM-CCC-ENV23109-DEV`

`az deployment sub create --location westeurope -f scenario7/infra/main.bicep --name=drcptst0701`

OR if not default values
`az deployment sub create --location westeurope -f scenario7/infra/main.bicep --name=drcptst0701 --parameters applicationInstanceCode=0701 environmentId=ENV23109 vnetPrefix='10.238.1.96/27' engineersGroupObjectId='522abf2a-8625-4ceb-9548-3f8e050bfe7a'`

where:
name - is the name of the deployment
applicationSystemCode - is the code for the combination of 'system+instance' within the application
environmentId - is the DRCP environment id as received from service now, used in naming subscriptions and VNets
vnetPrefix - is not a real network prefix, but a string used to compose subnet addresses
engineersGroupObjectId - is the objectId for the Engineers group that will receive RBAC assignments to deployed resources

### How to remove manually

`.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId ENV23109 -resourceFilter drcptst0701`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group