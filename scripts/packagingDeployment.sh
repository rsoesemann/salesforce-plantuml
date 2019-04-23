#!/bin/bash

clear
source `dirname $0`/local-config.sh

PACKAGE_VERSION="$(sfdx force:package:version:create -p $PACKAGE_NAME -d sfdx-source -x -w 10 --json)"
RESULT="$(echo $PACKAGE_VERSION | jq '.status')"
echo "Result is $RESULT"

if [ -z $RESULT ]; then
  exit 1
fi

if [ $RESULT -gt 0 ]; then
  echo $PACKAGE_VERSION
  exit 1
else
  sleep 300
fi

PACKAGE_VERSION="$(echo $PACKAGE_VERSION | jq '.result.SubscriberPackageVersionId' | tr -d '"')"

sfdx force:package:install --package $PACKAGE_VERSION -w 10 -u $TARGET_ORG -r
echo "Done"
