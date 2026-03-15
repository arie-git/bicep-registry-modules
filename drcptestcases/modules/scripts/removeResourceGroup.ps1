# Parameter help description
param(
    [string] [Parameter(Mandatory=$true)] $groupName,
    [string] [Parameter(Mandatory=$false)] $whatIf=""
)

try {

    if ( (az group exists --name $groupName) -ieq "true") {
        if($whatIf -eq '') {
            Write-Output "Starting to delete some resources before the $groupName resource group removal."

            $results = (az network private-endpoint list -g $groupName --query "[?contains(name, '$resourceFilter')].id") | ConvertFrom-Json
            if ($LastExitCode -gt 0) {
                Write-Output "Error looking for resources."
                Exit 1
            }
            Write-Output "Found $($results.Count) private-endpoint resources containing '$resourceFilter'"
            foreach ($id in $results) {
                Write-Output "Removing  private-endpoint ip $id "
                if($whatIf -eq '') {
                    az network private-endpoint delete --ids $id
                    if ($LastExitCode -gt 0) {
                        Write-Error "Unable to remove $id. Exiting ..."
                        Exit 1
                    }
                } else {
                    Write-Output "This is a test. Skipping removal ..."
                }
            }

            Write-Output "Starting to delete the $groupName resource group"
            az group delete --name $groupName --yes
            if (!$?) {
                Write-Error "Error deleting the resource group"
                Exit 1
            }
        } else {
            Write-Output "This is a test. Skipping removal ..."
        }
    } else {
        Write-Output "The resource group $groupName does not exist."
    }

    # purge removed resources
    Write-Output "Purging removed resources using filter '$resourceFilter'"

    # Keyvaults
    $results = (az keyvault list-deleted --query "[?contains(name, '$resourceFilter')].name") | ConvertFrom-Json
    if ($LastExitCode -gt 0) {
        Write-Output "Error looking for resources."
    } else {
        Write-Output "Found $($results.Count) keyVault resources containing '$resourceFilter'"
        foreach ($name in $results) {
            Write-Output "Removing keyvault $name "
            if($whatIf -eq '') {
                az keyvault purge --name $name --location 'Sweden Central' # hard coded for now
                if ($LastExitCode -gt 0) {
                    Write-Error "Unable to remove $name. Exiting ..."
                    Exit 1
                }
            } else {
                Write-Output "This is a test. Skipping removal ..."
            }
        }
    }
    # App Configuration
    $results = (az appconfig list-deleted --query "[?contains(name, '$resourceFilter')].name") 2>$null | ConvertFrom-Json
    if ($LastExitCode -gt 0) {
        Write-Output "Error looking for App Configuration resources."
    } else {
        Write-Output "Found $($results.Count) App Configuration resources containing '$resourceFilter'"
        foreach ($name in $results) {
            Write-Output "Removing App Configuration $name "
            if($whatIf -eq '') {
                az appconfig purge --name $name --location 'Sweden Central' --yes 2>$null # hard coded for now
                if ($LastExitCode -gt 0) {
                    Write-Error "Unable to remove $name. Exiting ..."
                    Exit 1
                }
            } else {
                Write-Output "This is a test. Skipping removal ..."
            }
        }
    }

    Exit 0

} catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}