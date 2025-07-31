#!/bin/bash

SPACK_ENV_VIEW=$SPACK_ENV/.spack-env/view

export jedi_cmake_ROOT="$SPACK_ENV_VIEW"
export CPATH="$SPACK_ENV_VIEW/include_r8:$CPATH"
export LD_LIBRARY_PATH="$SPACK_ENV_VIEW/lib64:$LD_LIBRARY_PATH"
