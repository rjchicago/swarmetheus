#!/bin/bash -eu

echo "SWARMETHEUS"

: "${HOSTNAME:?HOSTNAME is required}"
: "${PROMETHEUS_NETWORK:?PROMETHEUS_NETWORK is required}"
: ${PROMETHEUS_RELOAD_URL:=http://prometheus:9090/-/reload}

export PROMETHEUS_RELOAD_URL=$PROMETHEUS_RELOAD_URL
export PROMETHEUS_NETWORK=$PROMETHEUS_NETWORK
export HOSTNAME=$HOSTNAME

STATUS=$(docker node ls -f "role=manager" -f "name=$HOSTNAME" --format "{{.ManagerStatus}}")
if [ "$STATUS" = "Leader" ]; then
  sh ./scripts/write_files.sh
fi

sh ./scripts/run_health.sh
sh ./scripts/run_cadvisor.sh
sh ./scripts/run_node_exporter.sh

tail -f /dev/null
