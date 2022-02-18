#!/bin/bash -eu

echo "SWARMETHEUS"
: "${HOSTNAME:?HOSTNAME is required}"
: "${PROMETHEUS_NETWORK:?PROMETHEUS_NETWORK is required}"
: ${HOSTNAME:=localhost}
: ${PROMETHEUS_RELOAD_URL:=http://prometheus:9090/-/reload}
: ${PROMETHEUS_TARGET_FILE:=swarmetheus.yml}

function get_nodes() {
  # https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds
  [ "$HOSTNAME" = "localhost" ] && echo "host.docker.internal" || docker node ls --format "{{.Hostname}}"
}

function write_yml() {
  TYPE=$1
  PORT=${2:-}
  BASE_DIR="/swarmetheus/files"
  FILE="$BASE_DIR/$TYPE.yml"
  echo '---' > $FILE
  printf "- targets:\n" >> $FILE
  [ "$TYPE"="swarmetheus" ] && printf 'version: "3.8"\nx-hosts: &hosts\n' >> $FILE
  NODES=get_nodes
  for NODE in $NODES; do 
    IP=$(docker node inspect $NODE --format '{{.ManagerStatus.Addr}}' 2> /dev/null)
    [ -z $IP ] && IP=$(docker node inspect $NODE --format '{{.Status.Addr}}')
    if [ "$TYPE"="swarmetheus" ]; then
      printf "%2s$node: $ipmgr\n" >> $FILE
    else
      printf "%2s- $node:$PORT\n" >> $FILE
    fi
  done
  # append any labels...
  echo "$FILE:" && cat $FILE && echo
}

# function write_prometheus_target_file() {
#   TYPE=$1
#   PORT=$2
#   BASE_DIR="/swarmetheus/files"
#   FILE="$BASE_DIR/$TYPE.yml"
#   NODES=get_nodes
#   for NODE in $NODES; do 
#     IP=$(docker node inspect $NODE --format '{{.ManagerStatus.Addr}}' 2> /dev/null)
#     if [ -z $IP ]; then 
#       IP=$(docker node inspect $NODE --format '{{.Status.Addr}}')
#     fi
#   done

#   echo "---
# - targets:
# $(for NODE in $(get_nodes); do echo "  - $NODE:$PORT"; done)
#   labels:
#     env: ${ENV}" > $FILE
#   echo "$PROMETHEUS_TARGET_FILE:"
#   cat $FILE && echo
# }

function reload_prometheus() {
  echo "RELOAD PROMETHEUS: $PROMETHEUS_RELOAD_URL"
  if [[ ! -z $PROMETHEUS_RELOAD_URL ]]; then
    curl -X POST -i -s $PROMETHEUS_RELOAD_URL 2> /dev/null || true
  fi
}

function run_health() {
  IMAGE=$(docker inspect -f "{{.Config.Image}}" $(hostname))
  echo "STARTING: $IMAGE"
  docker container rm $CONTAINER_NAME-health -f 2> /dev/null
  docker run \
    -d \
    --rm \
    --init \
    --pid=host \
    --label hidden \
    --name="$CONTAINER_NAME-health" \
    --entrypoint="/swarmetheus/scripts/health.sh" \
    -e PARENT_PID="$(docker inspect -f "{{.State.Pid}}" $(hostname))" \
    -e CONTAINER_NAME="$CONTAINER_NAME" \
    --volume="/var/run/docker.sock:/var/run/docker.sock" \
    $IMAGE &
}

function run_image() {
  echo "STARTING: $CONTAINER_IMAGE"
  docker container rm $CONTAINER_NAME -f 2> /dev/null
  docker pull "$CONTAINER_IMAGE"
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

write_yml "swarmetheus"
write_yml "cadvisor" 9091
write_yml "node-exporter" 9092
reload_prometheus
run_health
run_image
