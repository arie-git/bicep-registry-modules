param(
    [Parameter(Mandatory=$false)]
    [string]$acrName= "s2amavmdevsecacr",
    [Parameter(Mandatory=$false)]
    [string]$modulesRootPath= "./bicep/"
)

$settingsFileName = Join-Path $modulesRootPath "../" "bicepconfig.json"
if(!(Test-Path $settingsFileName -PathType Leaf)) {
    Write-Error "bicepconfig.json was not found"
    exit 1
}

$settingsFile = Get-Content -Path $settingsFileName -Raw | ConvertFrom-Json
$settingsFile.moduleAliases.br.amavm.registry = "${acrName}.azurecr.io"
Set-Content ($settingsFile | ConvertTo-Json -Depth 100) -Path $settingsFileName