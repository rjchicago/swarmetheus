#!/bin/bash -eu
# set -x

: ${STACK_NAME:=swarmetheus}
: ${PROMETHEUS_SERVICE:=prometheus}
: ${PROMETHEUS_RELOAD_URL:=http://$PROMETHEUS_SERVICE:9090/-/reload}

FILES_DIR="/swarmetheus_data/files"
RULES_DIR="/swarmetheus_data/rules"
CONFIG_DIR="/swarmetheus_data/config"
mkdir -p $FILES_DIR
mkdir -p $RULES_DIR
mkdir -p $CONFIG_DIR

function get_ip() {
  local NODE=$1
  local IP=$(docker node inspect $NODE --format '{{.ManagerStatus.Addr}}' 2> /dev/null)
  [ -z $IP ] && IP=$(docker node inspect $NODE --format '{{.Status.Addr}}')
  echo $IP | cut -d: -f1
}

function node_swap() {
  local NODE=$1
  # https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds
  [ "$NODE" = "docker-desktop" ] && echo "host.docker.internal" || echo $NODE
}

function add_hosts() {
  local ADD_HOSTS=""
  for NODE in $(docker node ls --format "{{.Hostname}}"); do
    IP=$(get_ip $NODE)
    ADD_HOSTS="$ADD_HOSTS --host-add $NODE:$IP"
    echo "ADD HOST: $NODE:$IP"
  done
  docker service update $ADD_HOSTS ${STACK_NAME}_${PROMETHEUS_SERVICE}
}

function write_yml() {
  local TYPE=$1
  local PORT=$(source ./env/$TYPE.env && echo $PUBLISHED_PORT)
  local FILE="$FILES_DIR/$TYPE.yml"
  echo '---' > $FILE
  printf -- "- targets:\n" >> $FILE
  for NODE in $(docker node ls --format "{{.Hostname}}"); do
    local NODE_SWAP=$(node_swap $NODE)
    printf "%2s- $NODE_SWAP:$PORT\n" >> $FILE
  done
  # append any labels...
  printf "%2slabels:\n" >> $FILE
  printf "%4senv: ${ENV:-local}\n" >> $FILE
  printf "%4ssource: $TYPE\n" >> $FILE
  echo "$FILE:" && cat $FILE && echo
}

function write_files() {
  write_yml cadvisor
  write_yml node-exporter
}

function write_rules() {
  rm -rf $RULES_DIR/*
  cp -r /swarmetheus/rules/* $RULES_DIR
}

function write_config() {
  rm -rf $CONFIG_DIR/*
  cp -r /swarmetheus/config/* $CONFIG_DIR
}

function reload_prometheus() {
  echo "RELOAD PROMETHEUS: $PROMETHEUS_RELOAD_URL"
  # while ! sleep 1 | telnet prometheus 9090 2> /dev/null; do echo "waiting on prometheus"; done
  if [[ ! -z $PROMETHEUS_RELOAD_URL ]]; then
    curl -X POST -i -s $PROMETHEUS_RELOAD_URL 2> /dev/null || true
  fi
}

write_config
write_files
write_rules
add_hosts
reload_prometheus
