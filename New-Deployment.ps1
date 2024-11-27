param (
    [Parameter()]
    [string]$nameSuffix = "ek005",
    [Parameter()]
    [string]$deploymentName = "deploy-rg-fnapp-$nameSuffix",
    [Parameter()]
    [string]$location = "canadacentral",
    [Parameter()]
    [string]$templateFile = "infra/main.bicep",    
    [Parameter()]
    [string]$resourceGroupName = "rg-fnapp-$nameSuffix"
)

# echo parameters
Write-Host "deploymentName: $deploymentName"
Write-Host "location: $location"
Write-Host "templateFile: $templateFile"
Write-Host "nameSuffix: $nameSuffix"
Write-Host "resourceGroupName: $resourceGroupName"

# create resource group
az group create --name $resourceGroupName `
    --location $location

az deployment group create --name $deploymentName `
    --resource-group $resourceGroupName `
    --template-file $templateFile `
    --parameters nameSuffix="$nameSuffix"
