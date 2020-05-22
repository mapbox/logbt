#!/usr/bin/env bash

function main() {

  for i in $(ls ./test/*test.sh); do $i; done

}

main
