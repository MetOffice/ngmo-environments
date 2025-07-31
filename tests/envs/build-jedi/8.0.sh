#!/bin/bash

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

cat <<EOF
Running jedi test in $BASEDIR

EOF

cd "$BASEDIR"

# Check out jedi-bundle
if ! [[ -d jedi-bundle ]]; then
    git clone https://github.com/JCSDA/jedi-bundle
fi

#if [[ -d build ]]; then rm -r build; fi

#envrun ecbuild --log=DEBUG -S jedi-bundle -B build

envrun cmake --build build -j ${PBS_NCPUS:-1} --verbose
