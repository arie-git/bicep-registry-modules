# AMAVM Module — Task Tracker

> Part of [tasks/todo.md](../../tasks/todo.md)

## web/site — Auth & Diagnostics Improvements

### Completed

- [x] Three-branch auth defaults: Web App (RedirectToLoginPage), Function App (Return401), API apps (Return401)
- [x] All branches use FIC (federated identity credentials) — `OVERRIDE_USE_MI_FIC_ASSERTION_CLIENTID`, no client secrets
- [x] "Other" branch (api apps) fixed: `platform.enabled: true` for drcp-aps-18 compliance
- [x] Function app diagnostic defaults: `FunctionAppLogs` + `AppServiceAuthenticationLogs` (was only `AppService*`)
- [x] E2e test `functionApp.max`: uses `authSettingApplicationId` + module defaults instead of full manual override
- [x] E2e test `4webApp.max`: removed `platform.enabled: false` (drcp-aps-18), replaced `MICROSOFT_PROVIDER_AUTHENTICATION_SECRET` with FIC
- [x] E2e test `2webAppLinux.max`: replaced `MICROSOFT_PROVIDER_AUTHENTICATION_SECRET` with FIC
- [x] Local `bicep build` passes (main.bicep + all 11 e2e tests) with PE reference swapped to local path

### Open — Validation & Release

- [ ] Generate README: `pwsh -c "Import-Module ./utils/setModuleReadMe.ps1 -Force; Set-ModuleReadMe -TemplateFilePath 'bicep/res/web/site/main.bicep'"`
- [ ] Revert local PE path swap back to `br/amavm:res/network/private-endpoint:0.2.0` (main.bicep + slot/main.bicep) before commit
- [ ] Validate with `bicep build` on DRCP tenant (requires ACR access — codespace IP blocked)
- [ ] Test: deploy function app scenario with `authSettingApplicationId` set, verify Return401 + correct audience
- [ ] Test: deploy function app scenario without custom `diagnosticSettings`, verify `FunctionAppLogs` auto-configured
- [ ] Submit PR to AMAVM upstream once validated

---

## General — Module Maintenance

- [ ] Version bumps: inventory current vs latest versions across all modules
- [ ] Audit all `res/` modules for deprecated API versions (`use-recent-api-versions` warnings)
