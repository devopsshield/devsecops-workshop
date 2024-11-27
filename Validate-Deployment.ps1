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

#az account show                      
# get functionAppName
$functionAppName = az deployment group show --resource-group $resourceGroupName `
    --name $deploymentName `
    --query properties.outputs.azureFunctionName.value `
    -o tsv
Write-Host "functionAppName: $functionAppName"

# get testUrl with function key
$functionKey = az functionapp keys list --name $functionAppName `
    --resource-group $resourceGroupName `
    --query functionKeys.default `
    -o tsv

Write-Host "functionKey: $functionKey"

$addNameParameter = $true

if ($addNameParameter) {
    Write-Host "Adding name parameter to testUrl"
    $testUrl = "https://$functionAppName.azurewebsites.net/api/HttpExample?name=AzureDevOpsSmokeTest&code=$functionKey"
}
else {
    $testUrl = "https://$functionAppName.azurewebsites.net/api/HttpExample?code=$functionKey"
}

Write-Host "testUrl: $testUrl"

# test function
$testResult = Invoke-RestMethod -Uri $testUrl
Write-Host "testResult: $testResult"
