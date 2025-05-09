#!/bin/bash
#
# Run an environment test case
#
#     tests/run.sh $ENVIRONMENT $SITE

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

# shellcheck source=utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

ENVIRONMENT="$1"
export ENVIRONMENT

# Try to detect the site
if [[ $(hostname -f) =~ gadi.nci.org.au$ ]]; then
    NGMOENVS_SITE=pawsey
elif [[ $(hostname -f) =~ setonix.pawsey.org.au$ ]]; then
    NGMOENVS_SITE=pawsey
fi

SITE="${2:-${NGMOENVS_SITE:-generic}}"

if [[ ! -d "$SCRIPT_DIR/../environments/$ENVIRONMENT" ]]; then
	error "Unknown environment $ENVIRONMENT"
	exit 1
fi

if [[ ! -f "$SCRIPT_DIR/envs/$ENVIRONMENT.sh" ]]; then
        error "No test for environment $ENVIRONMENT"
        exit 1
fi

echo "Testing $ENVIRONMENT at site $SITE"

if [[ -f "$SCRIPT_DIR/site/$SITE.sh" ]]; then
	# Run the site-specific test
	"$SCRIPT_DIR/site/$SITE.sh" "$ENVIRONMENT"

else
        # Generic scripts without site specifics
        : "${NGMOENVS_BASEDIR:="~/ngmo-envs"}"
        export NGMOENVS_BASEDIR

	# Default path
	export PATH="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/bin:$PATH"

	export BASEDIR="${TMPDIR:-/tmp}/ngmo-envs-test/$ENVIRONMENT"
	mkdir -p "$BASEDIR"

	/bin/bash "$SCRIPT_DIR/envs/${ENVIRONMENT}.sh"
fi

