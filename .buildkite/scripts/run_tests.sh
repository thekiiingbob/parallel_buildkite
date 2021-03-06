#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
  echo "Received kill command... gracefully stopping"

  # stop zalenium EC2 if it's running
  if [ -z $ZALENIUM_IP ]
  then 
    echo "Zalenium should not be running. Not attempting shutdown of EC2 instance."
  else
    echo "--- $FINAL_MACHINE_NAME is up, tearing it down"
    sleep 5s
    cleanup
  fi

  # kill all other processes
  PGID=$(ps -o pgid= $$ | grep -o [0-9]*)
  kill -- -$PGID

  exit 0
}

function cleanup() {
  echo "--- Stopping $FINAL_MACHINE_NAME"
  docker-machine stop $FINAL_MACHINE_NAME
  echo "--- :exploding_death_star: Removing $FINAL_MACHINE_NAME"
  docker-machine rm -f $FINAL_MACHINE_NAME
}

echo "--- :docker: Checking docker paths"
whoami
pwd
ls /usr/local/bin

REGEX="tests\/(.+)"
if [[ $1 =~ $REGEX ]]
then
  FOLDER_NAME="${BASH_REMATCH[1]}"
  FOLDER_PATH=$1
  echo "Running tests in folder $FOLDER_NAME"
else
  echo "$1 doesn't match test path regex. Tests should live in test/specs/multibrowser/* Exiting..."
  exit 1
fi

# Create Docker Machine on AWS
echo "--- :aws: Creating docker machine on AWS for $1"

echo "ID $AWS_ACCESS_KEY_ID"
echo "KEY $AWS_SECRET_ACCESS_KEY"

if [ -z "$MACHINE_NAME" ]
then
  FINAL_MACHINE_NAME="$(whoami)-zalenium-$FOLDER_NAME-$RANDOM$RANDOM"
else
  FINAL_MACHINE_NAME="$BUILDKITE_PIPELINE_SLUG-$BUILDKITE_JOB_ID-$FOLDERNAME-zalenium"
fi

echo "--- :aws-ec2: Zalenium EC2 instance named: $FINAL_MACHINE_NAME"
docker-machine create \
--amazonec2-access-key $AWS_ACCESS_KEY_ID \
--amazonec2-secret-key $AWS_SECRET_ACCESS_KEY \
--driver amazonec2 \
--amazonec2-vpc-id vpc-686f0500 \
--amazonec2-region us-east-2 \
--amazonec2-instance-type c4.4xlarge $FINAL_MACHINE_NAME

ZALENIUM_IP=$(docker-machine ip $FINAL_MACHINE_NAME)
export ZALENIUM_IP
echo "--- Zalenium's IP is $ZALENIUM_IP"

# Start up Zalenium on EC2 Instance
echo "--- :docker: Switching docker environment to machine"
eval $(docker-machine env $FINAL_MACHINE_NAME --shell bash)

echo "--- :docker: Pulling elgalu/selenium on Zalenium EC2 Instance"
docker pull elgalu/selenium

echo "--- :docker: Starting up Zalenium server with docker compose"
docker-compose -f .buildkite/docker-compose.zalenium.yml up -d --force-recreate
DOCKER_COMPOSE_EXIT_STATUS=$?
echo "Docker compose exit status $DOCKER_COMPOSE_EXIT_STATUS"

ZALENIUM_READY="false"

if [[ $DOCKER_COMPOSE_EXIT_STATUS = 0 ]]
then
  echo "--- :white_check_mark: Checking to see if Zalenium Grid is ready"
  for n in 1 2 3 4 5; 
  do 
    echo "Attempt $n at checking if Zalenium is ready to receive tests."
    ZALENIUM_READY=$(curl -sSL http://$ZALENIUM_IP:4444/wd/hub/status | jq .value.ready )
    echo "Is Zalenium ready? $ZALENIUM_READY"

    if [[ $ZALENIUM_READY = "true" ]]
    then 
      echo "$FINAL_MACHINE_NAME server is ready"
      sleep 5s
      break
    else
      sleep 10s
    fi
  done
else
  echo "Docker compose command failed removing docker machine"
  cleanup
  exit 1
fi

if [[ $ZALENIUM_READY = "false" ]]
then 
  echo "$FINAL_MACHINE_NAME is NOT ready after 10 attempts"
  sleep 5s
  cleanup
  exit 1
fi

echo "--- :docker: Switching to default docker machine"
docker-machine list
eval $(docker-machine env default)

# add a new command step to run the tests in each test directory
for file in $FOLDER_PATH/*; do
  echo "--- :allthethings: Running Tests for "$file""
  bash $file
done

# Capture the exit status
TESTS_EXIT_STATUS=$?
echo "--- Test Exit Status $TESTS_EXIT_STATUS"

# Remove Zalenium EC2 at end of testing
cleanup

exit $TEST_EXIT_STATUS