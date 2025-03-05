#!/bin/bash

# Build the container

module load "singularity/4.1.0-slurm"

# Where we'll set up squashfs within the container
export CONTAINER_BASEDIR="/ngmo"

# Set variables inside the container
export NGMOENVS_BASEDIR="$CONTAINER_BASEDIR"
export NGMOENVS_ENVDIR="$CONTAINER_BASEDIR/env"
export SPACK_BOOTSTRAP_ROOT="$CONTAINER_BASEDIR/spack-bootstrap"

# Arguments to apptainer
export MOUNT_ARGS=(
    "--bind" "$LOCAL_SQUASHFS$CONTAINER_BASEDIR:$CONTAINER_BASEDIR:rw"
    "--bind" "/opt/AMD" # AOCC compiler
    "--bind" "/opt/rocm-5.7.1" # ROCM/clang compiler
    "--bind" "/usr/lib64:/host/lib64" # System libraries
)

set -x

# Set up squashfs directory
mkdir -p "$LOCAL_SQUASHFS$CONTAINER_BASEDIR/bin"

# Set up entrypoint
sed "$SITE_DIR/entrypoint.sh" \
    -e "s|^\(NGMOENVS_CONTAINER_BASEDIR\)=.*|\1='$CONTAINER_BASEDIR'|" \
    -e "s|^\(NGMOENVS_ENVIRONMENT\)=.*|\1='$ENVIRONMENT'|" \
    > "$LOCAL_SQUASHFS$CONTAINER_BASEDIR/bin/entrypoint.sh"
chmod +x "$LOCAL_SQUASHFS$CONTAINER_BASEDIR/bin/entrypoint.sh"

# Bootstrap container
singularity run "${MOUNT_ARGS[@]}" "$IMAGE" /bin/bash "$NGMOENVS_DEFS/utils/bootstrap.sh"

# Configure site
singularity run "${MOUNT_ARGS[@]}" "$IMAGE" spack config --scope=site add -f "$SITE_DIR/spack-packages.yaml"
singularity run "${MOUNT_ARGS[@]}" "$IMAGE" spack config --scope=site add -f "$SITE_DIR/spack-compilers.yaml"

# Install container environment
singularity run "${MOUNT_ARGS[@]}" "$IMAGE" /bin/bash "$NGMOENVS_DEFS/utils/install-stage-one.sh"
