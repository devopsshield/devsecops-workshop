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
    # make mandatory parameters
    [Parameter(Mandatory = $true)]
    [string] $ghOwner, # = "devopsabcs-engineering",
    [Parameter(Mandatory = $true)]
    [string] $ghRepo, # = "oss-pygoat-devsecops",
    [Parameter(Mandatory = $true)]
    [string] $dockerName, # = "crs001fwmpo7kn3hnty",
    [Parameter(Mandatory = $true)]
    [string] $dockerPassword,
    [Parameter(Mandatory = $true)]
    [string] $defectDojoProductId,
    [Parameter(Mandatory = $true)]
    [string] $defectDojoToken,
    [Parameter(Mandatory = $true)]
    [string] $githubReadOnlyPersonalAccessTokenClassic,
    # optional parameters - kubeconfig file or base64
    [string] $kubeConfigFileName,
    [string] $kubeConfigBase64
)
function New-Environment {
    param (
        [string] $EnvironmentName = "OSS_pygoat-test",
        [string] $ghOwner = "devopsabcs-engineering",
        [string] $ghRepo = "oss-pygoat-devsecops"
    )

    # create GitHub environment
    gh api --method PUT -H "Accept: application/vnd.github+json" repos/$ghOwner/$ghRepo/environments/$EnvironmentName
}

# ensure GitHub CLI is installed
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI is not installed. Please install it from https://cli.github.com/"
    exit
}

# ensure one of kubeconfig file or base64 is provided
if (-not $kubeConfigFileName -and -not $kubeConfigBase64) {
    Write-Host "Kubeconfig file or base64 must be provided"
    exit
}

# create all environments
New-Environment -EnvironmentName "dev" -ghOwner $ghOwner -ghRepo $ghRepo
New-Environment -EnvironmentName "OSS_pygoat-test" -ghOwner $ghOwner -ghRepo $ghRepo
New-Environment -EnvironmentName "OSS_pygoat-prod" -ghOwner $ghOwner -ghRepo $ghRepo

# create GitHub environment variables
gh variable set DEFECTDOJO_PRODUCTID --body $defectDojoProductId --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh secret set DOCKER_PASSWORD --body "$dockerPassword" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh secret set DEFECTDOJO_TOKEN --body "$defectDojoToken" --repo "https://github.com/$ghOwner/$ghRepo" --env dev
gh secret set TOKEN_FOR_DOS --body "$githubReadOnlyPersonalAccessTokenClassic" --repo "https://github.com/$ghOwner/$ghRepo" --env dev

# repository variable for simplicity
gh variable set DOCKER_USERNAME --body "$dockerName" --repo "https://github.com/$ghOwner/$ghRepo"

# check if kubeconfig file was provided and exists
if ($kubeConfigBase64) {
    Write-Host "Kubeconfig base64 provided"
    $kubeConfigBase64Secret = $kubeConfigBase64
}
elseif ($kubeConfigFileName) {
    Write-Host "Kubeconfig file provided: $kubeConfigFileName"
    # check if kubeconfig file exists
    if (-not (Test-Path $kubeConfigFileName)) {
        Write-Host "Kubeconfig file does not exist: $kubeConfigFileName"        
    }
    else {
        Write-Host "Kubeconfig file exists: $kubeConfigFileName"
        # get kubeconfig contents
        $kubeContent = Get-Content $kubeConfigFileName -Raw

        # convert kubeconfig to base64
        Write-Host "Converting kubeconfig to base64"
        $kubeConfigBase64Secret = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($kubeContent))
    }
}
if (-not $kubeConfigBase64Secret) {
    Write-Host "Kubeconfig not provided or invalid"    
}
else {
    gh secret set KUBE_CONFIG --body "$kubeConfigBase64Secret" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-test"
    gh secret set KUBE_CONFIG --body "$kubeConfigBase64Secret" --repo "https://github.com/$ghOwner/$ghRepo" --env "OSS_pygoat-prod"
}