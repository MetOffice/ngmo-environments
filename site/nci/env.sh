#!/bin/bash

set -eu
set -o pipefail

# shellcheck source=utils/common.sh
source "$SITE_DIR/../../utils/common.sh"

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
