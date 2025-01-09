#!/bin/bash

# Install a specific environment

set -eu
set -o pipefail
SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

# shellcheck source=utils/common.sh
source "$SITE_DIR/../../utils/common.sh"

# Enviornment to install
export ENVIRONMENT="$1"

# Base directory for environments
: "${NGMOENVS_BASEDIR:="$HOME/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Path to base of this repo
export NGMOENVS_DEFS=${SITE_DIR}/../..

: "${NGMOENVS_COMPILER:="intel"}"
: "${NGMOENVS_MPI:="mpich"}"
export NGMOENVS_COMPILER NGMOENVS_MPI

# Path to local spack source mirror
export NGMOENVS_SPACK_MIRROR=file:///g/sc/home_user/scwales/"spack-mirror"

# Path to local mosrs mirror
export NGMOENVS_MOSRS_MIRROR=file:///g/sc/bureau_b/research/data/ukmo/mosrs

# Load spack
SPACK_BASE=~scwales/"spack-0.22.3"
source "$SPACK_BASE/share/spack/setup-env.sh"

BOOTSTRAP=${NGMOENVS_SPACK_MIRROR#file://}/bootstrap
if ! e spack config get bootstrap | grep -w "$BOOTSTRAP"; then
    e spack bootstrap add --scope=site --trust local "$BOOTSTRAP/metadata/sources"
fi
e spack bootstrap root --scope=site "${BOOTSTRAP}_cache"

# Run the generic build script
"$NGMOENVS_DEFS/utils/install-stage-one.sh"
