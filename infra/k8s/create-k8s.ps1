# Create resource group and an identity with contributor access that GitHub can federate
az group create -l CanadaCentral -n rg-k8s-pygoat-dev-001

$app = (az ad app create --display-name "oss-pygoat-devsecops" --query "[appId,id]" -o tsv | ForEach-Object { $_.Split(" ") })
$spId = (az ad sp create --id $app[0] --query id -o tsv)
$subId = (az account show --query id -o tsv)

az role assignment create --role owner --assignee-object-id $spId --assignee-principal-type ServicePrincipal --scope "/subscriptions/$subId/resourceGroups/rg-k8s-pygoat-dev-001"

# # Create a new federated identity credential
# Import-Module -Name Microsoft.PowerShell.Utility

# $body = @{
#     name        = "oss-pygoat-devsecops-main-gh"
#     issuer      = "https://token.actions.githubusercontent.com"
#     subject     = "repo:devopsabcs-engineering/oss-pygoat-devsecops:ref:refs/heads/main"
#     description = "Access to branch main"
#     audiences   = [string[]]@("api://AzureADTokenExchange")
# }

# $bodyJson = $body | ConvertTo-Json -Depth 3

# Invoke-WebRequest -Uri "https://graph.microsoft.com/beta/applications/${app[1]}/federatedIdentityCredentials" `
#     -Method POST `
#     -Headers @{"Content-Type" = "application/json" } `
#     -Body $bodyJson
$appObjectId = $app[1]
# az rest --method POST `
#     --headers '{\"Content-Type\":\"application/json\"}' `
#     --url "https://graph.microsoft.com/beta/applications/${app[1]}/federatedIdentityCredentials" `
#     --body '{\"name\":\"oss-pygoat-devsecops-main-gh\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"description\":\"Access to branch main\",\"subject\":\"repo:devopsabcs-engineering/oss-pygoat-devsecops:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}'
Set-Content -Path credential.json -Value '{"name":"oss-pygoat-devsecops-main-gh","issuer":"https://token.actions.githubusercontent.com","description":"Access to branch main","subject":"repo:devopsabcs-engineering/oss-pygoat-devsecops:ref:refs/heads/main","audiences":["api://AzureADTokenExchange"]}'

az ad app federated-credential create --id $appObjectId --parameters credential.json


# create GitHub environment
gh api --method PUT -H "Accept: application/vnd.github+json" repos/devopsabcs-engineering/oss-pygoat-devsecops/environments/OSS_pygoat-test
gh api --method PUT -H "Accept: application/vnd.github+json" repos/devopsabcs-engineering/oss-pygoat-devsecops/environments/OSS_pygoat-prod

# Set Secrets
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" --env OSS_pygoat-test AZURE_CLIENT_ID -b $app[0]
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" --env OSS_pygoat-test AZURE_TENANT_ID -b (az account show --query tenantId -o tsv)
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" --env OSS_pygoat-test AZURE_SUBSCRIPTION_ID -b $subId
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" --env OSS_pygoat-test USER_OBJECT_ID -b $spId