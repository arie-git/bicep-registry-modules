<#
.SYNOPSIS
Build the module(s).

.DESCRIPTION
Build the bicep modules.

.PARAMETER modulesRootPath
Optional. The path of modules' root
.PARAMETER modulesSubpath
Optional. The path of sub module, if not provided then all the modules will be built.
.PARAMETER moduleName
Optional. The name of individual module

.EXAMPLE
./buildBicepFiles.ps1
./buildBicepFiles.ps1 -modulesSubpath 'res/sql'
./buildBicepFiles.ps1 -modulesSubpath 'res/sql' -moduleName 'database'
./buildBicepFiles.ps1 -modulesSubpath 'res' -buildReadme 'True'

Output will be the result of bicep build process either for all or individual modules.
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$modulesRootPath= "./bicep/",
    [Parameter(Mandatory=$false)]
    [string]$modulesSubpath= "",
    [Parameter(Mandatory=$false)]
    [string]$moduleName= "",
    [Parameter(Mandatory=$false)]
    [string]$buildReadme="False"
)

# Import required modules
Import-Module .\utils\setModuleReadMe.ps1 -Force

# Make sure we can resolve the path on the OS from the provider parameter
$resolvedRootPath = (Resolve-Path $modulesRootPath).Path
$resolvedPath = (Resolve-Path (Join-Path $modulesRootPath $modulesSubpath)).Path
Write-Host "Building modules under $resolvedPath"

# Capture errors while building
$build_errors = New-Object System.Collections.ArrayList
# Each folder 3 levels and below the root can contain modules (<res|ptn|utl>/<provider>/<resource>/[<subresource>]/[<subresource>]/[...] etc )
# Using -Filter instead of -Include for better performance (single-pass filesystem filtering)
$modules = Get-ChildItem -Path $resolvedPath -Recurse -Filter 'main.bicep'
foreach ($filename in $modules) {
    # Module name is a directory path between the bicep repository root and the main.bicep of the module
    $currentModuleName = (Split-Path $filename -Parent).Replace($resolvedRootPath,"").Replace("\","/").TrimStart("/")
    if ($currentModuleName -eq "") {
        $currentModuleName = (Get-Item $filename).Directory.Name
    }
    # If the module name is provided check only that one
    if (($moduleName.Length -gt 0) -and ($currentModuleName -ne $moduleName.Replace("\","/"))) {
        continue
    }
    # Check if there is a version.json file, otherwise it is not a module and can be skipped
    $versionFileName = Join-Path (Split-Path $filename -Parent) "version.json"
    if(!(Test-Path $versionFileName -PathType Leaf)) {
        continue
    }
    # Now the real work begings
    Write-Host "=> $currentModuleName"
    try {
        if ($buildReadme -eq "True") {
            Set-ModuleReadMe -TemplateFilePath $filename
            if ($LASTEXITCODE -gt 0) {
                throw "Code:$LASTEXITCODE"
            }
        }
        az bicep restore --file $filename --force
        if ($LASTEXITCODE -gt 0) {
            throw "Code:$LASTEXITCODE"
        }
        az bicep build --file $filename --stdout > $null
        if ($LASTEXITCODE -gt 0) {
            throw "Code:$LASTEXITCODE"
        }
    }
    catch {
        $build_errors.Add($_) > $null
    }
}

# When building READMEs, also generate for child modules that have a README.md but no version.json
# This matches the discovery logic of compareReadMe.ps1 which finds modules by scanning for *.md files
if ($buildReadme -eq "True") {
    $readmeFiles = Get-ChildItem -Path $resolvedPath -Recurse -Filter 'README.md'
    foreach ($readMeFile in $readmeFiles) {
        $moduleDir = Split-Path $readMeFile -Parent
        $versionFileName = Join-Path $moduleDir "version.json"
        # Skip modules that already have version.json (already processed in the main loop above)
        if (Test-Path $versionFileName -PathType Leaf) {
            continue
        }
        $bicepFileName = Join-Path $moduleDir "main.bicep"
        if (!(Test-Path $bicepFileName -PathType Leaf)) {
            continue
        }
        $currentModuleName = $moduleDir.Replace($resolvedRootPath,"").Replace("\","/").TrimStart("/")
        if ($currentModuleName -eq "") {
            $currentModuleName = (Get-Item $moduleDir).Name
        }
        if (($moduleName.Length -gt 0) -and ($currentModuleName -ne $moduleName.Replace("\","/"))) {
            continue
        }
        Write-Host "=> $currentModuleName (README only)"
        try {
            Set-ModuleReadMe -TemplateFilePath $bicepFileName
            if ($LASTEXITCODE -gt 0) {
                throw "Code:$LASTEXITCODE"
            }
        }
        catch {
            $build_errors.Add($_) > $null
        }
    }
}

# Print found errors
$numModulesWithErrors = $build_errors.Count
if ( $numModulesWithErrors -gt 0) {
    Write-Error "$numModulesWithErrors modules with errors found"
    exit 1
}