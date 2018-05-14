#!/bin/bash
echo "Folder Two - Test Two"
ZALENIUM_READY=$(curl --max-time 45 -sSL http://$ZALENIUM_IP:4444/wd/hub/status | jq .value.ready)
echo $ZALENIUM_READY
echo "Done!"
exit 0