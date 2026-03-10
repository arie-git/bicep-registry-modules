# Parameter help description
param(
    [string] [Parameter(Mandatory=$true)] $groupName,
    [string] [Parameter(Mandatory=$true)] $vnetName,
    [string] [Parameter(Mandatory=$true)] $resourceFilter,
    [string] [Parameter(Mandatory=$false)] $whatIf=""
)


try {

    $results = (az network vnet subnet list -g $groupName --vnet-name $vnetName --query "[?contains(name, '$resourceFilter')].id") | ConvertFrom-Json
    if ($LastExitCode -gt 0) {
        Write-Output "Error looking for subnets."
        Exit 1
    }

    Write-Output "Found $($results.Count) subnets containing '$resourceFilter' under the $vnetName"

    foreach ($id in $results) {
        Write-Output "Removing subnet $id "
        if($whatIf -eq '') {
            az network vnet subnet delete --ids $id
            if ($LastExitCode -gt 0) {
                Write-Error "Unable to remove subnet $id. Exiting ..."
                Exit 1
            }
        } else {
            Write-Output "This is a test. Skipping removal ..."
        }
    }

} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
    Exit 1
}

