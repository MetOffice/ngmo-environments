#!/bin/bash

# Builds conda packages required for an environment

for PKGDIR in "$SCRIPT_DIR/../../packages/conda/"*; do
	PKGNAME="$(basename $PKGDIR)"

	if ! grep "\<$PKGNAME\>" "$ENVDEFS/conda.yaml" > /dev/null; then
		# Package not required
		continue
	fi

	if [[ ! -f "$(conda build --output "$PKGDIR")" ]]; then
		# Package needs to be built (will autobuild dependencies)
		e conda build "$PKGDIR"
	fi

done
