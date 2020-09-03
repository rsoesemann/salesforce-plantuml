#!/bin/bash

clear
sfdx force:source:convert -d metadata --packagename=$PACKAGENAME

sfdx force:mdapi:deploy -u $PACKAGING_ORG_ALIAS -w 1 -d metadata

sfdx force:org:open -u $PACKAGING_ORG_ALIAS 

echo "Packaging Org is ready"