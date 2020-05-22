#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # test when an invalid command is passed to logbt
    export RESULT=0
    ${PATH_TO_LOGBT}/logbt -- doesnotexist >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    assertEqual "${RESULT}" "${COMMAND_NOT_FOUND_CODE}" "command not found should return ${COMMAND_NOT_FOUND_CODE}"
    exit_tests
}

main
