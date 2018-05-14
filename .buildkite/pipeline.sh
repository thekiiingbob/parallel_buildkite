#!/bin/bash

# exit immediately on failure, or if an undefined variable is used
set -eu

# begin the pipeline.yml file
echo "steps:"
echo "  - name: \":docker: Build\""
echo "    command: \"docker-compose build\""
echo "  - wait"

# add a new command step to run the tests in each test directory
for test_dir in tests/*; do
  # echo "  - command: \".buildkite/scripts/run_tests.sh "${test_dir}"\""
  echo "  - command: \"docker-compose run app .buildkite/scripts/run_tests.sh "${test_dir}"\""
  echo "    agents:"
  echo "      queue: \"default\""
  echo "    concurrency: 2"
  echo "    concurrency_group: \"my_tests\""
done