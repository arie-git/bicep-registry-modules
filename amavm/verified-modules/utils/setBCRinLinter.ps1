param(
    [Parameter(Mandatory=$false)]
    [string]$acrName= $env:AMAVM_ACR_NAME,
    [Parameter(Mandatory=$false)]
    [string]$modulesRootPath= "./bicep/"
)

if ([string]::IsNullOrEmpty($acrName)) {
    throw "ACR name is required. Set the AMAVM_ACR_NAME environment variable or pass -acrName parameter."
}

$settingsFileName = Join-Path $modulesRootPath "../" "bicepconfig.json"
if(!(Test-Path $settingsFileName -PathType Leaf)) {
    Write-Error "bicepconfig.json was not found"
    exit 1
}

$settingsFile = Get-Content -Path $settingsFileName -Raw | ConvertFrom-Json
$settingsFile.moduleAliases.br.amavm.registry = "${acrName}.azurecr.io"
Set-Content ($settingsFile | ConvertTo-Json -Depth 100) -Path $settingsFileName