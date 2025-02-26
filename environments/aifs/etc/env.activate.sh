#!/bin/bash

SPACK_ENV_VIEW=$SPACK_ENV/.spack-env/view

export LDMPI=mpifort
export FPP="cpp -traditional"
export FFLAGS="${FFLAGS:-} -I$SPACK_ENV_VIEW/include -I$SPACK_ENV_VIEW/lib"
export PFUNIT=$SPACK_ENV_VIEW
export LIBRARY_PATH=$SPACK_ENV_VIEW/lib:$LIBRARY_PATH

