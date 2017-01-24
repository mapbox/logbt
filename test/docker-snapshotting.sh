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

if [[ "$(docker images -q logbt-signals 2> /dev/null)" == "" ]]; then
    echo "Building container"
    docker build -t logbt-signals -f Dockerfile.signals .
else
    echo "Container already built"
fi

echo "Testing stopping container with ${SIGNAL}"

echo "starting detached container"
docker run --detach --privileged -it --name="logbt-signals" logbt-signals

trap "docker rm logbt-signals" EXIT

echo "getting logs"
docker logs logbt-signals --follow > ${TEMP_LOGFILE} & LOG_TRACKER=$!

echo "sleeping for 1 sec"
sleep 1

echo "sending USR1"
KILL_RETURN=0
docker kill --signal="SIGUSR1" logbt-signals || KILL_RETURN=$?
assertContains "${KILL_RETURN}" "0" "Should be able to send SIGUSR1"

echo "sleeping for 4 sec"
sleep 4

echo "sending ${SIGNAL}"
KILL_RETURN=0
docker kill --signal="SIG${SIGNAL}" logbt-signals || KILL_RETURN=$?
assertContains "${KILL_RETURN}" "0" "Should be able to kill docker container with SIG${SIGNAL}"


echo "waiting for log tracking to finish"
wait ${LOG_TRACKER}

echo "testing log output"
EXPECTED_EXIT=$(($(kill -l ${SIGNAL})+128))
assertContains "$(cat ${TEMP_LOGFILE})" "[logbt] using corefile location" "Should indicate logbt started okay"
assertContains "$(cat ${TEMP_LOGFILE})" "node::Start" "Should indicate logbt trigger backtrace" "Found backtrace symbol"
assertContains "$(cat ${TEMP_LOGFILE})" "[logbt] received signal:${EXPECTED_EXIT} (${SIGNAL})" "found confirmation of expected exit"
assertContains "$(cat ${TEMP_LOGFILE})" "[logbt] sending SIGTERM to node" "was able to kill child (sad but true)"

exit_tests