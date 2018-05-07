#!/bin/bash

# exit immediately on failure, or if an undefined variable is used
set -eu

# add a new command step to run the tests in each test directory
for file in $1/*; do
  echo "--- Running Test for "$file""
  $file
done