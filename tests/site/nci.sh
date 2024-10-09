#!/bin/bash
#
# Run an environment test case at NCI
#
#     tests/run.sh $NGMO_ENVIRONMENT

set -eu
set -o pipefail
set -x

: ${NGMO_ENVIRONMENT:="$1"}
: ${BASEDIR:="$TMPDIR/ngmo-envs-test/$NGMO_ENVIRONMENT"}
export NGMO_ENVIRONMENT
export BASEDIR

# Load the environment
module purge
module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"
module load "$NGMO_ENVIRONMENT"

if [[ ! -v PBS_ENVIRONMENT ]]; then
    # Only works outside of PBS
    SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
    export SCRIPT_DIR

    # Not running in the queue
    mkdir -p "$BASEDIR"

    # Run stage one
    export TEST_STAGE="one"
    /bin/bash "$SCRIPT_DIR/../envs/${NGMO_ENVIRONMENT}.sh"

    # Submit stage two
    qsub \
        -P $PROJECT \
        -N "ngmoenvs-test-$NGMO_ENVIRONMENT" \
        -l ncpus=8,mem=64gb,walltime=1:00:00,jobfs=20gb,wd \
        -v BASEDIR,NGMO_ENVIRONMENT,SCRIPT_DIR \
        -j oe \
        "$SCRIPT_DIR/nci.sh"

else
    # Running stage two in the queue
    export TEST_STAGE="two"
    /bin/bash "$SCRIPT_DIR/../envs/${NGMO_ENVIRONMENT}.sh"
fi

