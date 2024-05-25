$DEFEECTDOJO_TOKEN = "token"
$DEFEECTDOJO_COMMONPASSWORD = "password"

#!/bin/bash

if [ -z "$DEFEECTDOJO_TOKEN" ]; then
    echo "Warning: DEFEECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
    echo "Checking for DEFECTDOJO_COMMONPASSWORD"
    if [ -z "$DEFEECTDOJO_COMMONPASSWORD" ]; then
        echo "Error: DEFECTDOJO_TOKEN is not set. Please set the secret in the dev environment."
        echo "Error: DEFECTDOJO_COMMONPASSWORD is not set. Please set the secret in the dev environment."
        echo "You need to set either DEFECTDOJO_TOKEN or DEFECTDOJO_COMMONPASSWORD to run the pipeline."
        exit 1
    else
        echo "DEFECTDOJO_COMMONPASSWORD is set"
        echo "Trying to get token from common user Student000..."
        exit 0
    fi
else
    echo "DEFECTDOJO_TOKEN is set"
    exit 0
fi
