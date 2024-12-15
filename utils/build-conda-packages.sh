#!/bin/bash

set -eu
set -o pipefail

# shellcheck source=utils/common.sh
source "$SCRIPT_DIR/common.sh"

# Builds conda packages required for an environment

for PKGDIR in "$NGMOENVS_DEFS/conda/"*; do
	PKGNAME="$(basename "$PKGDIR")"

	if ! grep "\<$PKGNAME\>" "$ENVDEFS/conda.yaml" > /dev/null; then
		# Package not required
		continue
	fi

	if [[ ! -f "$(e conda build -c conda-forge --output "$PKGDIR")" ]]; then
		# Package needs to be built (will autobuild dependencies)
		e "$CONDA_EXE" build -c conda-forge "$PKGDIR"

                # Clean up any builds
                e "$CONDA_EXE" build purge
	fi

done
