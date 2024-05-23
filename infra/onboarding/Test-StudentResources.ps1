# # Example:
# .\Test-StudentResources.ps1 -NumberOfStudents 25

param (
    [int]    $NumberOfStudents = 5,
    [string] $keyVaultName = "kv-w001-rbf6xriugto5s",
    [string] $subscription = "Microsoft Azure Sponsorship", 
    [string] $location = "canadacentral", 
    [int]    $jsonDepth = 100,
    [string] $WorkshopNumber = "001"
)

function Test-StudentResource {
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
    $clusterName = "aks-wrkshp-$WorkshopNumber-s-$StudentNumber"

    # grab the kubeconfig file from the key vault
    $kubeConfigSecretName = "wrkshp-$WorkshopNumber-student-$StudentNumber-config-$clusterName"
    $kubeConfigFileName = "wrkshp-$WorkshopNumber-student-$StudentNumber-config-$clusterName-fetched"
    Write-Host "Deleting kubeconfig file $kubeConfigFileName if it already exists"
    Remove-Item -Path $kubeConfigFileName -ErrorAction SilentlyContinue
    Write-Host "Getting kubeconfig file from key vault"
    az keyvault secret download --vault-name $keyVaultName --name $kubeConfigSecretName --file $kubeConfigFileName --encoding ascii

    # verify that config-merged is correct
    #Get-Content $kubeConfigFileName
    kubectl --kubeconfig=$kubeConfigFileName config get-clusters    

    # verify that the context is correct    
    Write-Debug "Verifying that the context $clusterName is correct"
    kubectl config use-context $clusterName
    kubectl get nodes
    kubectl get ns

    # get acr credentials
    $acrName = az acr list --resource-group $resourceGroupName --query "[].name" -o tsv
    # get acr password
    Write-Host "Getting ACR password from key vault"
    $acrPasswordSecretName = "wrkshp-$WorkshopNumber-student-$StudentNumber-acr-password-$acrName"
    
    $acrPassword = az keyvault secret show --vault-name $keyVaultName --name $acrPasswordSecretName --query value -o tsv
    Write-Host "deleting acr password file if it already exists"
    Remove-Item -Path $acrPasswordSecretName -ErrorAction SilentlyContinue
    $download = $true
    if ($download) {
        Write-Host "Downloading ACR password to file $acrPasswordSecretName"
        az keyvault secret download --vault-name $keyVaultName --name $acrPasswordSecretName --file $acrPasswordSecretName --encoding ascii
    }
    #Write-Host "ACR password: $acrPassword"

    # verify that the acr password is correct
    Write-Host "Verifying that the ACR password is correct"
    az acr login --name $acrName --username $acrName --password $acrPassword
    #Write-Host "Logging into ACR: docker login $acrName.azurecr.io --username $acrName --password $acrPassword"
    #docker login $acrName.azurecr.io --username $acrName --password $acrPassword
    #Get-Content $acrPasswordSecretName | docker login $acrName.azurecr.io --username $acrName --password-stdin
}

for ($i = 1; $i -le $NumberOfStudents; $i++) {
    $studentNumberPadded = $i.ToString("000")
    Write-Host "Testing student resources $studentNumberPadded"
    Test-StudentResource -StudentNumber $studentNumberPadded `
        -keyVaultName $keyVaultName `
        -subscription $subscription `
        -location $location `
        -jsonDepth $jsonDepth `
        -WorkshopNumber $WorkshopNumber
}