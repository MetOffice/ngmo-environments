#!/bin/bash

# Builds Spack packages for two-stage builds
#
# `install-stage-one.sh` should have been run first with
# $NGMOENVS_DOWNLOAD_ONLY defined

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SCRIPT_DIR

# shellcheck source=utils/common.sh
source "$SCRIPT_DIR/common.sh"

# Activate the environment
e spack env activate "$NGMOENVS_ENVDIR/spack"

# Disable external bootstrap repos
e spack bootstrap disable github-actions-v0.5
e spack bootstrap disable github-actions-v0.4

e spack config blame

# Solve dependencies again in case node type changed
e spack concretize --fresh --force

# Install everything
if ! e spack install; then

    # Push completed packages to cache
    e spack buildcache push ngmo-spack-local $(spack find --format '/{hash}')
    exit 1
fi

# Run the post-install with the environment in place
export ENVDEFS="${NGMOENVS_DEFS}/environments/${ENVIRONMENT}"
if [[ -f "$ENVDEFS/post-install.sh" ]]; then
	e "$ENVDEFS/post-install.sh"
fi
