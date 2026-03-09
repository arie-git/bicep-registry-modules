<#
.SYNOPSIS
Merges two ToCs (tale of content) json files.

.DESCRIPTION
Updates the ToCs (table of content) json file, which is in source code repo, with the versions data from the additional ToC.

.PARAMETER sourcesTocPath
Optional. The path to sources ToC
.PARAMETER additionalTocPath
Optional. The path to ToC file to be merged in

.EXAMPLE
./mergeDocumentationTocs.ps1 -sourcesTocPath 'utils/html-assets/readmePublisher/menu/toc.json' -additionalTocPath 'temp/toc.json'

#>

param(
    [Parameter(Mandatory = $false)]
    [string]$sourcesTocPath="utils/html-assets/readmePublisher/menu/toc.json",
    [Parameter(Mandatory=$false)]
    [string]$additionalTocPath=$env:AMAVM_DOCUMENTATION_STORAGE_URL ? "$($env:AMAVM_DOCUMENTATION_STORAGE_URL)/menu/toc.json" : "",
    [Parameter(Mandatory=$false)]
    [string]$resultsPath="newtoc.json"
)

# Function to validate if the input is a URL
function Is-ValidUrl {
    param (
        [string]$Url
    )
    try {
        [uri]$result = $Url
        return ($result.ToString().Length -gt 0)
    }
    catch {
        return $false
    }
}

try {
    # Make sure we can resolve the path on the OS from the provider parameter
    $sourcesTocResolvedPath = (Resolve-Path $sourcesTocPath).Path
    if (-not (Test-Path -Path $sourcesTocResolvedPath)) {
        throw "Cannot find path $sourcesTocResolvedPath"
    }
    $sourcesTocContent = (Get-Content -Path $sourcesTocResolvedPath -Raw | ConvertFrom-Json)
    Write-Host "$($sourcesTocContent.Length) + records in sources JSON file."

    if (Is-ValidUrl -Url $additionalTocPath) {
        Write-Host "Fetching the file from the provided URL ${additionalTocPath}"
        # Download the JSON file if the URL is valid
        try {
            $additionalTocContent = ((Invoke-WebRequest -Uri $additionalTocPath -ErrorAction Stop).Content | ConvertFrom-Json)
        } catch {
            Write-Host "No published JSON file. Exiting..."
            exit(0)
        }
    } else {
        $additionalTocResolvedPath = (Resolve-Path $additionalTocPath).Path
        if (-not (Test-Path -Path $additionalTocResolvedPath)) {
            throw "Cannot find path $additionalTocResolvedPath"
        }
        $additionalTocContent = (Get-Content -Path $additionalTocResolvedPath | ConvertFrom-Json)
    }
    Write-Host "$($additionalTocContent.Length) + records in additional JSON file."

    # Iterate through each object in $contents and find corresponding object in $additional
    foreach ($item in $sourcesTocContent) {
        $id = $item.id
        Write-Host "ID: $id"

        # Find the corresponding object in $additional
        $itemAdditional = $additionalTocContent | Where-Object { $_.id -eq $id }

        if ($itemAdditional) {
            # Iterate through versions in $itemAdditional
            foreach ($versionAdditional in $itemAdditional.versions) {
                # Check if the version already exists in $item.versions
                $existingVersion = $item.versions | Where-Object { $_.version -eq $versionAdditional.version }

                # Append the version if it does not exist
                if (-not $existingVersion) {
                    $item.versions += $versionAdditional
                }
            }
        }

        # Output the updated versions
        foreach ($version in $item.versions) {
            $versionNumber = $version.version
            $page = $version.page
            Write-Host "   Version: $versionNumber, Page: $page"
        }
    }

    #$sourcesTocContent | ConvertTo-Json -Depth 10 | Write-Host

    # Serialize $contents to a file
    if ($resultsPath.Length -eq 0) {
        $resultsPath = "newtoc.json"
    }
    $sourcesTocContent | ConvertTo-Json -Depth 10 | Set-Content -Path $resultsPath
    Write-Host "Serialized contents to $resultsPath"
}
catch {
    Write-Error $_
    throw $_
}


