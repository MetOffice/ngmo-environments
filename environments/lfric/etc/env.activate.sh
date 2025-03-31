#!/bin/bash

SPACK_ENV_VIEW=$SPACK_ENV/.spack-env/view

export FCM_KEYWORDS=${FCM_KEYWORDS:-$NGMOENVS_ENVDIR/etc/fcm-keyword.cfg}
export FPP="cpp -traditional"
export FFLAGS="${FFLAGS:-} -I$SPACK_ENV_VIEW/include -I$SPACK_ENV_VIEW/lib"
export LDFLAGS="-L$SPACK_ENV_VIEW/lib"
export PFUNIT=$SPACK_ENV_VIEW

# Handle Cray linking with ftn rather than mpifort
if [[ "$(basename "$FC")" == "ftn" ]]; then
    export LDMPI=$FC
else
    export LDMPI=mpifort
fi
