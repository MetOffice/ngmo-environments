#!/bin/bash

set -eu
set -o pipefail

# Build the spack packages for the container
# Starting from the squashfs created in stage 1 we add all of the Spack packages

SITE_DIR="$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )"
export SITE_DIR

# Enviornment to install
ENVIRONMENT="$1"

# Common environment variables
# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

# What apptainer command is being used?
echo "APPTAINER=$APPTAINER"

# Extract the squashfs created by stage 1
SQUASHFS="$INSTALL_ENVDIR/etc/$ENVIRONMENT.squashfs"
/usr/sbin/unsquashfs -d "$LOCALSQUASHFS" "$SQUASHFS"

# Arguments to mount the squashfs directory inside the container
MOUNT_ARGS=(--bind "$LOCALSQUASHFS$CONTAINER_BASEDIR:$CONTAINER_BASEDIR:rw" --bind /lib64:/system/lib64 --bind /half-root --bind /opt/pbs)
export SINGULARITYENV_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/system/lib64"

# Build the spack packages themselves
export NGMOENVS_ENVDIR="${CONTAINER_ENVDIR}"
export ENVIRONMENT
e "${APPTAINER[@]}" run "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" /bin/bash "${SITE_DIR}/../../utils/install-stage-two.sh"

# Convert to squashfs
SQUASHFS="$INSTALL_ENVDIR/etc/$ENVIRONMENT.squashfs"
e "${MKSQUASHFS[@]}" "$LOCALSQUASHFS" "$SQUASHFS" -all-root -noappend -processors "${PBS_NCPUS:-1}"

# Install the squashfs to the container
IMAGE="$INSTALL_ENVDIR/etc/apptainer.sif"
mkdir -p "$(dirname "$IMAGE")"
cp "$NGMOENVS_BASEIMAGE" "$IMAGE"
e "${APPTAINER[@]}" sif add \
	--datatype 4 \
	--partfs 1 \
	--parttype 4 \
	--partarch 2 \
	--groupid 1 \
	"$IMAGE" \
	"$SQUASHFS"

# Envrun is installed by main install script
