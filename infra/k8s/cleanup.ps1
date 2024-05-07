# Get the app ID and ID for the specified display name
$rmId = (az ad app list --display-name "oss-pygoat-devsecops" --query "[[0].appId,[0].id]" -o tsv)

# Delete the federated identity credential
az rest -m DELETE -u "https://graph.microsoft.com/beta/applications/${rmId[1]}/federatedIdentityCredentials/$(az rest -m GET -u https://graph.microsoft.com/beta/applications/${rmId[1]}/federatedIdentityCredentials --query value[0].id -o tsv)"

# Delete the service principal
az ad sp delete --id $(az ad sp show --id ${rmId[0]} --query id -o tsv)
