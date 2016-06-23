#!/usr/bin/env bash

# strict mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -uo pipefail
shopt -s nullglob

DIR=$(dirname "$0")
TARGET_FILE="$1"
TARGET_FILE_BASENAME="$(basename ${TARGET_FILE%.es6})"

error() {
  echo "$1"
  exit 1
}

if [ ! -f "${TARGET_FILE}" ]; then
  echo "unable to find specified file: ${TARGET_FILE}";
  exit 1;
fi

echo "## ${TARGET_FILE_BASENAME}";

# run hardnosed closure and collect the output and the compilation report
"${DIR}"/../hardnosed-closure.sh "${TARGET_FILE}" 1> "${DIR}"/output.js 2> "${DIR}"/compile.log

# check that the compilation log matches the expected output
echo "- checking compilation log"
diff "${DIR}/compile.log" "${DIR}/expected-out/${TARGET_FILE_BASENAME}.log" || error "FAIL: ${TARGET_FILE_BASENAME}"

if [ -f "${DIR}/expected-out/${TARGET_FILE_BASENAME}.js" ]; then
  echo "- checking generated JS"
  diff "${DIR}/output.js" "${DIR}/expected-out/${TARGET_FILE_BASENAME}.js" || error "FAIL: ${TARGET_FILE_BASENAME}"
fi
