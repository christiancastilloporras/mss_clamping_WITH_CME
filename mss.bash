#!/bin/bash
: '
------- No supported in production -------
Enable MSS Clamping in a CME managed GW
Needs to be run in Autoprovision template with "MSS" as a custom parameter and also 
Rulebase name to install
------- No supported in production -------
'
. /opt/CPshared/5.0/tmp/.CPprofile.sh
AUTOPROV_ACTION=$1
GW_NAME=$2
CUSTOM_PARAMETERS=$3
RULEBASE=$4
if [[ $AUTOPROV_ACTION == delete ]]
then
        exit 0
fi
if [[ $CUSTOM_PARAMETERS != MSS ]];
then
    exit 0
fi
if [[ $CUSTOM_PARAMETERS == MSS ]]
then
INSTALL_STATUS=1
POLICY_PACKAGE_NAME=$RULEBASE
    echo "Connection to API server"
    SID=$(mgmt_cli -r true login -f json | jq -r '.sid')
    GW_JSON=$(mgmt_cli --session-id $SID show simple-gateway name $GW_NAME -f json)
    GW_UID=$(echo $GW_JSON | jq '.uid')
    echo "enabling MSS Clamping"
        mgmt_cli --session-id $SID set generic-object uid $GW_UID fwClampTcpMssControl true
    echo "Publishing changes"
        mgmt_cli publish --session-id $SID
    echo "Install policy"
        until [[ $INSTALL_STATUS != 1 ]]; do
            mgmt_cli --session-id $SID -f json install-policy policy-package $POLICY_PACKAGE_NAME targets $GW_UID
            INSTALL_STATUS=$?
        done
    echo "Policy Installed"
    echo "Logging out of session"
    mgmt_cli logout --session-id $SID
    exit 0
fi
exit 0
