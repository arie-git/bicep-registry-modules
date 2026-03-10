# DRCP Test Cases

Integration test scenarios that validate AMAVM Bicep modules deploy correctly to the hardened DRCP platform. Each scenario combines multiple modules into a realistic architecture, deploys via scheduled pipeline, and tears down afterwards.

## Scenarios

| # | Architecture | Key AMAVM Modules | Status |
|---|---|---|---|
| 1 | Function App + Key Vault + SQL | web/site, key-vault/vault, sql/server | Fully AMAVM |
| 2 | Function App + Key Vault + Cosmos DB | web/site, document-db/database-account | Fully AMAVM |
| 3 | Function App + Logic App + Storage | web/site, storage/storage-account | Fully AMAVM |
| 4 | Function App + Event Hub | web/site, event-hub/namespace | Fully AMAVM |
| 5 | App Gateway + Web Apps + Function App | network/application-gateway, web/site | Nearly AMAVM |
| 7 | Docker App Service + ACR | container-registry/registry, web/site | Nearly AMAVM |
| 8 | **PostgreSQL + Service Bus** | db-for-postgre-sql/flexible-server, service-bus/namespace | Planned |
| 9 | AKS + ACR + Storage | container-service/managed-cluster, container-registry/registry | Fully AMAVM |
| 10 | Data Factory + Databricks | data-factory/factory, databricks/workspace | Nearly AMAVM |
| 11 | Web Apps + SQL | web/site, sql/server | Fully AMAVM |
| 12 | N-Tier SQL (pattern module) | ptn/ntier/sql | Complete |
| 13 | Redis Cache (standalone) | cache/redis | Implemented |
| 14 | Event Hub + App Config + Function App | event-hub/namespace, app-configuration/configuration-store | Implemented |
| 15 | Cosmos DB NoSQL (standalone) | document-db/database-account | Implemented |
| 16 | AI Chatbot: OpenAI + AI Search | cognitive-services/account, search/search-service | Planned |
| 17 | Static Web App + Function API | web/static-site, web/site | Planned |

> Scenario 6 does not exist. See each scenario's `README.md` for components, deployment commands, and DRCP policy details.

## Nightly Runs

Each scenario runs nightly. The schedule is: scenario 1 at 1am (UTC), scenario 2 at 2am, etc. Test cases deploy as `tst` type.

### Environments

Environments are in `AM-CCC` application system (Sweden Central only — West Europe deprecated):

| Environment | Address Space | Type | Region | Purpose |
|---|---|---|---|---|
| ENV23968 | 10.238.18.0/24 | DEV | Sweden Central | Less restrictive — dev iteration |
| ENV23969 | 10.238.19.0/24 | DEV | Sweden Central | Less restrictive — dev iteration |
| ENV23978 | 10.238.64.0/24 | TST | Sweden Central | Strict policies — production mirror |
| ENV23979 | 10.238.65.0/24 | TST | Sweden Central | Strict policies — production mirror |

> West Europe environments (ENV23148, ENV23684) are deprecated. No new deployments to West Europe.

### Network Space — DEV (Sweden Central)

| Scenario | CIDR | Size | Status |
|---|---|---|---|
| 1 | 10.238.18.0/27 | /27 | Active |
| 2 | 10.238.18.32/27 | /27 | Active |
| 3 | 10.238.18.64/27 | /27 | Active |
| 4 | 10.238.18.96/27 | /27 | Active |
| 7 | 10.238.18.128/26 | /26 | Active |
| 5 | 10.238.18.192/26 | /26 | Active |
| 8 | 10.238.19.0/26 | /26 | Active |
| 10 | 10.238.19.64/27 | /27 | Active |
| 13 | 10.238.19.96/27 | /27 | **Planned** |
| 9 | 10.238.19.128/26 | /26 | Active |
| 11 | 10.238.19.192/26 | /26 | Active |
| 14-16 | TBD | /27-/26 | **Needs new address space** |

### Network Space — TST (Sweden Central)

| Scenario | CIDR | Size | Status |
|---|---|---|---|
| 1 | 10.238.64.0/27 | /27 | Active |
| 2 | 10.238.64.32/27 | /27 | Active |
| 3 | 10.238.64.64/27 | /27 | Active |
| 4 | 10.238.64.96/27 | /27 | Active |
| 7 | 10.238.64.128/26 | /26 | Active |
| 5 | 10.238.64.192/26 | /26 | Active |
| 8 | 10.238.65.0/26 | /26 | Active |
| 10 | 10.238.65.64/27 | /27 | Active |
| 13 | 10.238.65.96/27 | /27 | **Planned** |
| 14 | 10.238.65.128/27 | /27 | **Planned** |
| 15 | 10.238.65.160/27 | /27 | **Planned** |
| 11 | 10.238.65.192/26 | /26 | Active |
| 16 | TBD | /26 | **Needs address space** |
