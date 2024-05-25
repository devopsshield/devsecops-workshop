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
        # get token from common user
        $DEFECTDOJO_TOKEN_COMMON = (Invoke-RestMethod -Method Post -Uri "${env:DEFECTDOJO_URL}/api-token-auth/" `
                -ContentType 'application/json' `
                -Body (@{
                    "username" = "$env:DEFECTDOJO_COMMONUSER";
                    "password" = "$env:DEFECTDOJO_COMMONPASSWORD"
                } | ConvertTo-Json)).token

        if ($env:DEFECTDOJO_TOKEN_COMMON) {
            # Write-Host "DEFECTDOJO_TOKEN: $env:DEFECTDOJO_TOKEN_COMMON"
            Write-Host "DEFECTDOJO_TOKEN is set"
            Add-Content -Path $env:GITHUB_ENV -Value "DEFECTDOJO_TOKEN=$env:DEFECTDOJO_TOKEN_COMMON"
            exit 0            
        }
        else {
            Write-Host "Error: Failed to get token from common user ${env:DEFECTDOJO_COMMONUSER}. Please check the credentials."
            exit 1
        }
    }
    else {
        Write-Host "Error: DEFECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
        Write-Host "Error: DEFECTDOJO_COMMONPASSWORD is not set. Please set the secret in the dev environment."
        Write-Host "You need to set either DEFECTDOJO_TOKEN or DEFECTDOJO_COMMONPASSWORD to run the pipeline."
        exit 1
    }
}