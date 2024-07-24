#!/bin/bash

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

ENVIRONMENT="$1"

module purge

module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"

module load "$ENVIRONMENT"

export BASEDIR="$TMPDIR/ngmo-envs-test/lfric"
mkdir -p "$BASEDIR"

/bin/bash "$SCRIPT_DIR/test_${ENVIRONMENT}.sh"
