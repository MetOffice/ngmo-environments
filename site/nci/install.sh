#!/bin/bash

set -eu
set -o pipefail

SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

export ENVIRONMENT="$1"

: "${NGMOENVS_BASEDIR:="/scratch/$PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Default compiler and MPI
: "${NGMOENVS_COMPILER:="intel@2021.10.0"}"
: "${NGMOENVS_MPI:="openmpi@4.1.5"}"
export NGMOENVS_COMPILER NGMOENVS_MPI

VERSION="$(git describe --always)"
export VERSION

# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

# Run the apptainer build in the queue
# First stage is everything requiring networking - only download spack sources
STAGE1=$(qsub \
    -N "ngmoenvs1-$ENVIRONMENT" \
    -P "$PROJECT" \
    -q copyq \
    -l ncpus=1 \
    -l walltime=1:00:00 \
    -l mem=4gb \
    -l jobfs=50gb \
    -l storage=gdata/access+gdata/ki32 \
    -j oe \
    -W umask=0022 \
    -v PROJECT,NGMOENVS_BASEDIR,NGMOENVS_COMPILER,NGMOENVS_MPI,NGMOENVS_BASEIMAGE,NGMOENVS_MOSRS_MIRROR,NGMOENVS_SPACK_MIRROR,CONDA_BLD_PATH,APPTAINER,MKSQUASHFS,SPACK_DOWNLOAD_ONLY=true \
    -- bash "$SITE_DIR/install-stage-one.sh" "$ENVIRONMENT"
)
echo "$STAGE1"

# Second stage does the spack builds
qsub \
    -N "ngmoenvs2-$ENVIRONMENT" \
    -P "$PROJECT" \
    -q normal \
    -l ncpus=8 \
    -l walltime=1:00:00 \
    -l mem=32gb \
    -l jobfs=50gb \
    -l storage=gdata/access+gdata/ki32 \
    -l wd \
    -j oe \
    -m ae \
    -W umask=0022 \
    -v PROJECT,NGMOENVS_BASEDIR,NGMOENVS_COMPILER,NGMOENVS_MPI,NGMOENVS_BASEIMAGE,NGMOENVS_MOSRS_MIRROR,NGMOENVS_SPACK_MIRROR,CONDA_BLD_PATH,APPTAINER,MKSQUASHFS,SPACK_DOWNLOAD_ONLY=true \
    -W "depend=afterok:$STAGE1" \
    -- bash "$SITE_DIR/install-stage-two.sh" "$ENVIRONMENT"

MODULE="$NGMOENVS_BASEDIR/modules/$ENVIRONMENT"

mkdir -p "$(dirname "$MODULE")"
cat > "$MODULE" << EOF
#%Module1.0

set name         "$ENVIRONMENT"
set version      "$(git describe --always)"
set origin       "$(git remote get-url origin)"
set install_date "$(date --iso=minute)"
set installed_by "$USER - $(getent passwd "$USER" | cut -d ':' -f 5)"
set prefix       "$INSTALL_ENVDIR"

proc ModulesHelp {} {
    global name version origin install_date installed_by

    puts stderr "NGMO Environment \$name/\$version"
    puts stderr "  Install info:"
    puts stderr "    repo: \$origin"
    puts stderr "    rev:  \$version"
    puts stderr "    date: \$install_date"
    puts stderr "    by:   \$installed_by"
}

set name_upcase [string toupper [string map {- _} \$name]]

setenv \${name_upcase}_ROOT "\$prefix"
setenv \${name_upcase}_VERSION "\$version"

prepend-path PATH "\$prefix/bin"
EOF

mkdir -p "$INSTALL_ENVDIR/bin"
cp "$SITE_DIR/envrun" "$INSTALL_ENVDIR/bin"
chmod +x "$INSTALL_ENVDIR/bin/envrun"

cat <<EOF

Once PBS jobs are complete load the environment with

    module use "$NGMOENVS_BASEDIR/modules"
    module load "$ENVIRONMENT"
EOF
