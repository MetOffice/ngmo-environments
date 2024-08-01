#!/bin/bash

set -eu
set -o pipefail
SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

e() {
	echo "$@" >&2
	"$@"
}

# Build an apptainer container without requiring root permissions
# We can convert from Docker format to apptainer format without root
# And we can add a squashfs layer to an existing container without root
# So we do the build in two stages, first create a base container,
# then inside that container set up a directory that will be converted to
# a squashfs image

# Enviornment to install
ENVIRONMENT="$1"

# Commands
: "${APPTAINER:=$(which apptainer || which singularity || echo apptainer)}"
: "${MKSQUASHFS:=$(which mksquashfs || echo mksquashfs)}"

: "${NGMOENVS_TMPDIR:=${TMPDIR:-/tmp}}"

# Base directory for environments
: "${NGMOENVS_BASEDIR:="$HOME/ngmo-envs"}"

# Path to install the environment to on the host
ENVDIR="${NGMOENVS_BASEDIR}/envs/${ENVIRONMENT}"
INSTALL_ENVDIR="$ENVDIR"

# Host filesystem path for building squashfs
LOCALSQUASHFS="$NGMOENVS_TMPDIR/squashfs"

# Where to install the environment in the container
CONTAINER_BASEDIR=/ngmo
CONTAINER_ENVDIR="${CONTAINER_BASEDIR}/envs/${ENVIRONMENT}"

# Path to base of this repo
export NGMOENVS_DEFS="${SITE_DIR}/../.."

# What apptainer command is being used?
echo "APPTAINER=${APPTAINER}"

# Create the base image from our def file
: "${NGMOENVS_BASEIMAGE:="$NGMOENVS_TMPDIR/ngmoenvs-baseimage.sif"}"
if [[ ! -f "$NGMOENVS_BASEIMAGE" ]]; then
    mkdir -p "$(dirname "$NGMOENVS_BASEIMAGE")"
    # shellcheck disable=SC2086
    e $APPTAINER build \
            --force \
            "$NGMOENVS_BASEIMAGE" \
            "$SITE_DIR/image.def"
fi

# Prepare to create the squashfs directory
rm -rf "$LOCALSQUASHFS"
mkdir -p "$LOCALSQUASHFS/$CONTAINER_BASEDIR"

# Create the container entry point
ENTRYPOINT="$LOCALSQUASHFS/$CONTAINER_BASEDIR/bin/entrypoint.sh"
mkdir -p "$(dirname "$ENTRYPOINT")"
cat > "$ENTRYPOINT" << EOF
#!/bin/bash

# Activate spack and conda
source "$CONTAINER_BASEDIR/bin/activate"
export PATH=$CONTAINER_BASEDIR/conda/bin:\$PATH

# Activate the environment
if [[ -f $CONTAINER_BASEDIR/envs/$ENVIRONMENT/bin/activate ]]; then
    source $CONTAINER_BASEDIR/envs/$ENVIRONMENT/bin/activate
fi

exec "\$@"
EOF
chmod +x "$ENTRYPOINT"

# Arguments to mount the squashfs directory inside the container
MOUNT_ARGS=("--bind" "$LOCALSQUASHFS$CONTAINER_BASEDIR:$CONTAINER_BASEDIR:rw")

# Install conda and spack using the common bootstrap script
export NGMOENVS_BASEDIR="${CONTAINER_BASEDIR}"
# shellcheck disable=SC2086
e $APPTAINER exec "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" /bin/bash "${SITE_DIR}/../../utils/bootstrap.sh"

# Install the environment using the common onestage install script
export NGMOENVS_ENVDIR="${CONTAINER_ENVDIR}"
export ENVIRONMENT
# shellcheck disable=SC2086
e $APPTAINER run "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" /bin/bash "${SITE_DIR}/../../utils/install-stage-one.sh"

# Convert to squashfs
SQUASHFS="$NGMOENVS_TMPDIR/$ENVIRONMENT.squashfs"
# shellcheck disable=SC2086
e $MKSQUASHFS "$LOCALSQUASHFS" "$SQUASHFS" -all-root -noappend

# Install the squashfs to the container
IMAGE="$INSTALL_ENVDIR/etc/apptainer.sif"
mkdir -p "$(dirname "$IMAGE")"
cp "$NGMOENVS_BASEIMAGE" "$IMAGE"
# shellcheck disable=SC2086
e $APPTAINER sif add \
	--datatype 4 \
	--partfs 1 \
	--parttype 4 \
	--partarch 2 \
	--groupid 1 \
	"$IMAGE" \
	"$SQUASHFS"

# Install the environment
mkdir -p "$INSTALL_ENVDIR/bin"
cat > "$INSTALL_ENVDIR/bin/envrun" << EOF
#!/bin/bash
ENV_DIR=\$( cd -- "\$( dirname -- "\$(readlink -f "\${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )/..

\${APPTAINER:-${APPTAINER}} run "\$ENV_DIR/etc/apptainer.sif" "\$@"
EOF
chmod +x "$INSTALL_ENVDIR/bin/envrun"
