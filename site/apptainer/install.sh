#!/bin/bash

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

e() {
	echo "$@"
	"$@"
}

# Enviornment to install
ENVIRONMENT="$1"

# Base directory for environments
: ${NGMOENVS_BASEDIR:="$HOME/ngmo-envs"}

# Path to install the environment to
ENVDIR="${NGMOENVS_BASEDIR}/envs/${ENVIRONMENT}"
INSTALL_ENVDIR="$ENVDIR"

# Local filesystem path for building squashfs
LOCALSQUASHFS=${TMPDIR:-/tmp}/squashfs

# Where to install the environment in the container
CONTAINER_BASEDIR=/ngmo
CONTAINER_ENVDIR=${CONTAINER_BASEDIR}/envs/${ENVIRONMENT}

# Path to base of this repo
export NGMODEFS=${SCRIPT_DIR}/../..

echo "APPTAINER=$APPTAINER"

IMAGE="$ENVDIR/etc/apptainer.sif"
mkdir -p "$(dirname "$IMAGE")"

e $APPTAINER build \
	--force \
	"$IMAGE" \
	"$SCRIPT_DIR/image.def"

rm -rf "$LOCALSQUASHFS"
mkdir -p "$LOCALSQUASHFS/$CONTAINER_BASEDIR"

MOUNT_ARGS="--bind $LOCALSQUASHFS$CONTAINER_BASEDIR:$CONTAINER_BASEDIR:rw"

# Install conda and spack
export NGMOENVS_BASEDIR=${CONTAINER_BASEDIR}
e $APPTAINER exec $MOUNT_ARGS "$IMAGE" /bin/bash ${SCRIPT_DIR}/../../utils/bootstrap.sh
