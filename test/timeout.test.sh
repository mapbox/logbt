#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # run node process that waits to exit for set time
    # And ensure timeout is shorter and everything closes down correctly
    TIME_WAITING="10"
    timeout_cmd="timeout 4 ${PATH_TO_LOGBT}/logbt -- node test/wait.js ${TIME_WAITING}"
    ${timeout_cmd} >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    echo -e "\033[1m\033[32mok\033[0m - ran ${timeout_cmd} >${STDOUT_LOGS} 2>${STDERR_LOGS}"
    assertEqual "${RESULT}" "${TIMEOUT_CODE}" "emitted expected timeout code"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "Process id is" "Emitted expected line of stdout"
    assertEqual "$(stdout 4)" "Running for ${TIME_WAITING} s" "Emitted expected line of stdout"
    assertEqual "$(stdout 5)" "Running tic # 0" "Emitted expected line of stdout"
    assertEqual "$(stdout 6)" "Running tic # 1" "Emitted expected line of stdout"
    assertEqual "$(stdout 7)" "Running tic # 2" "Emitted expected line of stdout"
    assertEqual "$(stdout 8)" "Running tic # 3" "Emitted expected line of stdout"
    assertEqual "$(stdout 9)" "Running tic # 4" "Emitted expected line of stdout"
    assertEqual "$(stdout 10)" "Running tic # 5" "Emitted expected line of stdout"
    assertEqual "$(stdout 11)" "Running tic # 6" "Emitted expected line of stdout"
    assertEqual "$(stdout 12)" "Running tic # 7" "Emitted expected line of stdout"
    assertContains "$(all_lines)" "[logbt] received signal:${SIGTERM_CODE} (TERM)" "Emitted expected line of stdout"
    assertContains "$(all_lines)" "[logbt] sending SIGTERM to node" "Emitted expected line of stdout"
    assertContains "$(all_lines)" "node received SIGTERM" "Emitted expected line of stdout"
    exit_tests
}

main
