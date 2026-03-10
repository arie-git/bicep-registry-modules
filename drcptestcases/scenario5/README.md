# Scenario 5 - Application Gateway

Scenario 5 focuses on Application Gateway component which is enabled by DRCP team.
The goal of this scenarion is to successfully deploy the Application Gateway as a Web Application Firewall (WAF) following the guardrails.

## Components
Scenarion 5 makes use of folloing Azure resources

- Application Gateway - as WAF
- App Service - as a backend of application gateway
- Function App - as a backend of application gateway
- App Service Plan - as hosting platform for app services and function app
- Key Vault - Store for secrets
- Storage account (optiona)

### Changes to repo
As a part of development of this scnario, following changes are made to source repo
- a new module is created for App Services
- a new module is created for Application Gateway
- a new module is created for Application Gateway WAF policy
- a self signed certificate is added to the repo for reference. the certificate is created in key-vault and it is used in application gateway configuration
- <i>exportKVpfx.ps1</i> is added which exports the certificate from key-vault and encrypts it with private key. This is required because,
    - self-signed certificate generated in key-vault does not have a password (private key) associated with it
    - If the certificate is downloaded from key-vault then its private key is no longer required while importing the certificate while application gateway expects the private key value

## Source Code
The infrastructure source code is stored under `scenario5\infra\main.bicep`

## Deployment
The scenario 5 can be deployed using following pipelines
- Manual trigger- https://dev.azure.com/connectdrcpapg1/S02-App-AM-CCC/_build?definitionId=378
- Scheduled Trigger - https://dev.azure.com/connectdrcpapg1/S02-App-AM-CCC/_build?definitionId=379

### Local deployment
In order to deploy the scenario from local machine
`az login`

`az account set -s AM-CCC-ENV23594-DEV`

`az deployment sub create --location swedencentral -f scenario5/infra/main.bicep --name=drcpdev0501`

`az deployment sub create --location swedencentral --name drcpdev0501 --template-file scenario5/infra/main.bicep --parameters location=swedencentral --parameters '.\scenario5\infra\parameters.json' --parameters environmentId=ENV24083 --parameters networkAddressSpace='10.238.0.192/26' --parameters engineersGroupObjectId='623a26f3-3341-4911-bfe2-0e9da839c26e'`

### Un-install the infra
#### Azure Pipeline
The infrastrucure can be removed using the `Run Remove stage` switch in manually triggerred pipeline. The scheduled pipeline does it automatically.

#### From Local Machine
execute `.\modules\scripts\removeApplicationInfra.ps1 -snowEnvironmentId ENV23594 -resourceFilter drcpdev0501`

where:
groupName - is the name of the resource group where infra is deployed
vnetGroupName - is the name of the Virtual Network resource group
vnetName - is the name of the Virtual Network
resourceFilter - is the string used in part of the resource names to be removed in Virtual Network resource group