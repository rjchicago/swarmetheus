#!/bin/bash -eu
set -x

echo "SWARMETHEUS"

: "${PROMETHEUS_NETWORK:?PROMETHEUS_NETWORK is required}"
: ${HOSTNAME:=localhost}

export PROMETHEUS_NETWORK=$PROMETHEUS_NETWORK
export HOSTNAME=$HOSTNAME

sh ./scripts/run_health.sh
sh ./scripts/run_cadvisor.sh
sh ./scripts/run_node_exporter.sh

tail -f /dev/null
