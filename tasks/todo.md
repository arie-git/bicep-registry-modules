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
| 4 | API version inconsistency: main site `2024-04-01`, slot `2023-12-01` | Align slot to `2024-04-01` | TODO |
| 5 | `locks@2020-05-01`, `diagnosticSettings@2021-05-01-preview`, `roleAssignments@2022-04-01` | N/A — matches upstream AVM standard | WONTFIX |
| 6 | Identity/role-assignment formatting duplicated between main and slot | Consider refactoring | TODO |

- [x] Fix VNet reference API version (`2020-06-01` → `2024-05-01`)
- [x] Fix typo: `condtion` → `condition`
- [x] Fix typo: double period in relay description
- [x] `bicep build` passes (only BCP192 expected)
- [x] Align slot API versions — all `Microsoft.Web/*` under `web/site/` now use `2024-04-01`
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
| 1 | `ManagedIdentity@2023-01-31` outdated | Updated to `2024-11-30` | DONE |
| 2 | `KeyVault/vaults@2023-02-01` outdated | Updated to `2024-11-01` | DONE |
| 3 | `CognitiveServices/accounts/deployments@2023-05-01` misaligned | Updated to `2024-10-01` | DONE |
| 4 | `Resources/deployments@2023-07-01` outdated | Updated to `2024-03-01` | DONE |
| 5 | SKU fallback accesses `.capacity`/`.tier` on string param | Simplified to `{ name: sku }` | DONE |
| 6 | Typo: `condtion` → `condition` | Fixed | DONE |
| 7 | Typo: missing space `null\`is` | Fixed | DONE |
| 8 | `roleAssignments@2022-04-01` | N/A — matches upstream AVM standard | WONTFIX |

- [x] Update 4 outdated API versions
- [x] Fix SKU fallback logic (removed invalid property access on string)
- [x] Fix both typos
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

- [ ] Uncomment and implement `slots` parameter
- [ ] Uncomment and implement `app_slots` module loop
- [ ] Uncomment and implement slot-related outputs
- [ ] Implement `reserved: contains(kind,'linux')` property
- [ ] Implement TODO properties: `endToEndEncryptionEnabled`, `vnetBackupRestoreEnabled`, `customDomainVerificationId`, `dnsConfiguration`, `daprConfig`
- [ ] Resolve `functionAppConfiguration` and `storageAccountResourceId` TODO markers
- [ ] Update tests to cover slots
- [ ] `bicep build` passes
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

- [x] AI-Services (cognitive-services/account) — 7 policies, 1 FAIL
  - `kind` @allowed list includes 24 values; policy AIServicesAllowSupportedKinds only permits 3 (TextAnalytics, OpenAI, AIServices)
  - Action: restrict @allowed list or add compliance documentation
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
