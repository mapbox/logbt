#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # test sending TERM signal to logbt
    watcher_command="${PATH_TO_LOGBT}/logbt -- node test/wait.js 10"
    # background logbt and grab its PID
    ${watcher_command} >${STDOUT_LOGS} 2>${STDERR_LOGS} & LOGBT_PID=$!
    echo -e "\033[1m\033[32mok\033[0m - ran ${watcher_command} >${STDOUT_LOGS} 2>${STDERR_LOGS}"
    WAIT_BEFORE_SIGNAL=1
    sleep ${WAIT_BEFORE_SIGNAL}
    kill -TERM ${LOGBT_PID}
    RESULT=0
    wait ${LOGBT_PID} || export RESULT=$?
    assertEqual "${RESULT}" "${SIGTERM_CODE}" "emitted expected TERM code"
    assertContains "$(all_lines)" "[logbt] received signal:${SIGTERM_CODE} (TERM)" "Found TERM exit"
    assertContains "$(all_lines)" "[logbt] sending SIGTERM to node" "Found SIGTERM send"
    exit_tests
}

main
