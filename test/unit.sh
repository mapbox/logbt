#!/usr/bin/env bash

set -u
set -o pipefail

export CODE=0
export failures=0
export passed=0
export RESULT=0

function assertEqual() {
    if [[ "$1" == "$2" ]]; then
        echo -e "\033[1m\033[32mok\033[0m - $1 == $2 ($3)"
        export passed=$((passed+1))
    else
        echo -e "\033[1m\033[31mnot ok\033[0m - $1 != $2 ($3)"
        export CODE=1
        export failures=$((failures+1))
    fi
}

function assertContains() {
    if [[ "$1" =~ "$2" ]]; then
        echo -e "\033[1m\033[32mok\033[0m - Found string $2 in output ($3)"
        export passed=$((passed+1))
    else
        echo -e "\033[1m\033[31mnot ok\033[0m - Did not find string '$2' in '$1' ($3)"
        export CODE=1
        export failures=$((failures+1))
    fi
}

function exit_tests() {
    if [[ ${CODE} == 0 ]]; then
        echo -e "\033[1m\033[32m* Success: ${passed} tests succeeded\033[0m";
    else
        echo -e "\033[1m\033[31m* Error: ${failures} test(s) failed\033[0m";
    fi
    exit ${CODE}
}

function exit_early() {
    if [[ ${CODE} != 0 ]]; then
        exit_tests
    fi
}

export WORKING_DIR="/tmp/logbt"
mkdir -p ${WORKING_DIR}
export CXXFLAGS="-g -O0 -DDEBUG"
export CXX=${CXX:-g++}
export STDOUT_LOGS="stdout.txt"
export STDERR_LOGS="stderr.txt"

export SIGSEGV_CODE="139"
export SIGABRT_CODE="134"
if [[ $(uname -s) == 'Darwin' ]]; then
    export SIGBUS_CODE="138"
else
    # on linux this is also 135? Why?
    export SIGBUS_CODE="135"
fi

function stdout() {
    #head -n $1 ${STDOUT_LOGS} | tail -n 1
    sed "${1}q;d" ${STDOUT_LOGS}
}

function stderr() {
    sed "${1}q;d" ${STDERR_LOGS}
}

function all_lines() {
    cat ${STDOUT_LOGS}
}

function run_test() {
    ./bin/logbt $@ >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    echo -e "\033[1m\033[32mok\033[0m - ran ./bin/logbt $@ >${STDOUT_LOGS} 2>${STDERR_LOGS}"
    export passed=$((passed+1))
}

# test logbt with non-crashing program
run_test node -e "console.error('stderr');console.log('stdout')"
assertEqual "${RESULT}" "0" "emitted expected signal"
# check stdout
assertEqual "$(stdout 1)" "stdout" "Emitted expected first line of stdout"
assertEqual "$(stdout 2)" "node exited with code:0" "Emitted expected second line of stdout"
assertEqual "$(stdout 3)" "" "No line 3 present"
# check stderr
assertEqual "$(stderr 1)" "stderr" "Emitted expected first line of stderr"
assertEqual "$(stderr 2)" "" "No line 3 present"

# bail early if this trivial case is not working
exit_early

# run node process that segfaults after 1000ms
: '
run_test node segfault.js

assertEqual "${RESULT}" "${SIGSEGV_CODE}" "emitted expected signal"
assertEqual "$(stdout 1)" "running custom-node" "Emitted expected first line of stdout"
assertEqual "$(stdout 2)" "node exited with code:${SIGSEGV_CODE}" "Emitted expected second line of stdout"
assertContains "$(stdout 3)" "Found core at" "Found core file for given PID"
assertContains "$(all_lines)" "node::Kill(v8::FunctionCallbackInfo<v8::Value> const&)" "Found expected line number in backtrace output"

exit_early
'

# TODO: does not work, since we can't see pid
: '
# run node process that runs segfault.js as a child
run_test node children.js

assertEqual "${RESULT}" "${SIGSEGV_CODE}" "emitted expected signal"
assertEqual "$(stdout 1)" "running custom-node" "Emitted expected first line of stdout"
assertEqual "$(stdout 2)" "node exited with code:${SIGSEGV_CODE}" "Emitted expected second line of stdout"
assertContains "$(stdout 3)" "Found core at" "Found core file for given PID"
assertContains "$(all_lines)" "node::Kill(v8::FunctionCallbackInfo<v8::Value> const&)" "Found expected line number in backtrace output"

exit_early

'

# abort
echo "#include <cstdlib>" > ${WORKING_DIR}/abort.cpp
echo "int main() { abort(); }" >> ${WORKING_DIR}/abort.cpp

${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/abort.cpp
assertEqual "$?" "0" "able to compile program abort.cpp"

run_test ${WORKING_DIR}/run-test

assertEqual "${RESULT}" "${SIGABRT_CODE}" "emitted expected signal"
assertEqual "$(stdout 1)" "${WORKING_DIR}/run-test exited with code:${SIGABRT_CODE}" "Emitted expected first line of stdout"
assertContains "$(stdout 2)" "Found core at" "Found core file for given PID"
assertContains "$(all_lines)" "abort.cpp:2" "Found expected line number in backtrace output"

# segfault
echo "#include <signal.h>" > ${WORKING_DIR}/segfault.cpp
echo "int main() { raise(SIGSEGV); }" >> ${WORKING_DIR}/segfault.cpp

${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/segfault.cpp
assertEqual "$?" "0" "able to compile program segfault.cpp"

run_test ${WORKING_DIR}/run-test

assertEqual "${RESULT}" "${SIGSEGV_CODE}" "emitted expected signal from segfault"
assertEqual "$(stdout 1)" "${WORKING_DIR}/run-test exited with code:${SIGSEGV_CODE}" "Emitted expected first line of stdout"
assertContains "$(stdout 2)" "Found core at" "Found core file for given PID"
assertContains "$(all_lines)" "segfault.cpp:2" "Found expected line number in backtrace output"

# bus error
echo "#include <signal.h>" > ${WORKING_DIR}/bus_error.cpp
echo "int main() { raise(SIGBUS); }" >> ${WORKING_DIR}/bus_error.cpp

${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/bus_error.cpp
assertEqual "$?" "0" "able to compile program bus_error.cpp"

run_test ${WORKING_DIR}/run-test

assertEqual "${RESULT}" "${SIGBUS_CODE}" "emitted expected signal from bus error"
assertEqual "$(stdout 1)" "${WORKING_DIR}/run-test exited with code:${SIGBUS_CODE}" "Emitted expected first line of stdout"
assertContains "$(stdout 2)" "Found core at" "Found core file for given PID"
assertContains "$(all_lines)" "bus_error.cpp:2" "Found expected line number in backtrace output"

# TODO: test SIGQUIT, SIGILL, SIGFPE, etc: http://man7.org/linux/man-pages/man7/signal.7.html

exit_tests
