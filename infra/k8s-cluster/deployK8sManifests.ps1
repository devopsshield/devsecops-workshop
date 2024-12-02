param (
    [Parameter()]
    [string]$manifestTemplateFolder = "./manifests",
    [Parameter()]
    [string]$IMAGE = "devopsshield/devsecops-pygoat",
    [Parameter()]
    [string]$TAG = "latest",
    [Parameter()]
    [string]$HOSTURL = "pygoat-test.cad4devops.com"
)
# docker pull devopsshield/devsecops-pygoat:latest

# echo parameters
Write-Host "manifestTemplateFolder: $manifestTemplateFolder"

Write-Output "Deploying k8s manifests in folder $manifestTemplateFolder"

# loop through each manifest file in the folder with extension template.yaml
$manifestFiles = Get-ChildItem -Path $manifestTemplateFolder -Filter "*.template.yaml"
foreach ($manifestFile in $manifestFiles) {
    Write-Output "Processing manifest file $manifestFile"
    $manifestFileContent = Get-Content $manifestFile.FullName
    # replace #{image}# with the value of the environment variable IMAGE
    $manifestFileContent = $manifestFileContent -replace "#\{image\}#", $IMAGE
    # replace #{tag}# with the value of the environment variable TAG
    $manifestFileContent = $manifestFileContent -replace "#\{tag\}#", $TAG
    # replace #{host}# with the value of the environment variable HOST
    $manifestFileContent = $manifestFileContent -replace "#\{host\}#", $HOSTURL
    # create a new file with the same name but without the .template extension
    $newManifestFile = $manifestFile.FullName -replace ".template", ""
    Write-Output "Writing processed manifest file $newManifestFile"
    Set-Content -Path $newManifestFile -Value $manifestFileContent
    # apply the manifest file
    kubectl apply -f $manifestFile.FullName
}