#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # test that keeping core works
    # first get corefile directory
    COREFILE_DIR_LOCATION=$(dirname $(${PATH_TO_LOGBT}/logbt --current-pattern))
    CURRENT_COUNT=$(find $COREFILE_DIR_LOCATION | wc -l)
    RESULT=0
    ${PATH_TO_LOGBT}/logbt --read-only-mode -- node test/segfault.js >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    echo -e "\033[1m\033[32mok\033[0m - ran ${PATH_TO_LOGBT}/logbt --read-only-mode -- node test/segfault.js >${STDOUT_LOGS} 2>${STDERR_LOGS}"
    assertEqual "${RESULT}" "${SIGSEGV_CODE}" "emitted expected signal"
    NEW_COUNT=$(find $COREFILE_DIR_LOCATION | wc -l)
    assertEqual "${NEW_COUNT}" $((${CURRENT_COUNT} + 1)) "Added new file to core directory"

    # running this command to cleanup from previous test by clearing corefiles
    run_test test/segfault.js

    exit_tests
}

main
