#!/usr/bin/env bash

source $(dirname "${BASH_SOURCE[0]}")/utils.sh

function main() {
    if [[ $(uname -s) == 'Darwin' ]]; then
      # TODO: attaching with lldb is broken, likely due to PT_DENY_ATTACH
      # gets error like: error: attach failed: Error 1
      echo -e "\033[1m\033[35mRunning test on OS X\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
    else
      echo -e "\033[1m\033[35mRunning\033[0m \033[1m\033[32m${BASH_SOURCE[0]}\033[0m"
      # test sending custom USR1 signal (158) to logbt
      # background logbt and grab its PID
      ${PATH_TO_LOGBT}/logbt -- node test/wait.js 30 >${STDOUT_LOGS} 2>${STDERR_LOGS} & LOGBT_PID=$!
      echo -e "\033[1m\033[32mok\033[0m - ran ${PATH_TO_LOGBT}/logbt -- node test/wait.js 30 >${STDOUT_LOGS} 2>${STDERR_LOGS}"
      # give logbt time to startup
      WAIT_BEFORE_SIGNAL=1
      sleep ${WAIT_BEFORE_SIGNAL}
      # this should trigger a snapshot backtrace
      kill -USR1 ${LOGBT_PID}
      # wait 6 seconds for backtrace to get created
      sleep 2
      # then terminate the process
      RESULT=0
      kill -TERM ${LOGBT_PID}
      # wait for process to respond to shutdown request
      wait ${LOGBT_PID} || RESULT=$?
      assertEqual "${RESULT}" "143" "emitted expected signal"
      assertContains "$(all_lines)" "node::Start" "Found node::Start in backtrace output (from USR1)"
      assertContains "$(all_lines)" "[logbt] received signal:${SIGTERM_CODE} (TERM)" "Emitted expected line of stdout"
      assertContains "$(all_lines)" "[logbt] sending SIGTERM to node" "Emitted expected line of stdout"
      assertContains "$(all_lines)" "node received SIGTERM" "Emitted expected line of stdout"
    fi
    exit_tests
}

main
