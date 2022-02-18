#!/bin/bash -eu

NAME="node-exporter"
CONTAINER_NAME="swarmetheus-$NAME"
FILE="env/$NAME.env"
[ ! -f $FILE ] && echo "$FILE not found" && exit 1
source $FILE
echo "STARTING: $CONTAINER_NAME"
docker container rm $CONTAINER_NAME -f 2> /dev/null
docker pull "$IMAGE"
docker run \
  -d \
  --rm \
  --init \
  --pid=host \
  --label hidden \
  --name="$CONTAINER_NAME" \
  --network="$PROMETHEUS_NETWORK" \
  --publish="$PUBLISHED_PORT:${INTERNAL_PORT:-9100}" \
  --hostname="$HOSTNAME" \
  --volume=/:/host:ro \
  --volume=/sys:/host/sys:ro \
  --volume=/proc:/host/proc:ro \
  $IMAGE \
  --path.rootfs=/host \
  --path.sysfs=/host/sys \
  --path.procfs=/host/proc \
  --collector.filesystem.ignored-mount-points="^/(sys|proc|dev|host|etc|rootfs/var/lib/docker)($$|/)"
