#!/bin/bash

# exit immediately on failure, or if an undefined variable is used
set -e


ZALENIUM_HOST=zalenium

if [ -z "$BUILDKITE" ]
then
  echo "Not running on buildkite."
  eval $(dinghy env)
  docker-machine active
  ZALENIUM_HOST=zalenium.docker
else
  echo "Running on buildkite"
fi 

docker-compose -f .buildkite/docker-compose.zalenium.yml up -d --force-recreate

# add a new command step to run the tests in each test directory
for file in $1/*; do
  echo "--- Running Test for "$file""
  docker-compose run --service-ports -e ZALENIUM_HOST=$ZALENIUM_HOST app $file
done

docker-compose -f .buildkite/docker-compose.zalenium.yml stop