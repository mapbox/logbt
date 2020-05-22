#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    # abort
    echo "#include <cstdlib>" > ${WORKING_DIR}/abort.cpp
    echo "int main() { abort(); }" >> ${WORKING_DIR}/abort.cpp

    ${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/abort.cpp
    assertEqual "$?" "0" "able to compile program abort.cpp"

    run_test ${WORKING_DIR}/run-test

    assertEqual "${RESULT}" "${SIGABRT_CODE}" "emitted expected signal"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:${SIGABRT_CODE} (ABRT)" "Emitted expected line of stdout with error code"
    assertContains "$(stdout 4)" "Found corefile at" "Found corefile for given PID"
    assertContains "$(all_lines)" "abort.cpp:2" "Found expected line number in backtrace output"

    exit_early

    # segfault
    echo "#include <signal.h>" > ${WORKING_DIR}/segfault.cpp
    echo "int main() { raise(SIGSEGV); }" >> ${WORKING_DIR}/segfault.cpp

    ${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/segfault.cpp
    assertEqual "$?" "0" "able to compile program segfault.cpp"

    run_test ${WORKING_DIR}/run-test

    assertEqual "${RESULT}" "${SIGSEGV_CODE}" "emitted expected signal from segfault"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:${SIGSEGV_CODE} (SEGV)" "Emitted expected line of stdout with error code"
    assertContains "$(stdout 4)" "Found corefile at" "Found corefile for given PID"
    assertContains "$(all_lines)" "segfault.cpp:2" "Found expected line number in backtrace output"

    exit_early

    # bus error
    echo "#include <signal.h>" > ${WORKING_DIR}/bus_error.cpp
    echo "int main() { raise(SIGBUS); }" >> ${WORKING_DIR}/bus_error.cpp

    ${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/bus_error.cpp
    assertEqual "$?" "0" "able to compile program bus_error.cpp"

    run_test ${WORKING_DIR}/run-test

    assertEqual "${RESULT}" "${SIGBUS_CODE}" "emitted expected signal from bus error"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:${SIGBUS_CODE} (BUS)" "Emitted expected line of stdout with error code"
    assertContains "$(stdout 4)" "Found corefile at" "Found corefile for given PID"
    assertContains "$(all_lines)" "bus_error.cpp:2" "Found expected line number in backtrace output"

    exit_early

    # ILL error
    echo "#include <signal.h>" > ${WORKING_DIR}/illegal_instruction_error.cpp
    echo "int main() { raise(SIGILL); }" >> ${WORKING_DIR}/illegal_instruction_error.cpp

    ${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/illegal_instruction_error.cpp
    assertEqual "$?" "0" "able to compile program illegal_instruction_error.cpp"

    run_test ${WORKING_DIR}/run-test

    assertEqual "${RESULT}" "${SIGILL_CODE}" "emitted expected signal from illegal instruction error"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:${SIGILL_CODE} (ILL)" "Emitted expected line of stdout with error code"
    assertContains "$(stdout 4)" "Found corefile at" "Found corefile for given PID"
    assertContains "$(all_lines)" "illegal_instruction_error.cpp:2" "Found expected line number in backtrace output"

    exit_early

    # Floating point exception: 8
    echo "int main() { int zero = 0; float f2 = 1/zero; }" > ${WORKING_DIR}/floating-point-exception.cpp

    ${CXX} ${CXXFLAGS} -o ${WORKING_DIR}/run-test ${WORKING_DIR}/floating-point-exception.cpp
    assertEqual "$?" "0" "able to compile program floating-point-exception.cpp"

    run_test ${WORKING_DIR}/run-test

    assertEqual "${RESULT}" "${SIGFPE_CODE}" "emitted expected signal"
    assertContains "$(stdout 1)" "${EXPECTED_STARTUP_MESSAGE}" "Expected startup message"
    assertContains "$(stdout 2)" "${EXPECTED_STARTUP_MESSAGE2}" "Expected startup message"
    assertContains "$(stdout 3)" "exit with code:${SIGFPE_CODE} (FPE)" "Emitted expected line of stdout with error code"
    assertContains "$(stdout 4)" "Found corefile at" "Found corefile for given PID"
    assertContains "$(all_lines)" "floating-point-exception.cpp:1" "Found expected line number in backtrace output"
    exit_tests
}

main
