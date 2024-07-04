#!/bin/bash

set -eu
set -o pipefail
SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

# Build an apptainer container without requiring root permissions
# We can convert from Docker format to apptainer format without root
# And we can add a squashfs layer to an existing container without root
# So we do the build in two stages, first create a base container,
# then inside that container set up a directory that will be converted to
# a squashfs image

# Enviornment to install
ENVIRONMENT="$1"

# Common variables
# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

# What apptainer command is being used?
echo "APPTAINER=$APPTAINER"

# Path to externally created base image
: "${NGMOENVS_BASEIMAGE:="$NGMOENVS_TMPDIR/ngmoenvs-baseimage.sif"}"

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
e $APPTAINER exec "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" /bin/bash "${SITE_DIR}/../../utils/bootstrap.sh"

# Configure Spack to use NCI system packages
e $APPTAINER run "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" spack config --scope=site add -f "${SITE_DIR}/spack-packages.yaml"
e $APPTAINER run "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" spack config --scope=site add -f "${SITE_DIR}/spack-compilers.yaml"

# Install the basic environment without building Spack packages - this will be
# done in the compute queue
export NGMOENVS_ENVDIR="${CONTAINER_ENVDIR}"
export NGMOENVS_DOWNLOAD_ONLY=1
export ENVIRONMENT
e $APPTAINER run "${MOUNT_ARGS[@]}" "$NGMOENVS_BASEIMAGE" /bin/bash "${SITE_DIR}/../../utils/install-stage-one.sh"

# Convert to squashfs
SQUASHFS="$INSTALL_ENVDIR/etc/$ENVIRONMENT.squashfs"
mkdir -p "$(dirname "$SQUASHFS")"
e $MKSQUASHFS "$LOCALSQUASHFS" "$SQUASHFS" -all-root -noappend -processors "${PBS_NCPUS:-1}"

