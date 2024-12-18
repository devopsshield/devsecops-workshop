DEFECTDOJO_ENGAGEMENT_PERIOD=7
DEFECTDOJO_URL="https://defectdojo.cad4devops.com:8443/api/v2"
DEFECTDOJO_TOKEN="bba17a9471553b1702e1ab4c4bf455156ba5e7d7"
github_run_id="12070601425"
github_event_head_commit_message="Initial commit"
github_ref="refs/heads/main"
DEFECTDOJO_ENGAGEMENT_REASON="CI/CD pipeline"
github_server_url="https://github.com"
github_repository="devopsabcs-engineering/devsecops-workshop"
DEFECTDOJO_ENGAGEMENT_THREAT_MODEL=true
DEFECTDOJO_ENGAGEMENT_API_TEST=true
DEFECTDOJO_ENGAGEMENT_PEN_TEST=true
DEFECTDOJO_ENGAGEMENT_CHECK_LIST=true
DEFECTDOJO_ENGAGEMENT_STATUS="Not Started"
github_sha="4020d9cff3e64ff899913f988688b46f9c0e3ac3"
DEFECTDOJO_ENGAGEMENT_DEDUPLICATION_ON_ENGAGEMENT=true
DEFECTDOJO_PRODUCTID=1 # Product ID - do not forget to change this
DEFECTDOJO_ENGAGEMENT_BUILD_SERVER=null
DEFECTDOJO_ENGAGEMENT_SOURCE_CODE_MANAGEMENT_SERVER=null
DEFECTDOJO_ENGAGEMENT_ORCHESTRATION_ENGINE=null

# echo all the variables
echo "DEFECTDOJO_ENGAGEMENT_PERIOD: $DEFECTDOJO_ENGAGEMENT_PERIOD"
echo "DEFECTDOJO_URL: $DEFECTDOJO_URL"
echo "DEFECTDOJO_TOKEN: $DEFECTDOJO_TOKEN"
echo "github_run_id: $github_run_id"
echo "github_event_head_commit_message: $github_event_head_commit_message"
echo "github_ref: $github_ref"
echo "DEFECTDOJO_ENGAGEMENT_REASON: $DEFECTDOJO_ENGAGEMENT_REASON"
echo "github_server_url: $github_server_url"
echo "github_repository: $github_repository"
echo "DEFECTDOJO_ENGAGEMENT_THREAT_MODEL: $DEFECTDOJO_ENGAGEMENT_THREAT_MODEL"
echo "DEFECTDOJO_ENGAGEMENT_API_TEST: $DEFECTDOJO_ENGAGEMENT_API_TEST"
echo "DEFECTDOJO_ENGAGEMENT_PEN_TEST: $DEFECTDOJO_ENGAGEMENT_PEN_TEST"
echo "DEFECTDOJO_ENGAGEMENT_CHECK_LIST: $DEFECTDOJO_ENGAGEMENT_CHECK_LIST"
echo "DEFECTDOJO_ENGAGEMENT_STATUS: $DEFECTDOJO_ENGAGEMENT_STATUS"
echo "github_sha: $github_sha"
echo "DEFECTDOJO_ENGAGEMENT_DEDUPLICATION_ON_ENGAGEMENT: $DEFECTDOJO_ENGAGEMENT_DEDUPLICATION_ON_ENGAGEMENT"
echo "DEFECTDOJO_PRODUCTID: $DEFECTDOJO_PRODUCTID"
echo "DEFECTDOJO_ENGAGEMENT_BUILD_SERVER: $DEFECTDOJO_ENGAGEMENT_BUILD_SERVER"
echo "DEFECTDOJO_ENGAGEMENT_SOURCE_CODE_MANAGEMENT_SERVER: $DEFECTDOJO_ENGAGEMENT_SOURCE_CODE_MANAGEMENT_SERVER"
echo "DEFECTDOJO_ENGAGEMENT_ORCHESTRATION_ENGINE: $DEFECTDOJO_ENGAGEMENT_ORCHESTRATION_ENGINE"


TODAY=`date +%Y-%m-%d`
ENDDAY=$(date -d "+$DEFECTDOJO_ENGAGEMENT_PERIOD days" +%Y-%m-%d)

echo "TODAY: $TODAY"
echo "ENDDAY: $ENDDAY"
# Create engagement
echo "Creating engagement"

ENGAGEMENTID=`curl --fail --location --request POST "$DEFECTDOJO_URL/engagements/" \
--header "Authorization: Token $DEFECTDOJO_TOKEN" \
--header 'Content-Type: application/json' \
--data-raw "{
                \"tags\": [\"GITHUB\"],
                \"name\": \"pygoat-$github_run_id\",
                \"description\": \"$github_event_head_commit_message\",
                \"version\": \"$github_ref\",
                \"first_contacted\": \"${TODAY}\",
                \"target_start\": \"${TODAY}\",
                \"target_end\": \"${ENDDAY}\",
                \"reason\": \"$DEFECTDOJO_ENGAGEMENT_REASON\",
                \"tracker\": \"$github_server_url/$github_repository/\",
                \"threat_model\": \"$DEFECTDOJO_ENGAGEMENT_THREAT_MODEL\",
                \"api_test\": \"$DEFECTDOJO_ENGAGEMENT_API_TEST\",
                \"pen_test\": \"$DEFECTDOJO_ENGAGEMENT_PEN_TEST\",
                \"check_list\": \"$DEFECTDOJO_ENGAGEMENT_CHECK_LIST\",
                \"status\": \"$DEFECTDOJO_ENGAGEMENT_STATUS\",
                \"engagement_type\": \"CI/CD\",
                \"build_id\": \"$github_run_id\",
                \"commit_hash\": \"$github_sha\",
                \"branch_tag\": \"$github_ref\",
                \"deduplication_on_engagement\": \"$DEFECTDOJO_ENGAGEMENT_DEDUPLICATION_ON_ENGAGEMENT\",
                \"product\": \"$DEFECTDOJO_PRODUCTID\",
                \"source_code_management_uri\": \"$github_server_url/$github_repository\",
                \"build_server\": $DEFECTDOJO_ENGAGEMENT_BUILD_SERVER,
                \"source_code_management_server\": $DEFECTDOJO_ENGAGEMENT_SOURCE_CODE_MANAGEMENT_SERVER,
                \"orchestration_engine\": $DEFECTDOJO_ENGAGEMENT_ORCHESTRATION_ENGINE
}" | jq -r '.id'` &&
echo ${ENGAGEMENTID} > ENGAGEMENTID.env

echo "ENGAGEMENTID: $ENGAGEMENTID"