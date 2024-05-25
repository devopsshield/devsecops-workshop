$DEFEECTDOJO_TOKEN = "token"
$DEFEECTDOJO_COMMONPASSWORD = "password"

if ($DEFEECTDOJO_TOKEN.Length = 0) {
    echo "Warning: DEFEECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
    echo "checking for DEFECTDOJO_COMMONPASSWORD"
    if ($DEFEECTDOJO_COMMONPASSWORD.Length = 0) {
        echo "Error: DEFECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
        echo "Error: DEFECTDOJO_COMMONPASSWORD is not set. Please set the secret in the dev environment."
        echo "You need to set either DEFECTDOJO_TOKEN or DEFECTDOJO_COMMONPASSWORD to run the pipeline."
        exit 1
    }
    else {
        echo "DEFECTDOJO_COMMONPASSWORD is set"
        echo "Trying to get token from common user Student000..."
        exit 0
    }
}
else {
    echo "DEFECTDOJO_TOKEN is set"
    exit 0
}