param (
    [Parameter()]
    [string]
    $displayName = "GH__devopsabcs_engineering__WRKSHP_FunctionApps", #"<your-service-principal-name>"
    [Parameter()]
    [string]
    $githubRepo = "devopsabcs-engineering/WRKSHP_FunctionApps", #"<your-github-username>/<your-repo-name>"
    [Parameter()]
    [string]
    $subscriptionId = "64c3d212-40ed-4c6d-a825-6adfbdf25dad", #"<your-subscription-id>"
    [Parameter()]
    [string]
    $tenantId = "aa93b9d9-037d-4f08-a26d-783cff0e2369", #"<your-tenant-id>"
    [Parameter()]
    [string]
    $clientId = ""
)

# echo parameters
Write-Output "displayName: $displayName"
Write-Output "githubRepo: $githubRepo"
Write-Output "subscriptionId: $subscriptionId"
Write-Output "tenantId: $tenantId"
Write-Output "clientId: $clientId"

# create azure credentials for the pipeline in github actions

# Login to Azure
#az login --service-principal -u "<your-service-principal-id>" -p "<your-service-principal-secret>" --tenant $tenantId
az login --tenant $tenantId

# Create the federated service principal
$sp = az ad sp create-for-rbac --name $displayName --role Contributor `
    --scopes /subscriptions/$subscriptionId `
    --query "{clientId: appId, clientSecret: password}" -o json | ConvertFrom-Json
$clientId = $sp.clientId

# get object id from app registration
$objectId = az ad app show --id $clientId --query id -o tsv
Write-Output "Service principal object ID: $objectId"


Write-Output "Service principal created."
Write-Output "Client ID: $clientId"

# read credentials.json from file
#$credentialRaw = Get-Content -Path "credential.json" -Raw
$credentialRaw = 
@'
{
    "name": "__CREDENTIAL_NAME__",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "__SUBJECT__",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
'@

# find and replace the placeholders with the actual values
$credential = $credentialRaw -replace "__CREDENTIAL_NAME__", $displayName -replace "__SUBJECT__", "repo:${githubRepo}:ref:refs/heads/main"

#$appId = "<Your-App-Id>"
$credential = $credential | ConvertFrom-Json
Write-Output "Credential: $credential"
New-AzADAppFederatedCredential -ApplicationObjectId $objectId -Name $credential.name `
    -Issuer $credential.issuer -Subject $credential.subject `
    -Audience $credential.audiences

gh auth login

# Push secrets to GitHub
$secrets = @{
    AZURE_CLIENT_ID       = $clientId
    AZURE_TENANT_ID       = $tenantId
    AZURE_SUBSCRIPTION_ID = $subscriptionId
}

# use gh cli to push secrets to github
foreach ($secret in $secrets.GetEnumerator()) {
    $value = $secret.Value
    $name = $secret.Key
    gh secret set $name -b $value -R $githubRepo
}

Write-Output "Federated service principal created and secrets pushed to GitHub."
