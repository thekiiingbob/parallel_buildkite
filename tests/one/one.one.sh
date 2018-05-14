#!/bin/bash

set -eu

echo "Folder One - Test One"

ZALENIUM_READY=$(curl --max-time 15 -sSL http://$ZALENIUM_IP:4444/wd/hub/status | jq .value.ready )

echo $ZALENIUM_READY

if [[ $ZALENIUM_READY = true ]]
  then 
    echo "Zalenium server is ready"
    exit 0
  else
    echo "Zalenium is not ready"
    exit 1
fi
