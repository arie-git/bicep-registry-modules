# DRCP Test Cases — Task Tracker

## Purpose

These test cases validate that AMAVM Bicep modules deploy correctly to the hardened DRCP platform. Each scenario combines multiple modules into a realistic architecture, deploys via scheduled pipeline, and tears down afterwards to save costs. They serve as integration tests — catching issues that per-module e2e tests miss (cross-module wiring, private endpoint connectivity, identity/RBAC chains, naming conventions).

> **Historical details** (completed migration plans, component tables, design docs) are in [`todo-archive.md`](todo-archive.md).

---

## Scenario Status Overview

| Scenario | Architecture | AMAVM Status | Active local refs | AMAVM refs |
|---|---|---|---|---|
| 1 | Function App + KV + SQL | **Fully AMAVM** | 0 | 13 |
| 2 | Function App + KV + Cosmos DB | **Fully AMAVM** | 0 | 13 |
| 3 | Function App + Logic App + Storage | **Fully AMAVM** | 0 | 13 |
| 4 | Function App + Event Hub | **Fully AMAVM** | `roleAssignment.bicep` (x3) | 15 |
| 5 | App Gateway + Web Apps + Function App | **Nearly AMAVM** | 1 (public-ip-address) | 16 |
| 7 | Docker App Service + ACR | **Nearly AMAVM** | 1 (ACR task) + 1 (`acrRoleAssignment.bicep`) | 11 |
| 8 | **PostgreSQL + Service Bus** (repurposed) | **Fully AMAVM** | 0 | 12 |
| 9 | AKS + ACR + Storage | **Fully AMAVM** | 0 | 17 |
| 10 | Data Factory + Databricks | **Nearly AMAVM** | main.bicep: 2 local (IR, role-assignment) + central.bicep: 2 local (rbac, shir-auth) | main: 13, central: 7 |
| 11 | Web Apps + SQL | **Fully AMAVM** | 0 | 16 |
| 12 | N-Tier SQL (pattern module) | **Complete** | 0 | 2 |
| **13** | **Redis Cache (standalone)** | **Fully AMAVM** | 0 | 6 |
| **14** | **Event Hub + App Config + Function App** | **Fully AMAVM** | 0 | 13 |
| **15** | **Cosmos DB NoSQL (standalone)** | **Fully AMAVM** | 0 | 6 |
| **16** | **AI Chatbot: OpenAI + AI Search** | **Planned** (from chatbot-poc) | 2 (appregistration, rbac) | ~15 |
| **17** | **Static Web App + Function API** | **Fully AMAVM** | 0 | 11 |

**Note:** Scenario 6 does not exist. All scenarios use `br/amavm:utl/amavm/naming:0.1.0`. Scenario 8 repurposed from APIM to PostgreSQL + Service Bus.

---

## P0 — AMAVM Module Migration

### Completed ✅

| Scenario | What was done |
|---|---|
| S2 | Cosmos DB: 5 local refs → 0. AMAVM `document-db/database-account` with inline sqlDatabases, PE, diagnostics. `disableLocalAuth: true`. |
| S4 | Event Hub: 6 local refs → 0. AMAVM `event-hub/namespace` with inline eventhubs, consumerGroups, PE. 3 cross-dep RBAC helpers kept. |
| S10 | Data Factory + Databricks: Unity Catalog infra added, ADF migrated to AMAVM in main.bicep, central.bicep migrated (6 AMAVM, 3 eliminated, 3 kept local). 18 DRCP policies validated. |
| S8 | Repurposed from APIM → PostgreSQL + Service Bus. All AMAVM, 16 DRCP policies validated. |
| S7 | Simplified: removed Logic App (covered by S3). ACR + Docker only. `task.bicep` kept local. |

### Open — Cross-Scenario Role Assignment (blocked on GAP-6)

5 scenarios use local role-assignment helpers for circular dependency breaking. Once AMAVM `authorization/role-assignment/rg-scope` is available:

| Scenario | Local module(s) | Pattern |
|---|---|---|
| 4 | `roleAssignment.bicep`, `evhRoleAssignment.bicep`, `kvRoleAssignment.bicep` | Circular dep: FuncApp↔Storage/EVH/KV |
| 7 | `acrRoleAssignment.bicep` | Circular dep: WebApp↔ACR |
| 10 central | `security/rbac/role-assignment.bicep` | ADO RBAC (multi-principal batch) |
| 10 main | `data-factory/modules/role-assignment.bicep` | Cross-subscription shared IR RBAC |
| 16 | `modules/rbac.bicep` | AI Search MI → Storage (multi-principal) |

- [ ] Blocked until GAP-6 AMAVM module is created
- [ ] Migrate scenario 4 (3 local helpers → AMAVM)
- [ ] Migrate scenario 7 (1 local helper → AMAVM)
- [ ] Migrate scenario 10 central + main (2 local helpers → AMAVM)
- [ ] Migrate scenario 16 (1 local helper → AMAVM or inline on storage)
- [ ] Remove replaced local modules
- [ ] Validate `bicep build` on all affected scenarios

### Open — Scenario 10 Unity Catalog + Pipeline Expansion

- [x] Cluster policies to enforce `enableNoPublicIp: true` (drcp-adb-r04) — added to `setup-unity-catalog.py` step 8 (Databricks API)
- [x] Create `scenario10/src/setup-unity-catalog.py` — post-deployment UC setup notebook
- [x] Add `src/DataPipeline4.bicep` — ADF → Databricks → UC validation
- [x] Add `src/DataPipeline5.bicep` — Medallion: bronze → silver → gold
- [x] Update DataPipeline1 to write to UC bronze table (optional via `adlsUcName` param)
- [x] Validate: `bicep build` passes — DataPipeline1/4/5 clean; main.bicep blocked by ACR firewall (BCP192, expected from codespace)
- [ ] Validate: `what-if` (requires DRCP subscription + ACR access), deploy + run UC notebook, `/azure:azure-compliance`
- [x] Document medallion architecture pattern in README
- [x] Update DataPipelines pipeline YAML with DataPipeline4 + 5 steps

### Open — Scenario 5 Public IP (blocked)

- [ ] Blocked until AMAVM `network/public-ip-address` module is created (GAP-5)

### Open — Scenario 8 src/ cleanup

- [ ] Update `src/` directory for new architecture (old frontend/backend code references APIM)

---

## P1 — README Standardization ✅

All 12 scenario READMEs standardized to template format with components table, deploy/remove commands.

- [ ] Use `/azure:azure-resource-visualizer` to generate architecture diagrams for each scenario README (requires deployed resource group)

---

## P1.5 — New Test Scenarios

### Completed ✅

All 5 new scenarios (13-17) created with full Bicep, READMEs, and pipeline YAMLs. See [archive](todo-archive.md) for component tables and DRCP config details.

### Open — Pre-deployment validation

- [ ] S13: Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] S14: Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] S15: Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] S16: Use `/azure:azure-validate` for pre-deployment readiness check
- [ ] S16: Use `/azure:entra-app-registration` to validate app registration pattern
- [ ] S16: Use `/azure:azure-ai` for AI Search and OpenAI configuration best practices
- [ ] S16: Document shared private link approval process in README (DRCP portal + manual curl approval)
- [ ] S17: Use `/azure:azure-validate` for pre-deployment readiness check (pipeline has ENV_TODO for TST envSnowId)

---

## P2 — AMAVM Module Coverage ✅

**Full coverage achieved.** All 36 AMAVM `res/` modules covered by at least one scenario. See [archive](todo-archive.md) for the full coverage matrix.

---

## P2.5 — RBAC Enforcement

13 of 14 scenarios audited and compliant. Logic App (S3) exception documented.

- [ ] Audit scenario 8 for RBAC compliance (blocked on src/ update)
- [ ] Use `/azure:azure-rbac` to verify least-privilege roles per scenario

---

## P2.7 — Region Cleanup + Environment Mapping

### West Europe Deprecation

- [x] Remove West Europe from top-level README (network space + environments)
- [ ] Update files that reference `westeurope`:
  - [ ] `scenario5/infra/main.bicep` — line 94: location mapping (keep — used as abbreviation lookup)
  - [ ] `scenario7/README.md` — deploy command
  - [ ] `scenario8/README.md` — deploy command
  - [ ] `scenario10/README.md` — deploy command
  - [ ] `scenario10/pipeline/scenario10-DataPipelines.yaml`
  - [ ] `scenario16/pipelines/main.yaml`
  - [ ] `scenario16/pipelines/deploy-app.yaml`
  - [ ] `pipelines/universalPipeline.yaml`
  - [ ] `modules/pipelines/tpl/variables/commonVariables.yaml`
  - [ ] `modules/pipelines/tpl/tasks/*.yaml` (5 files)
  - [ ] `modules/infra/naming.bicep`
  - [ ] `modules/infra/network/virtual-network/README.md`

### Environment Mapping for New Scenarios (13-17)

Address space solved by ADO exclusive locks + teardown (see P2.9). All scenarios in a group reuse the same CIDR.

- [ ] Standardize `networkAddressSpace` defaults to use shared group CIDRs
- [ ] Assign new scenarios to groups (see P2.9 for rebalancing proposal)

---

## P2.9 — Test Concurrency & Scheduling

**Problem:** 17 scenarios share 4 VNets. ARM serializes subnet operations — concurrent deploys cause conflicts. Current 1-hour stagger doesn't scale.

**Solution:** ADO exclusive lock environments + parallel groups. See [archive](todo-archive.md) for full design.

- [ ] Create 4 ADO environments with exclusive lock: `drcp-vnet-{a,b}-{dev,tst}`
- [ ] Update all scenario pipeline YAMLs to use environment-based deployment (replaces time stagger)
- [ ] Standardize `networkAddressSpace` param: one shared CIDR per group
- [ ] Schedule Group A and Group B at the same start time (01:00 UTC)
- [ ] Decide group assignment for scenarios 13-17 (proposal: S13+S15 → Group A, S14+S16+S17 → Group B = 8/8 balance)
- [ ] Verify S12 `ptn/data/ingestion` works with shared CIDR when uncommented
- [ ] Document concurrency groups in top-level `drcptestcases/README.md`

---

## Pipeline Audit

| Scenario | Pipeline Dir | Schedule (UTC) | Status |
|----------|:--------:|----------|--------|
| 1 | `pipeline/` | 01:00 | OK |
| 2 | `pipelines/` | 02:00 | OK |
| 3 | `pipelines/` | 03:00 | OK |
| 4 | `pipelines/` | 04:00 | OK |
| 5 | `pipeline/` | 05:00 | OK |
| 7 | `pipeline/` | 07:00 | OK |
| 8 | `pipeline/` | 08:00 | OK |
| 9 | `pipeline/` | 09:00 | OK |
| 10 | `pipeline/` | 10:00 | OK |
| 11 | `pipeline/` | 11:00 | OK |
| 12 | `pipeline/` | 12:00 | OK |
| 13 | `pipeline/` | 13:00 | OK (ENV_TODO) |
| 14 | `pipeline/` | 14:00 | OK (ENV_TODO) |
| 15 | `pipeline/` | 15:00 | OK (ENV_TODO) |
| 16 | `pipelines/` | 16:00 | OK |
| 17 | `pipeline/` | 17:00 | OK |

- [ ] **Scenarios 13, 14, 15**: Fill ENV_TODO placeholders for envSnowId + networkAddressSpace

---

## P3 — Version Bumps

All scenarios use AMAVM module versions 0.1.0–0.3.0. After P0 migrations, bump to latest published versions.

- [ ] Inventory current vs latest versions
- [ ] Bump all scenarios
- [ ] Validate builds — use `bicep build` then `/azure:azure-validate`

---

## P4 — Cleanup

- [ ] Remove `modules/infra/storage/cosmos-db/` (S2 migrated)
- [ ] Remove `modules/infra/integration/event-hub/` (S4 migrated)
- [ ] Remove `modules/infra/integration/data-factory/` (S10 migrated — keep `integrationRuntime.bicep` + `role-assignment.bicep` for linked IR)
- [ ] Remove `modules/infra/network/private-endpoint/` (all PE refs migrated)
- [ ] Remove `modules/infra/integration/api-management/` (S8 repurposed, no longer needed)
- [ ] Audit remaining `modules/infra/` for other removable modules
- [ ] Keep: scenario-specific helpers, deployment scripts, `public-ip-address`

### Scenario 7 — ACR Task Module Update (LOW PRIORITY)

- [ ] Update ACR task API from `2019-06-01-preview` to latest GA
- [ ] Check if `taskRuns` resource type has a GA API version
- [ ] Validate `bicep build` after update
- [ ] Consider replacing ACR Tasks with GitHub Actions / ADO pipeline tasks

---

## Brainstorm: Function App Code Deployment via Bicep

**Recommendation:** Option E (Run From Package + MI) wrapped in a helper module. See [archive](todo-archive.md) for full analysis.

- [ ] Prototype helper module in S18 or integrate into S14
- [ ] Validate `WEBSITE_RUN_FROM_PACKAGE_BLOB_MI_RESOURCE_ID` works with system-assigned MI on DRCP
- [ ] Test blob container creation via storage account module's `blobServices.containers` param
