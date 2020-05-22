#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # ensure we can pass along DYLD_INSERT_LIBRARIES on OS X
    if [[ $(uname -s) == 'Darwin' ]]; then
        export RESULT=0
        LD_PRELOAD=/usr/lib/libc++.dylib run_test node -e "console.log(process.env.DYLD_INSERT_LIBRARIES);"
        assertEqual "${RESULT}" "0" "emitted expected signal send from child"
        assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
        assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
        assertContains "$(stdout 3)" "/usr/lib/libc++.dylib" "Emitted expected line of stdout with error code"
    fi
    exit_tests
}

main
