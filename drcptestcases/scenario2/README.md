# Scenario 2

KeyVault + Function App + CosmosDB (Core API)

## Installing the application infrastructure

Execute following script in powershell console

$cmd = "az deployment sub create ``
--location westeurope ``
--name '906main.bicep--what-if' ``
--template-file 'C:\Users\aa01675\source\repo\S02-App-AM-CCC-DrcpTestCases\scenario2\infra\main.bicep' ``
--parameters whatIf='' ``
--parameters location='westeurope' ``
--parameters deploymentId='007' --parameters engineersGroupObjectId='2ed0754e-8aec-41ec-8d60-a956dc578666' --parameters vnetPrefix='10.238.0' --parameters environmentType='dev' --parameters applicationInstanceCode='04' --parameters applicationCode='scne2' --parameters departmentCode='ccc' --parameters organizationCode='s2' --parameters namePrefix='' --parameters environmentId='ENV23145' --parameters applicationId='AM-CCC'"

Invoke-Expression -Command $cmd

### Unintalling the application infrastructure

.\modules\scripts\removeApplicationInfra.ps1 -groupName scne204-dev-westeurope-rg -vnetGroupName AM-CCC-ENV23145-VirtualNetworks -vnetName AM-CCC-ENV23145-VirtualNetwork -resourceFilter scne204`

** Note - Parameters in the above mentioned scripts are for guidance, those need to be replaced with actual values