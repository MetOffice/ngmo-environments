#!/bin/bash

# Install a specific environment

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

# Enviornment to install
ENVIRONMENT="$1"

# Base directory for environments
: ${NGMOENVS_BASEDIR:="$HOME/ngmo-envs"}

# Path to install the environment to
ENVDIR="${NGMOENVS_BASEDIR}/envs/${ENVIRONMENT}"

# Default compiler and MPI
#: ${NGMOENVS_COMPILER:=$(spack spec --format '{compiler.name}@{compiler.version}' mpi)}
#: ${NGMOENVS_MPI:=$(spack spec --format '{name}@{version}' mpi)}

source "$SCRIPT_DIR/../../utils/install-onestage.sh"
