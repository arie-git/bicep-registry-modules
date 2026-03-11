# Lessons Learned

## Rules

### 1. Description prefix requirement is PARAMETERS ONLY
The amavm README requires `Required.`/`Optional.`/`Conditional.`/`Generated.` at the start of parameter `@description()` decorators only. Output descriptions do NOT need these prefixes. Do not flag output descriptions as non-compliant.

### 2. Multi-line description format does NOT mean non-compliant
Bicep `'''` multi-line strings can start the prefix on the first content line (e.g., `'''Optional. ...`). The Explore agent incorrectly flagged these because they look different from single-line `@description('Optional. ...')`. Always read the actual content, not just the format.

### 3. Test folder naming uses numbered prefixes -- this is intentional
Folders like `1defaults`, `2priv`, `4waf-aligned` are a project convention for ordering. The build tooling reads all `tests/e2e/` subdirectories regardless of naming. Do not flag numbered prefixes as non-compliant.

### 4. `bicep build` will fail with BCP192 in this environment
Modules that reference the private ACR (`br/amavm:res/network/private-endpoint:0.2.0`) will always fail with BCP192 because we're not logged into Azure. This is NOT a code issue -- it's an environment limitation. Treat BCP192 errors as expected. Focus on whether there are any other (real) errors.

### 5. Verify audit findings before creating tasks
The initial Explore agent audit produced 3 false positives (TD-03, TD-04, TD-05). Always read the actual source file to confirm findings before adding tasks to the backlog. Subagent audits should be treated as leads, not facts.

### 6. Subscription-scoped modules are special
`insights/diagnostic-setting` uses `targetScope = 'subscription'` -- no tags support, so `finalTags` doesn't apply. Also, `{ categoryGroup: 'allLogs' }` is the correct default here since the module's purpose IS to export Activity Logs. Don't blindly apply the checklist to subscription-scoped modules.

### 7. Monitoring/alerting utility modules have no compliance state
Modules like action-group, metric-alert, webtest, etc. are utility primitives. They don't have inherent compliance requirements, so `evidenceOfNonCompliance = false` is the correct output. Don't invent artificial compliance checks for these.

### 8. Commented-out code = planned features, not dead code
In the amavm fork, commented-out blocks (slots, autoscaler, addons, etc.) represent upstream functionality that hasn't been implemented yet -- NOT dead code to remove. These should be tracked as feature implementation tasks (FEAT-*), not deletion targets. Only fix typos, API versions, and logic bugs in the active code.

### 9. locks, diagnosticSettings, and roleAssignments API versions are standard
`locks@2020-05-01`, `diagnosticSettings@2021-05-01-preview`, and `roleAssignments@2022-04-01` are the de facto standard across the entire upstream Microsoft AVM ecosystem. The bicep linter doesn't suggest newer versions (diagnosticSettings even suggests an older `2016-09-01`). Do NOT flag these as tech debt -- they match upstream intentionally.

### 10. Some modules use `@sys.description()` instead of `@description()`
When a module imports a user-defined function named `description` (or has a naming conflict with the built-in), the bare `@description()` decorator fails with BCP265. Use `@sys.description()` in these modules. Check existing decorators in the file before adding new ones -- match the convention already in use (e.g., `data-collection-endpoint` and `webtest` both use `@sys.description`).

### 11. Always update test cases when changing module parameters
When removing, renaming, or changing parameters in a module's `main.bicep`, ALWAYS immediately check and update the corresponding test cases under `tests/e2e/*/main.test.bicep`. Test cases validate parameter usage and will fail if they reference removed or renamed params. This must be done as part of the same change -- not as a separate step or afterthought. Build ALL test cases to verify, not just the module itself.

### 12. API version changes can remove or restructure properties
When updating API versions (e.g., `Microsoft.Web/sites` `2024-04-01` -> `2025-03-01`), properties may be removed or consolidated. Example: `vnetContentShareEnabled`, `vnetImagePullEnabled`, `vnetRouteAllEnabled` were removed in `2025-03-01` and replaced by the `outboundVnetRouting` object. Always check BCP037 warnings after an API version bump to catch removed properties, then propagate changes to test files.

### 13. Use upstream module + test cases as the reference implementation
The upstream AVM module (`microsoft-avm/avm/res/`) contains the correct parameter types, names, and test usage patterns. When syncing:
- **Parameter types**: Use `resourceInput<'...'>.properties.x?` for strongly-typed params, not loose `object?`. Copy the exact type from upstream.
- **Test cases**: Upstream test cases show correct parameter usage. When replacing/removing params, check upstream tests for the equivalent new usage pattern and replicate it in AMAVM tests.
- **Don't invent types**: If upstream uses `resourceInput<'Microsoft.Web/sites@2025-03-01'>.properties.outboundVnetRouting?`, use exactly that -- not `object?`.

### 15. Local PE/ACR reference switching for dev builds
When modules reference other modules via ACR (`br/amavm:res/network/private-endpoint:0.2.0`), builds fail with BCP192 without `az login`. For local development/CI validation:
1. Switch ACR refs to local relative paths (e.g., `../../network/private-endpoint/main.bicep`)
2. Run `buildBicepFiles.ps1` to validate all modules build
3. Fix any output property name mismatches (the local PE module uses `customDnsConfigs` and `networkInterfaceResourceIds`, not the old ACR module's `customDnsConfig` and `networkInterfaceIds`)
4. **IMPORTANT: Restore ACR references before committing** -- the local paths are for dev only
5. Same applies to other ACR refs: WAF policy (`application-gateway-web-application-firewall-policy`), private-dns-zone, kubernetes-configuration/extension
6. You can build a single module with: `./utils/buildBicepFiles.ps1 -modulesSubpath 'res/<provider>/<resource>' -moduleName 'res/<provider>/<resource>'`

### 16. PowerShell module scope isolation defeats scriptblock-level ErrorActionPreference
When a function is loaded via `Import-Module`, it runs in the **module's own scope**, which inherits `$ErrorActionPreference` from the process/global level -- NOT from the calling scriptblock. Setting `$ErrorActionPreference = 'Continue'` in a `ForEach-Object -Parallel` scriptblock does NOT propagate into imported module functions. Fix stderr issues at the source (e.g., `2>$null` on `az` commands) rather than trying to override error preferences from the caller.

### 17. Azure DevOps AzurePowerShell task sets ErrorActionPreference=Stop
The `AzurePowerShell@5` task sets `$ErrorActionPreference = 'Stop'` at the process level. This means ANY stderr output from native commands (`az`, `bicep`, etc.) becomes a terminating error -- even harmless warnings. Always redirect stderr (`2>$null`) on `az` commands that may emit warnings, and rely on `$LASTEXITCODE` or output null-checks for real error detection.

### 18. Parallel PowerShell may not help CPU-bound workloads on pipeline agents
`ForEach-Object -Parallel` showed ~6x speedup locally but zero improvement on Azure DevOps pipeline agents. Pipeline agents are likely single/dual-vCPU -- parallel runspaces just compete for the same CPU when the workload is CPU-bound (`az bicep build` = compiler). Parallelism only helps if the bottleneck is I/O (network, disk) or if agents have spare cores.

### 19. AMAVM param names differ from Azure API property names
The AMAVM module params use their own naming convention -- not always matching the Azure REST API property name. Example: Cosmos DB's `disableLocalAuth` (API property) is `disableLocalAuthentication` (AMAVM param). Always check the AMAVM module's `main.bicep` for the exact param name, or read the BCP037 error message which lists all permissible properties. Don't assume API docs map 1:1 to module params.

### 20. Always validate Bicep changes with `bicep build` before marking done
Never mark a code change as complete without running `bicep build`. Use the swap-build-restore workflow:
1. Run `localBuildHelper.ps1 -Action Replace` to swap ACR refs in AMAVM modules
2. Also swap ACR refs in the scenario files (helper only handles AMAVM, not scenarios)
3. Run `bicep build <file>` on each changed scenario
4. Restore all refs (helper `-Action Restore` for AMAVM, regex restore for scenarios)
Warnings from upstream modules are expected. Only errors indicate real problems.

### 21. Deprecated VNet routing params affect ALL web/site modules
When `vnetRouteAllEnabled`, `vnetContentShareEnabled`, `vnetImagePullEnabled` were replaced by `outboundVnetRouting` in the AMAVM web/site module, this affects EVERY scenario that uses `br/amavm:res/web/site` -- not just the one you're currently working on. When fixing deprecated params, grep ALL scenarios for the old param names and fix them all in one pass. Missing one causes a build failure you only discover later.

### 22. Circular dependency pattern for cross-resource RBAC
When resource A's managed identity needs a role on resource B, but resource B references resource A's outputs (e.g., ACR needs WebApp MI for AcrPull, WebApp needs ACR loginServer), you cannot use inline `roleAssignments` on either. Extract the RBAC to a separate helper module (e.g., `acrRoleAssignment.bicep`) that takes the resource name + principal ID + role GUID as params. Follow the pattern established in scenario 4 (`roleAssignment.bicep`, `evhRoleAssignment.bicep`, `kvRoleAssignment.bicep`).

### 14. Parameter defaults must be driven by compliance policy
Input parameters (optional, required, conditional) and their defaults should be based on required compliance from `policy/Generic/`. The AMAVM fork's purpose is to enforce policy compliance by default:
- If a policy requires a value, make the param `required` or set a compliant default
- If a policy denies a value, exclude it from `@allowed` or set the default to the compliant option
- Upstream defaults are permissive (general-purpose); AMAVM defaults must be restrictive (policy-compliant)
- Document in `metadata compliance` which params affect compliance

### 23. Don't add upstream features that contradict DRCP policy
When upstream AVM modules have features like `secretsExportConfiguration` (key export to Key Vault), check whether DRCP policy disables the underlying auth mechanism first. If `disableLocalAuth=true` or `disableAccessKeyAuthentication=true` is enforced by policy, exporting keys is contradictory and the feature should be skipped (WONTFIX). Always check the module's compliance metadata and policy tags before porting upstream features.

### 24. Stay on-plan -- don't scope-creep into "improvements"
When working through todo items, don't start "improving" adjacent files that aren't in the task list. Adding metadata, fixing typos, or restructuring files that aren't broken is scope creep. If something genuinely needs fixing, add it to todo.md first, then work on it as a separate task.

### 25. ALWAYS call Azure best practices tools before generating Bicep code
Before writing ANY Bicep code, plans, or todos involving Azure resources, call `mcp__plugin_azure_azure__get_azure_bestpractices` with `resource: "general", action: "code-generation"`. This is a BLOCKING requirement from MEMORY.md. Also use `mcp__plugin_azure_azure__documentation` for service-specific configuration details. Do not skip even if you think you know the answer — the tools may surface updated guidance or constraints.
