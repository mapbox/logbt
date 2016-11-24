set -u
set -o pipefail

export CODE=0

function assertEqual() {
    if [ "$1" == "$2" ]; then
        echo "ok - $1 ($3)"
    else
        echo "not ok - $1 != $2 ($3)"
        export CODE=1
    fi
}

export WORKING_DIR="/tmp/logbt"
mkdir -p ${WORKING_DIR}

echo "#include <iostream>" > ${WORKING_DIR}/test1.cpp
echo "int main() { std::string s(NULL); }" >> ${WORKING_DIR}/test1.cpp

g++ -o ${WORKING_DIR}/run-test ${WORKING_DIR}/test1.cpp
assertEqual "$?" "0" "able to compile program"

./bin/logbt ${WORKING_DIR}/run-test || RESULT=$?

if [[ $(uname -s) == 'Darwin' ]]; then
    assertEqual "${RESULT}" "139" "able to compile program"
else
    assertEqual "${RESULT}" "134" "able to compile program"
fi

exit ${CODE}