#!/bin/bash
#
# Run an environment test case
#
#     tests/run.sh $ENVIRONMENT

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

# shellcheck source=utils/common.sh
source "$SCRIPT_DIR/../utils/common.sh"

ENVIRONMENT="$1"
export ENVIRONMENT
SITE="${2:-${NGMOENVS_SITE:-generic}}"

: "${NGMOENVS_BASEDIR:="/scratch/$PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

if [[ ! -d "$SCRIPT_DIR/../environments/$ENVIRONMENT" ]]; then
	error "Unknown environment $ENVIRONMENT"
	exit 1
fi

echo "Testing $ENVIRONMENT at site $SITE"

if [[ -f "$SCRIPT_DIR/site/$SITE.sh" ]]; then
	# Run the site-specific test
	"$SCRIPT_DIR/site/$SITE.sh" "$ENVIRONMENT"
else
	if [[ ! -f "$SCRIPT_DIR/envs/$ENVIRONMENT.sh" ]]; then
		error "No test for environment $ENVIRONMENT"
		exit 1
	fi

	# Default path
	export PATH="$NGMOENVS_BASEDIR/envs/$ENVIRONMENT/bin:$PATH"

	export BASEDIR="${TMPDIR:-/tmp}/ngmo-envs-test/$ENVIRONMENT"
	mkdir -p "$BASEDIR"

	/bin/bash "$SCRIPT_DIR/envs/${ENVIRONMENT}.sh"
fi

