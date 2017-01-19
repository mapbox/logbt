#!/usr/bin/env bash
set -eu
echo "running custom-script"
node -e "process.kill(process.pid,'${1}');"
