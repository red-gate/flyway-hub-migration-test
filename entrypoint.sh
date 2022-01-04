#!/bin/bash

projectName=$1
flywayConfPath=$2
databaseName=$3
engine=$4

shift 4

if [[ -z "$FLYWAYHUB_ACCESS_TOKEN" ]]; then
    echo "FLYWAYHUB_ACCESS_TOKEN is not set"
    exit 1
fi

if [ "$flywayConfPath" != "" ]; then
  flywayConfPathFlag="--flywayconf=$flywayConfPath"
fi

if [ "$databaseName" != "" ]; then
  databaseFlag="--database=$databaseName"
fi

if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
  pr_number=$(cat $GITHUB_EVENT_PATH | jq -r '.number')
  prNumberFlag="--pr-number=$pr_number"
elif [ -z "$GITHUB_REF_NAME" ]; then
  commitHashFlag="--commit-hash=$GITHUB_SHA"
else
  branchFlag="--branch=$GITHUB_REF_NAME"
fi

flywayhub --verbose test \
  --project $projectName \
  --engine "$engine" \
  --initiator "Github Actions" \
  $flywayConfPathFlag \
  $databaseFlag \
  $prNumberFlag \
  $commitHashFlag \
  $branchFlag \
  $@
