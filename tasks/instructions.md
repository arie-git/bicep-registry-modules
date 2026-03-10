# Multi-Agent Instructions

**RULE: Always use installed Azure skills (`/azure:*`) when performing Azure-related work.** See the Mandatory Skill Usage Policy in the Azure Skills section below. Do not perform Azure tasks manually when a skill covers it — skills provide up-to-date best practices, correct API patterns, and validated configurations that manual work may miss.

## Scope

Only the **22 whitelisted Azure components** (defined in `policy/knowledge_base/Azure-Components/`) are in scope. All other upstream AVM modules are ignored.

### CI/CD

AMAVM uses **Azure DevOps** for build and publishing pipelines (`amavm/pipelines/`). This is intentional and will NOT change. Do not plan any CI/CD migration. Microsoft AVM's GitHub Actions workflows are irrelevant to amavm.

### File Scope

- **Only work with:** `.bicep` files and their associated `README.md` files.
- **Ignore:** JSON ARM templates (`main.json`), pipelines, GitHub workflows, PowerShell scripts, test infrastructure, and all other file types unless they are directly referenced by a `.bicep` file (e.g., `upstream.json`, `version.json`).
- **Read-only sources:** `microsoft-avm/` and `policy/` — NEVER modify files outside `amavm/verified-modules/`.

### Write Boundary

**All file writes MUST be within `amavm/verified-modules/` only.** No exceptions.

- `microsoft-avm/` — read-only reference. Never modify.
- `policy/` — read-only compliance source. Never modify.
- `amavm/pipelines/`, `amavm/utils/`, `amavm/samples/` — out of scope. Never modify.
- `tasks/` — task tracking files only (todo.md, lessons.md, instructions.md).

### Validation Toolchain

All three tools are available in this environment:

| Tool | Version | Path |
|---|---|---|
| Bicep CLI | 0.41.2 | `/usr/local/bin/bicep` |
| Azure CLI | 2.84.0 | `/usr/bin/az` |
| PowerShell | 7.5.4 | `/usr/bin/pwsh` |

#### 1. Bicep Build (minimum acceptance gate)

Validates that a module compiles without errors. **Every change must pass this.**

```bash
bicep build amavm/verified-modules/bicep/res/<category>/<module>/main.bicep
```

#### 2. Bicep Lint

Shows warnings (API version drift, unused imports, etc.). Informational — warnings don't block.

```bash
bicep lint amavm/verified-modules/bicep/res/<category>/<module>/main.bicep
```

#### 3. Build Script (PowerShell) — full module build

Runs code checking and optionally generates README.md. Run from `amavm/verified-modules/`.

```bash
cd /workspaces/bicep-registry-modules/amavm/verified-modules
pwsh -Command "./utils/buildBicepFiles.ps1 -moduleName 'res/<category>/<module>'"
```

With README generation:

```bash
pwsh -Command "./utils/buildBicepFiles.ps1 -moduleName 'res/<category>/<module>' -buildReadme 'True'"
```

#### 4. README Generation (PowerShell)

Generates `README.md` from `main.bicep` metadata and tests. Run from `amavm/verified-modules/`.

```bash
pwsh -Command "Import-Module ./utils/setModuleReadMe.ps1 -Force; Set-ModuleReadMe -TemplateFilePath 'bicep/res/<category>/<module>/main.bicep'"
```

#### 5. README Comparison (PowerShell)

Checks if generated README matches the committed one. Used by CI to detect drift.

```bash
pwsh -Command "./utils/compareReadMe.ps1"
```

#### Validation Sequence for Karen (Validator Agent)

1. `bicep build` — must exit 0 (hard gate)
2. `bicep lint` — review warnings, flag anything critical
3. `pwsh buildBicepFiles.ps1` — full build check
4. `pwsh setModuleReadMe.ps1` + `compareReadMe.ps1` — README drift check
5. `/azure:azure-validate` — pre-deployment readiness check (if `az login` available)
6. `/azure:azure-compliance` — spot-check module against subscription policies (if `az login` available)

### Azure Skills (Slash Commands)

The following Azure skills are installed and available via `/skill-name` syntax. Use them to leverage Azure-specific capabilities without leaving the agent workflow.

#### Resource & Infrastructure Skills

| Skill | Trigger | Use For |
|---|---|---|
| `/azure:azure-prepare` | Creating or modernizing apps, generating Bicep/Terraform, Dockerfiles, `azure.yaml` | Scaffolding new Azure apps, adding infra for deployment |
| `/azure:azure-validate` | Pre-deployment validation | Deep checks on Bicep/Terraform, config, permissions before deploying |
| `/azure:azure-deploy` | Deploying already-prepared apps (`azd up`, `bicep deploy`, `terraform apply`) | Executing deployments — requires `.azure/plan.md` from `azure-prepare` |
| `/azure:azure-resource-lookup` | Listing/finding Azure resources ("list my VMs", "show storage accounts") | Resource inventory and discovery via Azure Resource Graph |
| `/azure:azure-resource-visualizer` | Architecture diagrams from resource groups | Generating Mermaid diagrams showing resource relationships |

#### Security, Compliance & Identity Skills

| Skill | Trigger | Use For |
|---|---|---|
| `/azure:azure-compliance` | Compliance scans, security audits, Key Vault expiration checks | Best-practices assessment, expired certs/secrets, orphaned resources |
| `/azure:azure-rbac` | Finding the right RBAC role for least-privilege access | Role selection, CLI/Bicep role assignment generation |
| `/azure:entra-app-registration` | App registration, OAuth, MSAL integration | Configuring Entra ID authentication and service principals |

#### Diagnostics, Cost & Monitoring Skills

| Skill | Trigger | Use For |
|---|---|---|
| `/azure:azure-diagnostics` | Debugging production issues (Container Apps, Function Apps, KQL) | Log analysis, health checks, cold start/image pull troubleshooting |
| `/azure:azure-cost-optimization` | Reducing Azure spend | Utilization analysis, orphaned resources, rightsizing recommendations |
| `/azure:appinsights-instrumentation` | Instrumenting apps with Application Insights | Telemetry patterns, SDK setup, APM best practices |
| `/azure:azure-kusto` | KQL queries against Azure Data Explorer / ADX | Log analytics, time series, anomaly detection |

#### Compute, Storage & Messaging Skills

| Skill | Trigger | Use For |
|---|---|---|
| `/azure:azure-compute` | VM size recommendations, VMSS, autoscale | Workload-based VM selection, pricing estimates, scale-out guidance |
| `/azure:azure-storage` | Blob, File Shares, Queue, Table, Data Lake | Upload/download, access tiers, lifecycle management |
| `/azure:azure-messaging` | Event Hubs / Service Bus SDK issues | AMQP errors, message lock, checkpoint issues, SDK troubleshooting |

#### AI & Agent Skills

| Skill | Trigger | Use For |
|---|---|---|
| `/azure:azure-ai` | AI Search, Speech, OpenAI, Document Intelligence | Vector/hybrid search, speech-to-text, OCR |
| `/azure:azure-aigateway` | API Management as AI Gateway | Semantic caching, token limits, content safety, load balancing |
| `/azure:microsoft-foundry` | Foundry agents end-to-end | Deploy, evaluate, optimize agents; dataset curation, batch eval |
| `/azure:azure-hosted-copilot-sdk` | Building GitHub Copilot SDK apps on Azure | Scaffold, deploy, and host Copilot-powered apps |

#### Migration & Other Skills

| Skill | Trigger | Use For |
|---|---|---|
| `/azure:azure-cloud-migrate` | Cross-cloud migration (AWS/GCP to Azure) | Assessment reports, code conversion to Azure services |

#### Mandatory Skill Usage Policy

**These skills MUST be used whenever their trigger conditions are met.** Do not perform Azure work manually when a skill covers it.

| When you are... | You MUST use |
|---|---|
| Creating or modifying RBAC / role assignments in Bicep | `/azure:azure-rbac` to identify the correct least-privilege role |
| Auditing a module for policy compliance | `/azure:azure-compliance` alongside the local `policy/Generic/` check |
| Validating Bicep before marking a task done | `/azure:azure-validate` after `bicep build` passes |
| Debugging a deployment failure or reading logs | `/azure:azure-diagnostics` |
| Working with `diagnosticSettings`, log categories, or KQL | `/azure:azure-kusto` for query help |
| Adding or modifying Application Insights telemetry | `/azure:appinsights-instrumentation` |
| Working with storage (blob, queue, table, lifecycle) params | `/azure:azure-storage` for API patterns |
| Working with Event Hub or Service Bus SDK/config issues | `/azure:azure-messaging` |
| Generating Bicep/Terraform for a new module or feature | `/azure:azure-prepare` for scaffolding best practices |
| Looking up deployed resources or checking subscription state | `/azure:azure-resource-lookup` |
| Creating architecture diagrams for READMEs or docs | `/azure:azure-resource-visualizer` |
| Setting up Entra ID auth, app registrations, or MSAL | `/azure:entra-app-registration` |
| Evaluating cost impact of a module's SKU/tier defaults | `/azure:azure-cost-optimization` |

**Invocation:** Skills are invoked as `/azure:<skill-name>` in conversation.

**Prerequisites:** Skills that query live Azure resources (resource-lookup, diagnostics, cost-optimization, compliance) require an authenticated Azure CLI session (`az login`). If not authenticated, note the finding and flag it for later verification.

**Sequencing:**
- `azure-prepare` → `azure-validate` → `azure-deploy` (never skip validate)
- `azure-compliance` + `azure-rbac` should run during policy audit phases
- `azure-validate` should run as part of Karen's validation sequence (after `bicep build`)

---

## Whitelisted Components → Module Mapping

| # | Whitelisted Component | AVM Resource Path | Upstream Version | amavm Synced To | amavm Status |
|---|---|---|---|---|---|
| 1 | AI-Search | search/search-service | 0.12 | 0.12 | Present |
| 2 | AI-services | cognitive-services/account | 0.14 | 0.14 | Present |
| 3 | App-Configuration | app-configuration/configuration-store | 0.9 | 0.9 | Present |
| 4 | Application-Gateway | network/application-gateway | 0.9 | 0.9 | Present |
| 5 | Application-Insights | insights/component | 0.7 | 0.7 | Present |
| 6 | App-Service | web/site + web/serverfarm | 0.22, 0.7 | 0.22, 0.7 | Present |
| 7 | Container-Registry | container-registry/registry | 0.11 | 0.11 | Present |
| 8 | Cosmos-DB | document-db/database-account | 0.19 | 0.19 | Present |
| 9 | Databricks | databricks/workspace, databricks/access-connector | 0.12, 0.4 | 0.12, 0.4 | Present |
| 10 | Data-Factory | data-factory/factory | 0.11 | 0.11 | Present |
| 11 | Event-Hubs | event-hub/namespace | 0.14 | 0.14 | Present (ORPHANED upstream) |
| 12 | Key-Vault | key-vault/vault | 0.13 | 0.13 | Present |
| 13 | Kubernetes-Service | container-service/managed-cluster | 0.12 | 0.12 | Present |
| 14 | Log-Analytics-Workspace | operational-insights/workspace | 0.15 | 0.15 | Present |
| 15 | Monitor | insights/* (action-group, metric-alert, etc.) | various | various | Present |
| 16 | **Notification-Hubs** | _(no upstream AVM module)_ | N/A | N/A | **DEFERRED** |
| 17 | PostgreSQL | db-for-postgre-sql/flexible-server | 0.15 | 0.15 | Present |
| 18 | Redis | cache/redis | 0.16 | 0.16 | Present |
| 19 | Service-Bus | service-bus/namespace | 0.16 | 0.16 | Present |
| 20 | SQL-Database | sql/server | 0.21 | 0.21 | Present |
| 21 | Storage-Account | storage/storage-account | 0.32 | 0.32 | Present |
| 22 | Subscription | _(platform-level, not a res module)_ | N/A | N/A | N/A |

**Note:** "amavm Synced To" reflects the upstream version whose API versions and key params were synced into the fork. However, 17 modules' `upstream.json` files still show the original fork-point version — see SYNC Phase 2 in `tasks/todo.md`.

### Supporting Modules (present in amavm, required by whitelisted modules)

- `managed-identity/user-assigned-identity`
- `network/private-endpoint`, `network/virtual-network`, `network/network-security-group`, `network/route-table`
- `network/application-gateway-web-application-firewall-policy`
- `insights/diagnostic-setting`, `insights/data-collection-endpoint`, `insights/data-collection-rule`
- `insights/private-link-scope`, `insights/scheduled-query-rule`, `insights/webtest`
- `insights/action-group`, `insights/activity-log-alert`, `insights/metric-alert`
- `web/static-site`

---

## Projects Overview

### Project 1: Microsoft AVM (Upstream) — Read-Only Reference

- **Location:** `microsoft-avm/avm/res/` (only whitelisted modules)
- **Role:** Source of truth for module structure. Never modify.

### Project 2: Company AVM (amavm) — Active Development

- **Location:** `amavm/verified-modules/bicep/res/`
- **Shared code:** `amavm/verified-modules/bicep-shared/`
  - `types.bicep` — shared type definitions (corsRuleType, customerManagedKeyType, diagnosticSettingType, lockType, managedIdentitiesType, networkAclsType, privateEndpointType, roleAssignmentType)
  - `environments.bicep` — shared constants (telemetryId, builtInRoleNames, nvaIpAddress)
- **Role:** Active development target. Only writable location.

### Project 3: Company Policy & Knowledge Base — Read-Only Compliance Source

- **Location:** `policy/`
- **Policy definitions:** `policy/Generic/*.json` (315 JSON files)
- **Knowledge base:** `policy/knowledge_base/Azure-Components/<Component>/`
- **Role:** Source of truth for compliance. Never modify.

### How Projects Relate

```
microsoft-avm/avm/res/  (upstream, read-only)
         |
         | fork + customize per checklist below
         v
amavm/verified-modules/bicep/res/  (company modules, writable)
         |
         | must comply with
         v
policy/Generic/ + policy/knowledge_base/  (company policy, read-only)
```

---

## Module Customization Checklist

When forking an upstream module into amavm, or auditing an existing module, every item below must be satisfied. This is derived from `amavm/verified-modules/README.md`.

### Metadata (in main.bicep)

- [ ] `metadata owner = 'AMCCC'`
- [ ] `metadata compliance = '<value>'` present
- [ ] `metadata complianceVersion = '<value>'` present

### Parameters

- [ ] Every parameter's `@description()` starts with `Required.`, `Optional.`, `Conditional.`, or `Generated.`

### Outputs

- [ ] `evidenceOfNonCompliance` output parameter present

### Variables

- [ ] `versionInfo` variable present
- [ ] `moduleVersion` variable present

### Shared Types

- [ ] In-file type definitions replaced with imports from `../../../../bicep-shared/types.bicep`

### Telemetry

- [ ] `avmTelemetry` resource name uses `'${telemetryId}$'` not `'46d3xbcp'`
- [ ] Telemetry name field truncated to 64 chars

### Role Definitions

- [ ] Imports `builtInRoleNames as minimalBuiltInRoleNames` and `telemetryId` from `../../../../bicep-shared/environments.bicep`
- [ ] Pre-existing `builtInRoleNames` renamed to `specificBuiltInRoleNames`
- [ ] Common roles removed from `specificBuiltInRoleNames`
- [ ] `var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)` present

### Tags

- [ ] `var finalTags = union(tags ?? {}, { telemetryAVM: telemetryId })` present
- [ ] All resource `tags` properties use `finalTags` instead of `tags`

### Diagnostic Settings

- [ ] No `{ categoryGroup: 'allLogs' }` — replaced with explicit list of supported categories

### Tests

- [ ] `tests/e2e/defaults/` folder exists with compilable test
- [ ] `tests/e2e/max/` folder exists with compilable test
- [ ] `tests/e2e/waf-aligned/` folder exists with compilable test

### Documentation

- [ ] `README.md` present and up to date with module's current state

### Version Files

- [ ] `version.json` present with amavm version
- [ ] `upstream.json` present with upstream version reference

---

## Specialized Agents

### Agent 1: Bicep Tech Debt Analyst

**Purpose:** Analyzes existing amavm modules against the Module Customization Checklist above and the upstream module to identify gaps.

**Trigger:** For each module in TD-1 (upstream drift) and TD-3 (checklist compliance).

**Inputs:**
- amavm module path: `amavm/verified-modules/bicep/res/<category>/<module>/main.bicep`
- Upstream module path: `microsoft-avm/avm/res/<category>/<module>/main.bicep`
- Module Customization Checklist (above)

**Process:**
1. Read the amavm `main.bicep`
2. Read the upstream `main.bicep` for comparison
3. Check every item in the Module Customization Checklist
4. Compare upstream version (from upstream `version.json`) vs amavm `upstream.json`
5. Report: which checklist items pass, which fail, what upstream changes are missing

**Output:** Per-module tech debt report with specific line references and fix descriptions.

### Agent 2: Azure Policy Expert

**Purpose:** Cross-references amavm modules against company policy definitions to verify compliance.

**Trigger:** For each module in TD-2 (policy compliance audit) and all GAP modules.

**Required skills:** `/azure:azure-compliance` (for live subscription policy checks), `/azure:azure-rbac` (for role assignment validation).

**Inputs:**
- amavm module path: `amavm/verified-modules/bicep/res/<category>/<module>/main.bicep`
- Relevant policies: `policy/Generic/*.json` (filtered by service name)
- Knowledge base: `policy/knowledge_base/Azure-Components/<Component>/Security-Baseline.rst`

**Process:**
1. Read the module's `main.bicep`
2. Identify the Azure service type
3. Find all matching policy JSON files in `policy/Generic/`
4. Read the component's `Security-Baseline.rst`
5. For each policy: verify the module enforces it (via defaults, allowed values, or hardcoded config)
6. Run `/azure:azure-compliance` to cross-check findings against live subscription policies (if authenticated)
7. Run `/azure:azure-rbac` to validate any `roleAssignments` use least-privilege roles
8. Flag any policy that the module does NOT enforce or allows to be bypassed

**Output:** Per-module policy compliance report listing enforced vs. unenforced policies.

### Agent 3: Validator ("Karen")

**Purpose:** Strict acceptance gate. Verifies that completed work actually meets all acceptance criteria before a task can be marked done.

**Trigger:** After any GAP or TD task claims to be complete.

**Required skills:** `/azure:azure-validate` (pre-deployment readiness), `/azure:azure-compliance` (policy spot-check).

**Process:**
1. Re-read the task's acceptance criteria from `tasks/todo.md`
2. For each criterion:
   - **Bicep compiles:** Run `bicep build <main.bicep>` — must exit 0
   - **Checklist items:** Re-run the Module Customization Checklist against the module
   - **Policy compliance:** Spot-check key policies from `policy/Generic/`
   - **README exists:** Verify `README.md` is present
   - **Tests exist:** Verify `tests/e2e/defaults/`, `tests/e2e/max/`, `tests/e2e/waf-aligned/` exist
   - **Version files:** Verify `version.json` and `upstream.json` exist and are well-formed
3. Run `/azure:azure-validate` on the module's Bicep to check deployment readiness (if `az login` available)
4. Run `/azure:azure-compliance` to spot-check the module against subscription policies (if `az login` available)
5. If ANY criterion fails: reject with specific failure reason. Do not approve partial work.
6. If ALL criteria pass: approve and the task can be marked `[x]` in `tasks/todo.md`.

**Output:** PASS or FAIL with itemized results. Karen does not negotiate.

---

## Orchestration Model

Follow `claude.md` at repo root.

### Main Agent (Orchestrator)

- Plan mode for non-trivial tasks.
- Track all work in `tasks/todo.md`.
- Delegate to specialized agents. Never mark done without Karen's approval.

### Workflow for GAP Modules

1. **Plan agent** — design module implementation strategy
2. `/azure:azure-rbac` — identify least-privilege roles for the resource type's `roleAssignments`
3. **Azure Policy Expert** + `/azure:azure-compliance` — identify all policies the module must satisfy
4. **General-purpose agent (worktree)** — implement the module
5. **Bicep Tech Debt Analyst** — verify checklist compliance
6. `/azure:azure-validate` — pre-deployment readiness check on completed module
7. **Karen (Validator)** — final acceptance gate (includes skill-based checks)

### Workflow for Tech Debt

1. **Bicep Tech Debt Analyst** — audit module, produce itemized findings
2. **General-purpose agent (worktree)** — fix each finding
3. `/azure:azure-validate` — verify the fixed module is deployment-ready
4. **Karen (Validator)** — verify fixes, run `bicep build`

### Workflow for DRCP Test Scenarios

1. **Plan agent** — design migration/integration strategy
2. `/azure:azure-rbac` — verify role assignments in scenario are least-privilege
3. **General-purpose agent (worktree)** — implement changes
4. `bicep build` — must pass (use `swapPeReferences.ps1` for local PE path swap if no ACR access)
5. `/azure:azure-validate` — pre-deployment readiness check
6. `/azure:azure-resource-visualizer` — generate architecture diagram for README (requires deployed resources)
7. `/azure:azure-diagnostics` — troubleshoot any deployment failures

### Workflow for Policy Audits

1. **Azure Policy Expert** — static analysis against `policy/Generic/` and knowledge base
2. `/azure:azure-compliance` — live compliance scan against subscription policies
3. `/azure:azure-rbac` — validate role definitions are least-privilege
4. Update `evidenceOfNonCompliance` output and `[Policy: drcp-xxx-nn]` tags in parameter descriptions

### Workflow for Upstream Sync

1. Diff upstream vs fork params, types, resources, API versions
2. `/azure:azure-validate` — check new API versions and params are valid
3. Update `upstream.json`, verify `evidenceOfNonCompliance`, run `bicep build`
4. **Karen (Validator)** — final acceptance gate

### Self-Improvement

- Update `tasks/lessons.md` after any user correction.
- Review lessons at session start.

## Core Principles (from claude.md)

1. **Simplicity First** — minimal code impact.
2. **No Laziness** — find root causes, no temporary fixes.
3. **Minimal Impact** — only touch what's necessary.
4. **Demand Elegance** — for non-trivial changes, pause and ask "is there a more elegant way?"
5. **Use Skills** — always use Azure skills when their trigger conditions are met. Never do manually what a skill can do.
