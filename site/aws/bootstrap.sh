#!/bin/bash

# Prepare an amazonlinux instance for building ngmo environments

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

# Install system dependencies
sudo dnf install -y gcc g++ gfortran patch libtool

# Base directory for spack and mamba
: "${NGMOENVS_BASEDIR:="$HOME/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Run the common bootstrap to install conda and spack
"$SCRIPT_DIR/../../utils/bootstrap.sh"
