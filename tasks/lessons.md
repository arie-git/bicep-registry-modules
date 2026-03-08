# Lessons Learned

## Rules

### 1. Description prefix requirement is PARAMETERS ONLY
The amavm README requires `Required.`/`Optional.`/`Conditional.`/`Generated.` at the start of parameter `@description()` decorators only. Output descriptions do NOT need these prefixes. Do not flag output descriptions as non-compliant.

### 2. Multi-line description format does NOT mean non-compliant
Bicep `'''` multi-line strings can start the prefix on the first content line (e.g., `'''Optional. ...`). The Explore agent incorrectly flagged these because they look different from single-line `@description('Optional. ...')`. Always read the actual content, not just the format.

### 3. Test folder naming uses numbered prefixes — this is intentional
Folders like `1defaults`, `2priv`, `4waf-aligned` are a project convention for ordering. The build tooling reads all `tests/e2e/` subdirectories regardless of naming. Do not flag numbered prefixes as non-compliant.

### 4. `bicep build` will fail with BCP192 in this environment
Modules that reference the private ACR (`br/amavm:res/network/private-endpoint:0.2.0`) will always fail with BCP192 because we're not logged into Azure. This is NOT a code issue — it's an environment limitation. Treat BCP192 errors as expected. Focus on whether there are any other (real) errors.

### 5. Verify audit findings before creating tasks
The initial Explore agent audit produced 3 false positives (TD-03, TD-04, TD-05). Always read the actual source file to confirm findings before adding tasks to the backlog. Subagent audits should be treated as leads, not facts.

### 6. Subscription-scoped modules are special
`insights/diagnostic-setting` uses `targetScope = 'subscription'` — no tags support, so `finalTags` doesn't apply. Also, `{ categoryGroup: 'allLogs' }` is the correct default here since the module's purpose IS to export Activity Logs. Don't blindly apply the checklist to subscription-scoped modules.

### 7. Monitoring/alerting utility modules have no compliance state
Modules like action-group, metric-alert, webtest, etc. are utility primitives. They don't have inherent compliance requirements, so `evidenceOfNonCompliance = false` is the correct output. Don't invent artificial compliance checks for these.

### 8. Commented-out code = planned features, not dead code
In the amavm fork, commented-out blocks (slots, autoscaler, addons, etc.) represent upstream functionality that hasn't been implemented yet — NOT dead code to remove. These should be tracked as feature implementation tasks (FEAT-*), not deletion targets. Only fix typos, API versions, and logic bugs in the active code.

### 9. locks, diagnosticSettings, and roleAssignments API versions are standard
`locks@2020-05-01`, `diagnosticSettings@2021-05-01-preview`, and `roleAssignments@2022-04-01` are the de facto standard across the entire upstream Microsoft AVM ecosystem. The bicep linter doesn't suggest newer versions (diagnosticSettings even suggests an older `2016-09-01`). Do NOT flag these as tech debt — they match upstream intentionally.

### 10. Some modules use `@sys.description()` instead of `@description()`
When a module imports a user-defined function named `description` (or has a naming conflict with the built-in), the bare `@description()` decorator fails with BCP265. Use `@sys.description()` in these modules. Check existing decorators in the file before adding new ones — match the convention already in use (e.g., `data-collection-endpoint` and `webtest` both use `@sys.description`).
