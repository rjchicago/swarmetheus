#!/bin/bash -eu
# set -x

: ${PROMETHEUS_RELOAD_URL:=http://prometheus:9090/-/reload}

BASE_DIR="/swarmetheus/files"

function get_ip() {
  local NODE=$1
  local IP=$(docker node inspect $NODE --format '{{.ManagerStatus.Addr}}' 2> /dev/null)
  [ -z $IP ] && IP=$(docker node inspect $NODE --format '{{.Status.Addr}}')
  echo $IP
}

function node_swap() {
  local NODE=$1
  # https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds
  [ "$NODE" = "docker-desktop" ] && echo "host.docker.internal" || echo $NODE
}

function write_base() {
  local FILE="$BASE_DIR/swarmetheus.yml"
  echo '---' > $FILE
  printf 'version: "3.8"\nx-hosts: &hosts\n' >> $FILE
  for NODE in $(docker node ls --format "{{.Hostname}}"); do
    IP=$(get_ip $NODE)
    printf "%2s$NODE: $IP\n" >> $FILE
    # local NODE_SWAP=$(node_swap $NODE)
    # printf "%2s$NODE_SWAP: $IP\n" >> $FILE
  done
  echo "$FILE:" && cat $FILE && echo
}

function write_yml() {
  local TYPE=$1
  local PORT=$(source ./env/$TYPE.env && echo $PUBLISHED_PORT)
  local FILE="$BASE_DIR/$TYPE.yml"
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

function reload_prometheus() {
  echo "RELOAD PROMETHEUS: $PROMETHEUS_RELOAD_URL"
  if [[ ! -z $PROMETHEUS_RELOAD_URL ]]; then
    curl -X POST -i -s $PROMETHEUS_RELOAD_URL 2> /dev/null || true
  fi
}

write_base
write_yml cadvisor
write_yml node-exporter
reload_prometheus
