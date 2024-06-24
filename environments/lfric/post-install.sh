#!/bin/bash

set -eu
set -o pipefail

# Allow FCM keyword location to be configurable
# TODO: This should instead be in the fcm recipe
cat > $NGMENVS_ENVDIR/spack/.spack-env/view/etc/fcm/keyword.cfg <<EOF
include = \$FCM_KEYWORDS
EOF
