# create a user account for a new student in defect dojo
# Usage: New-Student.ps1 -FirstName <string> -LastName <string> -Email <string> -Username <string> -Password <string> -Role <string> -Team <string> -DojoUrl <string> -ApiKey <string>

# # Example:
# New-Students.ps1 -NumberOfStudents 25 `
#     -Password "P@ssw0rd!1" `
#     -DojoUrl "https://defectdojo-002.cad4devops.com:8443/" `
#     -ApiKey "your-api-key"

param (
    [int]    $NumberOfStudents = 3,
    [int]    $StudentStartNumber = 1,
    [string] $Password, # = "P@ssw0rd!1",
    [string] $DojoUrl = "https://defectdojo-002.cad4devops.com:8443/",
    [string] $ApiKey,
    [string] $groupId = 1, # workshop group
    [string] $keyVaultName = "kv-w001-rbf6xriugto5s",
    [string] $subscription = "Microsoft Azure Sponsorship",
    [string] $location = "canadacentral",
    [int]    $jsonDepth = 100,
    [string] $WorkshopNumber = "001",
    [string] $OutputFolder
)

function New-ComplexPassword {
    param (
        [int]$length = 12
    )

    $upperCase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $upperCaseArray = $upperCase.ToCharArray()
    $lowerCase = 'abcdefghijklmnopqrstuvwxyz'
    $lowerCaseArray = $lowerCase.ToCharArray()
    $numbers = '0123456789'
    $numbersArray = $numbers.ToCharArray()
    $specialChars = '!@#$%^&*()_-+=<>?'
    $specialCharsArray = $specialChars.ToCharArray()

    $randomUpperCase = $upperCaseArray | Get-Random -Count 1
    $randomLowerCase = $lowerCaseArray | Get-Random -Count 1
    $randomNumber = $numbersArray | Get-Random -Count 1
    $randomSpecialChar = $specialCharsArray | Get-Random -Count 1

    # Ensure the password includes at least one character from each set
    $initialPassword = $randomUpperCase + 
    $randomLowerCase + 
    $randomNumber + 
    $randomSpecialChar

    $allChars = $upperCase + $lowerCase + $numbers + $specialChars
    $allCharsArray = $allChars.ToCharArray()

    # Fill the rest of the password up to the desired length
    for ($i = $initialPassword.Length; $i -lt $length; $i++) {
        $initialPassword += $allCharsArray | Get-Random -Count 1
    }

    # Shuffle the password to prevent predictable patterns
    $shuffledPasswordChars = $initialPassword.ToCharArray() | Get-Random -Count $length
    $shuffledPassword = -join $shuffledPasswordChars

    return $shuffledPassword
}

function New-Student {
    param (
        [string] $StudentNumber,
        [string] $Password,
        [string] $DojoUrl,
        [string] $ApiKey,
        [string] $groupId = 1, # workshop group
        [int]    $jsonDepth = 100,
        [string] $WorkshopNumber = "001"
    )

    $FirstName = "Student"
    $LastName = $StudentNumber
    $Email = "${FirstName}${LastName}@example.com"
    $Username = "${FirstName}${LastName}"

    $DojoUrl = $DojoUrl.TrimEnd('/')
    $DojoUrl = $DojoUrl.TrimEnd('/api/v2')

    Write-Host "DojoUrl: $DojoUrl"

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")

    $dojoGroups = Invoke-RestMethod "$DojoUrl/api/v2/dojo_groups/" -Method 'GET' -Headers $headers
    $results = $dojoGroups.results
    $fetchedGroup = $results | Where-Object { $_.id -eq $groupId }
    Write-Host "Fetched group $($fetchedGroup.name) with id $groupId"

    # check if user exists
    $fetchedUser = Invoke-RestMethod "$DojoUrl/api/v2/users/?username=$Username" -Method 'GET' -Headers $headers
    $userExists = $fetchedUser.count -gt 0
    if ($userExists) {
        Write-Host "User $Username already exists"
        $fetchedUser | ConvertTo-Json -Depth $jsonDepth
        $fetchedUserId = $fetchedUser.results[0].id
        Write-Host "Fetched user $Username with id $fetchedUserId"
        $userId = $fetchedUserId

        # # update user password - can't update password using PATCH through the API
        # $user = @{
        #     password = $Password
        # }

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Token $ApiKey")
        $headers.Add("Content-Type", "application/json")

        $deletedUser = Invoke-RestMethod "$DojoUrl/api/v2/users/$userId/" -Method 'DELETE' -Headers $headers
        $userId = $deletedUser.id
        Write-Host "Deleted user $Username with id $userId"
        $deletedUser | ConvertTo-Json -Depth $jsonDepth     
    }
    
    
    Write-Host "User $Username does not exist"
    Write-Host "Creating user $Username with email $Email and password $Password"    

    $user = @{
        first_name = $FirstName
        last_name  = $LastName
        email      = $Email
        username   = $Username
        password   = $Password
        is_active  = $true
    }

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")
    $headers.Add("Content-Type", "application/json")

    $userJson = $user | ConvertTo-Json -Depth $jsonDepth

    $createdUser = Invoke-RestMethod "$DojoUrl/api/v2/users/" -Method 'POST' -Headers $headers -Body $userJson
    $userId = $createdUser.id
    Write-Host "Created user $($createdUser.username) with id $userId"
    $createdUser | ConvertTo-Json -Depth $jsonDepth
    

    # check if product exists
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")

    $productName = "GitHub-OSS-pygoat-devsecops-workshop-$WorkshopNumber-product-$StudentNumber"
    $fetchedProduct = Invoke-RestMethod "$DojoUrl/api/v2/products/?name=$productName" -Method 'GET' -Headers $headers
    $productExists = $fetchedProduct.count -gt 0
    # check if product exists
    if ($productExists) {
        Write-Host "Product $productName already exists"
        $fetchedProduct | ConvertTo-Json -Depth $jsonDepth
        $fetchedProductId = $fetchedProduct.results[0].id
        Write-Host "Fetched product $productName with id $fetchedProductId"
        $productId = $fetchedProductId
    }
    else {
        Write-Host "Product $productName does not exist"

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Token $ApiKey")
        $headers.Add("Content-Type", "application/json")

        $product = @{
            name        = "$productName"
            description = "GitHub-OSS-pygoat-devsecops workshop $WorkshopNumber at DevOps Days Montreal 2024 product $StudentNumber for student $StudentNumber"
            prod_type   = 1
        }

        $productJson = $product | ConvertTo-Json -Depth $jsonDepth

        $createdProduct = Invoke-RestMethod "$DojoUrl/api/v2/products/" -Method 'POST' -Headers $headers -Body $productJson
        $createdProductId = $createdProduct.id
        Write-Host "Created product $($createdProduct.name) with id $createdProductId"
        $createdProduct | ConvertTo-Json -Depth $jsonDepth
        $productId = $createdProductId
    }

    $addUserToWorkshopGroup = $false
    if ($addUserToWorkshopGroup) {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Token $ApiKey")
        $headers.Add("Content-Type", "application/json")

        $groupMember = @{
            group = $groupId
            user  = $userId
            role  = 2 # Writer
        }

        $groupMemberJson = $groupMember | ConvertTo-Json -Depth $jsonDepth

        $createdGroupMember = Invoke-RestMethod "$DojoUrl/api/v2/dojo_group_members/" -Method 'POST' -Headers $headers -Body $groupMemberJson
        $createdGroupMember | ConvertTo-Json -Depth $jsonDepth
    }

    # check if product member exists
    $fetchedProductMember = Invoke-RestMethod "$DojoUrl/api/v2/product_members/?product_id=$productId&user_id=$userId" -Method 'GET' -Headers $headers
    $productMemberExists = $fetchedProductMember.count -gt 0
    if ($productMemberExists) {
        Write-Host "Product member $productId $userId already exists"
        $fetchedProductMember | ConvertTo-Json -Depth $jsonDepth
        $fetchedProductMemberId = $fetchedProductMember.results[0].id
        Write-Host "Fetched product member $productId $userId with id $fetchedProductMemberId"
    }
    else {
        Write-Host "Product member $productId $userId does not exist"

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Token $ApiKey")
        $headers.Add("Content-Type", "application/json")

        $productMember = @{
            product = $productId
            user    = $userId
            role    = 2 # Writer
        } 

        $productMemberJson = $productMember | ConvertTo-Json -Depth $jsonDepth

        $createdProductMember = Invoke-RestMethod "$DojoUrl/api/v2/product_members/" -Method 'POST' -Headers $headers -Body $productMemberJson
        $createdProductMember | ConvertTo-Json -Depth $jsonDepth
    }

    # check if product group member exists
    $fetchedProductGroupMember = Invoke-RestMethod "$DojoUrl/api/v2/product_groups/?group_id=$groupId&product_id=$productId" -Method 'GET' -Headers $headers
    $productGroupMemberExists = $fetchedProductGroupMember.count -gt 0
    if ($productGroupMemberExists) {
        Write-Host "Product group member $productId $groupId already exists"
        $fetchedProductGroupMember | ConvertTo-Json -Depth $jsonDepth
        $fetchedProductGroupMemberId = $fetchedProductGroupMember.results[0].id
        Write-Host "Fetched product group member $productId $groupId with id $fetchedProductGroupMemberId"
    }
    else {
        Write-Host "Product group member $productId $groupId does not exist"

        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Token $ApiKey")
        $headers.Add("Content-Type", "application/json")

        $productGroupMember = @{
            product = $productId
            group   = $groupId
            role    = 2 # Writer
        }

        $productGroupMemberJson = $productGroupMember | ConvertTo-Json -Depth $jsonDepth

        $createdProductGroupMember = Invoke-RestMethod "$DojoUrl/api/v2/product_groups/" -Method 'POST' -Headers $headers -Body $productGroupMemberJson
        $createdProductGroupMember | ConvertTo-Json
    }

    # get api token for newly created user
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")
    $headers.Add("Content-Type", "application/x-www-form-urlencoded")

    $body = "password=$Password&username=$Username"

    $response = Invoke-RestMethod "$DojoUrl/api/v2/api-token-auth/" -Method 'POST' -Headers $headers -Body $body
    $token = $response.token
    $response | ConvertTo-Json

    return @{
        WorkshopNumber        = $WorkshopNumber
        StudentNumber         = $StudentNumber
        DefectDojoUrl         = "$DojoUrl/"
        DefectDojoUserId      = $userId
        DefectDojoUserName    = $Username
        DefectDojoPassword    = $Password
        DefectDojoProductName = $productName
        DefectDojoProductId   = $productId
        DefectDojoToken       = $token
    }
}

function New-StudentResource {
    param (
        [string] $StudentNumber = "001",  
        [string] $keyVaultName = "kv-w001-rbf6xriugto5s",
        [string] $subscription = "Microsoft Azure Sponsorship",
        [string] $location = "canadacentral",
        [int]    $jsonDepth = 100,
        [string] $WorkshopNumber = "001",
        [string] $OutputFolder
    )

    # if output folder is not set, set it to the current directory
    if (-not $OutputFolder) {
        $OutputFolder = Get-Location
    }
 
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

    # delete the ssh key if it already exists
    Write-Host "Deleting SSH key pair $privateKeyPath and $publicKeyPath if they already exist"
    if (Test-Path $privateKeyPath) {
        Write-Host "Deleting $privateKeyPath"
        Remove-Item $privateKeyPath
    }
    if (Test-Path $publicKeyPath) {
        Write-Host "Deleting $publicKeyPath"
        Remove-Item $publicKeyPath
    }

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
    
    # Create an Azure Kubernetes Service (AKS) cluster
    $dnsPrefix = "s$StudentNumber"
    $clusterName = "aks-wrkshp-$WorkshopNumber-s-$StudentNumber"
    $containerRegistryBaseName = "crs$StudentNumber"
    Write-Host "Creating AKS cluster $clusterName with DNS prefix $dnsPrefix"
    az deployment group create --resource-group $resourceGroupName `
        --template-file main.bicep `
        --parameters dnsPrefix=$dnsPrefix `
        --parameters clusterName=$clusterName `
        --parameters sshRSAPublicKey="$publicKey" `
        --parameters containerRegistryBaseName=$containerRegistryBaseName   

    # Get the credentials for the AKS cluster
    # create subfolder for kubeconfig files if it does not exist
    $kubeConfigFolder = Join-Path "$OutputFolder" "workshop$WorkshopNumber/student$StudentNumber"
    if (-not (Test-Path $kubeConfigFolder)) {
        Write-Host "Creating kubeconfig folder $kubeConfigFolder"
        New-Item -ItemType Directory -Path $kubeConfigFolder
    }
    else {
        Write-Host "Kubeconfig folder $kubeConfigFolder already exists"
    }
    # get absolute path to kubeconfig folder
    $kubeConfigFolder = (Get-Item $kubeConfigFolder).FullName
    $kubeConfigFileName = Join-Path "$kubeConfigFolder" "wrkshp-$WorkshopNumber-student-$StudentNumber-config-$clusterName"
    Write-Host "Getting credentials for AKS cluster $clusterName"
    az aks get-credentials --resource-group $resourceGroupName --name $clusterName --file $kubeConfigFileName --overwrite-existing

    # get absolute path to kubeconfig file
    $kubeConfigFileName = (Get-Item $kubeConfigFileName).FullName
    Write-Host "Kubeconfig file: $kubeConfigFileName"

    # Add the kubeconfig file to the key vault
    Write-Host "Adding kubeconfig file to key vault"
    $kubeConfigFileNameSecretName = "wrkshp-$WorkshopNumber-student-$StudentNumber-config-$clusterName"
    az keyvault secret set --vault-name $keyVaultName --name $kubeConfigFileNameSecretName --file $kubeConfigFileName --encoding ascii

    # get the kubeconfig file content
    $kubeContent = Get-Content $kubeConfigFileName -Raw
    # get base64 encoded kubeconfig file
    $kubeConfigBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeContent))

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

    return @{
        ResourceGroupName         = $resourceGroupName
        Location                  = $location
        ClusterName               = $clusterName
        SshKeyName                = $sshKeyName
        OutputFolder              = $OutputFolder
        KubernetesConfigFolder    = $kubeConfigFolder
        KubernetesConfigFileName  = $kubeConfigFileName
        KubernetesConfigBase64    = $kubeConfigBase64
        ContainerRegistryName     = $acrName
        ContainerRegistryPassword = $acrPassword
    }
}

# check if password is set
if (-not $Password) {
    Write-Host "Password is not set through parameter, generating password for each student"
    # generate a random password        
    $generateRandomPassword = $true
}
else {
    Write-Host "Password is set through parameter"
    $generateRandomPassword = $false
}

for ($i = $StudentStartNumber; $i -le $StudentStarNumber + $NumberOfStudents; $i++) {

    # check if password is set
    if ($generateRandomPassword) {
        Write-Host "Password is not set through parameter, generating password"
        # generate a random password        
        $Password = New-ComplexPassword -length 12
    }
    else {
        Write-Host "Password is set through parameter"
        Write-Host "Password: $Password"
    }

    $studentNumberPadded = $i.ToString("000")
    $StudentNumber = $studentNumberPadded
    Write-Host "Creating student $StudentNumber"
    $retValueStudent = New-Student -StudentNumber $StudentNumber `
        -Password $Password `
        -DojoUrl $DojoUrl `
        -ApiKey $ApiKey `
        -groupId $groupId `
        -jsonDepth $jsonDepth `
        -WorkshopNumber $WorkshopNumber

    Write-Host "Creating resources for student $StudentNumber"
    $retValueStudentResource = New-StudentResource -StudentNumber $StudentNumber `
        -keyVaultName $keyVaultName `
        -subscription $subscription `
        -location $location `
        -jsonDepth $jsonDepth `
        -WorkshopNumber $WorkshopNumber

    Write-Host "Student $StudentNumber created"

    # create a string array
    $strArray = @()
    $strArray += "Workshop Number: $($retValueStudent.WorkshopNumber)"
    $strArray += "Student Number: $($retValueStudent.StudentNumber)"
    $strArray += "Defect Dojo Url: $($retValueStudent.DefectDojoUrl)"
    $strArray += "Defect Dojo User Id: $($retValueStudent.DefectDojoUserId)"
    $strArray += "Defect Dojo User Name: $($retValueStudent.DefectDojoUserName)"
    $strArray += "Defect Dojo Password: $($retValueStudent.DefectDojoPassword)"
    $strArray += "Defect Dojo Product Name: $($retValueStudent.DefectDojoProductName)"
    $strArray += "Defect Dojo Product Id: $($retValueStudent.DefectDojoProductId)"
    $strArray += "Defect Dojo Token (API Key): $($retValueStudent.DefectDojoToken)"
    $strArray += "Resource Group Name: $($retValueStudentResource.ResourceGroupName)"
    $strArray += "Location: $($retValueStudentResource.Location)"
    $strArray += "Cluster Name: $($retValueStudentResource.ClusterName)"
    $strArray += "SSH Key Name: $($retValueStudentResource.SshKeyName)"
    $strArray += "Container Registry Name: $($retValueStudentResource.ContainerRegistryName)"
    $strArray += "Container Registry Password: $($retValueStudentResource.ContainerRegistryPassword)"
    $strArray += "Output Folder: $($retValueStudentResource.OutputFolder)"
    $strArray += "Kubernetes Config Folder: $($retValueStudentResource.KubernetesConfigFolder)"
    $strArray += "Kubernetes Config File Name: $($retValueStudentResource.KubernetesConfigFileName)"
    $strArray += "Kubernetes Config Base64:"
    $strArray += $retValueStudentResource.KubernetesConfigBase64

    # write the string array to a file
    Write-Host "Writing string array to file"
    $strArrayFileName = "wrkshp-$WorkshopNumber-student-$StudentNumber-info.txt"
    $kubeConfigFolder = $retValueStudentResource.KubernetesConfigFolder
    $strArrayFilePath = Join-Path $kubeConfigFolder $strArrayFileName
    # backup the file if it already exists
    if (Test-Path $strArrayFilePath) {
        Write-Host "Backing up file $strArrayFilePath"
        $strArrayFilePathBackup = $strArrayFilePath + ".bak"
        Move-Item $strArrayFilePath $strArrayFilePathBackup
    }
    Write-Host "Writing string array to file $strArrayFilePath"
    $strArray | Out-File $strArrayFilePath
}