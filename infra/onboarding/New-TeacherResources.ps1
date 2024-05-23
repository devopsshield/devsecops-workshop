param (
    [string] $subscription = "Microsoft Azure Sponsorship", 
    [string] $location = "canadacentral", 
    [int]    $jsonDepth = 100,
    [string] $WorkshopNumber = "001"
)

$doLogin = $false
if ($doLogin) {
    az login
    az account set --subscription "$subscription"
}

$resourceGroupName = "rg-aks-k8s-pygoat-wrkshp-$WorkshopNumber"

# create azure resource group
az group create --name $resourceGroupName --location "$location"

# get current user object id
#$currentUserObjectId = az ad signed-in-user show --query id -o tsv

# create azure key vault through bicep deployment
az deployment group create --resource-group $resourceGroupName `
    --template-file keyVault2.bicep

