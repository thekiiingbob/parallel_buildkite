#!/bin/bash

REGEX="\tests\/(.+)"

if [[ $1 =~ $REGEX ]]
then
    FOLDER_NAME="${BASH_REMATCH[1]}"
    FOLDER_PATH=$1
    echo "Running tests in folder $FOLDER_NAME"
    exit 0
else
    echo "$1 doesn't match test path regex. Tests should live in test/specs/multibrowser/* Exiting..."
    exit 1
fi