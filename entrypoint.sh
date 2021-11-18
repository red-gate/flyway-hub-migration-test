#!/bin/sh

hubhost="https://hub.flywaydb.org"

projectId=$1

if [[ -z "$FLYWAY_HUB_ACCESS_TOKEN" ]]; then
    echo "FLYWAY_HUB_ACCESS_TOKEN is not set"
    exit 1
fi

echo "making POST request to Flyway Hub..."
headers=$(https --ignore-stdin --check-status --headers \
  POST \
  $hubhost/api/test-migrations \
  "Authorization: Bearer $FLYWAY_HUB_ACCESS_TOKEN" \
  projectId:=$projectId \
  hash="$GITHUB_SHA")

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
    echo $result | jq --raw-output \
      '(["Category", "Version", "Path", "Duration"] | (., map(length*"-"))), (.flyway_output | fromjson.migrations[] | [(.category, .version, .filepath, "\(.executionTime)ms")]) | @tsv' \
      | column -t
    exitCode=0
    break
  elif [ "$status" = "FAILED" ]
  then
    exitCode=1
    break
  else
    sleep 1
  fi
done

echo
echo "test output available on Flyway Hub at: $hubhost/project/$projectId/job/$jobId"
echo

exit $exitCode
