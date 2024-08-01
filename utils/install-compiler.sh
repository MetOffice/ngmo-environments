#!/bin/bash

# Install a compiler into the curent environment

set -eu
set -o pipefail

# shellcheck source=utils/common.sh
source "$SCRIPT_DIR/common.sh"

echo NGMOENVS_COMPILER="$NGMOENVS_COMPILER"

COMPILER_NAME="${NGMOENVS_COMPILER%@*}"
COMPILER_VERSION="${NGMOENVS_COMPILER/#${COMPILER_NAME}/}"

# Is the compiler already available?
if e spack compiler info "$NGMOENVS_COMPILER" | tee "$NGMOENVS_TMPDIR/compiler_info"; then
    echo Compiler is preconfigured

    e spack env activate "$ENVDIR/spack"
else
    echo Compiler is unavailable, installing with Spack

    if [[ $COMPILER_NAME == "intel" ]]; then
            COMPILER_PACKAGE="intel-oneapi-compilers-classic$COMPILER_VERSION"
    elif [[ $COMPILER_NAME == "oneapi" ]]; then
            COMPILER_PACKAGE="intel-oneapi-compilers$COMPILER_VERSION"
    else
            COMPILER_PACKAGE="$NGMOENVS_COMPILER"
    fi

    # Install the compiler outside any environment
    e spack install --add "$COMPILER_PACKAGE"

    COMPILER_PATH="$(e spack find --format '{prefix}' "$COMPILER_PACKAGE")"

    # Add the compiler to the enviornment config
    spack env activate "$ENVDIR/spack"
    e spack compiler find "$COMPILER_PATH"
    e spack compiler info "$NGMOENVS_COMPILER" | tee "$NGMOENVS_TMPDIR/compiler_info"
fi

mkdir -p "$ENVDIR/etc"
cat > "$ENVDIR/etc/compiler.sh" <<EOF
export CC="$(sed -n -e 's/^\s*cc\s*=\s*\(\S\+\)/\1/p' "$NGMOENVS_TMPDIR/compiler_info")"
export FC="$(sed -n -e 's/^\s*fc\s*=\s*\(\S\+\)/\1/p' "$NGMOENVS_TMPDIR/compiler_info")"
export CXX="$(sed -n -e 's/^\s*cxx\s*=\s*\(\S\+\)/\1/p' "$NGMOENVS_TMPDIR/compiler_info")"

# Compilers for MPI
export OMPI_CC=\$CC
export OMPI_FC=\$FC
export OMPI_CXX=\$CXX
EOF
cat "$ENVDIR/etc/compiler.sh"
