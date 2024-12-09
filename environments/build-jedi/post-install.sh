#!/bin/bash

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

# Add FMS
echo "CPATH=$(spack find --format '{prefix}' fms)/include_r4:\$CPATH" >> $SPACK_ROOT/bin/activate-full.sh
