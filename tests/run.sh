#!/bin/bash
#
# Run an environment test case
#
#     tests/run.sh $ENVIRONMENT

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

ENVIRONMENT="$1"

export PATH="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/bin:$PATH"

export BASEDIR="${TMPDIR:-/tmp}/ngmo-envs-test/lfric"
mkdir -p "$BASEDIR"

/bin/bash "$SCRIPT_DIR/test_${ENVIRONMENT}.sh"
