#!/usr/bin/env bash

set -u
set -o pipefail

export CODE=0
export failures=0
export passed=0

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

export WORKING_DIR="/tmp/logbt"
mkdir -p ${WORKING_DIR}
export CXXFLAGS="-g -O0 -DDEBUG"
export CXX=${CXX:-g++}

# abort
echo "#include <cstdlib>" > ${WORKING_DIR}/abort.cpp
echo "int main() { abort(); }" >> ${WORKING_DIR}/abort.cpp

${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/abort.cpp
assertEqual "$?" "0" "able to compile program abort.cpp"

./bin/logbt ${WORKING_DIR}/run-test >logs.txt 2>log_errors.txt || RESULT=$?

assertEqual "${RESULT}" "134" "emitted expected signal"
assertEqual "$(head -n 1 logs.txt)" "${WORKING_DIR}/run-test exited with code:134" "Emitted expected first line of stdout"
assertContains "$(head -n 2 logs.txt | tail -n 1)" "Found core at" "Found core file for given PID"
assertContains "$(cat logs.txt)" "abort.cpp:2" "Found expected line number in backtrace output"
#cat logs.txt


# segfault
echo "#include <signal.h>" > ${WORKING_DIR}/segfault.cpp
echo "int main() { raise(SIGSEGV); }" >> ${WORKING_DIR}/segfault.cpp

${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/segfault.cpp
assertEqual "$?" "0" "able to compile program segfault.cpp"

./bin/logbt ${WORKING_DIR}/run-test >logs.txt 2>log_errors.txt || RESULT=$?

assertEqual "${RESULT}" "139" "emitted expected signal from segfault"
assertEqual "$(head -n 1 logs.txt)" "${WORKING_DIR}/run-test exited with code:139" "Emitted expected first line of stdout"
assertContains "$(head -n 2 logs.txt | tail -n 1)" "Found core at" "Found core file for given PID"
assertContains "$(cat logs.txt)" "segfault.cpp:2" "Found expected line number in backtrace output"
#cat logs.txt

# bus error
echo "#include <signal.h>" > ${WORKING_DIR}/bus_error.cpp
echo "int main() { raise(SIGBUS); }" >> ${WORKING_DIR}/bus_error.cpp

${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/bus_error.cpp
assertEqual "$?" "0" "able to compile program bus_error.cpp"

./bin/logbt ${WORKING_DIR}/run-test >logs.txt 2>log_errors.txt || RESULT=$?

assertEqual "${RESULT}" "138" "emitted expected signal from bus error"
assertEqual "$(head -n 1 logs.txt)" "${WORKING_DIR}/run-test exited with code:138" "Emitted expected first line of stdout"
assertContains "$(head -n 2 logs.txt | tail -n 1)" "Found core at" "Found core file for given PID"
assertContains "$(cat logs.txt)" "bus_error.cpp:2" "Found expected line number in backtrace output"
#cat logs.txt

if [[ ${CODE} == 0 ]]; then
    echo -e "\033[1m\033[32m* Success: ${passed} tests succeeded\033[0m";
else
    echo -e "\033[1m\033[31m* Error: ${failures} test(s) failed\033[0m";
fi
exit ${CODE}