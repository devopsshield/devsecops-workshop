param (
    [Parameter()]
    [string] $resourceGroup = "rg-dns-prod",
    [Parameter()]
    [string] $zoneName = "devopsshield.com",
    [Parameter()]
    [string] $subscriptionId = "Microsoft Azure Sponsorship",
    [Parameter()]
    [string] $aliasDefectDojo = "app-defectdojo-ek005",
    [Parameter()]
    [string] $aliasDefectDojoValue = "app-defectdojo-ek005-wjgilvkd363nc.canadacentral.cloudapp.azure.com",
    [Parameter()]
    [string] $aliasDefectDojoPostgresql = "app-defectdojo-ek005-postgresql",
    [Parameter()]
    [string] $aliasDefectDojoPostgresqlValue = "psql-defectdojo-ek005-wjgilvkd363nc.postgres.database.azure.com",
    [Parameter()]
    [string] $sshKeyPath = "$HOME\.ssh\vm-defectdojo-ek005-id_rsa",
    [Parameter()]
    [string] $sshUser = "azureuser",
    [Parameter()]
    [string] $instanceName = "app-defectdojo-ek005",
    [Parameter()]
    [string] $username = "ddadmin",
    [Parameter()]
    [string] $password = "booWgDmaYdgNxO5eNWql",
    [Parameter()]
    [string] $domain = "devopsshield.com",
    [Parameter()]
    [string] $email = "emmanuel.knafo@devopsshield.com",
    [Parameter()]
    [string] $adminUser = "emmanuel",
    [Parameter()]
    [string] $adminPassword = "N9rw04entPmou3Rbf6JP!"
)

Write-Output "resourceGroup: $resourceGroup"
Write-Output "zoneName: $zoneName"
Write-Output "subscriptionId: $subscriptionId"

# install az cli if not already installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Output "Installing az cli"
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://aka.ms/installazurecliwindows')
}
else {
    Write-Output "az cli already installed"    
}

# login
Write-Output "Logging in to Azure"
az login

# set subscription
Write-Output "Setting subscription to $subscriptionId"
az account set --subscription "$subscriptionId"

Write-Output "Listing DNS record sets"
az network dns record-set cname list `
    --resource-group $resourceGroup `
    --zone-name $zoneName `
    --output table

# add cname record
Write-Output "Adding CNAME record $aliasDefectDojo with value $aliasDefectDojoValue"
az network dns record-set cname set-record `
    --resource-group $resourceGroup `
    --zone-name $zoneName `
    --record-set-name $aliasDefectDojo `
    --cname $aliasDefectDojoValue

Write-Output "Adding CNAME record $aliasDefectDojoPostgresql with value $aliasDefectDojoPostgresqlValue"
az network dns record-set cname set-record `
    --resource-group $resourceGroup `
    --zone-name $zoneName `
    --record-set-name $aliasDefectDojoPostgresql `
    --cname $aliasDefectDojoPostgresqlValue

Write-Output "Listing DNS record sets"
az network dns record-set cname list `
    --resource-group $resourceGroup `
    --zone-name $zoneName `
    --output table

# az network dns record-set a add-record `
#     -g $resourceGroup `
#     -z $zoneName `
#     -n $dnsRecordSetNameTest `
#     -a $ipv4AddressTest

# az network dns record-set a add-record `
#     -g $resourceGroup `
#     -z $zoneName `
#     -n $dnsRecordSetNameProd `
#     -a $ipv4AddressProd

# az network dns record-set a list `
#     --resource-group $resourceGroup `
#     --zone-name $zoneName


# run some commands via ssh
Write-Host "Running some commands via ssh"
$fqdnDefectDojo = "${aliasDefectDojo}.${zoneName}"

# check if ssh key exists
if (-not (Test-Path $sshKeyPath)) {
    Write-Output "ssh key pair does not exist"
    exit 1
}
else {
    Write-Output "ssh key pair exists"
}   

Write-Output "Running ssh command on $fqdnDefectDojo with key $sshKeyPath and user $sshUser"

ssh -i $sshKeyPath -o StrictHostKeyChecking=no ${sshUser}@${fqdnDefectDojo} "echo 'Hello, world!'"

# now clone repo git clone https://github.com/DefectDojo/django-DefectDojo provided django-DefectDojo doesn't exist
ssh -i $sshKeyPath -o StrictHostKeyChecking=no ${sshUser}@${fqdnDefectDojo} "[ ! -d 'django-DefectDojo' ] && git clone https://github.com/DefectDojo/django-DefectDojo django-DefectDojo"

# prepare post-install.sh script by find and replacing the following in post-install.template.sh:
# __INSTANCE_NAME__ --> $instanceName
# __USERNAME__ --> $username
# __PASSWORD__ --> $password
# __DOMAIN__ --> $domain
# __EMAIL__ --> $email
# __ADMIN_USER__ --> $adminUser
# __ADMIN_PASSWORD__ --> $adminPassword
# then copy the post-install.sh script to the vm

$postInstallScriptPath = "post-install.sh"
$postInstallTemplatePath = "post-install.template.sh"

Write-Output "Preparing post-install.sh script"

# find and replace
(Get-Content $postInstallTemplatePath) `
    -replace "__INSTANCE_NAME__", $instanceName `
    -replace "__USERNAME__", $username `
    -replace "__PASSWORD__", $password `
    -replace "__DOMAIN__", $domain `
    -replace "__EMAIL__", $email `
    -replace "__ADMIN_USER__", $adminUser `
    -replace "__ADMIN_PASSWORD__", $adminPassword `
    -replace "__DO_PAUSES__", "true" `
    -replace "__REPO_NAME__", "django-DefectDojo"
| Set-Content $postInstallScriptPath

Write-Output "Copying post-install.sh script to $fqdnDefectDojo"
scp -i $sshKeyPath -o StrictHostKeyChecking=no $postInstallScriptPath ${sshUser}@${fqdnDefectDojo}:~/django-DefectDojo/post-install.sh

$dockerComposeOverrideInitializeFalsePath = "docker-compose.override.https.initializefalse.yml"

Write-Output "Copying $dockerComposeOverrideInitializeFalsePath to $fqdnDefectDojo"
scp -i $sshKeyPath -o StrictHostKeyChecking=no $dockerComposeOverrideInitializeFalsePath ${sshUser}@${fqdnDefectDojo}:~/django-DefectDojo/docker-compose.override.https.initializefalse.yml

$dockerEnvironmentsPostgresqlRedisPath = "docker/environments/postgresql-redis.env"

Write-Output "Copying $dockerEnvironmentsPostgresqlRedisPath to $fqdnDefectDojo"
# but first ensure the directory exists on the vm
ssh -i $sshKeyPath -o StrictHostKeyChecking=no ${sshUser}@${fqdnDefectDojo} "mkdir -p ~/django-DefectDojo/docker/environments"
scp -i $sshKeyPath -o StrictHostKeyChecking=no $dockerEnvironmentsPostgresqlRedisPath ${sshUser}@${fqdnDefectDojo}:~/django-DefectDojo/docker/environments/postgresql-redis.env

# # run the post-install.sh script
# Write-Output "Running post-install.sh script on $fqdnDefectDojo"
# ssh -i $sshKeyPath -o StrictHostKeyChecking=no ${sshUser}@${fqdnDefectDojo} "chmod +x ~/post-install.sh && ~/post-install.sh"

# # cleanup
# Write-Output "Cleaning up"
# Remove-Item $postInstallScriptPath

Write-Output "DefectDojo is deployed at $fqdnDefectDojo"


# To check manually the vm, run the following command:
Write-Output "To ssh into the VM, run the following command:"
Write-Output "ssh -i $sshKeyPath $sshUser@$fqdnDefectDojo"