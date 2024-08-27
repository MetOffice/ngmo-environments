#!/bin/bash
set -ex

${PYTHON} -m pip install -vv --no-deps --no-build-isolation ./um_spiral_search
${PYTHON} -m pip install -vv --no-deps --no-build-isolation ./um_packing
${PYTHON} -m pip install -vv --no-deps --no-build-isolation ./mule
${PYTHON} -m pip install -vv --no-deps --no-build-isolation ./um_ppibm
${PYTHON} -m pip install -vv --no-deps --no-build-isolation ./um_utils
