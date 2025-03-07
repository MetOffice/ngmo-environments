#!/bin/bash

#set -eu
#set -o pipefail
#
## Use conda pip to install flash-attn with cuda managed by Spack activated
## Execute `pip install` only during stage 1 with Internet 
#if [[ -v NGMOENVS_DOWNLOAD_ONLY ]]; then
#    # Activate the spack environment
#    spack env activate "$ENVDIR/spack"
#    spack install cuda@12.6.2
#    spack load cuda
#
#    # Use conda environment pip to install flash-attn
#    $NGMOENVS_ENVDIR/conda/bin/pip install flash-attn==2.7.2.post1 --no-cache-dir --no-build-isolation
#fi
