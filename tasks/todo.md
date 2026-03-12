# Task Tracker

## Legend

- Detailed AMAVM module tasks: [`amavm/verified-modules/todo.md`](../amavm/verified-modules/todo.md)
- Detailed DRCP test case tasks: [`drcptestcases/todo.md`](../drcptestcases/todo.md)
- Completed tasks archive: [`todo-archive.md`](todo-archive.md)
- Checklist items reference the Module Customization Checklist in `instructions.md`
- `bicep build` = minimum acceptance gate for any change

---

## GAP: New Modules Needed

### Completed

| Module | Status |
|--------|--------|
| GAP-1: Cosmos-DB (document-db/database-account) | Done (v0.1, Karen 18/18) |
| GAP-2: Event-Hubs (event-hub/namespace) | Done (v0.1, Karen 18/18) |
| GAP-3: Redis (cache/redis) | Done (v0.1, Karen 18/18) |
| GAP-4: Notification-Hubs | DEFERRED (no upstream module) |

### Open

**GAP-5: Public IP Address (network/public-ip-address)** — blocked, no upstream module

- [ ] Check if upstream AVM has a public-ip-address module
- [ ] Create AMAVM module with DRCP-compliant defaults
- [ ] Apply Module Customization Checklist
- [ ] `bicep build` passes

**GAP-6: Role Assignment (authorization/role-assignment)** — replaces 5+ local helpers across scenarios

- [ ] Sync `rg-scope/main.bicep` from upstream
- [ ] Apply AMAVM conventions
- [ ] `bicep build` passes
- [ ] Migrate scenario 4, 7, 10, 16 local RBAC helpers → AMAVM

---

## Pending Karen Validation

All implementations below are code-complete and `bicep build` verified. They await Karen's acceptance gate.

| Task | Module(s) | What changed |
|---|---|---|
| FEAT-1/1b | web/site + slot | Slots, `resourceInput<>` types, upstream param sync, FIC auth |
| FEAT-2/3/4/5/6 | container-service/managed-cluster | AutoScaler, agent pools, add-ons, security, flux removal |
| BF-7 | web/site config--appsettings | Queue/table URIs, AppInsights version, storage auth, relay fix |

- [ ] Run Karen validation on web/site + slot
- [ ] Run Karen validation on container-service/managed-cluster
- [ ] Run Karen validation on web/site config--appsettings

---

## Open Build Verification

- [ ] BF-1: cache/redis defaults test — verify `bicep build` on machine with ACR access
- [ ] BF-2: document-db defaults test — verify `bicep build` on machine with ACR access
- [ ] BV-3: Run `buildBicepFiles.ps1 -buildReadme 'True'` and `compareReadMe.ps1` to validate README consistency

### BV-2: Remaining ACR refs (modules not in fork)

| Module | ACR Reference | Status |
|---|---|---|
| container-service/managed-cluster | `br/amavm:avm/res/kubernetes-configuration/extension:0.3.8` | NOT IN FORK — BCP192 expected |
| web/static-site | `br/amavm:res/network/private-dns-zone:0.2.0` | NOT IN FORK — BCP192 expected |

---

## Open Features

### FEAT-9 Phase 2: PreLoadedContent Optimization

Eliminate double `az bicep build` compilation in `buildBicepFiles.ps1` when `buildReadme=True`. Implementation complete, needs testing.

- [x] Implement PreLoadedContent pattern in buildBicepFiles.ps1 (3 locations) and compareReadMe.ps1 (2 locations)
- [ ] Local build test: `./utils/buildBicepFiles.ps1 -modulesSubpath 'res' -buildReadme 'True'`
- [ ] Pipeline test: compare timing to 8-min build / 24-min compare baseline

### FEAT-7: Missing Features vs Upstream

| Feature | Priority |
|---------|----------|
| Static analysis (PSRule) integration | HIGH |
| Deployment history cleanup | MEDIUM |
| Module index publishing | MEDIUM |

- [ ] Evaluate PSRule integration for Azure DevOps pipelines
- [ ] Implement deployment history cleanup utility

### FEAT-8: HTML Pipeline Improvements

- [ ] Add unit tests for `convertreadmetohtml.py`
- [ ] Support Bicep code syntax highlighting in generated HTML

---

## Open Maintenance

### SYNC Phase 2: Documentation Updates

All 28 upstream syncs complete. `upstream.json` files updated for all modules.

- [ ] Update `instructions.md` whitelisted components table (upstream versions column is stale)
- [ ] Document WAF-aligned defaults test pattern in `instructions.md`

### Build Warnings (non-blocking)

| Warning | Modules Affected |
|---------|-----------------|
| `use-recent-api-versions` for `diagnosticSettings@2021-05-01-preview` | cognitive-services, event-hub, container-registry, app-gateway |
| `use-recent-api-versions` for container-registry child modules `@2023-06-01-preview` | 5 child modules |
| `BCP318` null safety | container-registry (3), databricks (2), app-gateway (2) |
| `BCP321` type coercion on PE outputs | app-configuration, data-factory, document-db, event-hub |

---

## Completed Sections (moved to archive)

The following sections are fully complete and can be found in [`todo-archive.md`](todo-archive.md):

- **TECH-DEBT**: TD-01 through TD-18 — all modules 18/18 PASS
- **POLICY**: All 17 modules audited, `evidenceOfNonCompliance` validated, policy IDs added to descriptions
- **SYNC**: All 28 upstream syncs complete (SYNC-01 through SYNC-28), `upstream.json` updated
- **META**: All 86 child module metadata compliance issues fixed (META-1 through META-4)
- **BUILD-FIX**: BF-1 through BF-9 (code fixes complete, some await machine verification)
- **FEAT-6**: All 10 utils bugs fixed
- **FEAT-6b**: Upstream sync for shared utils complete
- **FEAT-9 Phase 1**: Parallel build (no pipeline speedup — agent CPU-bound)
- **SYNC-TD**: `resourceInput<>` adoption gap addressed for 5 modules
