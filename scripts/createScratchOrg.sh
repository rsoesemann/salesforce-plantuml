#!/bin/bash
source `dirname $0`/config.sh

holdScreen=true
while getopts 'p' flag; do
  case "${flag}" in
    p) holdScreen=false ;;
  esac
done

execute() {
    $@ > temp.json
    cat temp.json
    $(jq '.status == 0' temp.json) || $holdScreen || exit 1
}

executenpm() {
    $@
    $(jq '.success' temp.json) || $holdScreen || exit 1
}


echo "deleting old scratch org"
sfdx force:org:delete -p -u $SCRATCH_ORG_ALIAS

echo "Creating scratch ORG"
sfdx force:org:create -a $SCRATCH_ORG_ALIAS -s -f ./config/project-scratch-def.json -d 1

echo "Pushing changes to scratch org"
execute "sfdx force:source:push --json"

echo "Assigning permission"
execute "sfdx force:user:permset:assign --json -n Admin"

echo "Running apex tests"
execute "sfdx force:apex:test:run -l RunLocalTests -w 30 --json"


echo "Running jest tests"
npm install
executenpm "npm run test:unit"

rm temp.json

if $holdScreen 
then
    echo "Org is set up"
    read
fi

