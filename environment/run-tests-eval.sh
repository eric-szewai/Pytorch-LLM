#!/usr/bin/env bash
# Test runner contract:
#   /test.sh                      run the whole fail2pass + pass2pass suite
#   /test.sh a.py::t1,b.py::t2     run only the listed test ids (comma-separated)
# The code under test is always states/before/. Exit 0 = every listed test passed.
set -euo pipefail
# In the image this script is /test.sh and the task lives in /task; locally it is environment/run-tests-eval.sh.
# TASK_ROOT overrides the task location.
TASK_DIR="${TASK_ROOT:-/task}"
if [ -d "$TASK_DIR/states" ]; then cd "$TASK_DIR"; else cd "$(dirname "$0")/.."; fi
export PYTHONPATH="$PWD/states/before"
PYTEST="${PYTEST:-python -m pytest}"
if [ "$#" -eq 0 ]; then
  $PYTEST -q -p no:cacheprovider tests/fail2pass tests/pass2pass
else
  IFS=',' read -ra T <<< "$1"
  $PYTEST -q -p no:cacheprovider "${T[@]}"
fi
