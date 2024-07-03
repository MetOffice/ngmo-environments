#!/bin/bash

# Install a specific environment

set -eu
set -o pipefail
SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

# Enviornment to install
export ENVIRONMENT="$1"

# Base directory for environments
: "${NGMOENVS_BASEDIR:="$HOME/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Path to base of this repo
export NGMOENVS_DEFS=${SITE_DIR}/../..

# Run the generic build script
"$NGMOENVS_DEFS/utils/install-onestage.sh"
