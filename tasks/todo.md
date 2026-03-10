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
- [x] Create `README.md` (generated, 100KB+, includes compliance section v20250308)
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
- [ ] Create `README.md` — use `pwsh buildBicepFiles.ps1 -moduleName 'res/event-hub/namespace' -buildReadme 'True'`
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
- [x] Create `README.md` (generated, 68KB+, includes compliance section v20250308)
- [x] Karen: 18/18 PASS

### GAP-4: Notification-Hubs — DEFERRED

No upstream AVM module exists. Only 2 policies (drcp-ntf-01 default access policies, drcp-sub-07 cross-sub PE). Would require building from scratch. Recommend deferring until upstream support exists.

- [x] Research: no upstream module, minimal policy coverage
- [x] Decision: DEFER

### GAP-5: Public IP Address (network/public-ip-address)

Needed by DRCP test cases (scenarios 5, 8) for Application Gateway public IP. Simple resource, low complexity. No upstream AVM module exists but straightforward to create.

- [ ] Check if upstream AVM has a public-ip-address module
- [ ] Use `/azure:azure-rbac` to identify least-privilege roles for Public IP management
- [ ] Use `/azure:azure-compliance` to check for any Public IP-specific policies in the subscription
- [ ] Create AMAVM module `network/public-ip-address` with DRCP-compliant defaults
- [ ] Apply Module Customization Checklist
- [ ] `bicep build` passes

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

### FEAT-1b: web/site — Slot Module Sync & Param Propagation

The slot module (`slot/main.bicep`) is missing params that the parent already has (added in FEAT-1) and upstream params from v0.11→v0.22 sync.

**P0 — Propagate parent params to slot (added in FEAT-1 but not propagated):**
- [x] `dnsConfiguration` — DNS settings
- [x] `sshEnabled` — SSH access control
- [x] `daprConfig` — Dapr configuration
- [x] `ipMode` — IP mode
- [x] `resourceConfig` — Function app resource requirements
- [x] `workloadProfileName` — Workload profile
- [x] `hostNamesDisabled` — Disable public hostnames
- [x] `e2eEncryptionEnabled` — End-to-end encryption
- [x] `outboundVnetRouting` — VNet routing (already on parent and slot)
- [x] Add all above as resource properties on the slot resource
- [x] Update parent module slot loop to pass these params through

**P1 — Sync missing upstream params (v0.11→v0.22):**
- [x] `managedEnvironmentResourceId` — Managed environment (Container Apps) — added to slot + parent loop
- [x] `clientAffinityProxyEnabled` — Session affinity proxy — added to both parent and slot
- [x] `clientAffinityPartitioningEnabled` — Session affinity partitioning (CHIPS) — added to both
- [x] `autoGeneratedDomainNameLabelScope` — Domain label scope — added to both parent and slot
- [x] `reserved` — Linux reserved flag — added to slot (parent already computes from kind)
- [x] `scmSiteAlsoStopped` — Stop SCM when app stops — added to slot (parent already has it)
- [x] Added to both parent and slot modules + resource properties + parent slot loop

**P2 — Adopt `resourceInput<>` types for type safety (slot module):**
- [x] `siteConfig` → `resourceInput<'Microsoft.Web/sites/slots@2025-03-01'>.properties.siteConfig` (with secure defaults)
- [x] `functionAppConfig` → `resourceInput<...>.properties.functionAppConfig`
- [x] `clientCertMode` → `resourceInput<...>.properties.clientCertMode`
- [x] `cloningInfo` → `resourceInput<...>.properties.cloningInfo`
- [x] `hostNameSslStates` → `resourceInput<...>.properties.hostNameSslStates`
- [x] `redundancyMode` → `resourceInput<...>.properties.redundancyMode`
- [x] `dnsConfiguration` → `resourceInput<...>.properties.dnsConfiguration`
- [x] `daprConfig` → `resourceInput<...>.properties.daprConfig`
- [x] `ipMode` → `resourceInput<...>.properties.ipMode`
- [x] `resourceConfig` → `resourceInput<...>.properties.resourceConfig`
- [x] `autoGeneratedDomainNameLabelScope` → `resourceInput<...>.properties.autoGeneratedDomainNameLabelScope`
- [x] Parent module: adopt `resourceInput<>` types for 9 params: `dnsConfiguration`, `daprConfig`, `ipMode`, `resourceConfig`, `functionAppConfiguration`, `cloningInfo`, `hostNameSslStates`, `clientCertMode`, `redundancyMode` (removed `@allowed` in favor of ARM schema constraints)
- [x] Updated `slotType` with 14 missing properties (`managedEnvironmentResourceId`, `clientAffinityProxyEnabled`, `clientAffinityPartitioningEnabled`, `e2eEncryptionEnabled`, `dnsConfiguration`, `daprConfig`, `sshEnabled`, `ipMode`, `resourceConfig`, `workloadProfileName`, `hostNamesDisabled`, `reserved`, `scmSiteAlsoStopped`, `autoGeneratedDomainNameLabelScope`) + `resourceInput<>` types on 8 existing properties
- [x] Suppressed 4 false-positive `outputs-should-not-contain-secrets` linter errors on slot outputs (caused by `resourceInput<>` type on `slotType.siteConfig` carrying `azureStorageAccounts.*.accessKey` schema metadata)
- [x] `bicep build` passes for parent + slot + all 11 tests
- [ ] Pre-fill defaults from policy/compliance where possible (secure defaults)

**P2b — Auth Settings V2 with Entra ID (workload identity, no client secret):**
- [x] Updated `authSettingV2Configuration` default to use federated identity credentials (FIC) pattern: `clientSecretSettingName: 'OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID'` instead of `'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'`
- [x] Documented FIC prerequisites in param description: managed identity, federated credential on app registration, `OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID` app setting
- [x] Added reference to Azure sample: `https://github.com/Azure-Samples/appservice-builtinauth-bicep`
- [x] Documented client secret fallback via `authSettingV2ConfigurationAdditional`
- [x] Updated compliance metadata to mention FIC auth default
- [ ] Add dedicated test case showing full FIC pattern with app registration dependency (requires Microsoft Graph Bicep)

**Validation:**
- [x] `bicep build` passes for parent + slot + all 11 tests (only BCP192 for PE — expected)
- [ ] Karen: validate

### FEAT-2: container-service/managed-cluster — AutoScaler Profile

The 16 individual autoScaler params (scanInterval, scaleDown delays, etc.) were stale — already superseded by the active `param autoScalerProfile` which passes through to the resource. Cleaned up:

- [x] Removed 56 lines of stale individual autoScalerProfile params (replaced by single `autoScalerProfile` param)
- [x] Updated `autoScalerProfile` type from `object?` to `resourceInput<...>` (matching upstream)
- [x] Updated `httpProxyConfig`, `workloadAutoScalerProfile`, `serviceMeshProfile`, `aiToolchainOperatorProfile`, `bootstrapProfile`, `upgradeSettings`, `windowsProfile`, `aksServicePrincipalProfile` to `resourceInput<>` types
- [x] Set `workloadAutoScalerProfile` default to `{ keda: { enabled: true } }` (secure default for KEDA)
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

**All implemented.** All commented-out items were stale duplicates of active params:
- httpApplicationRouting, webApplicationRouting, AGIC, ACI connector, DNS zone — all active
- fluxExtension — active at line 505 (+ extension module at line 922), but kubernetes-configuration/extension module not in fork (BCP192). No policy restricts flux, but it's not built in Azure DevOps pipeline. Keeping param as-is (no-op when not provided).
- kedaAddon — superseded by active `workloadAutoScalerProfile` param (KEDA configured as `{ keda: { enabled: true } }`)
- kubeDashboard, openServiceMesh — active at lines 543-544

Cleaned up all stale commented-out duplicates.

- [x] All add-on params already active
- [x] Removed stale commented-out duplicates
- [ ] Update tests
- [ ] Karen: validate

### FEAT-5: container-service/managed-cluster — Pod Identity and Security

**All implemented.** All relevant params already active:
- podIdentityProfile, identityProfile — active
- diskEncryptionSetResourceId — active at line 529
- httpProxyConfig — active at line 535
- CMK (customerManagedKey) — removed entirely per decision (not needed for platform)
- enablePodSecurityPolicy — removed (deprecated since K8s 1.21, removed in 1.25)

- [x] All security params already active
- [x] Removed CMK entirely (param, cMKKeyVault resource, customerManagedKeyType import)
- [x] Removed deprecated enablePodSecurityPolicy
- [x] `bicep build` passes (only BCP192 expected)
- [ ] Update tests
- [ ] Karen: validate

### FEAT-6: container-service/managed-cluster — Flux Extension Removal & Agent Pool Upstream Sync

**Flux extension** was dead code — `kubernetes-configuration/extension` module not in fork, not built in Azure DevOps, no policy requires it. Commented out entirely.

**Agent pool upstream sync** — synced 15 missing params from upstream (`microsoft-avm/avm/res/container-service/managed-cluster/agent-pool/main.bicep`), adopting `resourceInput<>` types and the security-first model:

- [x] Comment out flux extension param, module, type definition, and `enableReferencedModulesTelemetry` variable
- [x] Add 15 new agent pool params: `capacityReservationGroupResourceId`, `gatewayProfile`, `gpuProfile`, `hostGroupResourceId`, `kubeletConfig`, `linuxOSConfig`, `localDNSProfile`, `messageOfTheDay`, `networkProfile`, `podIPAllocationMode`, `powerState`, `securityProfile`, `upgradeSettings` (full object replacing `maxSurge`), `virtualMachinesProfile`, `windowsProfile`
- [x] Expand `osSku` @allowed: `AzureLinux3`, `Ubuntu2204`, `Ubuntu2404`, `Windows2025`
- [x] Use `resourceInput<>` types where upstream does (12 params)
- [x] Update `agentPoolType` exported type with all new properties
- [x] Update parent module agent pool loop to pass all new params
- [x] Fix array-of-arrays bug: `agentPoolType[]?` → `agentPoolType?` (type already includes `[]`)
- [x] Uncomment agent pools in 3azure test (2 user pools, AzureLinux, upgradeSettings)
- [x] Uncomment agent pools in 4waf-aligned test (2 user pools, 3 AZs, ephemeral OS, system pool taint)
- [x] Create 6max test — comprehensive coverage: identity, cilium networking, private cluster, defender, KV secrets, policy, image cleaner, disk encryption, KEDA, diagnostics, maintenance windows, labeled/tainted agent pools, locks, role assignments
- [x] All 6 tests + main module build with zero errors
- [ ] Karen: validate

### BF-7: web/site config--appsettings — upstream sync (identity auth, AppInsights, hybridConnection)

Critical bugs found by comparing fork's split config modules against upstream's unified `config/main.bicep`. These are "small things that cause big problems" — silent deployment failures.

**Issues found and fixed:**

1. **Missing AzureWebJobs queue/table URIs** (site + slot `config--appsettings`)
   - Fork only set `__accountName` and `__blobServiceUri` for identity-based storage auth
   - Missing `__queueServiceUri` and `__tableServiceUri`
   - **Impact**: Function apps with identity-based storage auth silently fail on queue/table triggers and bindings
   - [x] Added `AzureWebJobsStorage__queueServiceUri` and `AzureWebJobsStorage__tableServiceUri`

2. **Hardcoded ApplicationInsightsAgent_EXTENSION_VERSION** (site + slot `config--appsettings`)
   - Site: hardcoded `'~2'` for all app kinds
   - Slot: completely missing — no extension version set at all
   - Upstream dynamically selects `'~3'` for Linux/container apps, `'~2'` for Windows
   - **Impact**: Linux function apps and container apps get wrong/missing agent version, causing monitoring failures
   - [x] Added dynamic version selection based on `app.kind` (site) / `app::slot.kind` (slot)

3. **Site `storageAccountUseIdentityAuthentication` wrong default** (site `config--appsettings`)
   - Fork site-level defaulted to `true`, slot-level to `false`, upstream to `false`
   - Combined with #1 (missing queue/table URIs), this meant site-level function apps would silently break
   - [x] Changed site-level default to `false` (matches upstream and slot)

4. **Storage API version outdated** (site + slot `config--appsettings`)
   - Fork: `@2023-05-01` (2 years old)
   - Upstream: `@2025-01-01` / `@2025-06-01`
   - [x] Updated to `@2025-01-01`

5. **hybridConnectionRelay wrong property name** (site `main.bicep` + slot `main.bicep`)
   - Fork: `hybridConnectionRelay.resourceId`
   - Upstream: `hybridConnectionRelay.hybridConnectionResourceId`
   - **Impact**: Runtime error when deploying hybrid connection relays
   - [x] Fixed in both parent and slot modules

6. **Slot config--appsettings wrong metadata owner** (`Azure/module-maintainers` → `AMCCC`)
   - [x] Fixed

- [x] All 11 web/site e2e tests build clean (only expected BCP192/BCP104)
- [ ] Karen: validate

### BF-8: setModuleReadMe.ps1 — null-valued expression on outputs without description

**Root cause**: `output evidenceOfNonCompliance bool = false` has no `@description()` decorator, so the compiled ARM JSON has no `metadata.description` for that output. Line 665 of `setModuleReadMe.ps1` calls `.Replace()` on `$output.metadata.description` without null guard, crashing with "You cannot call a method on a null-valued expression".

The script enters the "outputs with descriptions" branch (line 657) because **some** outputs have metadata, then assumes **all** do.

- [x] Fixed line 665: added null guard for output descriptions
- [x] Fixed line 736: same pattern for function descriptions
- [x] Verified: key-value and replica modules generate README without error

### BF-9: buildBicepFiles.ps1 — child modules without version.json skipped for README generation

**Root cause**: `buildBicepFiles.ps1` discovers modules by scanning for `main.bicep` + `version.json`. Child modules (e.g., `key-value`, `replica`) without `version.json` are skipped entirely — including README generation when `-buildReadme "True"`. Meanwhile, the pipeline's `compareReadMe.ps1` discovers modules by scanning for `README.md` files (no `version.json` check), so it finds and validates child module READMEs. This causes local builds to miss 17 child modules that the pipeline processes.

- [x] Added second pass in `buildBicepFiles.ps1` for `buildReadme` mode: scans for `README.md` files, skips those with `version.json` (already handled), generates READMEs for remaining child modules
- [x] Verified: 17 child modules now discovered locally (app-configuration/2, db-for-postgre-sql/5, insights/2, search/1, service-bus/7)

### Pending Karen Validation Batch

All implementations below are code-complete and `bicep build` verified. They await Karen's acceptance gate (checklist re-audit + `/azure:azure-validate` + `/azure:azure-compliance`).

| Task | Module(s) | What changed |
|---|---|---|
| FEAT-1 | web/site (slots) | Slot param, module loop, outputs |
| FEAT-1b | web/site + slot | `resourceInput<>` types, upstream param sync, `slotType` update |
| FEAT-2 | container-service/managed-cluster | `autoScalerProfile` → `resourceInput<>`, stale params removed |
| FEAT-3 | container-service/managed-cluster | Agent pools (confirmed already active) |
| FEAT-4 | container-service/managed-cluster | Ingress/DNS/add-ons (stale comments cleaned) |
| FEAT-5 | container-service/managed-cluster | Pod identity/security, CMK removed, deprecated PSP removed |
| FEAT-6 | container-service/managed-cluster + agent-pool | Flux removed, 15 agent-pool params added, tests updated |
| BF-7 | web/site config--appsettings | Queue/table URIs, AppInsights version, storage auth, relay fix |

- [ ] Run Karen validation on FEAT-1 + FEAT-1b (web/site + slot)
- [ ] Run Karen validation on FEAT-2/3/4/5/6 (container-service/managed-cluster)
- [ ] Run Karen validation on BF-7 (web/site config--appsettings)

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
- [x] Restore all ACR refs before committing (PE, WAF policy) — confirmed: 20 `br/amavm:res/network/private-endpoint:0.2.0` refs in place

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

### FEAT-9: Pipeline Performance — Parallel Bicep Build & README Validation

Current pipeline takes ~30 min for a feature branch (RES only):
- Bicep build: ~8 min (sequential, ~35 parent modules)
- README validation: ~25 min (sequential, 66 README files × `az bicep build --stdout` via `Set-ModuleReadMe`)

**Root cause**: Both `buildBicepFiles.ps1` and `compareReadMe.ps1` process modules serially. Each `Set-ModuleReadMe` call invokes `az bicep build --stdout` to compile the template before generating the README — 66 sequential compiler invocations.

**Plan**: Parallelize using PowerShell 7 `ForEach-Object -Parallel`:

| Script | Change | Expected impact |
|---|---|---|
| `buildBicepFiles.ps1` | Parallel build loop (`-ThrottleLimit 4-8`) | ~8 min → ~2-3 min |
| `compareReadMe.ps1` | Parallel README generation + compare | ~25 min → ~5-7 min |

**Implementation notes:**
- `ForEach-Object -Parallel` runs in isolated runspaces — must re-import `setModuleReadMe.ps1` per runspace
- Use thread-safe `[System.Collections.Concurrent.ConcurrentBag[string]]` for error collection
- `az bicep restore` is idempotent — concurrent restores of same ACR artifact are safe
- Collect per-module output and print after completion to avoid log interleaving
- `Set-ModuleReadMe` has a `PreLoadedContent` param — future optimization: build once, pass compiled JSON to README generation (eliminates double compilation entirely)
- Both scripts support `-Sequential` switch for fallback/debugging and `-ThrottleLimit` (default: 6)
- **Deviation from upstream**: `setModuleReadMe.ps1` is NOT modified — parallelization wraps around it only
- Helper script `swapPeReferences.ps1` created for local testing (swaps ACR PE refs to local paths and back)

- [x] Parallelize `buildBicepFiles.ps1` main build loop
- [x] Parallelize `buildBicepFiles.ps1` child module README loop
- [x] Parallelize `compareReadMe.ps1` module loop
- [x] Handle `Set-ModuleReadMe` import in parallel runspaces
- [x] Local test: 52 parent modules built in ~80s parallel (ThrottleLimit=6)
- [x] Local test (MacBook M4 Pro): 55 parent + 17 child modules built with README in ~330s parallel (ThrottleLimit=6), ~8 min total including Claude prompt/startup. Used `localBuildHelper.ps1` to swap ACR refs to local paths.
- [x] Fix: `az bicep build` stderr warnings (e.g. `no-unused-imports`) caused `ErrorActionPreference=Stop` termination in Azure DevOps pipeline. `$ErrorActionPreference='Continue'` in parallel scriptblocks was ineffective due to PowerShell module scope isolation — `Set-ModuleReadMe` runs in its own module scope inheriting process-level `Stop`. Fixed at the source: `2>$null` on `az bicep build --stdout` in `setModuleReadMe.ps1:2175`. Real failures still caught via `$templateFileContent` null-check.
- [x] Test on pipeline (feature branch) with full RES build + README validation
- [x] Measure pipeline before/after timing

**Pipeline results (55 parent modules, 69 READMEs — 3 more modules than baseline):**

| Step | Sequential (52 modules) | Parallel ThrottleLimit=6 (55 modules) | Delta |
|---|---|---|---|
| Bicep build | ~7:30 min | ~8 min | +7% (but +6% more modules) |
| README compare | ~20 min | ~24 min | +20% (but +4.5% more modules) |

**Analysis**: Parallelization did NOT improve pipeline times. Despite local testing showing ~80s for 52 modules, the Azure DevOps pipeline agents show no speedup — likely bottlenecked by:
1. Single-core/limited-vCPU pipeline agents (parallel runspaces compete for the same CPU)
2. `az bicep build` being CPU-bound (compiler), not I/O-bound — parallelism only helps I/O-bound workloads on constrained agents
3. Overhead of parallel runspace creation + module re-import per runspace

**Recommendation**: The parallelization code is functionally correct and harmless, but provides no benefit on current pipeline agents. Real gains require the `PreLoadedContent` optimization (phase 2) to eliminate redundant `az bicep build` calls entirely.

#### Phase 2: PreLoadedContent Optimization (eliminate double compilation)

`Set-ModuleReadMe` already supports `-PreLoadedContent @{ TemplateFileContent = <hashtable> }` (setModuleReadMe.ps1:2172-2181). When provided, it skips its internal `az bicep build` call entirely. No changes to setModuleReadMe.ps1 needed.

**Impact**: buildBicepFiles.ps1 currently compiles each parent module TWICE when buildReadme=True (once inside Set-ModuleReadMe, once for build validation). Eliminating the double-compile saves ~55 `az bicep build` invocations (~4 min on pipeline). compareReadMe.ps1 has no double-compile, but moving `az bicep build` outside module scope improves reliability (avoids ErrorActionPreference issues).

**Pattern** (reused across all 5 locations):
```powershell
$buildJson = az bicep build --file $bicepFilePath --stdout 2>$null
if ($LASTEXITCODE -gt 0) { throw "Code:$LASTEXITCODE (build)" }
$templateContent = $buildJson | ConvertFrom-Json -AsHashtable
Set-ModuleReadMe -TemplateFilePath $bicepFilePath -PreLoadedContent @{
    TemplateFileContent = $templateContent
}
```

**Files to modify**: buildBicepFiles.ps1 (3 locations), compareReadMe.ps1 (2 locations)

- [ ] **buildBicepFiles.ps1 serial parent** (lines 82-107): Reorder to restore → build (capture stdout) → if buildReadme: pass PreLoadedContent to Set-ModuleReadMe. Remove redundant second `az bicep build` call. Remove stale `$LASTEXITCODE` check after Set-ModuleReadMe.
- [ ] **buildBicepFiles.ps1 parallel parent** (lines 158-195): Build first (capture stdout) → if buildReadme: parse JSON + pass PreLoadedContent. Remove redundant second build. Remove stale `$LASTEXITCODE` check after Set-ModuleReadMe.
- [ ] **buildBicepFiles.ps1 parallel child** (lines 224-247): Pre-compile with `az bicep build --stdout 2>$null`, pass as PreLoadedContent. No compile reduction but moves build outside module scope. Remove stale `$LASTEXITCODE` check after Set-ModuleReadMe.
- [ ] **compareReadMe.ps1 serial** (lines 65-123): Pre-compile, pass PreLoadedContent. Same compile count but outside module scope. Remove stale `$LASTEXITCODE` check after Set-ModuleReadMe.
- [ ] **compareReadMe.ps1 parallel** (lines 132-206): Pre-compile, pass PreLoadedContent. Same compile count but outside module scope. Remove stale `$LASTEXITCODE` check after Set-ModuleReadMe.
- [ ] Local build test: `./utils/buildBicepFiles.ps1 -modulesSubpath 'res' -buildReadme 'True'`
- [ ] Pipeline test: compare timing to 8-min build / 24-min compare baseline

### FEAT-7: Missing Features vs Upstream

| # | Feature | Upstream Location | Priority |
|---|---|---|---|
| 1 | Static analysis (PSRule) integration | `.github/workflows/platform.check.psrule.yml` | HIGH |
| 2 | Deployment history cleanup | `.github/workflows/platform.deployment.history.cleanup.yml` | MEDIUM |
| 3 | Module index publishing | `.github/workflows/platform.publish-module-index-json.yml` | MEDIUM |
| 4 | PR label automation | `.github/workflows/platform.set-avm-github-pr-labels.yml` | LOW |
| 5 | Workflow toggle automation | `.github/workflows/platform.toggle-avm-workflows.yml` | LOW |

- [ ] Evaluate PSRule integration for Azure DevOps pipelines — `/azure:azure-validate` covers similar pre-deployment checks; assess overlap
- [ ] Implement deployment history cleanup utility
- [ ] Implement module index publishing for internal registry
- [ ] Evaluate PR/pipeline label automation needs

**Skill-based alternatives for missing features:**
- `/azure:azure-validate` can serve as an interactive pre-deployment gate (complementing or replacing PSRule for dev workflows)
- `/azure:azure-compliance` can run ad-hoc compliance scans against deployed resources, supplementing static Bicep analysis

### FEAT-8: HTML-from-MD Pipeline Improvements

The `convertreadmetohtml.py` pipeline converts Bicep module READMEs to static HTML for Azure DevOps wiki/documentation portal. Current issues:

- [x] Fix anchor links in generated HTML — markdown2 `toc` extra kept underscores/parens in heading `id` attributes (e.g. `example-1-_deploying_`) but `setModuleReadMe.ps1` strips them from link targets (e.g. `#example-1-deploying`). Added post-processing regex in `convertreadmetohtml.py` to normalize heading IDs.
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

### SYNC Phase 2: Update upstream.json to match synced versions

**Issue:** SYNC-01 through SYNC-28 updated API versions and parameters within modules, but most `upstream.json` files still show the original fork-point version — not the version that was synced to. Only 5 modules have current `upstream.json`:

| Status | Modules |
|---|---|
| **upstream.json current** | cache/redis (0.16), document-db/database-account (0.19), event-hub/namespace (0.14), cognitive-services/account (0.14), storage/storage-account (0.32) |
| **upstream.json stale** | All other 17 whitelisted modules — upstream.json still shows the pre-SYNC version |

This means `upstream.json` does not accurately reflect what was synced. For traceability:

- [ ] Update `upstream.json` for all 17 stale modules to match the version synced in SYNC-01 through SYNC-28
- [ ] Update `instructions.md` whitelisted components table (upstream versions column is stale — shows original fork versions)
- [ ] Use `/azure:azure-validate` to spot-check modules after upstream.json updates

### SYNC-TD: Technical Debt Comparison vs Upstream (Whitelisted Modules Only)

Full comparison completed 2026-03-10. Compared all 35 whitelisted modules against current upstream.

**Convention differences (NOT bugs — intentional fork patterns):**
- `roleAssignmentType` / `lockType` / `diagnosticSettingType` / `privateEndpointType` — AMAVM types in `bicep-shared/types.bicep` already include `[]?`/`?`, so `param x roleAssignmentType` is correct (upstream uses `roleAssignmentType[]?` with their non-array types)
- `managedIdentitiesType = { systemAssigned: true }` — intentional secure default (upstream uses `managedIdentityAllType?`)
- Policy-enforced defaults (`publicNetworkAccess='Disabled'`, `allowSharedKeyAccess=false`, etc.) — intentional
- Import source (`bicep-shared/` vs `br/public`) — intentional fork pattern
- Explicit log categories instead of `{ categoryGroup: 'allLogs' }` — intentional

**Real findings — `resourceInput<>` adoption gap (upstream migrated, fork still uses `object?`/`string`):**

| Module | Params needing `resourceInput<>` | Priority |
|---|---|---|
| web/serverfarm | `kind`, `workerTierName`, `perSiteScaling`, `elasticScaleEnabled`, `maximumElasticWorkerCount`, `targetWorkerCount`, `zoneRedundant`, `isCustomMode` | Medium |
| insights/webtest | `request`, `locations`, `validationRules`, `configuration` | Medium |
| network/private-endpoint | `ipConfigurations`, `customDnsConfigs`, `manualPrivateLinkServiceConnections`, `privateLinkServiceConnections` | Medium |
| network/application-gateway | Many params (upstream did massive `resourceInput<>` migration); also missing `loadDistributionPolicies` | Low (complex) |
| cache/redis | `redisConfiguration`, `tenantSettings` | Low |
| event-hub/namespace | `maximumThroughputUnits` | Low |

**Real findings — missing upstream features:**

| Module | Missing Feature | Priority |
|---|---|---|
| cache/redis | `secretsExportConfiguration` param | Low |
| cognitive-services/account | `secretsExportConfiguration` param | Low |
| event-hub/namespace | `secretsExportConfiguration` param | Low |

**Real findings — other:**

| Module | Issue | Priority |
|---|---|---|
| search/search-service | `hostingMode` case: fork `'default'` vs upstream `'Default'` | Low |
| db-for-postgre-sql/flexible-server | Version default `'17'` vs upstream `'18'` — may need updating | Low |

- [x] Comparison completed for all 35 modules
- [x] Address `resourceInput<>` adoption gap:
  - [x] web/serverfarm — `kind` → `resourceInput<'Microsoft.Web/serverfarms@2025-03-01'>.kind`
  - [x] insights/webtest — `request`, `locations`, `validationRules`, `configuration`, `kind` → `resourceInput<'Microsoft.Insights/webtests@2022-06-15'>`
  - [x] network/private-endpoint — `ipConfigurations`, `manualPrivateLinkServiceConnections`, `privateLinkServiceConnections`, `ipVersionType` → `resourceInput<'Microsoft.Network/privateEndpoints@2025-05-01'>`, removed 3 custom type definitions
  - [x] cache/redis — `redisConfiguration`, `minimumTlsVersion`, `publicNetworkAccess`, `redisVersion`, `zonalAllocationPolicy` → `resourceInput<'Microsoft.Cache/redis@2024-11-01'>`
  - [x] event-hub/namespace — `minimumTlsVersion`, `publicNetworkAccess` → `resourceInput<'Microsoft.EventHub/namespaces@2024-01-01'>`
- [ ] Add `secretsExportConfiguration` to cache/redis, cognitive-services, event-hub
- [x] Fix search/search-service `hostingMode` case: `'default'`→`'Default'`, `'highDensity'`→`'HighDensity'` (main + 2 test files)
- [x] Restrict db-for-postgre-sql/flexible-server `version` @allowed to `['16','17','18']` (min 16 per policy drcp-psql-06)
- API version drift on resources and `reference()` calls
- Missing upstream params/child modules since last sync
- Build errors (test cases especially)

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

### BF-3: event-hub/namespace — waf-aligned test build failure (BCP034)

- **Error**: BCP034 on `diagnosticSettings` and `privateEndpoints` params in waf-aligned test
- **Root cause**: `diagnosticSettingType` already includes `[]?` and `privateEndpointType` already includes `[]` in `bicep-shared/types.bicep`. Using `diagnosticSettingType[]?` and `privateEndpointType[]?` in main.bicep created array-of-arrays, causing type mismatch (same pattern as BF-5).
- **Fix**: Changed `param diagnosticSettings diagnosticSettingType[]?` → `diagnosticSettingType` and `param privateEndpoints privateEndpointType[]?` → `privateEndpointType`
- [x] Fix type declarations in main.bicep
- [x] Verify all 3 tests build clean (defaults, max, waf-aligned) with local PE path
- [x] Documented shared type convention in README.md and MEMORY.md

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
