#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # test logbt misusage
    export RESULT=0
    ${PATH_TO_LOGBT}/logbt -- >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    assertEqual "${RESULT}" "1" "invalid usage (no args) should result in error code of 1"
    # check stderr
    assertContains "$(stderr 1)" "Usage for logbt:" "Emitted expected usage error"
    # check stdout
    assertEqual "$(stdout 1)" "" "no stdout on usage error"

    # test logbt version
    export RESULT=0
    ${PATH_TO_LOGBT}/logbt --version >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    assertEqual "${RESULT}" "0" "Should result in error code of 0"
    # check stdout
    assertContains "$(stdout 1)" "v" "Should contain v for version number"
    # check stderr
    assertEqual "$(stderr 1)" "" "Should be empty"

    # test logbt with non-crashing program
    run_test node -e "console.error('stderr');console.log('stdout')"
    assertEqual "${RESULT}" "0" "emitted expected signal"
    # check stdout
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertEqual "$(stdout 3)" "stdout" "Emitted expected first line of stdout"
    assertEqual "$(stdout 4)" "" "No line 4 present"
    # check stderr
    assertEqual "$(stderr 1)" "stderr" "Emitted expected first line of stderr"
    assertEqual "$(stderr 2)" "" "No line 3 present"
}

main
