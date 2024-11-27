param (    
    [Parameter()]
    [string]
    $githubRepo = "devopsabcs-engineering/devsecops-workshop", #"<your-github-username>/<your-repo-name>"
    [Parameter()]
    [string]
    $subscriptionName = "IT Test", #"<your-subscription-id>"
    [Parameter()]
    [string]
    $tenantName = "devopsabcs.com" #"<your-tenant-id>"
)

# get the display name from the repo name replacing the forward slash with a double underscore
$displayName = "GH__" + $githubRepo -replace "/", "__"

Write-Output "Creating federated identity for $displayName in $githubRepo"

$subscriptionsWithTenants = az account list --query "[].{SubscriptionName:name, TenantId:tenantId}" -o json | ConvertFrom-Json
$subscription = $subscriptionsWithTenants | Where-Object { $_.SubscriptionName -eq $subscriptionName }
$tenantId = $subscription.TenantId

# get tenant id from tenant name
Write-Output "Tenant ID: $tenantId"

# Login to Azure
#az login --service-principal -u "<your-service-principal-id>" -p "<your-service-principal-secret>" --tenant $tenantId
az login --tenant $tenantId

# set the default subscription
az account set --subscription $subscriptionName

# get subscription id from subscription name
$subscriptionId = az account show --query id -o tsv
Write-Output "Subscription ID: $subscriptionId"

# echo parameters
Write-Output "displayName: $displayName"
Write-Output "githubRepo: $githubRepo"
Write-Output "subscriptionName: $subscriptionName"
Write-Output "subscriptionId: $subscriptionId"
Write-Output "tenantName: $tenantName"
Write-Output "tenantId: $tenantId"
Write-Output "clientId: $clientId"


# create azure credentials for the pipeline in github actions

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

$appRegistrationJson = az ad app list --display-name "$displayName" -o json
Write-Output "App Registration: $appRegistrationJson"
$appRegistration = $appRegistrationJson | ConvertFrom-Json
Write-Output "App Registration: $appRegistration"



#$appId = "<Your-App-Id>"
$credential = $credential | ConvertFrom-Json
Write-Output "Credential: $credential"
az ad app show --id $objectId
$command = "New-AzADAppFederatedCredential -ApplicationObjectId $objectId -Name $($credential.name) -Issuer $($credential.issuer) -Subject $($credential.subject) -Audience $($credential.audiences)"

Write-Output "Command: $command"

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
