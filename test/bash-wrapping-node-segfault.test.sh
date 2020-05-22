#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # run bash script that runs node, which segfaults
    run_test ./test/wrapper.sh SIGSEGV

    assertEqual "${RESULT}" "${SIGSEGV_CODE}" "emitted expected signal"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertEqual "$(stdout 3)" "running custom-script" "Emitted expected first line of stdout"
    assertContains "$(stdout 4)" "exit with code:${SIGSEGV_CODE} (SEGV)" "Emitted expected stdout with exit code"
    assertContains "$(stdout 5)" "Found corefile (non-tracked) at" "Found corefile by directory search"
    assertContains "$(stdout 6)" "[logbt] Processing cores..." "Processing cores..."
    assertContains "$(all_lines)" "node::Kill(v8::FunctionCallbackInfo<v8::Value> const&)" "Found expected line number in backtrace output"
    exit_tests
}

main
