# Scenario 9

main: ACR -> Azure Kubernetes Service -> Application Gateway -> CosmosDb
extra: AKV, Storage Account, Log Analytics

## Source code

Infrastructure - `scenario9\infra\main.bicep`

## Azure Container Registry

Azure Container Registry has two functions: building the image from the source code and serving the image to the App Service.

To build the image, ACR Tasks are used with a trigger scheduled to run 10 minutes after the task deployment started (to solve the delay problem in private endpoints' DNS registration), and when running tasks are using custom agent pool that is integrated with the VNet. The source of the code to build the image is the ...

## Extras

Log analytics workspace is used to collect diagnostic logs from all deployed resources. Application Insights is used to collect application logs from the App Service.

Azure Storage and Keyvault : These components are not integrated into the solution and are used only for component testing, and not for integration testing.

## How-to's

### How to deploy manually

`az login`

`az account set -s AM-CCC-ENV23969-DEV`

`az deployment sub create --location swedencentral -f scenario9/infra/main.bicep --name=drcptst0801`

OR if not default values
`az deployment sub create --location swedencentral -f scenario9/infra/main.bicep --name=drcptst0901 --parameters applicationInstanceCode=0901 environmentId=ENV23969 engineersGroupObjectId='623a26f3-3341-4911-bfe2-0e9da839c26e'`

Example of deploying the test cases into a different application system:

```powershell
az login

az account set -s AM-CCC-ENV24148-DEV

az deployment sub create --location swedencentral -f scenario9/infra/main.bicep --name=drcptst0901 --parameters applicationId='TIBCOBWCE' departmentCode='int' applicationCode='tibco' applicationInstanceCode=01 environmentId=ENV24148 engineersGroupObjectId='8a1e2d88-5278-47e1-8b21-05a5fab83192' engineersContactEmail='DL-Application-Integration@apg-am.nl'
```

where, specifically 'engineersGroupObjectId' is the Entra ID object ID of the user group that will be granted default access to clusters, container images and data.

where:
name - is the name of the deployment
applicationSystemCode - is the code for the combination of 'system+instance' within the application
environmentId - is the DRCP environment id as received from service now, used in naming subscriptions and VNets
vnetPrefix - is not a real network prefix, but a string used to compose subnet addresses
engineersGroupObjectId - is the objectId for the Engineers group that will receive RBAC assignments to deployed resources

To deploy applications manually:

...

To test the application:

- endpoint to call ...
- look for created files in the storage account

```pwsh
az aks get-credentials --resource-group lztst0901-dev-swedencentral-rg --name s2c3lztst0901devsecaks --overwrite-existing
kubelogin convert-kubeconfig -l azurecli
kubectl config set-context --current --namespace=sampleapp
kubectl apply -f .\kscenario9\8s\sampleapp.yaml
k get all -o wide -n sampleapp
```

### How to remove manually

`.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId ENV23969 -resourceFilter drcptst0901`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group