# AMAVM Bicep Registry Modules - Memory

## Project Structure
- `microsoft-avm/avm/res/` — upstream AVM modules (read-only reference)
- `amavm/verified-modules/bicep/res/` — forked/customized modules (what we maintain)
- `policy/Generic/` — Azure Policy JSON definitions (drcp controls)
- `tasks/todo.md` — task tracker
- `bicep-shared/types.bicep` — shared type definitions (fork uses these instead of `br/public` imports)
- `bicep-shared/environments.bicep` — shared builtInRoleNames, telemetryId

## Critical Lesson: Module Improvement Workflow (from README.md)

When improving ANY module (parent OR child), ALWAYS do these checks:

### 1. Upstream Parameter Sync (AVM -> AMAVM)
Compare `microsoft-avm/avm/res/<module>/main.bicep` vs `amavm/verified-modules/bicep/res/<module>/main.bicep`:
- **New params** added upstream that are missing from fork
- **Removed params** that upstream deleted but fork still has
- **Changed params** (types, defaults, descriptions, @allowed values)
- **New child resources** (e.g., commitmentPlans, secretsExport)
- **API version drift** on all resources
- **New type definitions** needed for new params
- **New child modules** (check `modules/` subdirectory upstream)
- Update `upstream.json` version after sync
- **IMPORTANT**: Also sync ALL child/sub-type modules, not just parent

### 2. Required AMAVM Metadata Fields
Per `amavm/verified-modules/README.md`, **independently deployable** modules need full metadata.
A child module is deployable if it has its own `version.json`. Non-deployable children (internal helpers invoked only by parent) do NOT need owner/compliance/evidenceOfNonCompliance.

For deployable modules (parent or child with version.json):
- `metadata name` and `metadata description`
- `metadata owner = 'AMCCC'`
- `metadata compliance` (description of compliance requirements or "inherited from parent")
- `metadata complianceVersion` (date string like '20260309')
- `output evidenceOfNonCompliance bool = <expression>` (false for child modules that inherit)

### 3. Required AMAVM Variables/Patterns (parent modules only)
- `var versionInfo = loadJsonContent('version.json')`
- `var moduleVersion = versionInfo.version`
- `var finalTags = union({telemetryAVM: telemetryId, telemetryType: 'res', telemetryAVMversion: moduleVersion}, tags ?? {})`
- `take(telemetryName, 64)` for telemetry resource name
- `import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from 'bicep-shared/environments.bicep'`
- Rename existing `builtInRoleNames` to `specificBuiltInRoleNames`, remove common roles
- `var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)`
- Replace shared type imports from `br/public` with `import from 'bicep-shared/types.bicep'`
- **CRITICAL**: AMAVM shared types (`diagnosticSettingType`, `privateEndpointType`, `roleAssignmentType`) already include `[]`/`[]?` in their definitions. Do NOT append `[]?` when using them — `param foo diagnosticSettingType` is correct, `param foo diagnosticSettingType[]?` creates array-of-arrays. Upstream AVM uses singular object types with `[]?` appended at param declaration — our fork bakes the array into the type itself.
- Explicit log categories (NOT `{ categoryGroup: 'allLogs' }`)

### 4. Policy Compliance
- Check `policy/Generic/` for relevant policies
- Restrict @allowed values to match policy
- Update `metadata compliance` and `complianceVersion`

### 5. Build Verification
- `az bicep build --file <path>` — only BCP192 (ACR auth) is expected error
- **ALWAYS** also build test cases: `az bicep build --file tests/e2e/*/main.test.bicep`
- When removing/renaming params from a module, check ALL test files for references to those params and update them
- Test cases validate parameter usage — they will catch removed/renamed params that the module build alone won't

## Detailed Notes
- `/workspaces/bicep-registry-modules/tasks/lessons.md` — Lessons learned from mistakes and user corrections

## Module Version Tracking
See `tasks/todo.md` for detailed status. Key: `upstream.json` tracks which AVM version the fork is based on.
