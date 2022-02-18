#!/bin/bash -eu
# set -x

: ${PROMETHEUS_RELOAD_URL:=http://prometheus:9090/-/reload}

function write_yml() {
  TYPE=$1
  PORT=${2:-}
  BASE_DIR="/swarmetheus/files"
  FILE="$BASE_DIR/$TYPE.yml"
  echo '---' > $FILE
  printf -- "- targets:\n" >> $FILE
  [ "$TYPE" = "swarmetheus" ] && printf 'version: "3.8"\nx-hosts: &hosts\n' >> $FILE
  for NODE in $(docker node ls --format "{{.Hostname}}"); do
    # https://docs.docker.com/desktop/mac/networking/#use-cases-and-workarounds
    IP=$(docker node inspect $NODE --format '{{.ManagerStatus.Addr}}' 2> /dev/null)
    [ -z $IP ] && IP=$(docker node inspect $NODE --format '{{.Status.Addr}}')
    if [ "$NODE" = "docker-desktop" ]; then NODE="host.docker.internal"; fi
    if [ "$TYPE" = "swarmetheus" ]; then
      printf "%2s$NODE: $IP\n" >> $FILE
    else
      printf "%2s- $NODE:$PORT\n" >> $FILE
    fi
  done
  # append any labels...
  echo "$FILE:" && cat $FILE && echo
}

function reload_prometheus() {
  echo "RELOAD PROMETHEUS: $PROMETHEUS_RELOAD_URL"
  if [[ ! -z $PROMETHEUS_RELOAD_URL ]]; then
    curl -X POST -i -s $PROMETHEUS_RELOAD_URL 2> /dev/null || true
  fi
}

write_yml swarmetheus
write_yml cadvisor 9091
write_yml node-exporter 9092
reload_prometheus
