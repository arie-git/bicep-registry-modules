# Parameter help description
param(
    [string] [Parameter(Mandatory=$true)] $groupName,
    [string] [Parameter(Mandatory=$true)] $resourceFilter,
    [string] [Parameter(Mandatory=$false)] $whatIf=""
)

try {

    $results = (az network route-table list -g $groupName --query "[?contains(name, '$resourceFilter')].id") | ConvertFrom-Json
    if ($LastExitCode -gt 0) {
        Write-Output "Error looking for resources."
        Exit 1
    }

    Write-Output "Found $($results.Count) route-table resources containing '$resourceFilter'"

    foreach ($id in $results) {
        Write-Output "Removing route-table $id "
        if($whatIf -eq '') {
            az network route-table delete --ids $id
            if ($LastExitCode -gt 0) {
                Write-Error "Unable to remove $id. Exiting ..."
                Exit 1
            }
        } else {
            Write-Output "This is a test. Skipping removal ..."
        }
    }

} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}