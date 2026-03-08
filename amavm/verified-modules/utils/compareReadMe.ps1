<#
.SYNOPSIS
Comapre the README.md files.

.DESCRIPTION
Compares two README.md files, one which is in source code repo and other which us automatically generated during build process.

.PARAMETER modulesRootPath
Optional. The path of modules' root
.PARAMETER modulesSubpath
Optional. The path of sub module
.PARAMETER destinationPathPrefix
Mandatory. The path of file from source code

.EXAMPLE
./compareReadMe.ps1 -destinationPathPrefix 'tmp/repocode/bicep/res/'

Output will be depend if files match.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$modulesRootPath= "./bicep/",
    [Parameter(Mandatory=$false)]
    [string]$modulesSubpath= "",
    [Parameter(Mandatory = $true)]
    [string]$destinationPathPrefix
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
# Capture errors while building
$build_errors = New-Object System.Collections.ArrayList
# Each folder 3 levels and below the root can contain modules'Readme (<res|ptn>/<provider>/<resource>/[<subresource>]/[<subresource>]/[...] etc )
$modules = Get-ChildItem -Path $resolvedPath -Recurse -Include *.md

foreach ($readMeFile in $modules) {
    # Module name is a directory path between the bicep repository root and the READMME.md of the module
    $currentModuleName = (Split-Path $readMeFile -Parent).Replace($resolvedRootPath, "").Replace("\", "/").TrimStart("/")
    if ($currentModuleName -eq "") {
        $currentModuleName = (Get-Item $readMeFile).Directory.Name
    }

    # Now the actual logic
    Write-Host "=> $currentModuleName"
    try {
        if ($PSCmdlet.ShouldProcess("File in path [$readMeFile]", 'Read')) {
            # Generate the README.md
            $bicepFileName = Join-Path (Split-Path $readMeFile -Parent) "main.bicep"
            Set-ModuleReadMe -TemplateFilePath $bicepFileName
            if ($LASTEXITCODE -gt 0) {
                throw "Code:$LASTEXITCODE"
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
                Write-Error "File [$destinationfilePath] does not match with auto-generated README [$ReadMeFilePath]" -ErrorAction Continue
                throw "File [$destinationfilePath] does not match with auto-generated README [$ReadMeFilePath]"
            }
        }
    }
    catch {
        $build_errors.Add($_) > $null
        Write-Host $_
    }
}

# Print found errors
$numModulesWithErrors = $build_errors.Count
if ( $numModulesWithErrors -gt 0) {
    Write-Error "$numModulesWithErrors errors found due to README.md files mismatch from repo and auto-generated files."
    exit 1
}