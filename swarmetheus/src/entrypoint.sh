#!/bin/bash -eu

echo "SWARMETHEUS"
: "${HOSTNAME:?HOSTNAME is required}"
: "${CONTAINER_IMAGE:?CONTAINER_IMAGE is required}"
: "${CONTAINER_NAME:?CONTAINER_NAME is required}"
: "${CONTAINER_PUBLISHED_PORT:?CONTAINER_PUBLISHED_PORT is required}"
: "${CONTAINER_INTERNAL_PORT:?CONTAINER_INTERNAL_PORT is required}"
: "${PROMETHEUS_NETWORK:?PROMETHEUS_NETWORK is required}"
: "${PROMETHEUS_TARGET_FILE:?PROMETHEUS_TARGET_FILE is required}"

function get_nodes() {
  # https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds
  [ "$HOSTNAME" = "localhost" ] && echo "host.docker.internal" || docker node ls --format "{{.Hostname}}"
}

function write_prometheus_target_file() {
  FILE="/swarmetheus/data/$PROMETHEUS_TARGET_FILE"
  PORT=$CONTAINER_PUBLISHED_PORT
  echo "---
- targets:
$(for NODE in $(get_nodes); do echo "  - $NODE:$CONTAINER_PUBLISHED_PORT"; done)
  labels:
    env: ${ENV}" > $FILE
  echo "$PROMETHEUS_TARGET_FILE:"
  cat $FILE && echo
}

function reload_prometheus() {
  echo "CALLING RELOAD PROMETHEUS: $PROMETHEUS_RELOAD_URL"
  if [[ ! -z $PROMETHEUS_RELOAD_URL ]]; then
    curl -X POST -i -s $PROMETHEUS_RELOAD_URL 2> /dev/null || true
  fi
}

function docker_run() {
  docker pull "$CONTAINER_IMAGE"

  echo STARTING HEALTH CONTAINER
  docker container rm $CONTAINER_NAME-health -f 2> /dev/null
  docker run \
    -d \
    --rm \
    --init \
    --pid=host \
    --label hidden \
    --name="$CONTAINER_NAME-health" \
    --entrypoint="/swarmetheus/src/health.sh" \
    -e PARENT_PID="$(docker inspect -f "{{.State.Pid}}" $(hostname))" \
    -e CONTAINER_NAME="$CONTAINER_NAME" \
    --volume="/var/run/docker.sock:/var/run/docker.sock" \
    rjchicago/swarmetheus:latest &

  echo STARTING $CONTAINER_IMAGE
  docker container rm $CONTAINER_NAME -f 2> /dev/null
  docker run \
    --rm \
    --init \
    --pid=host \
    --label hidden \
    --env-file ./env/*.env \
    --name="$CONTAINER_NAME" \
    --network="$PROMETHEUS_NETWORK" \
    --publish="$CONTAINER_PUBLISHED_PORT:$CONTAINER_INTERNAL_PORT" \
    --hostname="$HOSTNAME" \
    "$CONTAINER_IMAGE" \
    ${CONTAINER_COMMAND:-}
}

write_prometheus_target_file
reload_prometheus
docker_run
