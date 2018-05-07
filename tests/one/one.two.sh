#!/bin/bash
echo "Folder One - Test Two"
curl -sSL http://localhost:4444/wd/hub/status | jq .value.ready | grep true