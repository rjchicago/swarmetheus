#!/bin/bash -eu

echo "SWARMETHEUS"

: "${HOSTNAME:?HOSTNAME is required}"
: "${PROMETHEUS_NETWORK:?PROMETHEUS_NETWORK is required}"
: ${PROMETHEUS_RELOAD_URL:=http://prometheus:9090/-/reload}
: ${CUSTOM_ENVS:=}

export PROMETHEUS_RELOAD_URL=$PROMETHEUS_RELOAD_URL
export PROMETHEUS_NETWORK=$PROMETHEUS_NETWORK
export CUSTOM_ENVS=$CUSTOM_ENVS

# we only want to write files from one node, so let's check if this is the leader...
STATUS=$(docker node ls -f "role=manager" -f "name=$HOSTNAME" --format "{{.ManagerStatus}}")
if [ "$STATUS" = "Leader" ]; then
  ./scripts/write_files.sh
fi

./scripts/run_health.sh
./scripts/run_cadvisor.sh
./scripts/run_node_exporter.sh

# keep process open - health is monitoring this PID
docker container logs -f swarmetheus-health 
