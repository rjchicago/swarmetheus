#!/bin/bash -eu

CONTAINER_NAME="swarmetheus-health"
IMAGE=$(docker inspect -f "{{.Config.Image}}" $(hostname))
echo "STARTING: $CONTAINER_NAME"
docker container rm $CONTAINER_NAME -f 2> /dev/null
docker run \
  -d \
  --rm \
  --init \
  --pid=host \
  --label hidden \
  --name="$CONTAINER_NAME" \
  --entrypoint="/swarmetheus/scripts/health.sh" \
  -e PARENT_PID="$(docker inspect -f "{{.State.Pid}}" $(hostname))" \
  -e STARTUP_SECONDS=${STARTUP_SECONDS:-30} \
  --volume="/var/run/docker.sock:/var/run/docker.sock" \
  $IMAGE
