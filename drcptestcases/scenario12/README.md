# Scenario 12 — Data Factory + Databricks + SQL

Azure Data Factory with Databricks compute and SQL backend. Uses the `ptn/ntier/sql` pattern module. Full DRCP compliance with private endpoints, managed identity, VNet integration, and diagnostics.

## Components

| Component | AMAVM Module | Purpose |
|---|---|---|
| N-Tier SQL Pattern | `br/amavm:ptn/ntier/sql` | Full-stack pattern (NSG, UDR, subnet, SQL, storage) |

> Note: This scenario uses the AMAVM pattern module which bundles networking, compute, and data components. The `ptn/data/ingestion` module reference is commented out pending migration.

## Deployment

### Deploy

```
az deployment sub create --location swedencentral \
  -f scenario12/infra/main.bicep \
  --name=drcpdev1201 \
  --parameters environmentId=<ENV_ID> \
  engineersGroupObjectId='<GROUP_OID>'
```

### Remove

```
.\modules\scripts\removeApplicationInfra.ps1 \
  -snowEnvironmentId <ENV_ID> \
  -resourceFilter drcpdev1201
```
