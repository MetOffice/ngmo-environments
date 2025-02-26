#!/bin/bash

set -eu
set -o pipefail

# Use conda pip to install flash-attn with cuda managed by Spack activated
# Execute `pip install` only during stage 1 with Internet 
if [[ -v NGMOENVS_DOWNLOAD_ONLY ]]; then
    # Activate the spack environment
    spack env activate "$ENVDIR/spack"
    spack env status
    spack install cuda@12.6.2
    spack load cuda

    echo $NGMOENVS_ENVDIR
#    $NGMOENVS_ENVDIR/conda/bin/pip install anemoi_inference==0.3.3 anemoi_models==0.2.1 anemoi_transform==0.1.0 \
#    anemoi_utils==0.4.9 earthkit_data==0.11.4 earthkit_geo==0.3.0 earthkit_meteo==0.3.0 earthkit_regrid==0.3.4 \
#    Cartopy==0.24.1 ecmwf_opendata==0.3.14 
    $NGMOENVS_ENVDIR/conda/bin/pip install flash-attn==2.7.2.post1 --no-cache-dir --no-build-isolation
fi