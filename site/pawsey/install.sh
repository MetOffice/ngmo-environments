#!/bin/bash
# Install ngmo-environments on Pawsey Setonix

set -eu
set -o pipefail

SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

# Base environments directory
export NGMOENVS_DEFS="$SITE_DIR/../.."

module purge
module load "pawsey"
module load "pawseyenv/2024.05"
module load "singularity/4.1.0-slurm"
source "$NGMOENVS_DEFS/utils/common.sh"

export ENVIRONMENT="$1"

: "${NGMOENVS_BASEDIR:="/scratch/$PAWSEY_PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Default compiler and MPI
: "${NGMOENVS_COMPILER:="cce"}"
: "${NGMOENVS_MPI:="cray-mpich"}"
export NGMOENVS_COMPILER NGMOENVS_MPI

# Base image
: "${NGMOENVS_BASEIMAGE:="$HOME/ngmoenvs-baseimage.sif"}"

# Directory we'll install the container to
: "${NGMOENVS_ENVDIR:="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/$VERSION"}"

# Path for modulefiles
: "${NGMOENVS_MODULE_ROOT:="$NGMOENVS_BASEDIR/modules"}"

# Where we'll set up squashfs on the host machine
export LOCAL_SQUASHFS="$NGMOENVS_ENVDIR/squashfs"

# Start clean
[[ -f "$NGMOENVS_ENVDIR" ]] && rm -r "$NGMOENVS_ENVDIR"

mkdir -p "$NGMOENVS_ENVDIR"/{bin,etc}

# Set up the image
export IMAGE="$NGMOENVS_ENVDIR/etc/image.sif"
cp "$NGMOENVS_BASEIMAGE" "$IMAGE"

# Set temp dir
export NGMOENVS_TMPDIR=/scratch/$PAWSEY_PROJECT/$USER/tmp

# Build the container
bash "$SITE_DIR/install-container.sh"

# Convert to squashfs
SQUASHFS="$NGMOENVS_ENVDIR/etc/env.squashfs"
e mksquashfs "$LOCAL_SQUASHFS" "$SQUASHFS" -all-root -noappend -processors 2

# Install into the container
e singularity sif add \
	--datatype 4 \
	--partfs 1 \
	--parttype 4 \
	--partarch 2 \
	--groupid 1 \
	"$IMAGE" \
	"$SQUASHFS"

# Clean up temp squashfs
e rm "$SQUASHFS"
e rm -r "$LOCAL_SQUASHFS"

# Set up scripts
for SCRIPT in envrun; do
    cp "$SITE_DIR/$SCRIPT" "$NGMOENVS_ENVDIR/bin/$SCRIPT"
    chmod +x "$NGMOENVS_ENVDIR/bin/$SCRIPT"
done

NGMOENVS_MODULE="$NGMOENVS_MODULE_ROOT/$ENVIRONMENT/$VERSION"
mkdir -p "$(dirname "$NGMOENVS_MODULE")"
cat > "$NGMOENVS_MODULE" << EOF
#%Module1.0

set name         "$ENVIRONMENT"
set version      "$VERSION"
set origin       "$(git remote get-url origin) $(git rev-parse HEAD)"
set install_date "$(date --iso=minute)"
set installed_by "$USER - $(getent passwd "$USER" | cut -d ':' -f 5)"
set prefix       "$NGMOENVS_ENVDIR"

proc ModulesHelp {} {
    global name version origin install_date installed_by

    puts stderr "NGMO Environment \$name/\$version"
    puts stderr "  Install info:"
    puts stderr "    repo: \$origin"
    puts stderr "    ver:  \$version"
    puts stderr "    date: \$install_date"
    puts stderr "    by:   \$installed_by"
}

set name_upcase [string toupper [string map {- _} \$name]]

setenv \${name_upcase}_ROOT "\$prefix"
setenv \${name_upcase}_VERSION "\$version"

prepend-path PATH "\$prefix/bin"
EOF

cat <<EOF

Environment for Pawsey-Setonix installed under

    $NGMOENVS_ENVDIR

Load as a module with

    module use "$NGMOENVS_MODULE_ROOT"
    module load "$ENVIRONMENT/$VERSION"

Run commands in the environment with

    envrun COMMAND

EOF
