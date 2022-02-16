#!/bin/bash -eu

: "${CONTAINER_NAME:?CONTAINER_NAME is required}"
: "${PARENT_PID:?PARENT_PID is required}"

STARTUP_SECONDS=${STARTUP_SECONDS:-10}

# startup period
echo "SLEEPING $STARTUP_SECONDS FOR STARTUP"
sleep $STARTUP_SECONDS

CONTAINER_ID=$(docker ps --filter "name=^$CONTAINER_NAME\$" --format "{{.ID}}")
CONTAINER_PID=$(docker inspect -f "{{.State.Pid}}" $CONTAINER_ID)

echo CONTAINER_ID=$CONTAINER_ID
echo CONTAINER_PID=$CONTAINER_PID

while true; do
    if ! kill -0 $PARENT_PID 2> /dev/null; then
        echo "PARENT PROCESS STOP DETECTED"
        if kill -0 $CONTAINER_PID; then
            echo "KILLING $CONTAINER_PID"
            kill $CONTAINER_PID 2> /dev/null
            echo "EXITING"
            exit 0
        fi
    fi
    sleep 2
done
