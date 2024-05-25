#$DEFEECTDOJO_TOKEN = "token"
$DEFECTDOJO_COMMONPASSWORD = "P@ssw0rd!1"
$DEFECTDOJO_COMMONUSER = "Student000"
$DEFECTDOJO_URL = "https://defectdojo-002.cad4devops.com:8443/api/v2"
$DEFECTDOJO_COMMONPRODUCTNAME = "GitHub-OSS-pygoat-devsecops-workshop-001-product-000"

$defectDojoTokenIsSet = $null -ne $DEFEECTDOJO_TOKEN -and $DEFEECTDOJO_TOKEN -ne ""
$defectDojoCommonPasswordIsSet = $null -ne $DEFECTDOJO_COMMONPASSWORD -and $DEFECTDOJO_COMMONPASSWORD -ne ""

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
        $DEFECTDOJO_TOKEN_COMMON = (Invoke-RestMethod -Method Post -Uri "$DEFECTDOJO_URL/api-token-auth/" `
                -ContentType 'application/json' `
                -Body (@{
                    "username" = "$DEFECTDOJO_COMMONUSER";
                    "password" = "$DEFECTDOJO_COMMONPASSWORD"
                } | ConvertTo-Json)).token

        if ($DEFECTDOJO_TOKEN_COMMON) {
            Write-Host "DEFECTDOJO_TOKEN: $DEFECTDOJO_TOKEN_COMMON"
            Write-Host "DEFECTDOJO_TOKEN is set"
            #Add-Content -Path $env:GITHUB_ENV -Value "DEFECTDOJO_TOKEN=$env:DEFECTDOJO_TOKEN_COMMON"

            # now to fetch the product id
            # Get the product id
            $DEFECTDOJO_PRODUCTID_COMMON = Invoke-RestMethod -Method Get -Uri "$DEFECTDOJO_URL/products/?name=$DEFECTDOJO_COMMONPRODUCTNAME" `
                -Headers @{ "Authorization" = "Token ${env:DEFECTDOJO_TOKEN}" }

            Write-Host "DEFECTDOJO_PRODUCTID_COMMON: $DEFECTDOJO_PRODUCTID_COMMON"

            if ($DEFECTDOJO_PRODUCTID_COMMON) {
                $DEFECTDOJO_PRODUCTID_COMMON_ID = $DEFECTDOJO_PRODUCTID_COMMON.results[0].id
                #Write-Host "DEFECTDOJO_PRODUCTID_COMMON_ID: $DEFECTDOJO_PRODUCTID_COMMON_ID"
                Write-Host "DEFECTDOJO_PRODUCTID: $DEFECTDOJO_PRODUCTID_COMMON_ID"
                Write-Host "DEFECTDOJO_PRODUCTID is set"
                #Add-Content -Path $env:GITHUB_ENV -Value "DEFECTDOJO_PRODUCTID=$DEFECTDOJO_PRODUCTID_COMMON"
                exit 0
            }
            else {
                Write-Host "Error: Failed to get product id for $DEFECTDOJO_COMMONPRODUCTNAME. Please check the product name."
                exit 1
            }


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