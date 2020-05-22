export passed=0
export failures=0

export CXX=${CXX:-g++}

function assertEqual() {
    if [[ "$1" == "$2" ]]; then
        echo -e "\033[1m\033[32mok\033[0m - $1 == $2 ($3)"
        export passed=$((passed+1))
    else
        echo -e "\033[1m\033[31mnot ok\033[0m - $1 != $2 ($3)"
        export failures=$((failures+1))
    fi
}

function assertContains() {
    if [[ "$1" =~ "$2" ]]; then
        echo -e "\033[1m\033[32mok\033[0m - Found string $2 in output ($3)"
        export passed=$((passed+1))
    else
        echo -e "\033[1m\033[31mnot ok\033[0m - Did not find string '$2' in '$1' ($3)"
        export failures=$((failures+1))
    fi
}

function init_variables() {
  export RESULT=0
  export PATH_TO_LOGBT=${PATH_TO_LOGBT:-./bin}
  export WORKING_DIR="/tmp/logbt-unit-test-outputs"
  export STDOUT_LOGS="./stdout.txt"
  export STDERR_LOGS="./stderr.txt"
  export CXXFLAGS="-g -O0 -DDEBUG"
  export SIGSEGV_CODE="139"
  export SIGABRT_CODE="134"
  export SIGFPE_CODE="136"
  export TIMEOUT_CODE="124"
  export SIGTERM_CODE="143"
  export SIGILL_CODE="132"
  export SIGHUP_CODE="129"
  export SIGKILL_CODE="137"
  export SIGINT_CODE="130"
  export COMMAND_NOT_FOUND_CODE="127"
  if [[ $(uname -s) == 'Darwin' ]]; then
      export SIGBUS_CODE="138"
      export SIGUSR1_CODE="158"
  else
      export SIGBUS_CODE="135"
      export SIGUSR1_CODE="138"
  fi
  export EXPECTED_STARTUP_MESSAGE="[logbt] using corefile location: "
  export EXPECTED_STARTUP_MESSAGE2="[logbt] using core_pattern: "
}

function teardown() {
    rm -rf ${WORKING_DIR}/
    rm -f ${STDOUT_LOGS}
    rm -f ${STDERR_LOGS}
}

function exit_tests() {
    if [[ ${failures} == 0 ]]; then
        echo -e "\033[1m\033[32m* Success: ${passed} tests succeeded\033[0m";
        exit 0
    else
        echo -e "\033[1m\033[31m* Error: ${failures} test(s) failed\033[0m";
        exit 1
    fi
}

function exit_early() {
    if [[ ${failures} != 0 ]]; then
        echo "bailing tests early"
        echo
        echo "dumping log of stdout"
        cat ${STDOUT_LOGS}
        echo
        echo "dumping log of stderr"
        cat ${STDERR_LOGS}
        echo
        exit_tests
    fi
}

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

function ensure_test_deps() {
    # Assert we have key deps before running tests
    if ! which node > /dev/null; then
        echo "Could not find required command 'node'"
        exit 1
    fi

    if ! which timeout > /dev/null; then
        echo "Could not find required command 'timeout'"
        exit 1
    fi

    if ! which ${CXX} > /dev/null; then
        echo "Could not find required command '${CXX}'"
        exit 1
    fi
}

function run_test() {
    export RESULT=0
    ${PATH_TO_LOGBT}/logbt -- $@ >${STDOUT_LOGS} 2>${STDERR_LOGS} || export RESULT=$?
    echo -e "\033[1m\033[32mok\033[0m - ran ${PATH_TO_LOGBT}/logbt -- $@ >${STDOUT_LOGS} 2>${STDERR_LOGS}"
    export passed=$((passed+1))
}

function main() {
  set -u
  set -o pipefail
  ensure_test_deps
  init_variables  
  trap "teardown" EXIT
  mkdir -p ${WORKING_DIR}
}

main


