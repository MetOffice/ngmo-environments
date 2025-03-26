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
    "--bind" "/run/user/$UID" # gpgagent sockets
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

# Load Cray PE
module load PrgEnv-cray
module load cce/18.0.1

export PKG_CONFIG_PATH=/opt/cray/xpmem/2.8.4-1.0_7.23__ga37cbd9.shasta/lib64/pkgconfig:\$PKG_CONFIG_PATH
EOF
fi

cat >> "$LOCAL_SQUASHFS$NGMOENVS_ENVDIR/bin/activate" <<EOF
# Modules used when building the env
module load craype-x86-milan
module load craype-network-ofi
module load cray-mpich/8.1.28
module load cray-hdf5-parallel/1.12.2.9
module load cray-netcdf-hdf5parallel/4.9.0.9
EOF
