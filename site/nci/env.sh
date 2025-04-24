#!/bin/bash

set -eu
set -o pipefail

# shellcheck source=utils/common.sh
source "$SITE_DIR/../../utils/common.sh"

: "${NGMOENVS_BASEDIR:="/scratch/$PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

: "${NGMOENVS_TMPDIR:=${TMPDIR:-/tmp}}"
export NGMOENVS_TMPDIR

# Host filesystem path for building squashfs
export LOCALSQUASHFS="$NGMOENVS_TMPDIR/squashfs"

# Where to install the environment in the container
export CONTAINER_BASEDIR=/ngmo
export CONTAINER_ENVDIR="${CONTAINER_BASEDIR}/envs/${ENVIRONMENT}"

# Path to base of this repo
export NGMOENVS_DEFS="${SITE_DIR}/../.."
export NGMOENVS_MOSRS_MIRROR=file:///g/data/ki32/mosrs

# System apptainer
export APPTAINER=/opt/singularity/bin/singularity
export MKSQUASHFS=/usr/sbin/mksquashfs

# Prebuild base image
export NGMOENVS_BASEIMAGE=/g/data/access/ngm/data/gadicontainer/202407/ngmoenvs-baseimage.sif

# Isolate Spack
export SPACK_DISABLE_LOCAL_CONFIG=true
export SPACK_USER_CACHE_PATH="$TMPDIR/spack"

# Path to install the environment to on the local machine
: "${NGMOENVS_ENVDIR:="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/$VERSION"}"
export NGMOENVS_ENVDIR
INSTALL_ENVDIR="$NGMOENVS_ENVDIR"
export INSTALL_ENVDIR

# Path for modulefiles
: "${NGMOENVS_MODULE:="$NGMOENVS_BASEDIR/modules/$ENVIRONMENT/$VERSION"}"
export NGMOENVS_MODULE

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Default compiler and MPI
: "${NGMOENVS_COMPILER:="intel@2021.10.0"}"
: "${NGMOENVS_MPI:="openmpi@5.0.5"}"
export NGMOENVS_COMPILER
export NGMOENVS_MPI
