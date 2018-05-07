#!/bin/bash
echo "Folder Two - Test Two"
curl -sSL http://localhost:4444/wd/hub/status | jq .value.ready | grep true