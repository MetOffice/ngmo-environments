#!/bin/bash
# Install ngmo-environments on Pawsey Setonix

set -eu
set -o pipefail
SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

# Base environments directory
export NGMOENVS_DEFS="$SITE_DIR/../.."

export ENVIRONMENT="$1"

: "${NGMOENVS_BASEDIR:="/scratch/$PAWSEY_PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Default compiler and MPI
: "${NGMOENVS_COMPILER:="aocc"}"
: "${NGMOENVS_MPI:="cray-mpich@8.1.27"}"
export NGMOENVS_COMPILER NGMOENVS_MPI

VERSION="$(git describe --always)"
export VERSION

# Base image
: "${NGMOENVS_BASEIMAGE:="$HOME/ngmoenvs-baseimage.sif"}"

# Directory we'll install the container to
: "${NGMOENVS_ENVDIR:="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/$VERSION"}"

# Where we'll set up squashfs on the host machine
export LOCAL_SQUASHFS="$NGMOENVS_ENVDIR/squashfs"

# Start clean
[[ -f "$NGMOENVS_ENVDIR" ]] && rm -r "$NGMOENVS_ENVDIR"

mkdir -p "$NGMOENVS_ENVDIR"/{bin,etc}

# Set up the image
export IMAGE="$NGMOENVS_ENVDIR/etc/image.sif"
cp "$NGMOENVS_BASEIMAGE" "$IMAGE"

# Build the container
bash "$SITE_DIR/install-container.sh"

# Clean up squashfs
# rm -r "$LOCAL_SQUASHFS"
