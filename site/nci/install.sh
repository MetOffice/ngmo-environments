#!/bin/bash

set -eu
set -o pipefail

SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

export ENVIRONMENT="$1"

: "${NGMOENVS_BASEDIR:="/scratch/$PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Version defaults to current git branch
: "${VERSION="$(git symbolic-ref --short HEAD)"}"
export VERSION

# Path to install the environment to on the local machine
: "${NGMOENVS_ENVDIR:="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/$VERSION"}"
export NGMOENVS_ENVDIR
INSTALL_ENVDIR=$NGMOENVS_ENVDIR

# Path for modulefiles
: "${NGMOENVS_MODULE:="$NGMOENVS_BASEDIR/modules/$ENVIRONMENT/$VERSION"}"

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Default compiler and MPI
: "${NGMOENVS_COMPILER:="intel@2021.10.0"}"
: "${NGMOENVS_MPI:="openmpi@4.1.5"}"
export NGMOENVS_COMPILER NGMOENVS_MPI

# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

QSUB_FLAGS=(
    -P "$PROJECT" \
    -l jobfs=50gb \
    -l storage=gdata/access+gdata/ki32 \
    -l wd \
    -j oe \
    -W umask=0022 \
    -v PROJECT,NGMOENVS_BASEDIR,NGMOENVS_COMPILER,NGMOENVS_MPI,NGMOENVS_SPACK_MIRROR,CONDA_BLD_PATH,SPACK_DOWNLOAD_ONLY=true,INSTALL_ENVDIR="${INSTALL_ENVDIR}" \
)

if ! [[ -v NGMOENVS_DEBUG ]]; then
    set +e

    # Run the apptainer build in the queue
    # First stage is everything requiring networking - only download spack sources
    JOBID=$(e qsub \
        -N "ngmoenvs1-$ENVIRONMENT" \
        -q copyq \
        -l ncpus=1 \
        -l walltime=1:00:00 \
        -l mem=4gb \
        "${QSUB_FLAGS[@]}" \
        -W block=true \
        -- bash "$SITE_DIR/install-stage-one.sh" "$ENVIRONMENT")
    EXIT=$?

    if ! [[ $EXIT -eq 0 ]]; then
        error "Building stage 1"
        exit $EXIT
    fi

    # Second stage does the spack builds
    JOBID=$(e qsub \
        -N "ngmoenvs2-$ENVIRONMENT" \
        -q normal \
        -l ncpus=8 \
        -l walltime=1:00:00 \
        -l mem=32gb \
        -l jobfs=50gb \
        "${QSUB_FLAGS[@]}" \
        -W block=true \
        -- bash "$SITE_DIR/install-stage-two.sh" "$ENVIRONMENT")
    EXIT=$?

    if ! [[ $EXIT -eq 0 ]]; then
        error "Building stage 2"
        exit $EXIT
    fi

    set -e
else

    echo Run: "$SITE_DIR/install-stage-two.sh" "$ENVIRONMENT"

    qsub \
        -N "ngmoenvs2-$ENVIRONMENT" \
        -q normal \
        -l ncpus=8 \
        -l walltime=2:00:00 \
        -l mem=32gb \
        -l jobfs=50gb \
        "${QSUB_FLAGS[@]}" \
        -I
fi

mkdir -p "$(dirname "$NGMOENVS_MODULE")"
cat > "$NGMOENVS_MODULE" << EOF
#%Module1.0

set name         "$ENVIRONMENT"
set version      "$VERSION"
set origin       "$(git remote get-url origin) $(git rev-parse HEAD)"
set install_date "$(date --iso=minute)"
set installed_by "$USER - $(getent passwd "$USER" | cut -d ':' -f 5)"
set prefix       "$INSTALL_ENVDIR"

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

mkdir -p "$INSTALL_ENVDIR/bin"

for script in envrun envrun-wrapped; do
    cp "$SITE_DIR/$script" "$INSTALL_ENVDIR/bin"
    chmod +x "$INSTALL_ENVDIR/bin/$script"
done

# Old launcher name
ln -sf "envrun" "$INSTALL_ENVDIR/bin/imagerun"

# Make rose commands run inside the container
ln -sf "envrun-wrapped" "$INSTALL_ENVDIR/bin/rose"

cat <<EOF

Environment build complete

Load the environment with

    module load "$NGMOENVS_MODULE"

Prepend commands with 'envrun' to run them in the container
EOF
