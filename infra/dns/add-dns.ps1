$resourceGroup = "rg-dns-prod"
$zoneName = "cad4devops.com"
$ipv4AddressProd = "20.175.235.66"
$ipv4AddressTest = "4.172.65.231"
$dnsRecordSetNameProd = "gh-pygoat"
$dnsRecordSetNameTest = "gh-pygoat-test"

az network dns record-set a list `
    --resource-group $resourceGroup `
    --zone-name $zoneName

az network dns record-set a add-record `
    -g $resourceGroup `
    -z $zoneName `
    -n $dnsRecordSetNameTest `
    -a $ipv4AddressTest

az network dns record-set a add-record `
    -g $resourceGroup `
    -z $zoneName `
    -n $dnsRecordSetNameProd `
    -a $ipv4AddressProd

az network dns record-set a list `
    --resource-group $resourceGroup `
    --zone-name $zoneName
