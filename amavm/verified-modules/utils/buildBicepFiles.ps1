<#
.SYNOPSIS
Build the module(s).

.DESCRIPTION
Build the bicep modules. Supports parallel processing via ForEach-Object -Parallel (PowerShell 7+).

.PARAMETER modulesRootPath
Optional. The path of modules' root
.PARAMETER modulesSubpath
Optional. The path of sub module, if not provided then all the modules will be built.
.PARAMETER moduleName
Optional. The name of individual module
.PARAMETER buildReadme
Optional. If 'True', also generates README.md files.
.PARAMETER Sequential
Optional. Switch to disable parallel processing and run serially (for debugging).
.PARAMETER ThrottleLimit
Optional. Maximum number of parallel runspaces. Default: 6.

.EXAMPLE
./buildBicepFiles.ps1
./buildBicepFiles.ps1 -modulesSubpath 'res/sql'
./buildBicepFiles.ps1 -modulesSubpath 'res/sql' -moduleName 'database'
./buildBicepFiles.ps1 -modulesSubpath 'res' -buildReadme 'True'
./buildBicepFiles.ps1 -modulesSubpath 'res' -buildReadme 'True' -Sequential

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
    [string]$buildReadme="False",
    [Parameter(Mandatory = $false)]
    [switch]$Sequential,
    [Parameter(Mandatory = $false)]
    [int]$ThrottleLimit = 6
)

# Import required modules
Import-Module .\utils\setModuleReadMe.ps1 -Force

# Make sure we can resolve the path on the OS from the provider parameter
$resolvedRootPath = (Resolve-Path $modulesRootPath).Path
$resolvedPath = (Resolve-Path (Join-Path $modulesRootPath $modulesSubpath)).Path
Write-Host "Building modules under $resolvedPath"

# Each folder 3 levels and below the root can contain modules (<res|ptn|utl>/<provider>/<resource>/[<subresource>]/[<subresource>]/[...] etc )
# Using -Filter instead of -Include for better performance (single-pass filesystem filtering)
$allBicepFiles = Get-ChildItem -Path $resolvedPath -Recurse -Filter 'main.bicep'

# Filter to only modules with version.json (parent modules)
$parentModules = @()
foreach ($filename in $allBicepFiles) {
    $currentModuleName = (Split-Path $filename -Parent).Replace($resolvedRootPath,"").Replace("\","/").TrimStart("/")
    if ($currentModuleName -eq "") {
        $currentModuleName = (Get-Item $filename).Directory.Name
    }
    if (($moduleName.Length -gt 0) -and ($currentModuleName -ne $moduleName.Replace("\","/"))) {
        continue
    }
    $versionFileName = Join-Path (Split-Path $filename -Parent) "version.json"
    if(!(Test-Path $versionFileName -PathType Leaf)) {
        continue
    }
    $parentModules += $filename
}

# Resolve the path to setModuleReadMe.ps1 for re-import in parallel runspaces
$setModuleReadMePath = (Resolve-Path ".\utils\setModuleReadMe.ps1").Path

if ($Sequential -or $parentModules.Count -le 1) {
    # ── Serial execution (original behavior) ──
    $build_errors = New-Object System.Collections.ArrayList

    foreach ($filename in $parentModules) {
        $currentModuleName = (Split-Path $filename -Parent).Replace($resolvedRootPath,"").Replace("\","/").TrimStart("/")
        if ($currentModuleName -eq "") {
            $currentModuleName = (Get-Item $filename).Directory.Name
        }
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
    if ($buildReadme -eq "True") {
        $readmeFiles = Get-ChildItem -Path $resolvedPath -Recurse -Filter 'README.md'
        foreach ($readMeFile in $readmeFiles) {
            $moduleDir = Split-Path $readMeFile -Parent
            $versionFileName = Join-Path $moduleDir "version.json"
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
} else {
    # ── Parallel execution (PowerShell 7+) ──
    Write-Host "Running parallel build with ThrottleLimit=$ThrottleLimit for $($parentModules.Count) parent modules"
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Pre-populate Bicep module cache serially to avoid cache contention (BCP233).
    # Multiple parallel restores of the same ACR module (e.g. private-endpoint) race on
    # the shared ~/.bicep/br/ cache — one deletes while another reads, causing failures.
    Write-Host "Pre-restoring module dependencies (serial)..."
    foreach ($filename in $parentModules) {
        az bicep restore --file $filename --force 2>&1 | Out-Null
    }
    Write-Host "Pre-restore complete."

    # Thread-safe error collection
    $build_errors = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

    $parentModules | ForEach-Object -Parallel {
        $filename = $_
        $resolvedRootPath = $using:resolvedRootPath
        $buildReadme = $using:buildReadme
        $setModuleReadMePath = $using:setModuleReadMePath
        $errorBag = $using:build_errors

        $currentModuleName = (Split-Path $filename -Parent).Replace($resolvedRootPath,"").Replace("\","/").TrimStart("/")
        if ($currentModuleName -eq "") {
            $currentModuleName = (Get-Item $filename).Directory.Name
        }

        # Collect output per module to avoid log interleaving
        $output = [System.Text.StringBuilder]::new()
        [void]$output.AppendLine("=> $currentModuleName")

        try {
            if ($buildReadme -eq "True") {
                # Re-import setModuleReadMe in this runspace
                Import-Module $setModuleReadMePath -Force
                Set-ModuleReadMe -TemplateFilePath $filename
                if ($LASTEXITCODE -gt 0) {
                    throw "Code:$LASTEXITCODE"
                }
            }
            az bicep build --file $filename --stdout 2>&1 > $null
            if ($LASTEXITCODE -gt 0) {
                throw "Code:$LASTEXITCODE (build)"
            }
            [void]$output.AppendLine("   OK")
        }
        catch {
            $errorBag.Add("$currentModuleName : $_")
            [void]$output.AppendLine("   ERROR: $_")
        }

        Write-Host $output.ToString()
    } -ThrottleLimit $ThrottleLimit

    # When building READMEs, also generate for child modules (README-only pass)
    if ($buildReadme -eq "True") {
        $readmeFiles = Get-ChildItem -Path $resolvedPath -Recurse -Filter 'README.md'
        # Filter to child modules (no version.json, has main.bicep)
        $childModules = @()
        foreach ($readMeFile in $readmeFiles) {
            $moduleDir = Split-Path $readMeFile -Parent
            $versionFileName = Join-Path $moduleDir "version.json"
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
            $childModules += @{ Name = $currentModuleName; BicepFile = $bicepFileName }
        }

        if ($childModules.Count -gt 0) {
            Write-Host "Running parallel README generation for $($childModules.Count) child modules"
            $childModules | ForEach-Object -Parallel {
                $module = $_
                $setModuleReadMePath = $using:setModuleReadMePath
                $errorBag = $using:build_errors

                Import-Module $setModuleReadMePath -Force

                $output = [System.Text.StringBuilder]::new()
                [void]$output.AppendLine("=> $($module.Name) (README only)")

                try {
                    Set-ModuleReadMe -TemplateFilePath $module.BicepFile
                    if ($LASTEXITCODE -gt 0) {
                        throw "Code:$LASTEXITCODE"
                    }
                    [void]$output.AppendLine("   OK")
                }
                catch {
                    $errorBag.Add("$($module.Name) : $_")
                    [void]$output.AppendLine("   ERROR: $_")
                }

                Write-Host $output.ToString()
            } -ThrottleLimit $ThrottleLimit
        }
    }

    $stopwatch.Stop()
    Write-Host "Parallel build completed in $([math]::Round($stopwatch.Elapsed.TotalSeconds, 1))s"
}

# Print found errors
$numModulesWithErrors = $build_errors.Count
if ( $numModulesWithErrors -gt 0) {
    Write-Error "$numModulesWithErrors modules with errors found"
    exit 1
}
