#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT

function ctrl_c() {
   # Get our process group id
  PGID=$(ps -o pgid= $$ | grep -o [0-9]*)

  # Kill it in a new new process group
  kill -- -$PGID
  exit 0
}

for n in 1 2 3 4 5 6 7 8 9 10; 
do 
  echo "Attempt $n in background process"
  sleep 2
done &

for n in 1 2 3 4 5 6 7 8 9 10; 
do 
  echo "Attempt $n in main process"
  sleep 2
done