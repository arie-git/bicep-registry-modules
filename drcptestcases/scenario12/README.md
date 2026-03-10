# Scenario 12

ResourceGroup + NSG + RouteTable + LogAnalytics + Subnet + Azure Data Factory + Storage Account + DataBricks

## How to deploy manually

`az login`

`az account set -s AM-CCC-ENVxxxxx-DEV`

`az deployment sub create --location swedencentral -f scenario12/infra/main.bicep --name=drcpdev1101`

OR if not default values
`az deployment sub create --location swedencentral -f scenario12/infra/main.bicep --name=drcpdev1201 --parameters networkAddressSpace='10.238.0.192/26' applicationInstanceCode=1201 environmentId=ENV24083 engineersGroupObjectId='4ac8afa1-dfbc-4096-967c-4b0fba1f37f6'`

where:
name - is the name of the deployment
applicationSystemCode - is the code for the combination of 'system+instance' within the application
environmentId - is the DRCP environment id as received from service now, used in naming subscriptions and VNets
vnetPrefix - is not a real network prefix, but a string used to compose subnet addresses
engineersGroupObjectId - is the objectId for the Engineers group that will receive RBAC assignments to deployed resources
