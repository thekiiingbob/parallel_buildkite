#!/bin/bash

set -eu

echo "Folder One - Test One"
echo "Sleeping for 15s"
sleep 15s

ZALENIUM_READY=$(curl --max-time 45 -sSL http://$ZALENIUM_HOST:4444/wd/hub/status | jq .value.ready)
echo $ZALENIUM_READY
echo "Done!"
exit 0
