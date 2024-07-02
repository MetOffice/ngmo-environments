#!/bin/bash

set -eu
set -o pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

e() {
	echo "$@"
	"$@"
}

# Builds conda packages required for an environment

for PKGDIR in "$NGMOENVS_DEFS/conda/"*; do
	PKGNAME="$(basename $PKGDIR)"

	if ! grep "\<$PKGNAME\>" "$ENVDEFS/conda.yaml" > /dev/null; then
		# Package not required
		continue
	fi

	if [[ ! -f "$(conda build -c conda-forge --output "$PKGDIR")" ]]; then
		# Package needs to be built (will autobuild dependencies)
		e $CONDA_EXE build -c conda-forge "$PKGDIR"
	fi

done
