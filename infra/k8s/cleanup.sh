rmId=($(az ad app list --display-name oss-pygoat-devsecops --query '[[0].appId,[0].id]' -o tsv))
az rest -m DELETE  -u "https://graph.microsoft.com/beta/applications/${rmId[1]}/federatedIdentityCredentials/$(az rest -m GET -u https://graph.microsoft.com/beta/applications/${rmId[1]}/federatedIdentityCredentials --query value[0].id -o tsv)"
az ad sp delete --id $(az ad sp show --id ${rmId[0]} --query id -o tsv)
