#!/usr/bin/env bash

set -eu
set -o pipefail

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

TEMP_LOGFILE=/tmp/logbt-signals.txt

function teardown() {
    rm -f ${TEMP_LOGFILE}
}

trap "teardown" EXIT

SIGNAL=${1:-TERM}

echo "Testing stopping container with ${SIGNAL}"

if [[ "$(docker images -q logbt-signals 2> /dev/null)" == "" ]]; then
    docker build -t logbt-signals -f Dockerfile.signals .
fi

echo "starting detached container"
docker run --detach --privileged -it --name="logbt-signals" logbt-signals

trap "docker rm logbt-signals" EXIT

echo "getting logs"
docker logs logbt-signals --follow > ${TEMP_LOGFILE} & LOG_TRACKER=$!

echo "sleeping for 1 sec"
sleep 1

echo "sending USR1"
docker kill --signal="SIGUSR1" logbt-signals

echo "sleeping for 4 sec"
sleep 4

echo "sending ${SIGNAL}"
docker kill --signal="SIG${SIGNAL}" logbt-signals

echo "waiting for log tracking to finish"
wait ${LOG_TRACKER}

echo "testing log output"
EXPECTED_EXIT=$(($(kill -l ${SIGNAL})+128))
assertContains "$(cat ${TEMP_LOGFILE})" "[logbt] using corefile location" "Should indicate logbt started okay"
assertContains "$(cat ${TEMP_LOGFILE})" "node::Start" "Should indicate logbt trigger backtrace" "Found backtrace symbol"
assertContains "$(cat ${TEMP_LOGFILE})" "[logbt] received signal:${EXPECTED_EXIT} (${SIGNAL})" "found confirmation of expected exit"
assertContains "$(cat ${TEMP_LOGFILE})" "[logbt] sending SIGTERM to node" "was able to kill child (sad but true)"

exit_tests