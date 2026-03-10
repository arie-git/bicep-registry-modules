param(
    [string] [Parameter(Mandatory=$false)] $groupName = "",
    [string] [Parameter(Mandatory=$false)] $vnetGroupName = "",
    [string] [Parameter(Mandatory=$false)] $vnetName = "",
    [string] [Parameter(Mandatory=$true)] $resourceFilter,
    [string] [Parameter(Mandatory=$false)] $whatIf = "",
    [string] [Parameter(Mandatory=$false)] $snowEnvironmentId = ""
)

if($groupName -eq '') {
    $groupName = "$resourceFilter-dev-swedencentral-rg"
}

if($vnetGroupName -eq '') {
    $vnetGroupName = "AM-CCC-$snowEnvironmentId-VirtualNetworks"
}

if($vnetName -eq '') {
    $vnetName = "AM-CCC-$snowEnvironmentId-VirtualNetwork"
}

if($snowEnvironmentId -ne '') {
    az account set -s "AM-CCC-$snowEnvironmentId-DEV"
    if (!$?) {
        Write-Error "Error setting the subscription to AM-CCC-$snowEnvironmentId-DEV"
        Exit 1
    }
}

Write-Output "Starting removeResourceGroup.ps1 ..."
& "$PSScriptRoot\removeResourceGroup.ps1" -groupName $groupName -whatIf $whatIf
if ($LastExitCode -gt 0) {
    Exit 1
}

Write-Output "Starting removeResourceSubnets.ps1 ..."
& "$PSScriptRoot\removeResourceSubnets.ps1" -groupName $vnetGroupName -vnetName $vnetName -resourceFilter $resourceFilter -whatIf $whatIf
if ($LastExitCode -gt 0) {
    Exit 1
}

Write-Output "Starting removeResourceNsgs.ps1 ..."
& "$PSScriptRoot\removeResourceNsgs.ps1" -groupName $vnetGroupName -resourceFilter $resourceFilter -whatIf $whatIf
if ($LastExitCode -gt 0) {
    Exit 1
}

Write-Output "Starting removeResourceRTs.ps1 ..."
& "$PSScriptRoot\removeResourceRTs.ps1" -groupName $vnetGroupName -resourceFilter $resourceFilter -whatIf $whatIf
if ($LastExitCode -gt 0) {
    Exit 1
}