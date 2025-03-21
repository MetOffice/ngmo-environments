#!/bin/bash
#
# Run an environment test case at NCI
#
#     tests/run.sh $ENVIRONMENT

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

ENVIRONMENT="$1"

# Grab $VERSION
source "$SCRIPT_DIR/../../utils/common.sh"

# Load the environment
module purge
module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"
module load "$ENVIRONMENT/$VERSION"
module list

# Set up run directory
export BASEDIR="$TMPDIR/ngmo-envs-test/$ENVIRONMENT"
mkdir -p "$BASEDIR"

# Run the test
/bin/bash "$SCRIPT_DIR/../envs/${ENVIRONMENT}.sh"
