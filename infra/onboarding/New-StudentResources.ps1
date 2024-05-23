# # Example:
# New-Students.ps1 -NumberOfStudents 25 `
#     -Password "P@ssw0rd!1" `
#     -DojoUrl "https://defectdojo-002.cad4devops.com:8443/" `
#     -ApiKey "your-api-key"
param (
    [int]    $NumberOfStudents = 5,
    [string] $keyVaultName = "kv-w001-rbf6xriugto5s",
    [string] $subscription = "Microsoft Azure Sponsorship", 
    [string] $location = "canadacentral", 
    [int]    $jsonDepth = 100,
    [string] $WorkshopNumber = "001"
)

function New-StudentResource {
    param (
        [string] $StudentNumber = "001",  
        [string] $keyVaultName = "kv-w001-rbf6xriugto5s",
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

    $resourceGroupName = "rg-aks-k8s-pygoat-wrkshp-$WorkshopNumber-student-$StudentNumber"

    $sshKeyName = "ssh-aks-k8s-pygoat-wrkshp-$WorkshopNumber-student-$StudentNumber"

    # Create a resource group
    Write-Host "Creating resource group $resourceGroupName in location $location"
    az group create --name $resourceGroupName --location "$location"

    # Create an SSH key pair using Azure CLI
    $publicKeyPath = "C:\Users\emmanuel.DEVOPSABCS\.ssh\$sshKeyName.pub"
    $privateKeyPath = "C:\Users\emmanuel.DEVOPSABCS\.ssh\$sshKeyName"

    Write-Host "Generating SSH key pair $privateKeyPath and $publicKeyPath"
    ssh-keygen -b 4096 -t rsa -f $privateKeyPath -q -N '""'

    $publicKey = Get-Content $publicKeyPath

    # delete the ssh key if it already exists
    Write-Host "Deleting SSH key $sshKeyName if it already exists"
    az sshkey delete --name $sshKeyName --resource-group $resourceGroupName --yes

    Write-Host "Creating SSH key $sshKeyName"
    az sshkey create --name $sshKeyName `
        --resource-group $resourceGroupName `
        --public-key "$publicKey"

    # Create an SSH key pair using ssh-keygen
    #ssh-keygen -t rsa -b 4096

    #To ssh private key in key vault as a secret:
    Write-Host "Adding SSH private key to key vault"
    $privateKeySecretName = "wrkshp-$WorkshopNumber-student-$StudentNumber-ssh-private-key"
    az keyvault secret set --vault-name $keyVaultName --name $privateKeySecretName --file $privateKeyPath --encoding ascii
    Write-Host "Adding SSH public key to key vault"
    $publicKeySecretName = "wrkshp-$WorkshopNumber-student-$StudentNumber-ssh-public-key"
    az keyvault secret set --vault-name $keyVaultName --name $publicKeySecretName --file $publicKeyPath --encoding ascii
    #To download from key vault:
    #az keyvault secret download --vault-name $keyVaultName --name $sshKeyName --file "$sshKeyName.pem"
    #To change permissions in order to use:
    #chmod 600 ./<name of key downloaded from vault>

    # Create an Azure Kubernetes Service (AKS) cluster
    # az aks create --resource-group $resourceGroupName `
    #     --name aks-$WorkshopNumber-student-$StudentNumber `
    #     --node-count 1 --enable-addons monitoring --generate

    # Create an Azure Kubernetes Service (AKS) cluster
    $dnsPrefix = "s$StudentNumber"
    $clusterName = "aks-wrkshp-$WorkshopNumber-s-$StudentNumber"
    Write-Host "Creating AKS cluster $clusterName with DNS prefix $dnsPrefix"
    az deployment group create --resource-group $resourceGroupName `
        --template-file main.bicep `
        --parameters dnsPrefix=$dnsPrefix `
        --parameters clusterName=$clusterName `
        --parameters sshRSAPublicKey="$publicKey"

    # Get the credentials for the AKS cluster
    $kubeConfigFileName = "wrkshp-$WorkshopNumber-student-$StudentNumber-config-$clusterName"
    Write-Host "Getting credentials for AKS cluster $clusterName"
    az aks get-credentials --resource-group $resourceGroupName --name $clusterName --file $kubeConfigFileName --overwrite-existing

    # Add the kubeconfig file to the key vault
    Write-Host "Adding kubeconfig file to key vault"
    az keyvault secret set --vault-name $keyVaultName --name $kubeConfigFileName --file $kubeConfigFileName --encoding ascii

    $mergedKubeConfigFiles = $true
    if ($mergedKubeConfigFiles) {
        $mergedKubeConfigFileName = "config-merged"
        $baseKubeConfigFileName = "C:\Users\emmanuel.DEVOPSABCS\.kube\config"

        # remove config cluster
        kubectl config delete-context $clusterName
     
        # merge both kube config files
        $ENV:KUBECONFIG = "$baseKubeConfigFileName;$kubeConfigFileName"
 
        # verify that the variable is set
        $ENV:KUBECONFIG
 
        # output to temp file
        kubectl config view --flatten > $mergedKubeConfigFileName
 
        # verify that config-merged is correct
        kubectl --kubeconfig=$mergedKubeConfigFileName config get-clusters
 
        # rename the original kube config file
        Move-Item $baseKubeConfigFileName "$baseKubeConfigFileName.bak"
 
        # move merged file to config
        Move-Item $mergedKubeConfigFileName $baseKubeConfigFileName

        kubectl config get-clusters
 
        # remove (optional)
        Remove-Item "$baseKubeConfigFileName.bak"

        kubectl config use-context $clusterName
        kubectl get nodes
        kubectl get ns

    }

    # Attach an Azure Container Registry (ACR) to the AKS cluster

    # Attach using acr-name
    Write-Host "Attaching ACR to AKS cluster"
    $acrName = az acr list --resource-group $resourceGroupName --query "[].name" -o tsv
    az aks update --name $clusterName --resource-group $resourceGroupName --attach-acr $acrName

    # get the ACR password
    $acrPassword = az acr credential show --name $acrName --query "passwords[0].value" -o tsv
    # add the ACR password to the key vault
    Write-Host "Adding ACR password to key vault"
    $acrPasswordSecretName = "wrkshp-$WorkshopNumber-student-$StudentNumber-acr-password-$acrName"
    az keyvault secret set --vault-name $keyVaultName --name $acrPasswordSecretName --value $acrPassword
}

for ($i = 1; $i -le $NumberOfStudents; $i++) {
    $studentNumberPadded = $i.ToString("000")
    Write-Host "Creating student $studentNumberPadded"
    New-StudentResource -StudentNumber $studentNumberPadded `
        -keyVaultName $keyVaultName `
        -subscription $subscription `
        -location $location `
        -jsonDepth $jsonDepth `
        -WorkshopNumber $WorkshopNumber
}