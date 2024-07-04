#!/bin/bash

# Builds Spack packages for two-stage builds
#
# `install-stage-one.sh` should have been run first with
# $NGMOENVS_DOWNLOAD_ONLY defined

set -eu
set -o pipefail

e() {
	echo "$@"
	"$@"
}

# Activate the environment
e spack env activate "$NGMOENVS_ENVDIR/spack"

# Solve dependencies again in case node type changed
e spack concretize --fresh --force

# Install everything
e spack install

# Run the post-install with the environment in place
export ENVDEFS="${NGMOENVS_DEFS}/environments/${ENVIRONMENT}"
if [[ -f "$ENVDEFS/post-install.sh" ]]; then
	e "$ENVDEFS/post-install.sh"
fi
