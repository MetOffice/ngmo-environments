#!/bin/bash
# Install ngmo-environments on Pawsey Setonix

set -eu
set -o pipefail

export ENVIRONMENT="$1"

: "${NGMOENVS_BASEDIR:="/scratch/$PAWSEY_PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Default compiler and MPI
: "${NGMOENVS_COMPILER:="gnu@12.2.0"}"
: "${NGMOENVS_MPI:="cray_mpich@8.1.27"}"
export NGMOENVS_COMPILER NGMOENVS_MPI

VERSION="$(git describe --always)"
export VERSION
