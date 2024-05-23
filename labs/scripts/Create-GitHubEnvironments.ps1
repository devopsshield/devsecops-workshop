param (
    [string] $ghOwner = "devopsabcs-engineering",
    [string] $ghRepo = "oss-pygoat-devsecops",
    [string] $dockerName = "crs001fwmpo7kn3hnty",
    [string] $dockerPassword
)
function New-Environment {
    param (
        [string] $EnvironmentName = "OSS_pygoat-test",
        [string] $ghOwner = "devopsabcs-engineering",
        [string] $ghRepo = "oss-pygoat-devsecops",
        [string] $dockerName = "crs001fwmpo7kn3hnty",
        [string] $dockerPassword
    )

    # create GitHub environment
    gh api --method PUT -H "Accept: application/vnd.github+json" repos/$ghOwner/$ghRepo/environments/$EnvironmentName

    # # Set environment Secrets
    # gh secret set --repo "https://github.com/$ghOwner/$ghRepo" --env $EnvironmentName AZURE_CLIENT_ID -b $app[0]
    # gh secret set --repo "https://github.com/$ghOwner/$ghRepo" --env $EnvironmentName AZURE_TENANT_ID -b (az account show --query tenantId -o tsv)
    # gh secret set --repo "https://github.com/$ghOwner/$ghRepo" --env $EnvironmentName AZURE_SUBSCRIPTION_ID -b $subId
    # gh secret set --repo "https://github.com/$ghOwner/$ghRepo" --env $EnvironmentName USER_OBJECT_ID -b $spId
}

# create all environments
New-Environment -EnvironmentName "dev" -ghOwner $ghOwner -ghRepo $ghRepo
New-Environment -EnvironmentName "OSS_pygoat-test" -ghOwner $ghOwner -ghRepo $ghRepo
New-Environment -EnvironmentName "OSS_pygoat-prod" -ghOwner $ghOwner -ghRepo $ghRepo

# create GitHub environment variables
gh variable set DOCKER_REGISTRY --body "$dockerName.azurecr.io" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh variable set DOCKER_REGISTRY --body "$dockerName.azurecr.io" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-test"
gh variable set DOCKER_REGISTRY --body "$dockerName.azurecr.io" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-prod"
gh variable set DOCKER_USERNAME --body "$dockerName" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh secret set DOCKER_PASSWORD --body "$dockerPassword" --repo "https://github.com/$ghOwner/$ghRepo" --env dev