#$DEFEECTDOJO_TOKEN = "token"
#$DEFEECTDOJO_COMMONPASSWORD = "password"

$defectDojoTokenIsSet = $null -ne $DEFEECTDOJO_TOKEN -and $DEFEECTDOJO_TOKEN -ne ""
$defectDojoCommonPasswordIsSet = $null -ne $DEFEECTDOJO_COMMONPASSWORD -and $DEFEECTDOJO_COMMONPASSWORD -ne ""

if ($defectDojoTokenIsSet) {
    Write-Host "DEFECTDOJO_TOKEN is set"
    exit 0
}
else {    
    Write-Host "Warning: DEFEECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
    Write-Host "checking for DEFECTDOJO_COMMONPASSWORD"
    if ($defectDojoCommonPasswordIsSet) {
        Write-Host "DEFECTDOJO_COMMONPASSWORD is set"
        Write-Host "Trying to get token from common user Student000..."
        exit 0
    }
    else {
        Write-Host "Error: DEFECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
        Write-Host "Error: DEFECTDOJO_COMMONPASSWORD is not set. Please set the secret in the dev environment."
        Write-Host "You need to set either DEFECTDOJO_TOKEN or DEFECTDOJO_COMMONPASSWORD to run the pipeline."
        exit 1
    }
}