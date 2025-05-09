#!/bin/bash
#
# Run an environment test case at Pawsey
#
#     tests/run.sh $ENVIRONMENT setonix

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

ENVIRONMENT="$1"

# Grab $VERSION
source "$SCRIPT_DIR/../../utils/common.sh"

# Load the environment
module purge
module load pawsey pawseyenv
module use "/scratch/$PAWSEY_PROJECT/$USER/ngmo-envs/modules"
module load "$ENVIRONMENT/$VERSION"
module list

# Set up run directory
export BASEDIR="/scratch/$PAWSEY_PROJECT/$USER/tmp/ngmo-envs-test/$ENVIRONMENT"
mkdir -p "$BASEDIR"

# Run the test
/bin/bash "$SCRIPT_DIR/../envs/${ENVIRONMENT}.sh"
