#!/bin/bash

set -eu
set -o pipefail

SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

export ENVIRONMENT="$1"

# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

QSUB_FLAGS=(
    -P "$PROJECT" \
    -l jobfs=50gb \
    -l storage=gdata/access+gdata/ki32 \
    -l wd \
    -j oe \
    -W umask=0022 \
    -v "PROJECT,NGMOENVS_BASEDIR,NGMOENVS_COMPILER,NGMOENVS_MPI,NGMOENVS_SPACK_MIRROR,CONDA_BLD_PATH,SPACK_DOWNLOAD_ONLY=true,INSTALL_ENVDIR=${INSTALL_ENVDIR}" \
)

if ! [[ -v NGMOENVS_DEBUG ]]; then
    set +e

    # Run the apptainer build in the queue
    # First stage is everything requiring networking - only download spack sources
    e qsub \
        -N "ngmoenvs1-$ENVIRONMENT" \
        -q copyq \
        -l ncpus=1 \
        -l walltime=1:30:00 \
        -l mem=4gb \
        "${QSUB_FLAGS[@]}" \
        -W block=true \
        -- bash "$SITE_DIR/install-stage-one.sh" "$ENVIRONMENT"
    EXIT=$?

    if ! [[ $EXIT -eq 0 ]]; then
        error "Building stage 1"
        exit $EXIT
    fi

    # Second stage does the spack builds
    e qsub \
        -N "ngmoenvs2-$ENVIRONMENT" \
        -q normal \
        -l ncpus=8 \
        -l walltime=2:00:00 \
        -l mem=32gb \
        -l jobfs=50gb \
        "${QSUB_FLAGS[@]}" \
        -W block=true \
        -- bash "$SITE_DIR/install-stage-two.sh" "$ENVIRONMENT"
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

# shellcheck source=site/nci/post-install.sh
e bash "$SITE_DIR/post-install.sh"
