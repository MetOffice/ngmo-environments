#!/bin/bash

# Install a compiler into the curent environment

set -eu
set -o pipefail

# shellcheck source=utils/common.sh
source "$SCRIPT_DIR/common.sh"

info NGMOENVS_COMPILER="$NGMOENVS_COMPILER"

COMPILER_NAME="${NGMOENVS_COMPILER%@*}"
COMPILER_VERSION="${NGMOENVS_COMPILER/#${COMPILER_NAME}/}"

# Is the compiler already available?
if e spack compiler info "$NGMOENVS_COMPILER" | tee "$NGMOENVS_TMPDIR/compiler_info"; then
    info Compiler is preconfigured

    e spack env activate "$ENVDIR/spack"
else
    info Compiler is unavailable, installing with Spack

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

# There might be more than one copy of a compiler installed - check them
# all and pick the first one that has all four compilers (cc, cxx, f90, f77)
# as not None. I.e. we ignore any compiler that has a 'None':
found=0
for compiler in $(spack compiler info "$NGMOENVS_COMPILER" | grep "^[^[:space:]]"); do
    spack compiler info "$compiler" > "$NGMOENVS_TMPDIR/compiler_info"
    num_none=$(grep -c None "$NGMOENVS_TMPDIR/compiler_info" || true)
    if [[ $num_none == "0" ]]; then
        echo "Using compiler $compiler"
        found=1
    fi
done

if [[ $found == 0 ]]; then
    error "Could not find compiler $NGMOENVS_COMPILER"
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
