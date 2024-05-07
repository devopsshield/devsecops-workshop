# Create resource group and an identity with contributor access that GitHub can federate
az group create -l CanadaCentral -n rg-k8s-pygoat-dev-001

$app = (az ad app create --display-name "oss-pygoat-devsecops" --query "[appId,id]" -o tsv | ForEach-Object { $_.Split(" ") })
$spId = (az ad sp create --id $app[0] --query id -o tsv)
$subId = (az account show --query id -o tsv)

az role assignment create --role owner --assignee-object-id $spId --assignee-principal-type ServicePrincipal --scope "/subscriptions/$subId/resourceGroups/rg-k8s-pygoat-dev-001"

# Create a new federated identity credential
az rest --method POST --uri "https://graph.microsoft.com/beta/applications/${app[1]}/federatedIdentityCredentials" --body "{\"name\":\"oss-pygoat-devsecops-main-gh\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:devopsabcs-engineering/oss-pygoat-devsecops:ref:refs/heads/main\",\"description\":\"Access to branch main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# Set Secrets
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" AZURE_CLIENT_ID -b $app[0]
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" AZURE_TENANT_ID -b (az account show --query tenantId -o tsv)
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" AZURE_SUBSCRIPTION_ID -b $subId
gh secret set --repo "https://github.com/devopsabcs-engineering/oss-pygoat-devsecops" USER_OBJECT_ID -b $spId