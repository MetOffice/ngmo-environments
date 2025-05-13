#!/bin/bash

# Install the environment at NCI outside of a container for development

set -eu
set -o pipefail

SITE_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
export SITE_DIR

# Enviornment to install
export ENVIRONMENT="$1"

# shellcheck source=site/nci/env.sh
source "$SITE_DIR/env.sh"

# Load bootstrap conda and spack
if [[ -f "$NGMOENVS_BASEDIR/bin/activate" ]]; then
    # shellcheck disable=SC1091
    source "$NGMOENVS_BASEDIR/bin/activate"
fi

export PATH=/apps/python3/3.11.7/bin:$PATH

# Run the generic build script
"$NGMOENVS_DEFS/utils/install-stage-one.sh"

# Add local customisations to activate
cat >> "$NGMOENVS_ENVDIR/bin/activate" <<EOF

# Local FCM keyword file
export FCM_KEYWORDS=/g/data/hr22/apps/etc/fcm/mosrs/keyword.cfg
EOF

# shellcheck source=site/nci/post-install.sh
bash "$SITE_DIR/post-install.sh"
