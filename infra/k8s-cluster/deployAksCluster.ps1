param (
    [Parameter()]
    [string]$nameSuffix = "ek002",
    [Parameter()]
    [string]$deploymentName = "deploy-rg-aks-$nameSuffix",
    [Parameter()]
    [string]$resourceGroupName = "rg-aks-$nameSuffix",
    [Parameter()]
    [string]$location = "canadacentral",
    [Parameter()]
    [string]$templateFile = "main.bicep",
    [Parameter()]
    [string]$clusterName = "aks-cluster-$nameSuffix",
    [Parameter()]
    [string]$dnsPrefix = "$nameSuffix",
    [Parameter()]
    [string]$linuxAdminUsername = "azureuser",
    [Parameter()]
    [int]$agentCount = 1,
    [Parameter()]
    [string]$sshKeyPath = "$HOME\.ssh\aks-${nameSuffix}-id_rsa"
)

# echo parameters
Write-Host "deploymentName: $deploymentName"
Write-Host "nameSuffix: $nameSuffix"
Write-Host "resourceGroupName: $resourceGroupName"
Write-Host "location: $location"
Write-Host "templateFile: $templateFile"
Write-Host "clusterName: $clusterName"
Write-Host "dnsPrefix: $dnsPrefix"
Write-Host "linuxAdminUsername: $linuxAdminUsername"
Write-Host "agentCount: $agentCount"

Write-Output "Creating resource group $resourceGroupName in location $location"

# create resource group
az group create --name $resourceGroupName `
    --location $location

# generate ssh key pair
Write-Output "Generating ssh key pair at $sshKeyPath"
if (-not (Test-Path $sshKeyPath)) {
    ssh-keygen -t rsa -b 2048 -f $sshKeyPath -q -N ""
}
else {
    Write-Output "ssh key pair already exists"
}

# echo ssh public key
Write-Output "Public key:"
$sshPublicKey = Get-Content "$sshKeyPath.pub"
Write-Output $sshPublicKey

Write-Output "Deploying AKS cluster $clusterName in resource group $resourceGroupName"

# deploy aks cluster
az deployment group create --resource-group $resourceGroupName `
    --name $deploymentName `
    --template-file $templateFile `
    --parameters clusterName=$clusterName `
    --parameters dnsPrefix=$dnsPrefix `
    --parameters linuxAdminUsername=$linuxAdminUsername `
    --parameters agentCount=$agentCount `
    --parameters sshRSAPublicKey="`"$sshPublicKey`""

# output aks cluster fqdn from deployment output
$fqdn = (az deployment group show `
        --name $deploymentName `
        --resource-group $resourceGroupName `
        --query "properties.outputs.fqdn.value" `
        --output tsv)

Write-Output "AKS cluster is deployed at $fqdn"

# give instructions to connect to the cluster
Write-Output "To connect to the cluster, run the following command:"
Write-Output "az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing"

# # give instructions on how to ssh into the cluster
# Write-Output "To ssh into the cluster, run the following command:"
# Write-Output "ssh -i $sshKeyPath $linuxAdminUsername@$fqdn"