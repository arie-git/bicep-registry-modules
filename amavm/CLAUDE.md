# AMAVM — Azure Module Verified Modules

AMAVM is a fork of Microsoft's Azure Verified Modules (AVM) with DRCP platform-specific hardening. Modules are published to a private Azure Container Registry and consumed as `br/amavm:res/<namespace>/<resource>:<version>`.

---

## Workflow Discipline (READ FIRST)

1. **Read `amavm/verified-modules/todo.md`** before starting work — check what's done, what's in progress
2. **Always call Azure MCP tools first** — run `mcp__plugin_azure_azure__get_azure_bestpractices` (resource: "general", action: "code-generation") BEFORE writing or modifying any Bicep code. Use `mcp__plugin_azure_azure__documentation` for service-specific details. This is non-negotiable.
3. **Consult DRCP policy definitions** in `/policy/Generic/` for the resource type being configured
4. **Update `todo.md`** as you go — mark items `[x]` when complete, add blockers

---

## Repository Structure

```
amavm/verified-modules/
├── bicep/
│   ├── res/                          # Resource modules (one per Azure resource type)
│   │   └── <namespace>/<resource>/   # e.g. web/site, storage/storage-account
│   │       ├── main.bicep            # Module implementation
│   │       ├── README.md             # Auto-generated documentation
│   │       ├── version.json          # AMAVM version (published as <major>.<minor>.0)
│   │       ├── upstream.json         # Upstream AVM version this module is based on
│   │       ├── dependencies.json     # Cross-module dependencies (e.g. private-endpoint)
│   │       ├── <sub-resource>/       # Child resources (e.g. config--appsettings, slot)
│   │       │   └── main.bicep
│   │       └── tests/
│   │           └── e2e/
│   │               ├── <kind>.defaults/   # Minimal deployment test
│   │               ├── <kind>.max/        # Full-featured deployment test
│   │               └── waf-aligned/       # WAF best-practices test
│   ├── ptn/                          # Pattern modules (multi-resource compositions)
│   └── utl/                          # Utility modules (e.g. naming convention)
├── bicep-shared/
│   ├── types.bicep                   # Shared type definitions (diagnosticSettingType, privateEndpointType, etc.)
│   └── environments.bicep            # Shared constants (telemetryId, builtInRoleNames, NVA IP)
├── bicepconfig.json                  # Linter rules + registry aliases (br/amavm → s2amavmprdsecacr.azurecr.io)
├── pipelines/
│   ├── buildBicepFiles.yaml          # CI: build + README comparison on push to non-main
│   └── publishToBCR.yaml             # CD: build + publish to ACR + HTML docs
├── utils/
│   ├── buildBicepFiles.ps1           # Build all modules (restore + compile + optional README)
│   ├── setModuleReadMe.ps1           # Generate README from main.bicep + tests
│   ├── publishToBCR.ps1              # Publish to ACR
│   ├── compareReadMe.ps1             # CI check: committed README matches generated
│   └── readmePublisher/              # README → HTML conversion for docs website
├── README.md                         # Full SDLC documentation
└── todo.md                           # Active task tracker
```

---

## AMAVM vs Upstream AVM — Key Differences

AMAVM modules are derived from Microsoft AVM but differ in these ways:

| Aspect | Upstream AVM | AMAVM |
|--------|-------------|-------|
| Registry | `mcr.microsoft.com/bicep` (public) | `s2amavmprdsecacr.azurecr.io` (private ACR) |
| Shared types | Inline per module | Imported from `bicep-shared/types.bicep` |
| Role definitions | All roles inline | Common roles in `bicep-shared/environments.bicep`, module-specific in `specificBuiltInRoleNames` |
| Telemetry | `46d3xbcp` prefix | `${telemetryId}$` from environments.bicep |
| Tags | `tags` param used directly | `finalTags = union(tags ?? {}, { telemetryAVM: telemetryId })` |
| Diagnostics | `allLogs` category group | Explicit category lists per resource type |
| Auth (web/site) | No auth defaults | Three-branch Entra ID auth with FIC (drcp-aps-18) |
| Compliance metadata | None | `compliance` and `complianceVersion` metadata fields |
| Outputs | Standard | Adds `evidenceOfNonCompliance` output |
| Version tracking | `version.json` only | `version.json` (AMAVM) + `upstream.json` (AVM sync point) |

### Shared Types Warning

AMAVM shared types (`diagnosticSettingType`, `privateEndpointType`, `roleAssignmentType`) already include the array suffix (`[]` or `[]?`) in their definitions. **Do not add `[]?`** when using them — e.g. use `param diagnosticSettings diagnosticSettingType`, NOT `diagnosticSettingType[]?` (which would create array-of-arrays).

---

## How to Create or Modify an AMAVM Module

### Before Writing Any Code

1. Call `mcp__plugin_azure_azure__get_azure_bestpractices` (resource: "general", action: "code-generation")
2. Call `mcp__plugin_azure_azure__documentation` for service-specific API details
3. Read DRCP policy JSONs in `/policy/Generic/` for the resource type (e.g. `AppService*.json` for web apps)
4. Cross-check properties against policy `then.details.field` and `then.details.value` requirements

### Module Structure Requirements (main.bicep)

When creating or modifying an AMAVM module:

1. **Metadata**: set `owner` to `'AMCCC'`, add `compliance` and `complianceVersion` fields
2. **Imports**: `import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '<path>/bicep-shared/environments.bicep'`
3. **Types**: replace inline type definitions with imports from `bicep-shared/types.bicep`
4. **Role definitions**: rename module-specific roles to `specificBuiltInRoleNames`, remove common roles, merge with `union(specificBuiltInRoleNames, minimalBuiltInRoleNames)`
5. **Tags**: add `var finalTags = union(tags ?? {}, { telemetryAVM: telemetryId })`, use `finalTags` everywhere
6. **Telemetry**: in `avmTelemetry` resource, use `${telemetryId}$` and truncate name to 64 chars
7. **Diagnostics**: replace `{ categoryGroup: 'allLogs' }` with explicit category lists for the resource type
8. **Outputs**: add `evidenceOfNonCompliance` output
9. **Descriptions**: ensure every parameter description starts with `Required.`, `Optional.`, `Conditional.`, or `Generated.`

### E2E Tests

Every module must have at minimum:
- `tests/e2e/<kind>.defaults/` — minimal deployment with required params only
- `tests/e2e/<kind>.max/` — full-featured deployment exercising most params
- `tests/e2e/waf-aligned/` — WAF best-practices deployment

Each test folder has:
- `main.test.bicep` — test deployment (subscription-scoped, `@batchSize(1)` loop over `['init', 'idem']`)
- `dependencies.bicep` — prerequisite resources (VNet, MI, storage, etc.)

### Building Locally

**Important:** The `br/amavm:` registry references point to a private ACR that is not accessible from all networks (codespace IPs are blocked). For local builds:

1. **Swap** `br/amavm:res/network/private-endpoint:0.2.0` → `../../network/private-endpoint/main.bicep` (relative path) in the module's `main.bicep` and any child modules (e.g. `slot/main.bicep`)
2. **Build**: `az bicep build --file main.bicep`
3. **Build tests**: `az bicep build --file tests/e2e/<test>/main.test.bicep`
4. **Revert** the swap before committing

Or use the build script:
```powershell
cd amavm/verified-modules
./utils/buildBicepFiles.ps1 -modulesSubpath 'res/web' -moduleName 'site'
```

### Generating README

```powershell
cd amavm/verified-modules
Import-Module ./utils/setModuleReadMe.ps1 -Force
Set-ModuleReadMe -TemplateFilePath 'bicep/res/web/site/main.bicep'
```

Or with the build script:
```powershell
./utils/buildBicepFiles.ps1 -modulesSubpath 'res/web' -moduleName 'site' -buildReadme 'True'
```

### Publishing

Modules are published to ACR as `br:<acrName>.azurecr.io/<module>:<major>.<minor>.0`:
```powershell
./utils/publishToBCR.ps1 -acrName 's2amavmdevsecacr' -modulesSubpath 'res/web/'
```

---

## DRCP Platform Compliance (MANDATORY)

All AMAVM modules must enforce these — no exceptions:

| Rule | Requirement |
|------|-------------|
| **Private Endpoints** | All PaaS resources use PE. Public network access disabled. |
| **Managed Identity** | System-assigned or user-assigned MI. No service principals, no local auth, no access keys. |
| **TLS 1.2+** | Minimum TLS version on all services. |
| **VNet Integration** | App services route all traffic through VNet (`outboundVnetRouting`). |
| **Diagnostics** | All resources send logs to Log Analytics. Explicit category lists (not `allLogs`). |
| **No Admin Users** | Disable admin accounts (ACR admin, AKS local accounts, etc.). |
| **Auth (web/site)** | `platform.enabled: true` on all `Microsoft.Web/sites` kinds (drcp-aps-18). FIC by default. |

### Policy Reference

DRCP policy definitions are in `/policy/Generic/`. Always check:
- `then.details.field` — the ARM property being enforced
- `then.details.value` — the required value
- `then.effect` — deny, audit, or modify

---

## Upstream Sync Process

1. Check `upstream.json` for the current sync point version
2. Compare with the latest upstream AVM module at `microsoft-avm/avm/res/<namespace>/<resource>/`
3. Cherry-pick upstream changes that don't conflict with AMAVM customizations
4. Update `upstream.json` with the new version
5. Bump `version.json` if the interface changed (new params, breaking changes)
6. Regenerate README
7. Validate with `bicep build`
