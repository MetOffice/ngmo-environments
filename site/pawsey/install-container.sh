#!/bin/bash

set -eu
set -o pipefail

# Build the container
source "$NGMOENVS_DEFS/utils/common.sh"

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

# Set up squashfs directory
mkdir -p "$LOCAL_SQUASHFS$CONTAINER_BASEDIR/bin"

# Set up entrypoint
sed "$SITE_DIR/entrypoint.sh" \
    -e "s|^\(NGMOENVS_CONTAINER_BASEDIR\)=.*|\1='$CONTAINER_BASEDIR'|" \
    -e "s|^\(NGMOENVS_ENVIRONMENT\)=.*|\1='$ENVIRONMENT'|" \
    > "$LOCAL_SQUASHFS$CONTAINER_BASEDIR/bin/entrypoint.sh"
chmod +x "$LOCAL_SQUASHFS$CONTAINER_BASEDIR/bin/entrypoint.sh"

# Bootstrap container
e singularity run "${MOUNT_ARGS[@]}" "$IMAGE" /bin/bash "$NGMOENVS_DEFS/utils/bootstrap.sh"

# Configure site
e singularity run "${MOUNT_ARGS[@]}" "$IMAGE" spack config --scope=site add -f "$SITE_DIR/spack-packages.yaml"
e singularity run "${MOUNT_ARGS[@]}" "$IMAGE" spack config --scope=site add -f "$SITE_DIR/spack-compilers.yaml"

# Install container environment
e singularity run "${MOUNT_ARGS[@]}" "$IMAGE" /bin/bash "$NGMOENVS_DEFS/utils/install-stage-one.sh"

if [[ "${NGMOENVS_COMPILER%@*}" == cce ]]; then
    # Set compiler variables 
    cat >> "$LOCAL_SQUASHFS$NGMOENVS_ENVDIR/bin/activate" <<EOF

# Variables specific for pawsey site
export GCC_X86_64=/opt/cray/pe/gcc/10.3.0/snos
EOF
fi
