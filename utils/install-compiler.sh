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

spack load $COMPILER_HASH
cat > "$ENVDIR/etc/compiler.sh" <<EOF
export CC=$CC
export FC=$FC
export CXX=$CXX
EOF

## Swap to hashed version
echo COMPILER_PATH=$COMPILER_PATH

COMPILER_DEPS=$(spack find --deps --format "packages:{name}:require:'@{version}%{compiler.name}@{compiler.version}'" $COMPILER_PACKAGE)

e spack env activate "$ENVDIR/spack"

# Some packages must be built with gcc
e spack config add "packages:intel-oneapi-compilers:require:'%gcc'"
e spack config add "packages:intel-oneapi-compilers-classic:require:'%gcc'"
e spack config add "packages:gcc-runtime:require:'%gcc'"
e spack config add "packages:diffutils:require:'%gcc'"
e spack config add "packages:gettext:require:'%gcc'"

e spack compiler find "$COMPILER_PATH"
