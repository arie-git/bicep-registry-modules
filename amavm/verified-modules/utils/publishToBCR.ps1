param(
    [Parameter(Mandatory=$false)]
    [string]$acrName= "s2amavmdevsecacr",
    [Parameter(Mandatory=$false)]
    [string]$modulesRootPath= "./bicep/",
    [Parameter(Mandatory=$false)]
    [string]$modulesSubpath= "",
    [Parameter(Mandatory=$false)]
    [string]$documentationUri = "https://dev.azure.com/connectdrcpapg1/S02-App-AMAVM/_git/verified-modules?path=/bicep",
    [Parameter(Mandatory=$false)]
    [string]$moduleName= ""
)

# Capture errors while building
$global:publish_errors = New-Object System.Collections.ArrayList
# Capture already published modules, to avoid duplicate efforts
$global:published_modules = New-Object System.Collections.ArrayList
# Capture dependencies, to help identifying circular relationships
$global:inprogress_modules = New-Object System.Collections.ArrayList

function Publish-Module-To-AMAVM([string]$module, [string]$resolvedPath, [string]$acrName, [string]$documentationUri) {

    # If there is no version.json then it is not a module, so don't publish it
    $versionFileName = Join-Path $resolvedPath $module "version.json"
    if(!(Test-Path $versionFileName -PathType Leaf)) {
        continue
    }

    # Get full filename of the module. This will also test it for existance
    $moduleFileFullPath = (Get-Item (Join-Path $resolvedPath $module "main.bicep")).FullName
    # if(!(Test-Path $moduleFilename -PathType Leaf)) {
    #     throw "Cannot find module $moduleFilename)"
    # }
    # Test Uri for validity
    if (!($documentationUri.StartsWith("https://"))) {
        throw "Invalid documentationUri $documentationUri"
    }

    # Skip if already deployed earlier
    if ($global:published_modules.Contains($module)){
        return
    }
    # Add module to in-progress
    $global:inprogress_modules.Add($moduleFileFullPath) > $null

    try {
        # If there is a dependency file in the module directory, publish all dependencies first
        $dependenciesFileName = Join-Path (Split-Path $moduleFileFullPath -Parent) "dependencies.json"
        if((Test-Path $dependenciesFileName -PathType Leaf)) {
            # Read the list of modules, and publish them in order
            foreach ($dependency in (Get-Content -Path $dependenciesFileName | ConvertFrom-Json).modules) {
                # Resolve full path to dependency, and calculate the module name from it.
                $dependencySafeFileName = (Resolve-Path (Join-Path $resolvedPath $dependency.Replace("/main.bicep","") "main.bicep")).Path
                # Skip if it is already in the list of modules being processed (circular dependency)
                if($global:inprogress_modules.Contains($dependencySafeFileName)) {
                    Write-Error "
                    Circular dependency identified when processing dependency $dependencySafeFileName
                    Already in-progress stack is ... $global:inprogress_modules
                    Skipping the dependency"
                    continue
                }
                # Module name is a string between repo root and main.bicep
                $dependency_module = (Split-Path $dependencySafeFileName -Parent).Replace($resolvedPath,"").Replace("\","/").TrimStart("/")
                # Publish the dependency module, and if there were errors continue with the next module
                try {
                    # Publish the module
                    Publish-Module-To-AMAVM -module $dependency_module -resolvedPath $resolvedPath -acrName $acrName -documentationUri $documentationUri
                }
                catch {
                    $global:publish_errors.Add($_) > $null
                    Write-Error $_
                }
            }
        }

        $version = (Get-Content -Path $versionFileName | ConvertFrom-Json).version
        $patch = "0"

        # Publish the module
        Write-Host "=> ${module}:${version}.${patch}"
        az bicep restore --file $filename --force
        if ($LASTEXITCODE -gt 0) {
            throw "Code:$LASTEXITCODE. Error restoring bicep modules."
        }

        $moduleWebPath = $module.Replace("\","-").Replace("/","-")
        $moduleWebPage = "$($version.Replace(".","-"))-${patch}.html"
        $documentationUri = "${documentationUri}/${moduleWebPath}/${moduleWebPage}"
        az bicep publish --file $moduleFileFullPath --target "br:$acrName.azurecr.io/${module}:${version}.${patch}" --documentation-uri $documentationUri --force #--with-source
        if ($LASTEXITCODE -gt 0) {
            throw
        }
        # If all is good, add it to the list of published
        $global:published_modules.Add($module) > $null
    }
    catch {
        Write-Error $_
        $global:publish_errors.Add($_) > $null
    }

    # Remove the module from the list of being processed
    $global:inprogress_modules.Remove($moduleFileFullPath) > $null

} # end of Publish-Module-To-AMAVM function

# Make sure we can resolve the path on the OS from the provider parameter
$resolvedPath = ""
try {
    if (-not (Test-Path -Path $modulesRootPath)) {
        throw "Cannot find path $modulesRootPath"
    }
    $resolvedPath = (Resolve-Path $modulesRootPath).Path
    $fullModulesPath = Join-Path $resolvedPath $modulesSubpath
    if (-not (Test-Path -Path $fullModulesPath)) {
        throw "Cannot find path $fullModulesPath"
    }
    $resolvedSubpath = (Resolve-Path $fullModulesPath).Path
}
catch {
    throw
}

# Proceed to publishing
Write-Host "Publishing modules under $resolvedSubpath to $acrName"

# Each folder 3 levels and below the root can contain modules (<res|ptn>/<provider>/<resource>/[<subresource>]/[<subresource>]/[...] etc )
$modules = Get-ChildItem -Path $resolvedSubpath -Include *.bicep -Recurse
foreach ($filename in $modules) {
    # Module name is a string between repo root and main.bicep
    $currentModuleName = (Split-Path $filename -Parent).Replace($resolvedPath,"").Replace("\","/").TrimStart("/")
    # If the module name is provided check only that one
    if (($moduleName.Length -gt 0) -and ($currentModuleName -ne $moduleName.Replace("\","/"))) {
        continue
    }
    # Process the module. Log errors if it failed and continue with the next module
    try {
        Publish-Module-To-AMAVM -module $currentModuleName -resolvedPath $resolvedPath -acrName $acrName -documentationUri $documentationUri
    }
    catch {
        $global:publish_errors.Add($_) > $null
        Write-Error $_
    }
}
$numModulesWithErrors = $global:publish_errors.Count
if ( $numModulesWithErrors -gt 0) {
    Write-Error "$numModulesWithErrors modules with publishing errors"
    exit 1
}
$numModulesPublished = $global:published_modules.Count
Write-Host "$numModulesPublished modules published successfully"
