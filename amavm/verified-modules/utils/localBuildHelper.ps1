<#
.SYNOPSIS
  Helper script to replace ACR (br/amavm:) references with local relative paths for local builds,
  and restore them afterwards.

.DESCRIPTION
  Bicep modules referencing 'br/amavm:...' will fail locally without Azure login (BCP192).
  This script swaps those references to local relative paths, enabling offline builds.

.EXAMPLE
  # Replace ACR refs with local paths
  ./utils/localBuildHelper.ps1 -Action Replace

  # Restore original ACR refs
  ./utils/localBuildHelper.ps1 -Action Restore
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet('Replace', 'Restore')]
    [string]$Action,

    [string]$BicepRoot = (Join-Path $PSScriptRoot '..' 'bicep' -Resolve -ErrorAction SilentlyContinue) ??
                         (Join-Path $PSScriptRoot '..' 'bicep')
)

$ErrorActionPreference = 'Stop'

# Resolve the bicep root to an absolute path
$BicepRoot = (Resolve-Path $BicepRoot).Path

function Get-RelativeBicepPath {
    param(
        [string]$FromFile,    # The .bicep file containing the reference
        [string]$ToModule     # e.g. 'res/network/private-endpoint'
    )

    $fromDir = Split-Path $FromFile -Parent
    $toFile = Join-Path $BicepRoot $ToModule 'main.bicep'

    if (-not (Test-Path $toFile)) {
        Write-Warning "Local module not found: $toFile (referenced from $FromFile)"
        return $null
    }

    # Compute relative path from the directory of the source file to the target
    $relPath = [System.IO.Path]::GetRelativePath($fromDir, $toFile)
    # Normalize to forward slashes for Bicep
    $relPath = $relPath -replace '\\', '/'
    return $relPath
}

function Replace-AcrReferences {
    Write-Host "Replacing ACR references with local paths under: $BicepRoot" -ForegroundColor Cyan

    $bicepFiles = Get-ChildItem -Path $BicepRoot -Filter '*.bicep' -Recurse
    $totalReplacements = 0

    foreach ($file in $bicepFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        $originalContent = $content

        # Match pattern: 'br/amavm:some/module/path:version'
        $pattern = "'br/amavm:(?:avm/)?([^:]+):\d+\.\d+\.\d+'"

        $matches = [regex]::Matches($content, $pattern)
        if ($matches.Count -eq 0) { continue }

        foreach ($match in $matches) {
            $fullMatch = $match.Value           # e.g. 'br/amavm:res/network/private-endpoint:0.2.0'
            $modulePath = $match.Groups[1].Value # e.g. res/network/private-endpoint

            $relPath = Get-RelativeBicepPath -FromFile $file.FullName -ToModule $modulePath
            if ($null -eq $relPath) {
                Write-Warning "  Skipping $fullMatch in $($file.FullName)"
                continue
            }

            $replacement = "'$relPath'"
            $content = $content.Replace($fullMatch, $replacement)
            $totalReplacements++
            Write-Host "  $($file.Name): $fullMatch -> $replacement" -ForegroundColor Green
        }

        if ($content -ne $originalContent) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
        }
    }

    Write-Host "`nReplaced $totalReplacements ACR reference(s)." -ForegroundColor Cyan
    Write-Host "IMPORTANT: Run './utils/localBuildHelper.ps1 -Action Restore' when done!" -ForegroundColor Yellow
}

function Restore-AcrReferences {
    Write-Host "Restoring ACR references via git checkout..." -ForegroundColor Cyan

    # Use git to restore all .bicep files to their committed state
    $gitRoot = git -C $BicepRoot rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        Write-Error "Not in a git repository. Cannot auto-restore."
        return
    }

    # Get relative path of BicepRoot from git root
    $relBicepRoot = [System.IO.Path]::GetRelativePath($gitRoot, $BicepRoot) -replace '\\', '/'

    git -C $gitRoot checkout -- "$relBicepRoot"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Restored all .bicep files under $relBicepRoot to committed state." -ForegroundColor Green
    } else {
        Write-Error "git checkout failed. Please manually restore files."
    }
}

switch ($Action) {
    'Replace' { Replace-AcrReferences }
    'Restore' { Restore-AcrReferences }
}
