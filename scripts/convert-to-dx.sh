#!/bin/bash

# Make sure that the shared-functions.sh script exists.
if [ ! -r `dirname $0`/lib/shared-functions.sh ]; then
  echo "\nFATAL ERROR: `tput sgr0``tput setaf 1`Could not load dev-tools/lib/shared-functions.sh.  File not found.\n"
  exit 1
fi

# Load the shared-functions.sh library.  This action will also cause the
# config variables from dev-tools/lib/local-config.sh to be loaded.
source `dirname $0`/lib/shared-functions.sh

confirmScriptExecution "Do you want to create dx source from metadata?"

(cd $PROJECT_ROOT && exec sfdx force:mdapi:convert --rootdir ./src --outputdir ./sfdx-source/$NAMESPACE_PREFIX)

echoScriptCompleteMsg \
"DX Sources created from metadata successfully."

exit 0