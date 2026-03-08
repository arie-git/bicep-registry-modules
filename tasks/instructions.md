# Multi-Agent Instructions

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

---

## Whitelisted Components → Module Mapping

| # | Whitelisted Component | AVM Resource Path | Upstream Version | amavm Status |
|---|---|---|---|---|
| 1 | AI-Search | search/search-service | 0.9 | Present |
| 2 | AI-services | cognitive-services/account | 0.9 | Present |
| 3 | App-Configuration | app-configuration/configuration-store | 0.6 | Present |
| 4 | Application-Gateway | network/application-gateway | 0.5 | Present |
| 5 | Application-Insights | insights/component | 0.4 | Present |
| 6 | App-Service | web/site + web/serverfarm | 0.11, 0.2 | Present |
| 7 | Container-Registry | container-registry/registry | 0.3 | Present |
| 8 | **Cosmos-DB** | document-db/database-account | 0.19 | **GAP** |
| 9 | Databricks | databricks/workspace, databricks/access-connector | 0.5, 0.1 | Present |
| 10 | Data-Factory | data-factory/factory | 0.3 | Present |
| 11 | **Event-Hubs** | event-hub/namespace | 0.14 | **GAP** |
| 12 | Key-Vault | key-vault/vault | 0.6 | Present |
| 13 | Kubernetes-Service | container-service/managed-cluster | 0.3 | Present |
| 14 | Log-Analytics-Workspace | operational-insights/workspace | 0.3 | Present |
| 15 | Monitor | insights/* (action-group, metric-alert, etc.) | various | Present |
| 16 | **Notification-Hubs** | _(no upstream AVM module)_ | N/A | **GAP** |
| 17 | PostgreSQL | db-for-postgre-sql/flexible-server | 0.13 | Present |
| 18 | **Redis** | cache/redis | 0.16 | **GAP** |
| 19 | Service-Bus | service-bus/namespace | 0.14 | Present |
| 20 | SQL-Database | sql/server | 0.4 | Present |
| 21 | Storage-Account | storage/storage-account | 0.10 | Present |
| 22 | Subscription | _(platform-level, not a res module)_ | N/A | N/A |

### Supporting Modules (present in amavm, required by whitelisted modules)

- `managed-identity/user-assigned-identity`
- `network/private-endpoint`, `network/virtual-network`, `network/network-security-group`, `network/route-table`
- `network/application-gateway-web-application-firewall-policy`
- `insights/diagnostic-setting`, `insights/data-collection-endpoint`, `insights/data-collection-rule`
- `insights/private-link-scope`, `insights/scheduled-query-rule`, `insights/webtest`
- `insights/action-group`, `insights/activity-log-alert`
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
6. Flag any policy that the module does NOT enforce or allows to be bypassed

**Output:** Per-module policy compliance report listing enforced vs. unenforced policies.

### Agent 3: Validator ("Karen")

**Purpose:** Strict acceptance gate. Verifies that completed work actually meets all acceptance criteria before a task can be marked done.

**Trigger:** After any GAP or TD task claims to be complete.

**Process:**
1. Re-read the task's acceptance criteria from `tasks/todo.md`
2. For each criterion:
   - **Bicep compiles:** Run `bicep build <main.bicep>` — must exit 0
   - **Checklist items:** Re-run the Module Customization Checklist against the module
   - **Policy compliance:** Spot-check key policies from `policy/Generic/`
   - **README exists:** Verify `README.md` is present
   - **Tests exist:** Verify `tests/e2e/defaults/`, `tests/e2e/max/`, `tests/e2e/waf-aligned/` exist
   - **Version files:** Verify `version.json` and `upstream.json` exist and are well-formed
3. If ANY criterion fails: reject with specific failure reason. Do not approve partial work.
4. If ALL criteria pass: approve and the task can be marked `[x]` in `tasks/todo.md`.

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
2. **Azure Policy Expert** — identify all policies the module must satisfy
3. **General-purpose agent (worktree)** — implement the module
4. **Bicep Tech Debt Analyst** — verify checklist compliance
5. **Karen (Validator)** — final acceptance gate

### Workflow for Tech Debt

1. **Bicep Tech Debt Analyst** — audit module, produce itemized findings
2. **General-purpose agent (worktree)** — fix each finding
3. **Karen (Validator)** — verify fixes, run `bicep build`

### Self-Improvement

- Update `tasks/lessons.md` after any user correction.
- Review lessons at session start.

## Core Principles (from claude.md)

1. **Simplicity First** — minimal code impact.
2. **No Laziness** — find root causes, no temporary fixes.
3. **Minimal Impact** — only touch what's necessary.
4. **Demand Elegance** — for non-trivial changes, pause and ask "is there a more elegant way?"
