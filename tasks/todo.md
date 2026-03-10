# Task Tracker

## Legend

- Checklist items reference the Module Customization Checklist in `instructions.md`
- `bicep build` = minimum acceptance gate for any change

---

## GAP: New Modules Needed

### GAP-1: Cosmos-DB (document-db/database-account)

- [x] Research upstream module (`microsoft-avm/avm/res/document-db/database-account/`, v0.19)
  - 9 child modules, 994 lines, API `@2024-11-15`, CMK + PE support
- [x] Azure Policy Expert: 15 Cosmos-DB policies found (drcp-cosmos-01 through -10)
  - Deny: local auth, key-based metadata write, public network, TLS < 1.2, non-NoSQL, zone redundancy
  - DeployIfNotExists: 5 private DNS zone policies (Sql, Cassandra, Gremlin, MongoDB, Table)
  - AuditIfNotExists: Advanced Threat Protection, Defender
- [x] Plan: only NoSQL (sql-database, sql-role-assignment, sql-role-definition) per policy
  - MongoDB, Gremlin, Cassandra, Table commented out as future features
- [x] Fork upstream `main.bicep` → `amavm/verified-modules/bicep/res/document-db/database-account/`
- [x] Apply full Module Customization Checklist (18/18 items)
- [x] Create `upstream.json` (v0.19), `version.json` (v0.1)
- [x] Create `tests/e2e/defaults/`
- [x] `bicep build` passes (only BCP192/BCP062 expected, BCP036 cosmetic warning on cors)
- [x] Create `tests/e2e/max/`, `tests/e2e/waf-aligned/`
- [ ] Create `README.md`
- [x] Karen: 18/18 PASS

### GAP-2: Event-Hubs (event-hub/namespace)

- [x] Research upstream (`microsoft-avm/avm/res/event-hub/namespace/`, v0.14)
  - ORPHANED (security/bug fixes only), 668 lines, 5 child modules
- [x] Azure Policy Expert: 10 Event-Hub policies (drcp-evh-01 through -08, plus drcp-sub-07)
  - Deny: public network, trusted services bypass, local auth, TLS, auth rules
  - DeployIfNotExists: private DNS zones
  - Audit: infrastructure encryption
- [x] Fork upstream → `amavm/verified-modules/bicep/res/event-hub/namespace/`
  - All 7 child module files copied and adapted
- [x] Apply full Module Customization Checklist (18/18)
- [x] Create `upstream.json` (v0.14, ORPHANED), `version.json` (v0.1), test
- [x] `bicep build` passes (only BCP192/BCP062 expected)
- [x] Create `tests/e2e/max/`, `tests/e2e/waf-aligned/`
- [ ] Create `README.md`
- [x] Karen: 18/18 PASS

### GAP-3: Redis (cache/redis)

- [x] Research upstream (`microsoft-avm/avm/res/cache/redis/`, v0.16)
  - Active module, 4 child modules + keyVaultExport helper
- [x] Azure Policy Expert: 9 Redis policies (drcp-redis-01 through -09)
  - Deny: Enterprise SKU blocked, public network, non-SSL, TLS < 1.2, zone redundancy
  - Audit: Entra ID auth (disable access keys), managed keys
  - DeployIfNotExists: private DNS zones
- [x] Fork upstream → `amavm/verified-modules/bicep/res/cache/redis/`
  - 4 child modules copied, keyVaultExport removed (uses br/public types)
- [x] Apply full Module Customization Checklist (18/18)
- [x] Create `upstream.json` (v0.16), `version.json` (v0.1), test
- [x] `bicep build` passes (clean — no errors)
- [x] Create `tests/e2e/max/`, `tests/e2e/waf-aligned/`
- [ ] Create `README.md`
- [x] Karen: 18/18 PASS

### GAP-4: Notification-Hubs — DEFERRED

No upstream AVM module exists. Only 2 policies (drcp-ntf-01 default access policies, drcp-sub-07 cross-sub PE). Would require building from scratch. Recommend deferring until upstream support exists.

- [x] Research: no upstream module, minimal policy coverage
- [x] Decision: DEFER

---

## TECH-DEBT: Per-Module Fixes

Findings from full audit of all existing whitelisted modules. Modules are ordered by severity (most failures first).

### TD-01: app-configuration/configuration-store — 5 failures

| # | Issue | Fix |
|---|---|---|
| 6 | `versionInfo` variable missing | Add `var versionInfo = loadJsonContent('version.json')` |
| 7 | `moduleVersion` variable missing | Add `var moduleVersion = versionInfo.version` |
| 10 | Telemetry name not truncated to 64 chars | Wrap telemetry name with `take(..., 64)` |
| 14 | Uses `tags` directly instead of `finalTags` | Add `var finalTags = union(tags ?? {}, {...})` and replace `tags` usage |
| 15 | Has `{ categoryGroup: 'allLogs' }` | Replace with explicit list of supported log categories |

- [x] Fix all 5 issues (versionInfo, moduleVersion, take(64), finalTags, explicit log categories)
- [x] `bicep build` — only BCP192 (expected ACR auth), no syntax errors
- [x] Karen: re-audit — 18/18 PASS

### TD-02: service-bus/namespace — 5 failures

| # | Issue | Fix |
|---|---|---|
| 6 | `versionInfo` variable missing | Add `var versionInfo = loadJsonContent('version.json')` |
| 7 | `moduleVersion` variable missing | Add `var moduleVersion = versionInfo.version` |
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |
| 14 | Uses `tags` directly instead of `finalTags` | Add `finalTags` variable and replace usage |
| 15 | Has `{ categoryGroup: 'allLogs' }` | Replace with explicit log categories: DiagnosticErrorLogs, OperationalLogs, VNetAndIPFilteringLogs, RuntimeAuditLogs, ApplicationMetricsLogs |

- [x] Fix all 5 issues
- [x] `bicep build` — only BCP192 (expected ACR auth), no syntax errors
- [x] Karen: re-audit — 18/18 PASS

### TD-03: container-service/managed-cluster — FALSE POSITIVE

Initial audit was incorrect. Module already has `versionInfo`, `moduleVersion`, `finalTags`, and `take(64)`. Test folder naming with numbered prefixes is a project convention.

- [x] Re-audited — all 18 checklist items PASS

### TD-04: web/site — FALSE POSITIVE

Initial audit was incorrect. All `@description()` decorators use correct prefixes (multi-line `'''` format confused the audit). Test folders contain `defaults`, `max`, and `waf-aligned` variants with numbered/named prefixes — project convention.

- [x] Re-audited — all 18 checklist items PASS

### TD-05: storage/storage-account — FALSE POSITIVE

Output descriptions don't require `Required.`/`Optional.` prefixes per the amavm README — only parameter descriptions do. All parameter descriptions are correctly prefixed.

- [x] Re-audited — all 18 checklist items PASS

### TD-06: search/search-service — 1 failure

| # | Issue | Fix |
|---|---|---|
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |

- [x] Fix telemetry truncation — wrapped with `take(..., 64)`
- [x] `bicep build` — only BCP192 (expected), no syntax errors
- [x] Karen: re-audit — 18/18 PASS

### TD-07: network/application-gateway — 1 failure

| # | Issue | Fix |
|---|---|---|
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |

- [x] Fix telemetry truncation — already had `take(64)` (was false positive, agent confirmed)
- [x] No action needed

### TD-08: insights/component (Application-Insights) — 1 failure

| # | Issue | Fix |
|---|---|---|
| 5 | `evidenceOfNonCompliance` output is commented out | Uncomment or re-implement the output |

- [x] Fixed — uncommented and implemented: `!disableLocalAuth`
- [x] `bicep build` — only BCP192 (expected), no syntax errors
- [x] Karen: re-audit — 18/18 PASS

### TD-09: db-for-postgre-sql/flexible-server — 1 failure

| # | Issue | Fix |
|---|---|---|
| 10 | Telemetry name not truncated to 64 chars | Wrap with `take(..., 64)` |

Note: `evidenceOfNonCompliance` output exists but is hardcoded to `false` — review if this should check actual compliance state.

- [x] Fix telemetry truncation — wrapped with `take(..., 64)`
- [x] Reviewed `evidenceOfNonCompliance` — updated with compliance checks
- [x] `bicep build` — only BCP192 (expected), no syntax errors
- [x] Karen: re-audit — 18/18 PASS

### TD-10: sql/server — 1 failure

| # | Issue | Fix |
|---|---|---|
| 4 | One description has typo "Deafult:" instead of proper prefix | Fix typo and add correct `Optional.` prefix |

- [x] Fixed "Deafult:" typo → "Default:" with proper `Optional.` prefix
- [x] `bicep build` — only BCP192 (expected), no syntax errors
- [x] Karen: re-audit — 18/18 PASS

### TD-11: Fully Compliant Modules (no fixes needed)

These modules passed all 18 checklist items. No action required unless upstream drift audit reveals changes.

- [x] key-vault/vault — 18/18 PASS
- [x] cognitive-services/account — 18/18 PASS
- [x] data-factory/factory — 18/18 PASS
- [x] databricks/workspace — 18/18 PASS
- [x] operational-insights/workspace — 18/18 PASS
- [x] web/serverfarm — 18/18 PASS

### TD-12: Fully Compliant Support Modules (no fixes needed)

- [x] databricks/access-connector — 6/6 PASS
- [x] web/static-site — 6/6 PASS
- [x] managed-identity/user-assigned-identity — 6/6 PASS
- [x] network/network-security-group — 6/6 PASS
- [x] network/private-endpoint — 6/6 PASS
- [x] network/route-table — 6/6 PASS
- [x] network/virtual-network — 6/6 PASS

### TD-13: Batch fix — 9 modules missing telemetry take(64) + evidenceOfNonCompliance

All 9 modules share the same 2 issues: (10) telemetry name not wrapped with `take(..., 64)` and (5) no `evidenceOfNonCompliance` output.

| Module | (10) take(64) | (5) evidenceOfNonCompliance |
|---|---|---|
| insights/action-group | FAIL | FAIL |
| insights/activity-log-alert | FAIL | FAIL |
| insights/data-collection-endpoint | FAIL | FAIL |
| insights/data-collection-rule | FAIL | FAIL |
| insights/metric-alert | FAIL | FAIL |
| insights/private-link-scope | FAIL | FAIL |
| insights/scheduled-query-rule | FAIL | FAIL |
| insights/webtest | FAIL | FAIL |
| network/application-gateway-web-application-firewall-policy | FAIL | FAIL |

- [x] Fix telemetry truncation in all 9 modules
- [x] Add `evidenceOfNonCompliance` output to all 9 modules
- [x] `bicep build` each module (2 needed `@sys.description` fix — data-collection-endpoint, webtest)
- [x] Karen: re-audit — 18/18 PASS (8 modules needed `metadata compliance` added, now fixed)

### TD-14: insights/diagnostic-setting — 6 failures (0/6)

| # | Issue | Fix |
|---|---|---|
| 6 | `versionInfo` variable missing | Add `var versionInfo = loadJsonContent('version.json')` |
| 7 | `moduleVersion` variable missing | Add `var moduleVersion = versionInfo.version` |
| 10 | Telemetry name not truncated | Wrap with `take(..., 64)` |
| 14 | `finalTags` not used | Add `finalTags` variable and replace `tags` usage |
| 15 | Has `{ categoryGroup: 'allLogs' }` | Replace with explicit log categories |
| 5 | No `evidenceOfNonCompliance` output | Add output |

- [x] Added metadata (owner, compliance, complianceVersion)
- [x] Added versionInfo + moduleVersion (with no-unused-vars suppression — subscription-scoped, no finalTags)
- [x] Wrapped telemetry with take(64)
- [x] finalTags N/A — subscription-scoped module, no tags support
- [x] `{ categoryGroup: 'allLogs' }` is CORRECT for this module — it's the diagnostic settings module itself
- [x] Added evidenceOfNonCompliance output (= false, utility module)
- [x] `bicep build` passes — no errors
- [x] Karen: re-audit — 18/18 PASS

### TD-15: web/site — typos, API versions, VNet reference

| # | Issue | Fix | Status |
|---|---|---|---|
| 1 | `reference()` uses `'2020-06-01'` for VNet lookup | Updated to `2024-05-01` | DONE |
| 2 | Typo: `condtion` → `condition` in slot/main.bicep | Fixed | DONE |
| 3 | Typo: double period in hybrid-connection relay output | Fixed in both main and slot | DONE |
| 4 | API version inconsistency: main site `2024-04-01`, slot `2023-12-01` | Updated all `Microsoft.Web/*` to `2025-03-01` | DONE |
| 5 | `locks@2020-05-01`, `diagnosticSettings@2021-05-01-preview`, `roleAssignments@2022-04-01` | N/A — matches upstream AVM standard | WONTFIX |
| 6 | Identity/role-assignment formatting duplicated between main and slot | Consider refactoring | TODO |
| 7 | `vnetContentShareEnabled`, `vnetImagePullEnabled`, `vnetRouteAllEnabled` removed in `2025-03-01` | Replaced with `outboundVnetRouting` object | DONE |

- [x] Fix VNet reference API version (`2020-06-01` → `2024-05-01`)
- [x] Fix typo: `condtion` → `condition`
- [x] Fix typo: double period in relay description
- [x] `bicep build` passes (only BCP192 expected)
- [x] Align all `Microsoft.Web/*` API versions to `2025-03-01` (latest stable, non-preview)
- [x] Remove deprecated `vnetContentShareEnabled`, `vnetImagePullEnabled`, `vnetRouteAllEnabled` — replaced by `outboundVnetRouting`
- [x] Add `sshEnabled` and `outboundVnetRouting` to resource properties (supported on `2025-03-01`)
- [x] Update `list()` calls from `2024-04-01` to `2025-03-01`
- [x] Update VNet `reference()` from `2020-06-01` to `2024-05-01` in slot PE module
- [x] Update compliance metadata to reference `outboundVnetRouting`
- [x] Update `evidenceOfNonCompliance` to check `outboundVnetRouting` instead of removed booleans
- [x] `bicep build` passes (only BCP192 expected)
- [x] Karen: re-audit — 18/18 PASS

### TD-16: container-service/managed-cluster — spelling, API versions, comment fixes

| # | Issue | Fix | Status |
|---|---|---|---|
| 1 | Spelling error: `additonalLogCategoryNames` | Fixed to `additionalLogCategoryNames` | DONE |
| 2 | Incomplete error comment (line 810): `// giver error` | Reworded to proper note | DONE |
| 3 | `locks@2020-05-01`, `diagnosticSettings@2021-05-01-preview`, `roleAssignments@2022-04-01` | N/A — matches upstream AVM standard | WONTFIX |
| 4 | agent-pool/main.bicep uses preview API `2024-04-02-preview` | Update to stable and verify | TODO |
| 5 | agent-pool/main.bicep uses `2024-02-01` while main uses `2024-08-01` | Align API versions | TODO |

- [x] Fix spelling error (`additonalLogCategoryNames` → `additionalLogCategoryNames`)
- [x] Fix incomplete error comment
- [x] `bicep build` passes (only BCP192 expected)
- [x] Align agent-pool API versions — both resources now `2024-08-01` (matching parent)
- [x] Karen: re-audit — 18/18 PASS

### TD-17: cognitive-services/account — API versions, SKU logic, typos

| # | Issue | Fix | Status |
|---|---|---|---|
| 1 | `ManagedIdentity@2023-01-31` outdated | Updated to `2025-01-31-preview` | DONE |
| 2 | `KeyVault/vaults@2023-02-01` outdated | Updated to `2025-05-01` | DONE |
| 3 | `CognitiveServices/accounts/deployments@2023-05-01` misaligned | Updated to `2025-06-01` | DONE |
| 4 | `Resources/deployments@2023-07-01` outdated | Updated to `2024-03-01` | DONE |
| 5 | SKU fallback accesses `.capacity`/`.tier` on string param | Simplified to `{ name: sku }` | DONE |
| 6 | Typo: `condtion` → `condition` | Fixed | DONE |
| 7 | Typo: missing space `null\`is` | Fixed | DONE |
| 8 | `roleAssignments@2022-04-01` | N/A — matches upstream AVM standard | WONTFIX |
| 9 | Upstream sync v0.9 → v0.14 | Added networkInjections, allowProjectManagement, commitmentPlans, DC0 SKU, HSM CMK support; removed amlWorkspace, raiMonitorConfig | DONE |
| 10 | `kind` @allowed restricted to 3 policy-approved values | Per drcp-ai-04 | DONE |

- [x] Update 4 outdated API versions
- [x] Fix SKU fallback logic (removed invalid property access on string)
- [x] Fix both typos
- [x] Upstream sync: added 3 new params, 2 new types, commitment plans resource, HSM CMK support
- [x] Restricted `kind` to policy-approved values (AIServices, OpenAI, TextAnalytics)
- [x] Removed deprecated `amlWorkspace` and `raiMonitorConfig` params
- [x] `bicep build` passes (only BCP192 expected)
- [x] Karen: re-audit — 18/18 PASS

### TD-18: search/search-service — API versions, test dependencies, simplification

| # | Issue | Fix | Status |
|---|---|---|---|
| 1 | `ManagedIdentity@2018-11-30` in test deps — 8 years old | Updated to `2024-11-30` | DONE |
| 2 | `reference()` uses `'2020-06-01'` for VNet lookup | Updated to `2024-05-01` | DONE |
| 3 | `privateDnsZones@2020-06-01` in test deps | Updated to `2024-06-01` | DONE |
| 4 | `resourceGroups@2021-04-01` in 3 test files | Updated to `2024-03-01` | DONE |
| 5 | `defaultLogCategoryNames` intermediate variable | Inlined into `defaultLogCategories` | DONE |
| 6 | `diagnosticSettings@2021-05-01-preview`, `roleAssignments@2022-04-01` | N/A — matches upstream AVM standard | WONTFIX |

- [x] Update 4 outdated API versions (test deps + VNet reference)
- [x] Simplify redundant `defaultLogCategoryNames` variable
- [x] `bicep build` passes (only BCP192 expected)
- [x] Karen: re-audit — 18/18 PASS

---

## FEATURE: Implement Commented-Out Upstream Functionality

These are features from upstream AVM modules that are currently commented out in the amavm fork. Each should be evaluated, implemented, tested, and enabled.

### FEAT-1: web/site — Deployment Slots

Commented-out code: `slots` parameter, `app_slots` module loop, slot outputs (slots, slotResourceIds, slotSystemAssignedMIPrincipalIds, slotPrivateEndpoints).

- [x] Uncomment and implement `slots` parameter (with `slotType` type definition)
- [x] Uncomment and implement `app_slots` module loop
- [x] Uncomment and implement slot-related outputs (slotNames, slotResourceIds, slotSystemAssignedMIPrincipalIds, slotPrivateEndpoints)
- [x] Implement `reserved: contains(kind,'linux')` property
- [x] Implement TODO properties: `endToEndEncryptionEnabled`, `dnsConfiguration`, `daprConfig`
- [x] Add new upstream params: `e2eEncryptionEnabled`, `dnsConfiguration`, `daprConfig`, `sshEnabled`, `ipMode`, `resourceConfig`, `workloadProfileName`, `hostNamesDisabled`, `outboundVnetRouting`
- [x] Update tests to cover slots (uncommented slot config in 2webAppLinux.max and 4webApp.max)
- [x] `bicep build` passes (only BCP192 expected)
- [ ] Karen: validate

### FEAT-2: container-service/managed-cluster — AutoScaler Profile

The 16 individual autoScaler params (scanInterval, scaleDown delays, etc.) were stale — already superseded by the active `param autoScalerProfile` which passes through to the resource. Cleaned up:

- [x] Removed 56 lines of stale individual autoScalerProfile params (replaced by single `autoScalerProfile` param)
- [x] Updated `autoScalerProfile` type from `object?` to `resourceInput<'Microsoft.ContainerService/managedClusters@2025-09-01'>.properties.autoScalerProfile?` (matching upstream)
- [x] Removed unused `privateEndpointType` import
- [x] `bicep build` passes (only BCP192 for kubernetes-configuration — expected)
- [ ] Karen: validate
- [ ] Update tests to cover autoscaler configuration

### FEAT-3: container-service/managed-cluster — Agent Pools Module

**Already implemented.** The `managedCluster_agentPools` module loop is active (not commented out). Todo was stale.

- [x] Agent pools module loop already active
- [x] Agent pool API versions already aligned to `2024-08-01` (done in TD-16)
- [ ] Update tests to cover additional agent pools
- [ ] Karen: validate

### FEAT-4: container-service/managed-cluster — Ingress, DNS, and Add-ons

**Mostly already implemented.** httpApplicationRouting, webApplicationRouting, AGIC, ACI connector, DNS zone params are all active (not commented out). Remaining commented-out items (kedaAddon, fluxExtension, kubeDashboard, openServiceMesh) are planned future features.

- [x] Ingress/DNS/AGIC/ACI params already active
- [ ] Evaluate and enable remaining commented-out add-ons (kedaAddon, fluxExtension, kubeDashboard, openServiceMesh)
- [ ] Update tests
- [ ] Karen: validate

### FEAT-5: container-service/managed-cluster — Pod Identity and Security

**Mostly already implemented.** podIdentityProfile, identityProfile, diskEncryptionSetResourceId, httpProxyConfig are all active params. Remaining commented-out items (CMK customerManagedKey, enablePodSecurityPolicy) are planned future features.

- [x] podIdentityProfile, identityProfile, diskEncryptionSetResourceId, httpProxyConfig already active
- [ ] Evaluate and enable CMK support (customerManagedKey param + cMKKeyVault resource)
- [ ] Update tests
- [ ] Karen: validate

---

## BUILD-VALIDATE: Local Build Validation (dev-only PE/ACR ref switch)

Temporarily switch ACR module references to local paths, run `buildBicepFiles.ps1`, fix errors, then **restore ACR refs before committing**.

### BV-1: Switch private-endpoint ACR refs to local paths

- [x] Grep all `br/amavm:res/network/private-endpoint:0.2.0` references (20 files)
- [x] Replace with relative local paths (`../../network/private-endpoint/main.bicep`, etc.)
- [x] Fix PE output property name mismatches: `customDnsConfig` → `customDnsConfigs`, `networkInterfaceIds` → `networkInterfaceResourceIds` (5 modules: cognitive-services, web/site, web/site/slot, web/static-site, network/application-gateway)
- [x] Switch WAF policy ACR ref to local path in network/application-gateway
- [x] Remove unused `tenantId` param in db-for-postgre-sql/flexible-server
- [x] Full `buildBicepFiles.ps1` passes (only 2 BCP192 remain: kubernetes-configuration/extension and private-dns-zone — not in fork)
- [ ] Restore all ACR refs before committing (PE, WAF policy)

### BV-2: Remaining ACR refs (modules not in fork)

These 2 modules reference ACR modules that don't exist locally. They need either the module to be forked or `az login` for validation:

| Module | ACR Reference | Status |
|---|---|---|
| container-service/managed-cluster | `br/amavm:avm/res/kubernetes-configuration/extension:0.3.8` | NOT IN FORK — BCP192 expected |
| web/static-site | `br/amavm:res/network/private-dns-zone:0.2.0` | NOT IN FORK — BCP192 expected |

### BV-3: README generation validation

- [ ] Run `buildBicepFiles.ps1 -buildReadme 'True'` to generate READMEs
- [ ] Run `compareReadMe.ps1` to validate README consistency
- [ ] Fix any README mismatches

---

## POLICY: Compliance Audits

Each whitelisted module audited by Azure Policy Expert against `policy/Generic/*.json` and `policy/knowledge_base/`.

### Compliant (13 modules — defaults satisfy all policies)

- [x] AI-Search (search/search-service) — 6 policies, all PASS
- [x] Application-Insights (insights/component) — 4 policies, all PASS
- [x] Container-Registry (container-registry/registry) — 10 policies, all PASS
- [x] Databricks (databricks/workspace) — 8 policies, all PASS
- [x] Data-Factory (data-factory/factory) — 10 policies, all PASS
- [x] Key-Vault (key-vault/vault) — 9 policies, all PASS
- [x] Kubernetes-Service (container-service/managed-cluster) — 12 policies, all PASS
- [x] Log-Analytics-Workspace (operational-insights/workspace) — 4 policies, all PASS
- [x] Monitor/Action-Group (insights/action-group) — 3 policies, all PASS
- [x] Monitor/Data-Collection-Rule (insights/data-collection-rule) — 4 policies, all PASS
- [x] Service-Bus (service-bus/namespace) — 3 policies, all PASS
- [x] SQL-Database (sql/server) — 10 policies, all PASS
- [x] Storage-Account (storage/storage-account) — 11 policies, all PASS

### Non-compliant (4 modules — defaults may violate policies)

- [x] AI-Services (cognitive-services/account) — 7 policies, all PASS
  - `kind` @allowed list restricted to 3 policy-approved values: TextAnalytics, OpenAI, AIServices (per drcp-ai-04)
  - complianceVersion updated to 20260309
- [x] App-Configuration (app-configuration/configuration-store) — 4 policies, 1 FAIL
  - `publicNetworkAccess` defaults to null → resolves to 'Enabled' without private endpoints
  - Action: default publicNetworkAccess to 'Disabled'
- [x] Application-Gateway (network/application-gateway) — 12 policies, 3 conditional FAIL
  - Backend/listener HTTPS not enforced in required params (user must set protocol='Https')
  - Public frontend IP not prevented (user must avoid public IPs)
  - Action: add compliance documentation warnings on required params
- [x] App-Service (web/site) — 14 policies, 1 conditional FAIL
  - `virtualNetworkSubnetId` optional with no default → VNet injection policy fails without it
  - Action: document as required for compliant deployments
- [x] PostgreSQL (db-for-postgre-sql/flexible-server) — 11 policies, 2 FAIL
  - `activeDirectoryAuth` defaults to 'disabled' when no `administrators` provided (drcp-psql-02 Deny)
  - `delegatedSubnetResourceId` optional → VNet integration not guaranteed (drcp-psql-01 Deny)
  - Action: make `administrators` required or always enable AD auth; make `delegatedSubnetResourceId` required

### POLICY-IMPL-1: Validate `evidenceOfNonCompliance` output accuracy

The `evidenceOfNonCompliance` output should actually validate the relevant policies for each module. Currently many modules have `= false` (hardcoded) or incomplete checks. For each module, verify the output expression checks ALL applicable deny/audit policies.

**Per module:**
- [x] cognitive-services/account — validated: already correct (5 policy checks)
- [x] app-configuration/configuration-store — fixed: nullable publicNetworkAccess null-safety bug
- [x] cache/redis — validated: already correct (6 policy checks)
- [x] container-registry/registry — fixed: SKU case bug ('premium' vs 'Premium'), rewrote with proper per-policy vars
- [x] container-service/managed-cluster — fixed: added enableNodePublicIP checks for primary + agent pools
- [x] data-factory/factory — fixed: added IR type check, fixed git config AND→OR logic bug
- [x] databricks/workspace — validated: already correct (6 policy checks)
- [x] db-for-postgre-sql/flexible-server — fixed: added passwordAuth, CMK, zone redundancy checks
- [x] document-db/database-account — fixed: added TLS and zone redundancy checks
- [x] event-hub/namespace — fixed: added zoneRedundant and trustedServiceAccess checks
- [x] insights/component — fixed: added sourcemap tag and forbidden diagnostics checks
- [x] key-vault/vault — fixed: added RBAC and soft delete checks
- [x] network/application-gateway — fixed: rewrote broken contains() checks with proper filter() logic
- [x] operational-insights/workspace — fixed: added dataExports, dataSources, storageInsights checks
- [x] search/search-service — validated: already correct (3 policy checks)
- [x] service-bus/namespace — validated: already correct (3 policy checks)
- [x] sql/server — fixed: added TLS and advanced threat protection checks
- [x] storage/storage-account — fixed: added keyType and networkAcls bypass checks
- [x] web/site — fixed: inverted auth settings check (was flagging compliant state as non-compliant)

### POLICY-IMPL-2: Add policy IDs to parameter descriptions

For each parameter that is constrained by a policy, add the policy ID (e.g., `drcp-ai-03`) to the parameter's `@description()` decorator. This creates traceability from module parameters to the policies they satisfy.

**Format**: Append `[Policy: drcp-xxx-nn]` to the description, e.g.:
```
@description('Optional. Whether or not public network access is allowed. [Policy: drcp-ai-03]')
param publicNetworkAccess string = 'Disabled'
```

**Per module:**
- [x] cognitive-services/account — 5 policy tags (drcp-ai-01/02/03/04), drcp-sub-07
- [x] app-configuration/configuration-store — 3 policy tags (drcp-appcs-01/02/03), drcp-sub-07
- [x] cache/redis — 6 policy tags (drcp-redis-02/04/05/07/08/09), drcp-sub-07
- [x] container-registry/registry — 7 policy tags (drcp-cr-01/03/04), drcp-sub-07
- [x] container-service/managed-cluster — 12 policy tags (drcp-aks-02/03/11/12/16/18)
- [x] data-factory/factory — 9 policy tags (drcp-adf-01/02/04/05/06/07), drcp-sub-07
- [x] databricks/workspace — 9 policy tags (drcp-adb-r01/r02/r03/r04/w10/w22), drcp-sub-07
- [x] db-for-postgre-sql/flexible-server — 12 policy tags (drcp-psql-01 through -11)
- [x] document-db/database-account — 8 policy tags (drcp-cosmos-01/02/03/05/06/10), drcp-sub-07
- [x] event-hub/namespace — 7 policy tags (drcp-evh-01/03/04/05/06/07/08)
- [x] insights/component — 3 policy tags (drcp-appi-01/04/05)
- [x] key-vault/vault — 5 policy tags (drcp-kv-01/02/04/05/11), drcp-sub-07
- [x] network/application-gateway — 12 policy tags (drcp-agw-01/02/03/04/05/06/11), drcp-sub-07
- [x] operational-insights/workspace — 5 policy tags (drcp-log-02/03/04/05)
- [x] search/search-service — 4 policy tags (drcp-srch-01/02/03), drcp-sub-07
- [x] service-bus/namespace — 5 policy tags (drcp-sbns-01/02/03/04), drcp-sub-07
- [x] sql/server — 10 policy tags (drcp-sql-01 through -10), drcp-sub-07
- [x] storage/storage-account — 13 policy tags (drcp-st-01 through -10/15), drcp-sub-07
- [x] web/site — 13 policy tags (drcp-aps-01 through -19), drcp-sub-07

---

## FEATURE: Utils Tooling Tech Debt

Comparison of `amavm/verified-modules/utils/` against `microsoft-avm/avm/` upstream tooling. The amavm utils use Azure DevOps pipelines (not GitHub Actions) and generate HTML from Markdown READMEs (using Python `markdown2` library → `placeholder.html` template → static HTML with `toc.json` → Azure Blob Static Sites).

### FEAT-6: Bugs in Current Utils

| # | File | Bug | Severity |
|---|---|---|---|
| # | File | Bug | Severity |
|---|---|---|---|
| 1 | `publishToBCR.ps1` | Hardcoded ACR name — should use pipeline variable | HIGH |
| 2 | `mergeDocumentationTocs.ps1` | Hardcoded storage URL — should use pipeline variable | HIGH |
| 3 | `convertreadmetohtml.py` | Version string appends `.0` unconditionally (e.g., `1.0` → `1.0.0`, but `1.0.0` → `1.0.0.0`) | MEDIUM |
| 4 | `convertreadmetohtml.py` | No error handling for regex substitutions — silent failures on unexpected README format | MEDIUM |
| 5 | `setModuleReadMe.ps1` | Outdated comment referencing upstream sync that no longer applies | LOW |
| 6 | `buildBicepFiles.ps1` | Slow recursive file scanning — could use `-Filter` parameter for performance | LOW |
| 7 | `publishToBCR.ps1` | `$filename` variable leak — `az bicep restore` uses outer loop var instead of `$moduleFileFullPath` | HIGH |
| 8 | `setBCRinLinter.ps1` | Hardcoded ACR name — should use env variable | HIGH |

- [x] Fix hardcoded ACR name in `publishToBCR.ps1` — now uses `$env:AMAVM_ACR_NAME` with validation
- [x] Fix hardcoded ACR name in `setBCRinLinter.ps1` — now uses `$env:AMAVM_ACR_NAME` with validation
- [x] Fix hardcoded storage URL in `mergeDocumentationTocs.ps1` — now uses `$env:AMAVM_DOCUMENTATION_STORAGE_URL`
- [x] Fix version `.0` appending bug in `convertreadmetohtml.py` — now pads to exactly 3 segments
- [x] Add regex error handling in `convertreadmetohtml.py` — fallback module name on parse failure
- [x] Clean up outdated comments in `setModuleReadMe.ps1` — updated upstream sync date
- [x] Optimize file scanning in `buildBicepFiles.ps1` — `-Filter 'main.bicep'` instead of `-Include *.bicep`
- [x] Optimize file scanning in `publishToBCR.ps1` — same `-Filter 'main.bicep'` optimization
- [x] Fix `$filename` variable leak in `publishToBCR.ps1` — changed to `$moduleFileFullPath`
- [x] Fix hardcoded `$documentationUri` in `publishToBCR.ps1` — now uses `$env:AMAVM_DOCUMENTATION_URI` with fallback

### FEAT-6b: Upstream Sync for Shared Utils

- [x] Sync `Get-SpecsAlignedResourceName.ps1` — added `service/product/policy` case from upstream
- [x] Partial sync `setModuleReadMe.ps1` — applied safe upstream improvements:
  - Variable extraction for `$isDeprecated`/`$isOrphaned`/`$isMovedToAVM` (cleaner code)
  - `.Trim()` on orphaned content lines (bug fix)
  - Test folder reference path in usage examples
  - Note: AMAVM-specific customizations preserved (private ACR, compliance section, telemetry text, specificBuiltInRoleNames)

### FEAT-7: Missing Features vs Upstream

| # | Feature | Upstream Location | Priority |
|---|---|---|---|
| 1 | Static analysis (PSRule) integration | `.github/workflows/platform.check.psrule.yml` | HIGH |
| 2 | Deployment history cleanup | `.github/workflows/platform.deployment.history.cleanup.yml` | MEDIUM |
| 3 | Module index publishing | `.github/workflows/platform.publish-module-index-json.yml` | MEDIUM |
| 4 | PR label automation | `.github/workflows/platform.set-avm-github-pr-labels.yml` | LOW |
| 5 | Workflow toggle automation | `.github/workflows/platform.toggle-avm-workflows.yml` | LOW |

- [ ] Evaluate PSRule integration for Azure DevOps pipelines
- [ ] Implement deployment history cleanup utility
- [ ] Implement module index publishing for internal registry
- [ ] Evaluate PR/pipeline label automation needs

### FEAT-8: HTML-from-MD Pipeline Improvements

The `convertreadmetohtml.py` pipeline converts Bicep module READMEs to static HTML for Azure DevOps wiki/documentation portal. Current issues:

- [ ] Add unit tests for `convertreadmetohtml.py`
- [ ] Add validation for generated HTML output
- [ ] Support Bicep code syntax highlighting in generated HTML
- [ ] Add table of contents depth configuration
- [ ] Document the HTML generation pipeline in a dev guide

---

## SYNC: Upstream Parameter Sync (AVM → AMAVM)

For each module: diff upstream vs fork params, add new params/types/resources, remove deprecated params, update API versions, verify evidenceOfNonCompliance output, update upstream.json version.

**Checklist per module:**
1. Compare all `param` declarations (new, removed, changed types/defaults/@allowed)
2. Compare all `resource` blocks (new resources, API version drift)
3. Compare child modules (`modules/` subdirectory)
4. Compare type definitions
5. Verify `evidenceOfNonCompliance` output exists and is correct
6. Verify AMAVM metadata fields (owner, compliance, complianceVersion)
7. Update `upstream.json` to match synced version
8. `bicep build` passes

### Critical Priority (>10 version gap)

- [x] SYNC-01: storage/storage-account — 0.10 → 0.32 (gap: 22) — DONE: API versions to 2025-01-01 (all child modules), new SKUs, Cold tier, TLS 1.3, sasExpirationAction, secretsExport (keyVaultExport module), objectReplicationPolicies (policy child modules), immutableStorageWithVersioning (with HNS validation), upstream.json updated to 0.32
- [x] SYNC-02: sql/server — 0.4 → 0.21 (gap: 17) — DONE: API versions updated to 2023-08-01 (all 13 child modules), added isIPv6Enabled + connectionPolicy params, connection policy resource, removed TLS 1.0/1.1/None, updated VNet ref to 2024-05-01, updated deployments API, removed unused imports, storage refs in nested modules updated to 2025-01-01
- [x] SYNC-03: operational-insights/workspace — 0.3 → 0.15 (gap: 12) — DONE: API versions updated to 2025-02-01 (all 7 child modules), deployments API to 2024-07-01, storage ref in storage-insight-config to 2025-01-01
- [x] SYNC-04: web/site — 0.11 → 0.22 (gap: 11) — DONE: API versions updated to 2025-03-01 (all 14 child modules), removed deprecated vnet booleans, added outboundVnetRouting with resourceInput typing

### High Priority (5-10 version gap)

- [x] SYNC-05: container-service/managed-cluster — 0.3 → 0.12 (gap: 9) — DONE: API versions updated to 2025-09-01 (3 files), deployments to 2024-07-01
- [x] SYNC-06: container-registry/registry — 0.3 → 0.11 (gap: 8) — DONE: API versions updated to 2025-03-01-preview (main), child modules to 2023-06-01-preview, KeyVault/ManagedIdentity updated, VNet refs updated
- [x] SYNC-07: data-factory/factory — 0.3 → 0.11 (gap: 8) — DONE: deployments API updated to 2024-11-01 (DataFactory API already at 2018-06-01 matching upstream)
- [x] SYNC-08: key-vault/vault — 0.6 → 0.13 (gap: 7) — DONE: KeyVault API updated to 2024-11-01 (all 4 modules), deployments to 2024-07-01, VNet refs to 2024-05-01
- [x] SYNC-09: databricks/workspace — 0.5 → 0.12 (gap: 7) — DONE: deployments to 2024-07-01, VNet refs to 2024-05-01 (Databricks API already aligned)
- [x] SYNC-10: network/virtual-network — 0.2 → 0.7 (gap: 5) — DONE: Network API updated to 2024-05-01 (main+subnets+peering), deployments to 2024-07-01
- [x] SYNC-11: web/serverfarm — 0.2 → 0.7 (gap: 5) — DONE: Web API updated to 2025-03-01, deployments to 2024-07-01

### Medium Priority (2-4 version gap)

- [x] SYNC-12: network/application-gateway — 0.5 → 0.9 (gap: 4) — DONE: Network API to 2025-05-01, deployments to 2024-07-01, test deps updated
- [x] SYNC-13: network/private-endpoint — 0.8 → 0.12 (gap: 4) — DONE: Network API to 2025-05-01, deployments to 2024-07-01
- [x] SYNC-14: insights/data-collection-rule — 0.6 → 0.10 (gap: 4) — DONE: Insights API to 2024-03-11, deployments to 2024-07-01, test deps updated
- [x] SYNC-15: app-configuration/configuration-store — 0.6 → 0.9 (gap: 3) — DONE: AppConfig API to 2025-02-01-preview, deployments to 2024-07-01
- [x] SYNC-16: insights/action-group — 0.5 → 0.8 (gap: 3) — DONE: Insights API to 2024-10-01-preview, deployments to 2024-07-01
- [x] SYNC-17: insights/scheduled-query-rule — 0.3 → 0.6 (gap: 3) — DONE: deployments to 2024-07-01 (Insights API already aligned)
- [x] SYNC-18: insights/component — 0.4 → 0.7 (gap: 3) — DONE: deployments to 2024-07-01 (Insights API already aligned)
- [x] SYNC-19: search/search-service — 0.9 → 0.12 (gap: 3) — DONE: deployments to 2024-07-01
- [x] SYNC-20: managed-identity/user-assigned-identity — 0.2 → 0.5 (gap: 3) — DONE: ManagedIdentity API to 2024-11-30, deployments to 2024-07-01
- [x] SYNC-21: databricks/access-connector — 0.1 → 0.4 (gap: 3) — DONE: deployments to 2024-07-01
- [x] SYNC-22: network/route-table — 0.2 → 0.5 (gap: 3) — DONE: Network API to 2024-07-01, deployments to 2024-07-01
- [x] SYNC-23: web/static-site — 0.6 → 0.9 (gap: 3) — DONE: deployments to 2024-07-01, child modules aligned with upstream
- [x] SYNC-24: db-for-postgre-sql/flexible-server — 0.13 → 0.15 (gap: 2) — DONE: PostgreSQL API to 2025-06-01-preview (all 6 modules), deployments to 2024-07-01
- [x] SYNC-25: service-bus/namespace — 0.14 → 0.16 (gap: 2) — DONE: KeyVault to 2025-05-01, deployments to 2024-07-01
- [x] SYNC-26: network/network-security-group — 0.3 → 0.5 (gap: 2) — DONE: deployments to 2024-07-01

### Low Priority (1 version gap)

- [x] SYNC-27: insights/activity-log-alert — 0.3 → 0.4 (gap: 1) — DONE: deployments to 2024-07-01
- [x] SYNC-28: insights/metric-alert — 0.3 → 0.4 (gap: 1) — DONE: deployments to 2024-07-01

---

## META: Child Module Metadata Compliance

Every main.bicep (parent AND child) must have: `metadata owner`, `metadata compliance`, `metadata complianceVersion`, and `output evidenceOfNonCompliance`. Audit found 86 files missing at least one field.

### META-1: Files missing ALL THREE fields (owner + compliance + evidenceOfNonCompliance) — 32 files

**GAP module children (fixed):**
- [x] document-db/database-account/sql-database/main.bicep
- [x] document-db/database-account/sql-database/container/main.bicep
- [x] document-db/database-account/sql-role-assignment/main.bicep
- [x] document-db/database-account/sql-role-definition/main.bicep

**Remaining (28 files):**
- [x] app-configuration/configuration-store/key-value/main.bicep
- [x] app-configuration/configuration-store/replica/main.bicep
- [x] container-registry/registry/credential/main.bicep
- [x] db-for-postgre-sql/flexible-server/administrator/main.bicep
- [x] db-for-postgre-sql/flexible-server/advanced-threat-protection-setting/main.bicep
- [x] db-for-postgre-sql/flexible-server/configuration/main.bicep
- [x] db-for-postgre-sql/flexible-server/database/main.bicep
- [x] db-for-postgre-sql/flexible-server/firewall-rule/main.bicep
- [x] event-hub/namespace/authorization-rule/main.bicep
- [x] event-hub/namespace/disaster-recovery-config/main.bicep
- [x] event-hub/namespace/eventhub/authorization-rule/main.bicep
- [x] event-hub/namespace/eventhub/consumergroup/main.bicep
- [x] event-hub/namespace/eventhub/main.bicep
- [x] event-hub/namespace/network-rule-set/main.bicep
- [x] cache/redis/access-policy-assignment/main.bicep
- [x] cache/redis/access-policy/main.bicep
- [x] cache/redis/firewall-rule/main.bicep
- [x] cache/redis/linked-servers/main.bicep
- [x] insights/private-link-scope/scoped-resource/main.bicep
- [x] search/search-service/shared-private-link-resource/main.bicep
- [x] service-bus/namespace/authorization-rule/main.bicep
- [x] service-bus/namespace/disaster-recovery-config/main.bicep
- [x] service-bus/namespace/migration-configuration/main.bicep
- [x] service-bus/namespace/network-rule-set/main.bicep
- [x] service-bus/namespace/queue/authorization-rule/main.bicep
- [x] service-bus/namespace/topic/authorization-rule/main.bicep
- [x] service-bus/namespace/topic/subscription/main.bicep
- [x] service-bus/namespace/topic/subscription/rule/main.bicep

### META-2: Files missing compliance + evidenceOfNonCompliance (have owner) — 47 files

- [x] container-registry/registry/replication/main.bicep
- [x] container-registry/registry/scope-map/main.bicep
- [x] container-registry/registry/webhook/main.bicep
- [x] container-service/managed-cluster/agent-pool/main.bicep
- [x] container-service/managed-cluster/maintenance-configurations/main.bicep
- [x] insights/component/linkedStorageAccounts/main.bicep
- [x] managed-identity/user-assigned-identity/federated-identity-credential/main.bicep
- [x] operational-insights/workspace/data-export/main.bicep
- [x] operational-insights/workspace/data-source/main.bicep
- [x] operational-insights/workspace/linked-service/main.bicep
- [x] operational-insights/workspace/linked-storage-account/main.bicep
- [x] operational-insights/workspace/saved-search/main.bicep
- [x] operational-insights/workspace/storage-insight-config/main.bicep
- [x] operational-insights/workspace/table/main.bicep
- [x] sql/server/audit-settings/main.bicep
- [x] sql/server/database/backup-long-term-retention-policy/main.bicep
- [x] sql/server/database/backup-short-term-retention-policy/main.bicep
- [x] sql/server/elastic-pool/main.bicep
- [x] sql/server/encryption-protector/main.bicep
- [x] sql/server/firewall-rule/main.bicep
- [x] sql/server/key/main.bicep
- [x] sql/server/outbound-firewall-rule/main.bicep
- [x] sql/server/security-alert-policy/main.bicep
- [x] sql/server/sql-vulnerability-assessment/main.bicep
- [x] sql/server/virtual-network-rule/main.bicep
- [x] sql/server/vulnerability-assessment/main.bicep
- [x] storage/storage-account/blob-service/container/immutability-policy/main.bicep
- [x] storage/storage-account/local-user/main.bicep
- [x] storage/storage-account/queue-service/main.bicep
- [x] storage/storage-account/table-service/main.bicep
- [x] storage/storage-account/table-service/table/main.bicep
- [x] web/site/basic-publishing-credentials-policy/main.bicep — N/A (no version.json, not independently deployable)
- [x] web/site/config--appsettings/main.bicep — N/A
- [x] web/site/config--authsettingsv2/main.bicep — N/A
- [x] web/site/config--logs/main.bicep — N/A
- [x] web/site/config--web/main.bicep — N/A
- [x] web/site/extensions--msdeploy/main.bicep — N/A
- [x] web/site/hybrid-connection-namespace/relay/main.bicep — N/A
- [x] web/site/slot/basic-publishing-credentials-policy/main.bicep — N/A
- [x] web/site/slot/config--appsettings/main.bicep — N/A
- [x] web/site/slot/config--authsettingsv2/main.bicep — N/A
- [x] web/site/slot/extensions--msdeploy/main.bicep — N/A
- [x] web/site/slot/hybrid-connection-namespace/relay/main.bicep — N/A
- [x] web/site/slot/main.bicep — N/A
- [x] web/static-site/config/main.bicep
- [x] web/static-site/custom-domain/main.bicep
- [x] web/static-site/linked-backend/main.bicep

### META-3: Files missing only evidenceOfNonCompliance (have owner + compliance) — 7 files

- [x] data-factory/factory/managed-virtual-network/main.bicep
- [x] data-factory/factory/managed-virtual-network/managed-private-endpoint/main.bicep
- [x] network/private-endpoint/private-dns-zone-group/main.bicep
- [x] service-bus/namespace/queue/main.bicep
- [x] service-bus/namespace/topic/main.bicep
- [x] storage/storage-account/blob-service/main.bicep
- [x] storage/storage-account/file-service/main.bicep

### META-4: Files missed in original audit (found by explorer) — 1 file needed fix

- [x] container-registry/registry/credential-set/main.bicep — added compliance + complianceVersion + evidenceOfNonCompliance
- [x] All other missed files (key-vault/vault/key, secret, access-policy; container-registry/cache-rule; network/virtual-network/subnet; data-factory/integration-runtime, linked-service; storage/management-policy, queue-service/queue, file-service/share, blob-service/container) — already had all metadata fields

### Up-to-Date (no sync needed)

- [x] SYNC-29: cognitive-services/account — 0.14 (synced)
- [x] SYNC-30: document-db/database-account — 0.19 (synced)
- [x] SYNC-31: event-hub/namespace — 0.14 (synced)
- [x] SYNC-32: cache/redis — 0.16 (synced)
- [x] SYNC-33: insights/data-collection-endpoint — 0.5 (synced)
- [x] SYNC-34: insights/private-link-scope — 0.7 (synced)
- [x] SYNC-35: insights/webtest — 0.3 (synced)
- [x] SYNC-36: insights/diagnostic-setting — 0.1 (synced)
- [x] SYNC-37: network/application-gateway-web-application-firewall-policy — 0.2 (synced)

---

## BUILD-FIX: Machine Build Results 2026-03-10

Full build run on machine with ACR access (bicep v0.41.2). PE module published as v0.2.0 before build.
Log file: `/workspaces/bicep-registry-modules/machine-build-results-2026-03-10.txt`

### BF-8: web/static-site — remove private DNS zone self-deployment

- **Issue**: Module deployed its own `br/amavm:res/network/private-dns-zone:0.2.0` via `staticSite_privateDnsZone`. On the hardened platform, private DNS zones are created by remediation policy, not by individual modules.
- **Fix**: Removed `staticSite_privateDnsZone` module, `createPrivateDnsZone` param, `virtualNetworkResourceId` param, and the `privateDnsZoneGroup` fallback referencing the removed zone. PE now just passes through `privateEndpoint.?privateDnsZoneGroup`.
- **Checked other new modules**: redis, event-hub, document-db — none deploy their own private DNS zones (correct).
- [x] Remove DNS zone deployment from `web/static-site/main.bicep`
- [x] Verify build passes (local PE path, warnings only)
- [x] Checked `cache/redis`, `event-hub/namespace`, `document-db/database-account` — no DNS zone self-deployment found

### Pattern: WAF-aligned dependencies for defaults test cases

When Azure policy denies public network access, the "defaults" test case must deploy with private endpoints. Use the waf-aligned dependencies for the defaults test (reuse `../waf-aligned/dependencies.bicep`). See `cognitive-services/account/tests/e2e/defaults/main.test.bicep` for the reference pattern:

```bicep
module nestedDependencies '../waf-aligned/dependencies.bicep' = {
  scope: resourceGroup
  name: '...-nestedDependencies'
  params: { ... }
}
// Then deploy module with privateEndpoints using nestedDependencies.outputs.subnetResourceId
```

**TODO**: Document this pattern in `instructions.md` as a standard practice.

### BF-1: cache/redis — defaults test build failure

- **Error**: `Exception: Failed to build template [...\cache\redis\tests\e2e\defaults\main.test.bicep]`
- **Root cause**: Parent module references `br/amavm:res/network/private-endpoint:0.2.0`. The setModuleReadMe script builds test files without `az bicep restore`, so PE ACR module is not in local cache for newly added modules. Also, defaults test deploys without PE which would violate public network access policy at deployment time.
- **Fix**: Rewrite defaults test to use waf-aligned dependencies pattern — reference `../waf-aligned/dependencies.bicep` for VNet/subnet/private DNS zone, deploy with `privateEndpoints` configured.
- [x] Update `tests/e2e/defaults/main.test.bicep` to use waf-aligned deps pattern (rewritten with PE + Premium SKU)
- [ ] Verify `bicep build` passes on machine with ACR access (PE module needed)

### BF-2: document-db/database-account — defaults test build failure

- **Error**: `Exception: Failed to build template [...\document-db\database-account\tests\e2e\defaults\main.test.bicep]`
- **Root cause**: Same as BF-1. Parent references PE module. Defaults test needs PE for policy compliance.
- **Fix**: Same pattern — reference `../waf-aligned/dependencies.bicep`, add `privateEndpoints` to deployment.
- [x] Update `tests/e2e/defaults/main.test.bicep` to use waf-aligned deps pattern (rewritten with PE + networkRestrictions)
- [ ] Verify `bicep build` passes on machine with ACR access

### BF-3: event-hub/namespace — waf-aligned + max test build failures

- **Error**: `Exception: Failed to build template [...\event-hub\namespace\tests\e2e\waf-aligned\main.test.bicep]` and `[...\max\main.test.bicep]`
- **Root cause**: Parent module references `br/amavm:res/network/private-endpoint:0.2.0`. PE not in local cache for this newly added module. Both waf-aligned and max tests reference the parent module which transitively requires PE.
- **Fix**: Use local PE path temporarily for build validation (BV-1 pattern). The test content itself is correct — the issue is purely the ACR reference resolution.
- **Note**: The `diagnostic.dependencies.bicep` (from `utils/e2e-template-assets/templates/`) is used by both tests and is a valid reference — there is a working sample included.
- [ ] Verify tests build with local PE path (BV-1)
- [ ] Ensure PE is published before running full build

### BF-4: insights/scheduled-query-rule — waf-aligned + max test build failures

- **Error**: `Exception: Failed to build template [...\scheduled-query-rule\tests\e2e\waf-aligned\main.test.bicep]` and `[...\max\main.test.bicep]`
- **Root cause**: Both test files use parameter `suppressForMinutes: 'PT5M'` (line 89 in waf-aligned, line 115 in max) but the parent module parameter is named `muteActionsDuration` (line 76 of main.bicep).
- **Fix**: Rename `suppressForMinutes` to `muteActionsDuration` in both test files.
- [x] Fix `tests/e2e/waf-aligned/main.test.bicep` — renamed `suppressForMinutes` to `muteActionsDuration`
- [x] Fix `tests/e2e/max/main.test.bicep` — renamed `suppressForMinutes` to `muteActionsDuration`
- [x] Verify `bicep build` passes (both tests build successfully with only warnings)

### BF-5: insights/activity-log-alert — max test build failure

- **Error**: `Exception: Failed to build template [...\activity-log-alert\tests\e2e\max\main.test.bicep]`
- **Root cause**: Likely related to `resourceInput<'Microsoft.Insights/activityLogAlerts@2020-10-01'>` type resolution. The API version `2020-10-01` is 1986 days old (linter warning suggests `2026-01-01`). The `resourceInput<>` syntax may not resolve types correctly for this old API in bicep v0.41.2. The dependencies file also uses `@2018-11-30` for ManagedIdentity and `@2022-06-01` for actionGroups.
- **Actual root cause**: Two issues found:
  1. API version `2020-10-01` was 1986 days old → updated to `2026-01-01`
  2. `param roleAssignments roleAssignmentType[]?` was wrong — `roleAssignmentType` in `types.bicep` is already defined as `{...}[]?` (nullable array), so `[]?` made it array-of-arrays. Fixed to `roleAssignmentType`.
- [x] Investigated exact build error — BCP034 type mismatch on roleAssignments (array-of-arrays)
- [x] Updated API version from `2020-10-01` to `2026-01-01`
- [x] Fixed `roleAssignmentType[]?` → `roleAssignmentType`
- [x] Verify `bicep build` passes — all 3 tests (defaults, max, waf-aligned) build successfully

### BF-6: container-service/managed-cluster — BCP192 (known)

- **Error**: `Error BCP192: Unable to restore the artifact with reference "br:s2amavmdevsecacr.azurecr.io/avm/res/kubernetes-configuration/extension:0.3.8": The artifact does not exist in the registry.`
- **Root cause**: Known issue (BV-2). Module references `kubernetes-configuration/extension` which is not in the fork/ACR.
- **Status**: Expected — no action unless this module is added to the fork.

### BF-7: app-configuration/configuration-store — BCP321 warning (resolved)

- **Warning**: BCP321 on PE output type mismatch (`customDnsConfigs`, `networkInterfaceResourceIds`) — lines 394-395 of main.bicep.
- **Root cause**: Was an error (BCP083/BCP053) on bicep v0.40, became a warning (BCP321) after upgrade to v0.41.2. The PE module output names (`customDnsConfigs`, `networkInterfaceResourceIds`) match correctly. The warning is about nullable type coercion.
- **Status**: Resolved by bicep upgrade. Warning is cosmetic — no code change required.

### Build Warnings Summary (non-blocking)

These warnings appeared across multiple modules. Not errors, but should be tracked for future cleanup:

| Warning | Modules Affected | Notes |
|---|---|---|
| `use-recent-api-versions` for `Microsoft.Resources/deployments@2024-03-01` | redis, cognitive-services, document-db, event-hub, data-collection-endpoint, diagnostic-setting, private-link-scope, app-gateway-waf-policy, insights/webtest | Should be `2024-07-01` or newer |
| `use-recent-api-versions` for `Microsoft.Insights/diagnosticSettings@2021-05-01-preview` | cognitive-services, event-hub, container-registry, app-gateway | 1774 days old |
| `use-recent-api-versions` for container-registry child modules `@2023-06-01-preview` | container-registry (webhook, scope-map, cache-rule, credential-set, replication) | 1013 days old |
| `no-unused-imports` | container-registry/cache-rule (minimalBuiltInRoleNames), data-factory/integration-runtime (minimalBuiltInRoleNames), data-factory/factory (networkAclsType, linkedServiceTypePropertiesType), container-service (privateEndpointType, customerManagedKeyType), databricks/workspace (managedIdentitiesType), key-vault (managedIdentitiesType), app-gateway (customerManagedKeyManagedDiskType, customerManagedKeyType) | Clean up unused imports |
| `BCP187` "notes" property | Multiple modules (all modules using telemetry with `notes` field) | Expected — ARM schema gap |
| `BCP187` "privateDnsZoneGroup" property | cognitive-services, data-factory, key-vault, app-gateway | Expected — ARM schema gap |
| `BCP318` null safety | container-registry (3), databricks/workspace (2), app-gateway (2), data-collection-rule (6) | Consider adding `?` safe access |
| `BCP321` type coercion | app-configuration, data-factory, document-db, event-hub | Nullable type mismatch on PE outputs |

---

## Completed Tasks

- [x] Set up multi-agent task management structure
- [x] Document three-project architecture
- [x] Narrow scope to 22 whitelisted components
- [x] Gap analysis: identify 4 missing modules
- [x] Map all existing modules with upstream version tracking
- [x] Define Module Customization Checklist from amavm README
- [x] Define 3 specialized agents (Bicep Tech Debt Analyst, Azure Policy Expert, Karen)
- [x] Full audit of all 17 whitelisted modules against 18-point checklist
- [x] Create granular per-module task backlog with specific findings
