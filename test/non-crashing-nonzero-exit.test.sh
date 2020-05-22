#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # test logbt with non-crashing program
    run_test false
    assertEqual "${RESULT}" "1" "emitted expected signal"
    # check stdout
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:1 (HUP)" "Emitted expected stdout with exit code"
    exit_tests
}

main
