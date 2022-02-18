#!/bin/bash -eu

NAME="cadvisor"
FILE="env/$NAME.env"
[ ! -f $FILE ] && echo "$FILE not found" && exit 1
source $FILE
echo "STARTING: $NAME"
docker container rm $NAME -f 2> /dev/null
docker pull "$IMAGE"
docker run \
  -d \
  --rm \
  --init \
  --pid=host \
  --label hidden \
  --name="swarmetheus-$NAME" \
  --network="$PROMETHEUS_NETWORK" \
  --publish="$PUBLISHED_PORT:${INTERNAL_PORT:-8080}" \
  --hostname="$HOSTNAME" \
  --volume=/:/rootfs:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/var/run/docker.sock:/var/run/docker.sock:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  $IMAGE
