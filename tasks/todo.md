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
- [ ] Create `tests/e2e/max/`, `tests/e2e/waf-aligned/`
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
- [ ] Create `tests/e2e/max/`, `tests/e2e/waf-aligned/`
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
- [ ] Create `tests/e2e/max/`, `tests/e2e/waf-aligned/`
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
- [ ] Update tests to cover slots
- [x] `bicep build` passes (only BCP192 expected)
- [ ] Karen: validate

### FEAT-2: container-service/managed-cluster — AutoScaler Profile

~56 lines of commented-out autoscaler parameters (scanInterval, scaleDown delays, utilization threshold, etc.) and ~28 lines of commented autoScalerProfile resource block.

- [ ] Uncomment and implement autoScaler profile parameters
- [ ] Uncomment and implement autoScalerProfile in managedCluster properties
- [ ] Update tests to cover autoscaler configuration
- [ ] `bicep build` passes
- [ ] Karen: validate

### FEAT-3: container-service/managed-cluster — Agent Pools Module

~43 lines of commented-out agentPools module loop.

- [ ] Uncomment and implement agentPools module loop
- [ ] Update agent-pool/main.bicep API version from preview to stable
- [ ] Align agent-pool API version with main cluster (`2024-08-01`)
- [ ] Update tests to cover additional agent pools
- [ ] `bicep build` passes
- [ ] Karen: validate

### FEAT-4: container-service/managed-cluster — Ingress, DNS, and Add-ons

Commented-out: httpApplicationRouting, webApplicationRouting, AGIC, ACI connector, DNS zone, flux extension.

- [ ] Evaluate which add-ons are needed for amavm scope
- [ ] Uncomment and implement selected add-on parameters
- [ ] Uncomment and implement DNS zone role assignment (if webApplicationRouting enabled)
- [ ] Uncomment and implement flux extension module (if GitOps required)
- [ ] Update tests
- [ ] `bicep build` passes
- [ ] Karen: validate

### FEAT-5: container-service/managed-cluster — Pod Identity and Security

Commented-out: podIdentityProfile parameters (allowNetworkPluginKubenet, enable, userAssignedIdentities, exceptions), identityProfile, diskEncryptionSetID, httpProxyConfig.

- [ ] Evaluate which security features are needed
- [ ] Uncomment and implement selected parameters
- [ ] Update tests
- [ ] `bicep build` passes
- [ ] Karen: validate

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

---

## FEATURE: Utils Tooling Tech Debt

Comparison of `amavm/verified-modules/utils/` against `microsoft-avm/avm/` upstream tooling. The amavm utils use Azure DevOps pipelines (not GitHub Actions) and generate HTML from Markdown READMEs (using Python `markdown2` library → `placeholder.html` template → static HTML with `toc.json` → Azure Blob Static Sites).

### FEAT-6: Bugs in Current Utils

| # | File | Bug | Severity |
|---|---|---|---|
| 1 | `publishToBCR.ps1` | Hardcoded ACR name — should use pipeline variable | HIGH |
| 2 | `mergeDocumentationTocs.ps1` | Hardcoded storage URL — should use pipeline variable | HIGH |
| 3 | `convertreadmetohtml.py` | Version string appends `.0` unconditionally (e.g., `1.0` → `1.0.0`, but `1.0.0` → `1.0.0.0`) | MEDIUM |
| 4 | `convertreadmetohtml.py` | No error handling for regex substitutions — silent failures on unexpected README format | MEDIUM |
| 5 | `setModuleReadMe.ps1` | Outdated comment referencing upstream sync that no longer applies | LOW |
| 6 | `buildBicepFiles.ps1` | Slow recursive file scanning — could use `-Filter` parameter for performance | LOW |

- [ ] Fix hardcoded ACR name in `publishToBCR.ps1`
- [ ] Fix hardcoded storage URL in `mergeDocumentationTocs.ps1`
- [ ] Fix version `.0` appending bug in `convertreadmetohtml.py`
- [ ] Add regex error handling in `convertreadmetohtml.py`
- [ ] Clean up outdated comments in `setModuleReadMe.ps1`
- [ ] Optimize file scanning in `buildBicepFiles.ps1`

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

- [ ] SYNC-01: storage/storage-account — 0.10 → 0.32 (gap: 22)
- [ ] SYNC-02: sql/server — 0.4 → 0.21 (gap: 17)
- [ ] SYNC-03: operational-insights/workspace — 0.3 → 0.15 (gap: 12)
- [ ] SYNC-04: web/site — 0.11 → 0.22 (gap: 11)

### High Priority (5-10 version gap)

- [ ] SYNC-05: container-service/managed-cluster — 0.3 → 0.12 (gap: 9)
- [ ] SYNC-06: container-registry/registry — 0.3 → 0.11 (gap: 8)
- [ ] SYNC-07: data-factory/factory — 0.3 → 0.11 (gap: 8)
- [ ] SYNC-08: key-vault/vault — 0.6 → 0.13 (gap: 7)
- [ ] SYNC-09: databricks/workspace — 0.5 → 0.12 (gap: 7)
- [ ] SYNC-10: network/virtual-network — 0.2 → 0.7 (gap: 5)
- [ ] SYNC-11: web/serverfarm — 0.2 → 0.7 (gap: 5)

### Medium Priority (2-4 version gap)

- [ ] SYNC-12: network/application-gateway — 0.5 → 0.9 (gap: 4)
- [ ] SYNC-13: network/private-endpoint — 0.8 → 0.12 (gap: 4)
- [ ] SYNC-14: insights/data-collection-rule — 0.6 → 0.10 (gap: 4)
- [ ] SYNC-15: app-configuration/configuration-store — 0.6 → 0.9 (gap: 3)
- [ ] SYNC-16: insights/action-group — 0.5 → 0.8 (gap: 3)
- [ ] SYNC-17: insights/scheduled-query-rule — 0.3 → 0.6 (gap: 3)
- [ ] SYNC-18: insights/component — 0.4 → 0.7 (gap: 3)
- [ ] SYNC-19: search/search-service — 0.9 → 0.12 (gap: 3)
- [ ] SYNC-20: managed-identity/user-assigned-identity — 0.2 → 0.5 (gap: 3)
- [ ] SYNC-21: databricks/access-connector — 0.1 → 0.4 (gap: 3)
- [ ] SYNC-22: network/route-table — 0.2 → 0.5 (gap: 3)
- [ ] SYNC-23: web/static-site — 0.6 → 0.9 (gap: 3)
- [ ] SYNC-24: db-for-postgre-sql/flexible-server — 0.13 → 0.15 (gap: 2)
- [ ] SYNC-25: service-bus/namespace — 0.14 → 0.16 (gap: 2)
- [ ] SYNC-26: network/network-security-group — 0.3 → 0.5 (gap: 2)

### Low Priority (1 version gap)

- [ ] SYNC-27: insights/activity-log-alert — 0.3 → 0.4 (gap: 1)
- [ ] SYNC-28: insights/metric-alert — 0.3 → 0.4 (gap: 1)

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
- [ ] app-configuration/configuration-store/key-value/main.bicep
- [ ] app-configuration/configuration-store/replica/main.bicep
- [ ] container-registry/registry/credential/main.bicep
- [ ] db-for-postgre-sql/flexible-server/administrator/main.bicep
- [ ] db-for-postgre-sql/flexible-server/advanced-threat-protection-setting/main.bicep
- [ ] db-for-postgre-sql/flexible-server/configuration/main.bicep
- [ ] db-for-postgre-sql/flexible-server/database/main.bicep
- [ ] db-for-postgre-sql/flexible-server/firewall-rule/main.bicep
- [ ] event-hub/namespace/authorization-rule/main.bicep
- [ ] event-hub/namespace/disaster-recovery-config/main.bicep
- [ ] event-hub/namespace/eventhub/authorization-rule/main.bicep
- [ ] event-hub/namespace/eventhub/consumergroup/main.bicep
- [ ] event-hub/namespace/eventhub/main.bicep
- [ ] event-hub/namespace/network-rule-set/main.bicep
- [ ] cache/redis/access-policy-assignment/main.bicep
- [ ] cache/redis/access-policy/main.bicep
- [ ] cache/redis/firewall-rule/main.bicep
- [ ] cache/redis/linked-servers/main.bicep
- [ ] insights/private-link-scope/scoped-resource/main.bicep
- [ ] search/search-service/shared-private-link-resource/main.bicep
- [ ] service-bus/namespace/authorization-rule/main.bicep
- [ ] service-bus/namespace/disaster-recovery-config/main.bicep
- [ ] service-bus/namespace/migration-configuration/main.bicep
- [ ] service-bus/namespace/network-rule-set/main.bicep
- [ ] service-bus/namespace/queue/authorization-rule/main.bicep
- [ ] service-bus/namespace/topic/authorization-rule/main.bicep
- [ ] service-bus/namespace/topic/subscription/main.bicep
- [ ] service-bus/namespace/topic/subscription/rule/main.bicep

### META-2: Files missing compliance + evidenceOfNonCompliance (have owner) — 47 files

- [ ] container-registry/registry/replication/main.bicep
- [ ] container-registry/registry/scope-map/main.bicep
- [ ] container-registry/registry/webhook/main.bicep
- [ ] container-service/managed-cluster/agent-pool/main.bicep
- [ ] container-service/managed-cluster/maintenance-configurations/main.bicep
- [ ] insights/component/linkedStorageAccounts/main.bicep
- [ ] managed-identity/user-assigned-identity/federated-identity-credential/main.bicep
- [ ] operational-insights/workspace/data-export/main.bicep
- [ ] operational-insights/workspace/data-source/main.bicep
- [ ] operational-insights/workspace/linked-service/main.bicep
- [ ] operational-insights/workspace/linked-storage-account/main.bicep
- [ ] operational-insights/workspace/saved-search/main.bicep
- [ ] operational-insights/workspace/storage-insight-config/main.bicep
- [ ] operational-insights/workspace/table/main.bicep
- [ ] sql/server/audit-settings/main.bicep
- [ ] sql/server/database/backup-long-term-retention-policy/main.bicep
- [ ] sql/server/database/backup-short-term-retention-policy/main.bicep
- [ ] sql/server/elastic-pool/main.bicep
- [ ] sql/server/encryption-protector/main.bicep
- [ ] sql/server/firewall-rule/main.bicep
- [ ] sql/server/key/main.bicep
- [ ] sql/server/outbound-firewall-rule/main.bicep
- [ ] sql/server/security-alert-policy/main.bicep
- [ ] sql/server/sql-vulnerability-assessment/main.bicep
- [ ] sql/server/virtual-network-rule/main.bicep
- [ ] sql/server/vulnerability-assessment/main.bicep
- [ ] storage/storage-account/blob-service/container/immutability-policy/main.bicep
- [ ] storage/storage-account/local-user/main.bicep
- [ ] storage/storage-account/queue-service/main.bicep
- [ ] storage/storage-account/table-service/main.bicep
- [ ] storage/storage-account/table-service/table/main.bicep
- [ ] web/site/basic-publishing-credentials-policy/main.bicep
- [ ] web/site/config--appsettings/main.bicep
- [ ] web/site/config--authsettingsv2/main.bicep
- [ ] web/site/config--logs/main.bicep
- [ ] web/site/config--web/main.bicep
- [ ] web/site/extensions--msdeploy/main.bicep
- [ ] web/site/hybrid-connection-namespace/relay/main.bicep
- [ ] web/site/slot/basic-publishing-credentials-policy/main.bicep
- [ ] web/site/slot/config--appsettings/main.bicep
- [ ] web/site/slot/config--authsettingsv2/main.bicep
- [ ] web/site/slot/extensions--msdeploy/main.bicep
- [ ] web/site/slot/hybrid-connection-namespace/relay/main.bicep
- [ ] web/site/slot/main.bicep
- [ ] web/static-site/config/main.bicep
- [ ] web/static-site/custom-domain/main.bicep
- [ ] web/static-site/linked-backend/main.bicep

### META-3: Files missing only evidenceOfNonCompliance (have owner + compliance) — 7 files

- [ ] data-factory/factory/managed-virtual-network/main.bicep
- [ ] data-factory/factory/managed-virtual-network/managed-private-endpoint/main.bicep
- [ ] network/private-endpoint/private-dns-zone-group/main.bicep
- [ ] service-bus/namespace/queue/main.bicep
- [ ] service-bus/namespace/topic/main.bicep
- [ ] storage/storage-account/blob-service/main.bicep
- [ ] storage/storage-account/file-service/main.bicep

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
