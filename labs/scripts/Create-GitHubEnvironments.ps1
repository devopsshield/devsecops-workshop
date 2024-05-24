# # Example:
# .\Create-GitHubEnvironments.ps1 -ghOwner emmanuel-knafo `
#     -ghRepo oss-pygoat-devsecops `
#     -dockerName crs001fwmpo7kn3hnty `
#     -dockerPassword "Dgv*************************************************" `
#     -defectDojoProductId 6 `
#     -defectDojoToken "607*************************************" `
#     -githubReadOnlyPersonalAccessTokenClassic "ghp_pPK*********************************" `
#     -kubeConfigFileName "E:\src\GitHub\devopsshield\oss-pygoat-devsecops\infra\onboarding\wrkshp-001-student-001-config-aks-wrkshp-001-s-001"

param (
    [string] $ghOwner = "devopsabcs-engineering",
    [string] $ghRepo = "oss-pygoat-devsecops",
    [string] $dockerName = "crs001fwmpo7kn3hnty",
    [string] $dockerPassword,
    [string] $defectDojoProductId,
    [string] $defectDojoToken,
    [string] $githubReadOnlyPersonalAccessTokenClassic,
    [string] $kubeConfigFileName
)
function New-Environment {
    param (
        [string] $EnvironmentName = "OSS_pygoat-test",
        [string] $ghOwner = "devopsabcs-engineering",
        [string] $ghRepo = "oss-pygoat-devsecops"
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
#gh variable set DOCKER_REGISTRY --body "$dockerName.azurecr.io" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh variable set DEFECTDOJO_PRODUCTID --body $defectDojoProductId --repo "https://github.com/$ghOwner/$ghRepo" --env dev
#gh variable set DOCKER_REGISTRY --body "$dockerName.azurecr.io" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-test"
#gh variable set DOCKER_REGISTRY --body "$dockerName.azurecr.io" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-prod"
gh secret set DOCKER_PASSWORD --body "$dockerPassword" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh secret set DEFECTDOJO_TOKEN --body "$defectDojoToken" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh secret set TOKEN_FOR_DOS --body "$githubReadOnlyPersonalAccessTokenClassic" --repo "https://github.com/$ghOwner/$ghRepo" --env dev

# repository variable for simplicity
gh variable set DOCKER_USERNAME --body "$dockerName" --repo "https://github.com/$ghOwner/$ghRepo"

# get kubeconfig contents
$kubeContent = Get-Content $kubeConfigFileName -Raw

# convert kubeconfig to base64
$kubeConfigBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeContent))
 
gh secret set KUBE_CONFIG --body "$kubeConfigBase64" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-test"
gh secret set KUBE_CONFIG --body "$kubeConfigBase64" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-prod"