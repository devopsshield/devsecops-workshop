param (
    [Parameter()]
    [string]$nameSuffix = "ek005",
    [Parameter()]
    [string]$deploymentName = "deploy-rg-defectdojo-$nameSuffix",
    [Parameter()]
    [string]$location = "canadacentral",
    [Parameter()]
    [string]$templateFile = "main.bicep",    
    [Parameter()]
    [string]$resourceGroupName = "rg-defectdojo-$nameSuffix",
    [Parameter()]
    [string]$subscriptionId = "IT Test",
    [Parameter()]
    [string]$sshKeyPath = "$HOME\.ssh\vm-defectdojo-${nameSuffix}-id_rsa",
    [Parameter()]
    [string] $username = "ddadmin",
    [Parameter()]
    [string] $password = "booWgDmaYdgNxO5eNWql",
    [Parameter()]
    [string] $adminUsername = "azureuser"
)

# function to generate random password
function New-Password {
    param (
        [int]$length = 32
    )

    $chars = [char[]]('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?')
    $password = -join ($chars | Get-Random -Count $length)
    return $password
}

# install az cli if not already installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Output "Installing az cli"
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://aka.ms/installazurecliwindows')
}
else {
    Write-Output "az cli already installed"    
}

# login
Write-Output "Logging in to Azure"
az login

# set subscription
Write-Output "Setting subscription to $subscriptionId"
az account set --subscription "$subscriptionId"

# echo parameters
Write-Output "nameSuffix: $nameSuffix"
Write-Output "deploymentName: $deploymentName"
Write-Output "location: $location"
Write-Output "templateFile: $templateFile"
Write-Output "resourceGroupName: $resourceGroupName"

# deploy
# create resource group
Write-Output "Creating resource group $resourceGroupName in location $location"
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

# # generate random password for postgresql
# $password = New-Password -length 32
# Write-Output "Generated password for PostgreSQL: $password"

# deploy bicep
Write-Output "Deploying bicep template $templateFile to resource group $resourceGroupName"
az deployment group create `
    --name $deploymentName `
    --resource-group $resourceGroupName `
    --template-file main.bicep `
    --parameters sshPublicKey="`"$sshPublicKey`"" `
    --parameters administratorLoginPassword="`"$password`"" `
    --parameters nameSuffix="`"$nameSuffix`"" `
    --parameters adminUsername="`"$adminUsername`"" `
    --parameters administratorLogin="`"$username`"" `

# output vm public ip address from deployment output
$fqdn = (az deployment group show `
        --name $deploymentName `
        --resource-group $resourceGroupName `
        --query "properties.outputs.fqdn.value" `
        --output tsv)

Write-Output "DefectDojo is deployed at $fqdn"

# output postgresql fqdn from deployment output
$fullyQualifiedDomainName = (az deployment group show `
        --name $deploymentName `
        --resource-group $resourceGroupName `
        --query "properties.outputs.fullyQualifiedDomainName.value" `
        --output tsv)

Write-Output "PostgreSQL is deployed at $fullyQualifiedDomainName"

# output admin username from deployment output
$adminUsername = (az deployment group show `
        --name $deploymentName `
        --resource-group $resourceGroupName `
        --query "properties.outputs.adminUsername.value" `
        --output tsv)

Write-Output "Admin username is $adminUsername"

# get psql password from deployment output
$administratorLogin = (az deployment group show `
        --name $deploymentName `
        --resource-group $resourceGroupName `
        --query "properties.outputs.administratorLogin.value" `
        --output tsv)

# give ssh instructions
Write-Output "To ssh into the VM, run the following command:"
Write-Output "ssh -i $sshKeyPath $adminUsername@$fqdn"

# give psql instructions
Write-Output "To connect to PostgreSQL, run the following command:"
Write-Output "psql -h $fullyQualifiedDomainName -U $administratorLogin -P $password"