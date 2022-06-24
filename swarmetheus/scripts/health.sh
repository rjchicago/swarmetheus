#!/bin/bash -eu

: "${PARENT_PID:?PARENT_PID is required}"

STARTUP_SECONDS=${STARTUP_SECONDS:-20}

# startup period
echo "SLEEPING $STARTUP_SECONDS FOR STARTUP"
sleep $STARTUP_SECONDS

SELF_ID=$(docker ps --filter "name=^swarmetheus-health\$" --format "{{.ID}}")
SELF_PID=$(docker inspect -f "{{.State.Pid}}" $SELF_ID)
CONTAINER_IDS=$(docker ps --filter "name=^swarmetheus-.+\$" --format "{{.ID}}")
CONTAINER_PIDS=$(docker inspect -f "{{.State.Pid}}" $CONTAINER_IDS)

echo "CONTAINER_PIDS:"
printf "$CONTAINER_PIDS\n"

while true; do
    if ! kill -0 $PARENT_PID 2> /dev/null; then
        echo "PARENT PROCESS STOP DETECTED"
        for CONTAINER_PID in $CONTAINER_PIDS; do
            if [ $SELF_PID != $CONTAINER_PID ]; then
                if kill -0 $CONTAINER_PID; then
                    echo "KILLING $CONTAINER_PID"
                    kill $CONTAINER_PID 2> /dev/null
                fi
            fi
        done
        echo "EXITING" && exit 0
    fi
    sleep 2
done
