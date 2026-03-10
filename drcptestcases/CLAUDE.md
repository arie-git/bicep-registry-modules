# DRCP Test Cases — Project Instructions

## Workflow Discipline (READ FIRST)

Before starting any work in this directory, **read these files in order**:

1. **`tasks/instructions.md`** — Master project scope, whitelisted modules, agents, validation workflows
2. **`tasks/lessons.md`** — Mistakes already made and patterns to avoid repeating
3. **`drcptestcases/todo.md`** — Current task tracker for this directory; check what's done, what's in progress, what's next

### Rules

- **Never start work without checking `drcptestcases/todo.md`** — find the relevant task, confirm it's not already done
- **Update `drcptestcases/todo.md`** as you go — mark items `[x]` when complete, add notes on blockers
- **Follow the priority order** in todo.md: P0 (migrations) → P1 (READMEs) → P1.5 (new scenarios) → P2 (coverage) → P3 (versions) → P4 (cleanup)
- **After any correction from the user**, update `tasks/lessons.md` with the pattern so it doesn't repeat
- **Don't invent new tasks** — if something seems needed but isn't in todo.md, propose it to the user first
- **Don't modify scenarios outside the current task scope** — one task at a time

---

## Platform Policy Compliance (MANDATORY)

All Bicep code in this directory **must** comply with DRCP platform policies defined in `/policy/`.

### Policy Sources

| Folder | Contents | Usage |
|--------|----------|-------|
| `policy/Generic/` | 315 Azure Policy definitions (JSON) | Reference for required resource configurations |
| `policy/knowledge_base/` | Platform documentation (RST) | Architecture patterns, components, processes |

### Non-Negotiable DRCP Rules

Every scenario must enforce these — no exceptions:

1. **Private Endpoints**: All PaaS resources must use private endpoints. Public network access = disabled.
2. **Managed Identity**: Use system-assigned or user-assigned managed identity. No service principals, no local auth, no access keys.
3. **TLS 1.2+**: Minimum TLS version on all services.
4. **VNet Integration**: App services must route all traffic through VNet.
5. **Diagnostics**: All resources must send logs to Log Analytics workspace.
6. **No Admin Users**: Disable admin accounts (ACR admin, AKS local accounts, etc.).
7. **DNS**: Private DNS zones for all private endpoints.

### Before Writing or Reviewing Bicep

1. **Read the relevant policy JSONs** in `policy/Generic/` for the resource type you're configuring (e.g., `AKS*.json` for AKS, `AppService*.json` for web apps)
2. **Cross-check** your Bicep properties against policy `then.details.field` and `then.details.value` requirements
3. **Use `/azure:azure-compliance`** skill to validate after writing

---

## Module References

- Use AMAVM registry modules: `br/amavm:res/<provider>/<resource>:<version>`
- Use AMAVM naming module: `br/amavm:utl/amavm/naming:0.1.0`
- Do NOT use local path references like `../../modules/infra/naming.bicep` (legacy — migrate to AMAVM)
- Check `tasks/instructions.md` whitelisted components table for current versions

## Scenario Structure

Each scenario folder should contain:
```
scenarioN/
├── infra/
│   ├── main.bicep          # Main deployment
│   └── modules/            # Custom modules (if needed)
├── bicepconfig.json        # Registry aliases (or inherit from parent drcptestcases/)
├── pipelines/              # CI/CD (optional)
└── README.md               # Purpose, architecture, DRCP compliance notes
```

## Validation Checklist (before marking a scenario done)

- [ ] All DRCP rules enforced (PE, MI, TLS, VNet, diagnostics, no admin)
- [ ] Policy JSONs consulted for each resource type
- [ ] `bicep build` passes (or documented why it can't — e.g., ACR access)
- [ ] README created with components table, deploy/remove commands
- [ ] `drcptestcases/todo.md` updated with completion status
