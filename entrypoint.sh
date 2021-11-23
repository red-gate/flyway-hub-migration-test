#!/bin/sh

displaySuccessfulMigrations() {
  result=$1
  echo $result | jq --raw-output \
    '["CATEGORY", "VERSION", "PATH", "DURATION"], (.flyway_output | fromjson.migrations[] | [(.category, .version, .filepath, "\(.executionTime)ms")]) | @tsv' \
    | column -t
}

hubhost="https://hub.flywaydb.org"

projectId=$1
flywayConfPath=$2

if [ -z "$flywayConfPath" ]; then
  flywayConfPath=null
else
  flywayConfPath=\"$flywayConfPath\"
fi

if [[ -z "$FLYWAY_HUB_ACCESS_TOKEN" ]]; then
    echo "FLYWAY_HUB_ACCESS_TOKEN is not set"
    exit 1
fi

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
  pr_number=$(cat $GITHUB_EVENT_PATH | jq -r '.number')
  payload="pr_number:=$pr_number"
elif [ -z "$GITHUB_REF_NAME" ]; then
  payload="hash=$GITHUB_SHA"
else
  payload="branch=$GITHUB_REF_NAME"
fi

echo "making POST request to Flyway Hub..."
headers=$(https --ignore-stdin --check-status --headers \
  POST \
  $hubhost/api/test-migrations \
  "Authorization: Bearer $FLYWAY_HUB_ACCESS_TOKEN" \
  projectId:=$projectId \
  flywayConf:=$flywayConfPath \
  $payload)

locationHeader=$(echo "$headers" | grep 'Location: ')
if [ -z "$locationHeader" ]; then
  echo "no Location header found in response"
  exit 1
fi

location=$(echo "$locationHeader" | cut -f2 -d' ' | tr -d '\r\n')
if [ -z "$location" ]; then
  echo "failed to parse URL from Location header"
  exit 1
fi

jobId=$(echo $location | grep -o "\d*$")
if [ -z "$jobId" ]; then
  echo "failed to parse jobId from Location header"
  exit 1
fi

echo "polling for test completion..."
exitCode=0
while true ; do
  result=$(https --ignore-stdin --check-status --body \
    $location \
    "Authorization: Bearer $FLYWAY_HUB_ACCESS_TOKEN")

  status=$(echo $result | jq -r '.status')

  if [ "$status" = "COMPLETED" ]
  then
    echo "Status: $(echo $result | jq --raw-output '.status')"
    echo
    displaySuccessfulMigrations "$result"
    exitCode=0
    break
  elif [ "$status" = "FAILED" ]
  then
    echo "Status: $(echo $result | jq --raw-output '.status')"
    echo
    displaySuccessfulMigrations "$result"
    echo
    echo $result | jq --raw-output '.flyway_output | fromjson.error.message'
    exitCode=1
    break
  else
    sleep 1
  fi
done

echo
echo "Full test output available on Flyway Hub at: $hubhost/project/$projectId/job/$jobId"
echo

exit $exitCode
