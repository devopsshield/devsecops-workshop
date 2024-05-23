# create a user account for a new student in defect dojo
# Usage: New-Student.ps1 -FirstName <string> -LastName <string> -Email <string> -Username <string> -Password <string> -Role <string> -Team <string> -DojoUrl <string> -ApiKey <string>

# # Example:
# New-Students.ps1 -NumberOfStudents 25 `
#     -Password "P@ssw0rd!1" `
#     -DojoUrl "https://defectdojo-002.cad4devops.com:8443/" `
#     -ApiKey "your-api-key"


param (
    [int]    $NumberOfStudents = 25,
    [string] $Password,
    [string] $DojoUrl,
    [string] $ApiKey,
    [string] $groupId = 1, # workshop group
    [int]    $jsonDepth = 100,
    [string] $WorkshopNumber = "001"
)
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

    Write-Host "Creating user $Username with email $Email"

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
    $createdUserId = $createdUser.id
    Write-Host "Created user $($createdUser.username) with id $createdUserId"
    $createdUser | ConvertTo-Json -Depth $jsonDepth

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")
    $headers.Add("Content-Type", "application/json")

    $product = @{
        name        = "GitHub-OSS-pygoat-devsecops-workshop-$WorkshopNumber-product-$StudentNumber"
        description = "GitHub-OSS-pygoat-devsecops workshop $WorkshopNumber at DevOps Days Montreal 2024 product $StudentNumber for student $StudentNumber"
        prod_type   = 1
    }

    $productJson = $product | ConvertTo-Json -Depth $jsonDepth

    $createdProduct = Invoke-RestMethod "$DojoUrl/api/v2/products/" -Method 'POST' -Headers $headers -Body $productJson
    $createdProductId = $createdProduct.id
    Write-Host "Created product $($createdProduct.name) with id $createdProductId"
    $createdProduct | ConvertTo-Json -Depth $jsonDepth

    $addUserToWorkshopGroup = $false
    if ($addUserToWorkshopGroup) {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Authorization", "Token $ApiKey")
        $headers.Add("Content-Type", "application/json")

        $groupMember = @{
            group = $groupId
            user  = $createdUserId
            role  = 2 # Writer
        }

        $groupMemberJson = $groupMember | ConvertTo-Json -Depth $jsonDepth

        $createdGroupMember = Invoke-RestMethod "$DojoUrl/api/v2/dojo_group_members/" -Method 'POST' -Headers $headers -Body $groupMemberJson
        $createdGroupMember | ConvertTo-Json -Depth $jsonDepth
    }


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")
    $headers.Add("Content-Type", "application/json")

    $productMember = @{
        product = $createdProductId
        user    = $createdUserId
        role    = 2 # Writer
    } 

    $productMemberJson = $productMember | ConvertTo-Json -Depth $jsonDepth

    $createdProductMember = Invoke-RestMethod "$DojoUrl/api/v2/product_members/" -Method 'POST' -Headers $headers -Body $productMemberJson
    $createdProductMember | ConvertTo-Json -Depth $jsonDepth


    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Token $ApiKey")
    $headers.Add("Content-Type", "application/json")

    $productGroupMember = @{
        product = $createdProductId
        group   = $groupId
        role    = 2 # Writer
    }

    $productGroupMemberJson = $productGroupMember | ConvertTo-Json -Depth $jsonDepth

    $createdProductGroupMember = Invoke-RestMethod "$DojoUrl/api/v2/product_groups/" -Method 'POST' -Headers $headers -Body $productGroupMemberJson
    $createdProductGroupMember | ConvertTo-Json
}

for ($i = 1; $i -le $NumberOfStudents; $i++) {
    $studentNumberPadded = $i.ToString("000")
    Write-Host "Creating student $studentNumberPadded"
    New-Student -StudentNumber $studentNumberPadded `
        -Password $Password `
        -DojoUrl $DojoUrl `
        -ApiKey $ApiKey `
        -groupId $groupId `
        -jsonDepth $jsonDepth `
        -WorkshopNumber $WorkshopNumber
}