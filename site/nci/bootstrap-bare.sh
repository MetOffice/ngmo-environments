#!/bin/bash

set -eu
set -o pipefail

SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

ENVIRONMENT="none"

# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

# Run the generic bootstrap script
"$NGMOENVS_DEFS/utils/bootstrap.sh"

cat >> $NGMOENVS_BASEDIR/bin/activate <<EOF
export SPACK_PYTHON=/apps/python3/3.11.7/bin/python3
EOF

source $NGMOENVS_BASEDIR/bin/activate

# Configure Spack to use NCI system packages
e spack config --scope=site add -f "${SITE_DIR}/spack-packages.yaml"
e spack config --scope=site add -f "${SITE_DIR}/spack-compilers.yaml"

# Set up bootstraps
BOOTSTRAP=${NGMOENVS_SPACK_MIRROR#file://}/bootstrap
e spack bootstrap mirror "$BOOTSTRAP"
e spack bootstrap add --scope=site --trust local "$BOOTSTRAP/metadata/sources"
e spack bootstrap root --scope=site "${BOOTSTRAP}_cache"
