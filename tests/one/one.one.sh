#!/bin/bash

set -eu

echo "Folder One - Test One"
echo "Sleeping for 30s"
sleep 30s

ZALENIUM_READY=$(curl --max-time 15 -sSL http://zalenium:4444/wd/hub/status )
echo $ZALENIUM_READY
echo "Done!"
exit 0
