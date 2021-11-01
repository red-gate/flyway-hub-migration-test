#!/bin/sh

projectId=$1
ref=$(echo "$2" | cut -f3 -d'/')

if [[ -z "$FLYWAY_HUB_ACCESS_TOKEN" ]]; then
    echo "FLYWAY_HUB_ACCESS_TOKEN is not set"
    exit 1
fi

echo "making POST request to Flyway Hub..."
headers=$(https --ignore-stdin --check-status --headers \
  POST \
  app-flyway-spawn.staging.spawn.cc/api/test-migrations \
  "Authorization: Bearer $FLYWAY_HUB_ACCESS_TOKEN" \
  projectId:=$projectId \
  branch="$ref")

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

echo "response location: $location"

echo "polling for job completion..."
complete=0
while [ $complete -ne 1 ]; do
  result=$(https --ignore-stdin --check-status --body \
    $location \
    "Authorization: Bearer $FLYWAY_HUB_ACCESS_TOKEN")

  status=$(echo $result | jq -r '.status')
  echo "migration job status: $status"

  if [ "$status" = "COMPLETED" ]
  then
    complete=1
  elif [ "$status" = "FAILED" ]
  then
    exit 1
  else
    sleep 1
  fi
done
