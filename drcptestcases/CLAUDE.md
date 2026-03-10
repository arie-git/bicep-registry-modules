# DRCP Test Cases — Project Instructions

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
2. **Managed Identity**: Use User-Assigned Managed Identity (UAMI). No service principals, no local auth, no access keys.
3. **TLS 1.2+**: Minimum TLS version on all services.
4. **VNet Integration**: App services must route all traffic through VNet.
5. **Diagnostics**: All resources must send logs to Log Analytics workspace.
6. **No Admin Users**: Disable admin accounts (ACR admin, AKS local accounts, etc.).
7. **DNS**: Private DNS zones for all private endpoints.

### Before Writing or Reviewing Bicep

1. **Read the relevant policy JSONs** in `policy/Generic/` for the resource type you're configuring (e.g., `AKS*.json` for AKS, `AppService*.json` for web apps)
2. **Cross-check** your Bicep properties against policy `then.details.field` and `then.details.value` requirements
3. **Use `/azure:azure-compliance`** skill to validate after writing

### Module References

- Use AMAVM registry modules: `br/amavm:res/<provider>/<resource>:<version>`
- Use AMAVM naming module: `br/amavm:utl/amavm/naming:0.1.0`
- Do NOT use local path references like `../../modules/infra/naming.bicep` (legacy — migrate to AMAVM)

### Scenario Structure

Each scenario folder should contain:
```
scenarioN/
├── infra/
│   ├── main.bicep          # Main deployment
│   └── modules/            # Custom modules (if needed)
├── bicepconfig.json        # Registry aliases
├── pipelines/              # CI/CD (optional)
└── README.md               # Purpose, architecture, DRCP compliance notes
```
