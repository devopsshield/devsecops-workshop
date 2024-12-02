param (
    [Parameter()]
    [string]$nameSuffix = "ek002",
    [Parameter()]
    [string]$deploymentName = "deploy-rg-fnapp-$nameSuffix",
    [Parameter()]
    [string]$resourceGroupName = "rg-fnapp-$nameSuffix"
)

# echo parameters
Write-Host "deploymentName: $deploymentName"
Write-Host "nameSuffix: $nameSuffix"
Write-Host "resourceGroupName: $resourceGroupName"