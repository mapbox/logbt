#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # test node --abort-on-uncaught-exception
    run_test node --abort-on-uncaught-exception -e "JSON.parse({})"
    assertEqual "${RESULT}" "${SIGILL_CODE}" "emitted expected signal from illegal instruction error"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:${SIGILL_CODE} (ILL)" "Emitted expected line of stdout with error code"
    assertContains "$(stdout 4)" "Found corefile at" "Found corefile for given PID"
    assertContains "$(all_lines)" "ParseJson" "Found ParseJson in backtrace output (from ILL)"
    exit_tests
}

main
