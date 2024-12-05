#!/bin/bash

# Install the environment into /g/data/access

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

export ENVIRONMENT="$1"

# Install version
export VERSION=$(date +%y%m)

# Path to install the environment to
export NGMOENVS_ENVDIR=/g/data/access/ngm/envs/$ENVIRONMENT/$VERSION

# Path to install the modulefile to
export NGMOENVS_MODULE=/g/data/access/ngm/modules/$ENVIRONMENT/$VERSION

if [[ -f "$NGMOENVS_ENVDIR" ]]; then
    echo "Environment $ENVIRONMENT alread exists at $NGMOENVS_ENVDIR"
    exit 1
fi

# Run the install script with the pre-set central install paths
$SCRIPT_DIR/install.sh $ENVIRONMENT

