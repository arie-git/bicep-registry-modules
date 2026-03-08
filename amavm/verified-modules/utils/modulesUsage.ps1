# Define your tag key and value
$tagKey = "telemetryAVM"
$tagValue = "amavm1"

# Get all subscriptions
$subscriptions = Get-AzSubscription

# Loop through each subscription
foreach ($sub in $subscriptions) {
    # Set the current subscription
    Set-AzContext -SubscriptionId $sub.Id

    # Output current subscription info
    Write-Host "Listing resources in subscription: $($sub.Name)"

    # Get all resources with the specified tag
    $resources = Get-AzResource -Tag @{ $tagKey = $tagValue }

    # Display resource details
    $resources | Select-Object Name, ResourceType, ResourceGroupName | Format-Table -AutoSize
}