#!/usr/bin/env bash

set -eu
set -o pipefail

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

if [[ "$(docker images -q logbt-signals 2> /dev/null)" == "" ]]; then
    docker build -t logbt-signals -f Dockerfile.signals .
fi

echo "starting detached container"
docker run --detach --privileged -it --name="logbt-signals" logbt-signals

trap "docker rm logbt-signals" EXIT

echo "getting logs"
docker logs logbt-signals --follow > /tmp/logbt-signals.txt & LOG_TRACKER=$!

echo "sleeping for 1 sec"
sleep 1

echo "sending USR1"
docker kill --signal="SIGUSR1" logbt-signals

echo "sleeping for 4 sec"
sleep 4

echo "sending TERM"
docker kill --signal="SIGTERM" logbt-signals

echo "waiting for log tracking to finish"
wait ${LOG_TRACKER}

echo "testing log output"
assertContains "$(cat /tmp/logbt-signals.txt)" "[logbt] using corefile location" "Should indicate logbt started okay"
assertContains "$(cat /tmp/logbt-signals.txt)" "node::Start" "Should indicate logbt trigger backtrace" "Found backtrace symbol"
assertContains "$(cat /tmp/logbt-signals.txt)" "[logbt] received signal:143 (TERM)" "found confirmation of expected exit"
assertContains "$(cat /tmp/logbt-signals.txt)" "[logbt] sending SIGTERM to node" "was able to kill child (sad but true)"
