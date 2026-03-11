<#
.SYNOPSIS
Compare the README.md files.

.DESCRIPTION
Compares two README.md files, one which is in source code repo and other which is automatically generated during build process.
Supports parallel processing via ForEach-Object -Parallel (PowerShell 7+) for significantly faster validation.

.PARAMETER modulesRootPath
Optional. The path of modules' root
.PARAMETER modulesSubpath
Optional. The path of sub module
.PARAMETER destinationPathPrefix
Mandatory. The path of file from source code
.PARAMETER Sequential
Optional. Switch to disable parallel processing and run serially (for debugging).
.PARAMETER ThrottleLimit
Optional. Maximum number of parallel runspaces. Default: 6.

.EXAMPLE
./compareReadMe.ps1 -destinationPathPrefix 'tmp/repocode/bicep/res/'
./compareReadMe.ps1 -destinationPathPrefix 'tmp/repocode/bicep/res/' -Sequential
./compareReadMe.ps1 -destinationPathPrefix 'tmp/repocode/bicep/res/' -ThrottleLimit 4

Output will be depend if files match.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$modulesRootPath= "./bicep/",
    [Parameter(Mandatory=$false)]
    [string]$modulesSubpath= "",
    [Parameter(Mandatory = $true)]
    [string]$destinationPathPrefix,
    [Parameter(Mandatory = $false)]
    [switch]$Sequential,
    [Parameter(Mandatory = $false)]
    [int]$ThrottleLimit = 6
)

# Import required modules
Import-Module .\utils\setModuleReadMe.ps1 -Force

try {
    # Make sure we can resolve the path on the OS from the provider parameter
    $resolvedRootPath = (Resolve-Path $modulesRootPath).Path
    $resolvedPath = (Resolve-Path (Join-Path $modulesRootPath $modulesSubpath)).Path
}
catch {
    Write-Error $_
    throw $_
}
Write-Host "Fetching ReadMe under $resolvedPath"

# Each folder 3 levels and below the root can contain modules'Readme (<res|ptn>/<provider>/<resource>/[<subresource>]/[<subresource>]/[...] etc )
$modules = Get-ChildItem -Path $resolvedPath -Recurse -Include *.md

# Resolve the path to setModuleReadMe.ps1 for re-import in parallel runspaces
$setModuleReadMePath = (Resolve-Path ".\utils\setModuleReadMe.ps1").Path

if ($Sequential -or $modules.Count -le 1) {
    # --- Serial execution (original behavior) ---
    $build_errors = New-Object System.Collections.ArrayList

    foreach ($readMeFile in $modules) {
        $currentModuleName = (Split-Path $readMeFile -Parent).Replace($resolvedRootPath, "").Replace("\", "/").TrimStart("/")
        if ($currentModuleName -eq "") {
            $currentModuleName = (Get-Item $readMeFile).Directory.Name
        }

        Write-Host "=> $currentModuleName"
        try {
            # Pre-compile and generate the README.md with PreLoadedContent
            $bicepFileName = Join-Path (Split-Path $readMeFile -Parent) "main.bicep"
            $buildJson = az bicep build --file $bicepFileName --stdout 2>$null
            if ($LASTEXITCODE -gt 0) {
                throw "Code:$LASTEXITCODE (build)"
            }
            $templateContent = $buildJson | ConvertFrom-Json -AsHashtable
            Set-ModuleReadMe -TemplateFilePath $bicepFileName -PreLoadedContent @{
                TemplateFileContent = $templateContent
            }
            # Derive file paths and read, if exist
            $destinationfilePath = Join-Path $destinationPathPrefix $currentModuleName "README.md"
            Write-Verbose "Comparing [$readMeFile] to [$destinationfilePath]" -Verbose
            # Read source files
            if (-not (Test-Path $readMeFile -PathType 'Leaf')) {
                Write-Error "File [$readMeFile] does not exist." -ErrorAction Continue
                throw "[$readMeFile] is no valid file path."
            }
            $automatedFileContents = Get-Content -Path $readMeFile -Force -Raw
            # Read destination files
            if (-not (Test-Path $destinationfilePath -PathType 'Leaf')) {
                Write-Error "File [$destinationfilePath] does not exist." -ErrorAction Continue
                throw "[$destinationfilePath] is no valid file path."
            }
            $repoReadMeFileContents = Get-Content -Path $destinationfilePath -Force -Raw
            # Compare two files, depending on result continue or flag error and then continue
            if ($automatedFileContents -ne $repoReadMeFileContents) {
                Write-Error "File [$destinationfilePath] does not match with auto-generated README" -ErrorAction Continue
                # Show diff to help diagnose mismatches
                $autoLines = $automatedFileContents -split "`n"
                $repoLines = $repoReadMeFileContents -split "`n"
                $maxLines = [Math]::Max($autoLines.Count, $repoLines.Count)
                $diffCount = 0
                for ($i = 0; $i -lt $maxLines -and $diffCount -lt 20; $i++) {
                    $autoLine = if ($i -lt $autoLines.Count) { $autoLines[$i].TrimEnd("`r") } else { '<EOF>' }
                    $repoLine = if ($i -lt $repoLines.Count) { $repoLines[$i].TrimEnd("`r") } else { '<EOF>' }
                    if ($autoLine -ne $repoLine) {
                        $diffCount++
                        Write-Host "  Line $($i+1) GENERATED: $autoLine"
                        Write-Host "  Line $($i+1) REPO:      $repoLine"
                        Write-Host ""
                    }
                }
                if ($diffCount -eq 0) {
                    Write-Host "  (No visible line differences -- likely line-ending mismatch: CRLF vs LF)"
                    Write-Host "  Generated bytes: $($automatedFileContents.Length)  Repo bytes: $($repoReadMeFileContents.Length)"
                }
                throw "File [$destinationfilePath] does not match with auto-generated README"
            }
        }
        catch {
            $build_errors.Add($_) > $null
            Write-Host $_
        }
    }
} else {
    # --- Parallel execution (PowerShell 7+) ---
    Write-Host "Running parallel README validation with ThrottleLimit=$ThrottleLimit for $($modules.Count) modules"
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    # Thread-safe error collection
    $build_errors = [System.Collections.Concurrent.ConcurrentBag[string]]::new()

    $modules | ForEach-Object -Parallel {
        $readMeFile = $_
        $resolvedRootPath = $using:resolvedRootPath
        $destinationPathPrefix = $using:destinationPathPrefix
        $setModuleReadMePath = $using:setModuleReadMePath
        $errorBag = $using:build_errors

        # Re-import setModuleReadMe in this runspace
        Import-Module $setModuleReadMePath -Force

        $currentModuleName = (Split-Path $readMeFile -Parent).Replace($resolvedRootPath, "").Replace("\", "/").TrimStart("/")
        if ($currentModuleName -eq "") {
            $currentModuleName = (Get-Item $readMeFile).Directory.Name
        }

        # Collect output per module to avoid log interleaving
        $output = [System.Text.StringBuilder]::new()
        [void]$output.AppendLine("=> $currentModuleName")

        try {
            # Pre-compile and generate the README.md with PreLoadedContent
            $bicepFileName = Join-Path (Split-Path $readMeFile -Parent) "main.bicep"
            $buildJson = az bicep build --file $bicepFileName --stdout 2>$null
            if ($LASTEXITCODE -gt 0) {
                throw "Code:$LASTEXITCODE (build)"
            }
            $templateContent = $buildJson | ConvertFrom-Json -AsHashtable
            Set-ModuleReadMe -TemplateFilePath $bicepFileName -PreLoadedContent @{
                TemplateFileContent = $templateContent
            }
            # Derive file paths and read
            $destinationfilePath = Join-Path $destinationPathPrefix $currentModuleName "README.md"
            [void]$output.AppendLine("   Comparing [$readMeFile] to [$destinationfilePath]")

            if (-not (Test-Path $readMeFile -PathType 'Leaf')) {
                throw "[$readMeFile] is no valid file path."
            }
            $automatedFileContents = Get-Content -Path $readMeFile -Force -Raw

            if (-not (Test-Path $destinationfilePath -PathType 'Leaf')) {
                throw "[$destinationfilePath] is no valid file path."
            }
            $repoReadMeFileContents = Get-Content -Path $destinationfilePath -Force -Raw

            # Compare
            if ($automatedFileContents -ne $repoReadMeFileContents) {
                [void]$output.AppendLine("   MISMATCH: [$destinationfilePath] does not match with auto-generated README")
                # Show diff to help diagnose mismatches
                $autoLines = $automatedFileContents -split "`n"
                $repoLines = $repoReadMeFileContents -split "`n"
                $maxLines = [Math]::Max($autoLines.Count, $repoLines.Count)
                $diffCount = 0
                for ($i = 0; $i -lt $maxLines -and $diffCount -lt 20; $i++) {
                    $autoLine = if ($i -lt $autoLines.Count) { $autoLines[$i].TrimEnd("`r") } else { '<EOF>' }
                    $repoLine = if ($i -lt $repoLines.Count) { $repoLines[$i].TrimEnd("`r") } else { '<EOF>' }
                    if ($autoLine -ne $repoLine) {
                        $diffCount++
                        [void]$output.AppendLine("  Line $($i+1) GENERATED: $autoLine")
                        [void]$output.AppendLine("  Line $($i+1) REPO:      $repoLine")
                        [void]$output.AppendLine("")
                    }
                }
                if ($diffCount -eq 0) {
                    [void]$output.AppendLine("  (No visible line differences -- likely line-ending mismatch: CRLF vs LF)")
                    [void]$output.AppendLine("  Generated bytes: $($automatedFileContents.Length)  Repo bytes: $($repoReadMeFileContents.Length)")
                }
                throw "File [$destinationfilePath] does not match with auto-generated README"
            } else {
                [void]$output.AppendLine("   OK")
            }
        }
        catch {
            $errorBag.Add($_.ToString())
            [void]$output.AppendLine("   ERROR: $_")
        }

        # Write collected output as a single block
        Write-Host $output.ToString()
    } -ThrottleLimit $ThrottleLimit

    $stopwatch.Stop()
    Write-Host "Parallel README validation completed in $([math]::Round($stopwatch.Elapsed.TotalSeconds, 1))s"
}

# Print found errors
$numModulesWithErrors = $build_errors.Count
if ( $numModulesWithErrors -gt 0) {
    Write-Error "$numModulesWithErrors errors found due to README.md files mismatch from repo and auto-generated files."
    exit 1
}
