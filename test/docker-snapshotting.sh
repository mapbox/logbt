#!/usr/bin/env bash

set -eu
set -o pipefail

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

if [[ "$(docker images -q logbt-signals 2> /dev/null)" == "" ]]; then
    docker build -t logbt-signals -f Dockerfile.signals .
fi

echo "starting detached container"
docker run --detach --privileged -it --rm --name="logbt-signals" logbt-signals

#trap "docker rm logbt-signals" EXIT

echo "getting logs"
docker logs logbt-signals --tail 100 > /tmp/logbt-signals.txt
assertContains "$(cat /tmp/logbt-signals.txt)" "[logbt] using corefile location" "Should indicate logbt started okay"

docker kill --signal="SIGUSR1" logbt-signals
sleep 1

docker logs logbt-signals --tail 100  > /tmp/logbt-signals.txt
assertContains "$(cat /tmp/logbt-signals.txt)" "node::Start" "Should indicate logbt trigger backtrace"

sleep 10

docker kill --signal="SIGUSR1" logbt-signals

cat /tmp/logbt-signals.txt
docker logs logbt-signals --tail 100  > /tmp/logbt-signals.txt
assertContains "$(cat /tmp/logbt-signals.txt)" "node::Start" "Should indicate logbt trigger backtrace"

docker kill --signal="SIGTERM" logbt-signals
