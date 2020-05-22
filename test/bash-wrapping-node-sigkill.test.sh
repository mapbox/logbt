#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # run bash script that runs node, which is killed (as if it OOM'd and was stopped with kill -9)
    run_test ./test/wrapper.sh SIGKILL

    assertEqual "${RESULT}" "${SIGKILL_CODE}" "emitted expected signal"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertEqual "$(stdout 3)" "running custom-script" "Emitted expected first line of stdout"
    assertContains "$(stdout 4)" "exit with code:${SIGKILL_CODE} (KILL)" "Emitted expected stdout with exit code"
    exit_tests
}

main
