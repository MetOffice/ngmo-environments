#!/bin/bash

# Install a compiler into the curent environment

set -eu
set -o pipefail

e() {
	echo "$@"
	"$@"
}

echo NGMOENVS_COMPILER=$NGMOENVS_COMPILER

COMPILER_NAME=${NGMOENVS_COMPILER%@*}
COMPILER_VERSION=${NGMOENVS_COMPILER/#${COMPILER_NAME}/}

if [[ $COMPILER_NAME == "intel" ]]; then
	COMPILER_PACKAGE=intel-oneapi-compilers-classic$COMPILER_VERSION
elif [[ $COMPILER_NAME == "oneapi" ]]; then
	COMPILER_PACKAGE=intel-oneapi-compilers$COMPILER_VERSION
else
	COMPILER_PACKAGE=$NGMOENVS_COMPILER
fi

e spack install --add $COMPILER_PACKAGE
COMPILER_HASH=$(spack find --format '{name}/{hash}' $COMPILER_PACKAGE)
COMPILER_PATH=$(spack find --format '{prefix}' $COMPILER_PACKAGE)

## Swap to hashed version
#e spack remove $COMPILER_PACKAGE
#e spack add $COMPILER_PACKAGE$COMPILER_HASH
echo COMPILER_PATH=$COMPILER_PATH

e spack env activate "$ENVDIR/spack"

# Some packages must be built with gcc
e spack config add "packages:intel-oneapi-compilers:require:'%gcc'"
e spack config add "packages:intel-oneapi-compilers-classic:require:'%gcc'"
e spack config add "packages:gcc-runtime:require:'%gcc'"
e spack config add "packages:diffutils:require:'%gcc'"
e spack config add "packages:gettext:require:'%gcc'"

e spack add $COMPILER_HASH

e spack compiler find "$COMPILER_PATH"
