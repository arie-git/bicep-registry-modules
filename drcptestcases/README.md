# Introduction

DRCP Test Cases


**7th**
main: App Service with Docker + Azure Container Registry + Azure Storage Account (blob/file) + LogicApp
extra: KeyVault + Log Analytics + Application Insights

**8th**
main: Function App on App Service Plan -> CosmosDb -> Function App on App Service Plan -> Azure Storage Account (blob/file)
extra: KeyVault + Log Analytics + Application Insights

**9th**
main: ACR -> Azure Kubernetes Service -> Application Gateway -> CosmosDb
extra: AKV, Storage Account, Log Analytics


## Nightly Run

Each scenario runs nightly. The schedule is as follows: scenario1 at 1am (UTC), scenario2 at 2am, etc.

Test cases are deployed as 'tst' type.

### Environments used for nightly runs

Environments are in 'AM-CCC' application system:

- ENV23148 with '10.238.2.0/24' of DEV in West Europe
- ENV23684 with '10.238.6.0/24' of DEV in West Europe
- ENV23968 with '10.238.18.0/24' of DEV in Sweden Central
- ENV23969 with '10.238.19.0/24' of DEV in Sweden Central
- ENV23978 with '10.238.64.0/24' of TST in Sweden Central
- ENV23979 with '10.238.65.0/24' of TST in Sweden Central

### Network space used for nightly runs - DEV

West Europe:

- scenario 1: '10.238.2.0/27'
- scenario 2: '10.238.2.32/27'
- scenario 3: '10.238.2.64/27'
- scenario 4: '10.238.2.96/27'
- scenario 5: '10.238.2.192/26'
- scenario 7: '10.238.2.128/26'
- scenario 8: '10.238.6.0/26'
- scenario 10: '10.238.6.64/27'

Central Sweden:

- scenario 1: '10.238.18.0/27'
- scenario 2: '10.238.18.32/27'
- scenario 3: '10.238.18.64/27'
- scenario 4: '10.238.18.96/27'
- scenario 5: '10.238.18.192/26'
- scenario 7: '10.238.18.128/26'
- scenario 8: '10.238.19.0/26'
- scenario 9: '10.238.19.128/26'
- scenario 10: '10.238.19.64/27'
- scenario 11: '10.238.19.196/26'

### Network space used for nightly runs - TST

Central Sweden:

- scenario 1: '10.238.64.0/27'
- scenario 2: '10.238.64.32/27'
- scenario 3: '10.238.64.64/27'
- scenario 4: '10.238.64.96/27'
- scenario 5: '10.238.64.192/26'
- scenario 7: '10.238.64.128/26'
- scenario 8: '10.238.65.0/26'
- scenario 10: '10.238.65.64/27'
- scenario 11: '10.238.65.196/26'
