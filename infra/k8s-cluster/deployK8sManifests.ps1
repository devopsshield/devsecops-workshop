param (
    [Parameter()]
    [string]$manifestTemplateFolder = "./manifests",
    [Parameter()]
    [string]$IMAGE = "devopsshield/devsecops-pygoat",
    [Parameter()]
    [string]$TAG = "latest",
    [Parameter()]
    [string]$dnsResourceGroupName = "rg-dns-prod",
    [Parameter()]
    [string]$dnsZoneName = "cad4devops.com",
    [Parameter()]
    [ValidateSet("", "-dev", "-test")]
    [string]$environmentSuffix = "-test", # "-dev", "-test", ""
    [Parameter()]
    [string]$dnsRecordSetName = "pygoat${environmentSuffix}",
    [Parameter()]
    [string]$HOSTURL = "${dnsRecordSetName}.${dnsZoneName}",
    [Parameter()]
    [string]$serviceName = "pygoat-svc",
    [Parameter()]
    [string]$namespace = "pygoat${environmentSuffix}",
    [Parameter()]
    [string]$subscriptionId = "Microsoft Azure Sponsorship"
)
# docker pull devopsshield/devsecops-pygoat:latest

# echo parameters
Write-Host "manifestTemplateFolder: $manifestTemplateFolder"
Write-Host "IMAGE: $IMAGE"
Write-Host "TAG: $TAG"
Write-Host "HOSTURL: $HOSTURL"
Write-Host "serviceName: $serviceName"
Write-Host "namespace: $namespace"
Write-Host "dnsResourceGroupName: $dnsResourceGroupName"
Write-Host "dnsZoneName: $dnsZoneName"
Write-Host "dnsRecordSetName: $dnsRecordSetName"
Write-Host "subscriptionId: $subscriptionId"
Write-Host "environmentSuffix: $environmentSuffix"


# create a namespace if it does not exist
Write-Output "Creating namespace $namespace if it does not exist"
kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f -

# deploy k8s manifests
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
    $newEnvironmentSuffix = $environmentSuffix -replace "-", "."
    $newManifestFile = $manifestFile.FullName -replace ".template", $newEnvironmentSuffix
    Write-Output "Writing processed manifest file $newManifestFile"
    Set-Content -Path $newManifestFile -Value $manifestFileContent
    # apply the manifest file
    Write-Output "Applying manifest file $newManifestFile"
    kubectl apply -f $manifestFile.FullName --namespace $namespace
}

Write-Output "Finished deploying k8s manifests"

# get the external IP address of the service
$service = kubectl get service $serviceName --namespace $namespace -o json | ConvertFrom-Json
$externalIp = $service.status.loadBalancer.ingress[0].ip
Write-Output "External IP address of the service $serviceName is $externalIp"

# get all pods in the namespace
$pods = kubectl get pods --namespace $namespace
Write-Output "Pods in namespace ${namespace}:"
Write-Output $pods

# now get all
Write-Output "Getting all resources in namespace $namespace"
kubectl get all --namespace $namespace

# give instructions to access the service
Write-Output "To access the service, open a web browser and go to http://$externalIp"

# open a web browser
Write-Output "Opening a web browser to http://$externalIp"
Start-Process "http://$externalIp"

# create a DNS record for the service in Azure DNS
Write-Output "Creating a DNS record for the service in Azure DNS"

# login to Azure
Write-Output "Logging in to Azure"
az login

# set subscription
Write-Output "Setting subscription to $subscriptionId"
az account set --subscription "$subscriptionId"

# show the current subscription
Write-Output "Current subscription:"
az account show

Write-Output "Creating DNS record set $dnsRecordSetName in zone $dnsZoneName in resource group $dnsResourceGroupName"
# delete the existing DNS record set if it exists
Write-Output "Deleting existing DNS record set $dnsRecordSetName in zone $dnsZoneName in resource group $dnsResourceGroupName"
az network dns record-set a delete `
    --resource-group $dnsResourceGroupName `
    --zone-name $dnsZoneName `
    --name $dnsRecordSetName `
    --yes
Write-Output "DNS record set $dnsRecordSetName deleted in zone $dnsZoneName in resource group $dnsResourceGroupName"
az network dns record-set a create `
    --resource-group $dnsResourceGroupName `
    --name $dnsRecordSetName `
    --zone-name $dnsZoneName 
Write-Output "DNS record set $dnsRecordSetName created in zone $dnsZoneName in resource group $dnsResourceGroupName"
az network dns record-set a add-record `
    --resource-group $dnsResourceGroupName `
    --zone-name $dnsZoneName `
    --record-set-name $dnsRecordSetName `
    --ipv4-address $externalIp

Write-Output "DNS record set $dnsRecordSetName created in zone $dnsZoneName in resource group $dnsResourceGroupName"

Write-Output "Finished creating DNS record set"

# test the DNS record
Write-Output "Testing the DNS record"

# open a web browser
Write-Output "Opening a web browser to http://$HOSTURL"
Start-Process "http://$HOSTURL"