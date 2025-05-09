#!/bin/bash
# Set up Pawsey Setonix to build environments

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

: "${NGMOENVS_BASEDIR:="/scratch/$PAWSEY_PROJECT/$USER/ngmo-envs"}"
export NGMOENVS_BASEDIR

# Cache paths
: "${NGMOENVS_SPACK_MIRROR:="file://$NGMOENVS_BASEDIR/spack-mirror"}"
: "${CONDA_BLD_PATH:="$NGMOENVS_BASEDIR/conda-bld"}"
export NGMOENVS_SPACK_MIRROR
export CONDA_BLD_PATH

# Run the common bootstrap to install conda and spack
"$SCRIPT_DIR/../../utils/bootstrap.sh"

# Load up spack
source "$NGMOENVS_BASEDIR/bin/activate"

# Configure spack
spack config --scope=site add -f "$SCRIPT_DIR/spack-packages.yaml"
spack config --scope=site add -f "$SCRIPT_DIR/spack-compilers.yaml"
