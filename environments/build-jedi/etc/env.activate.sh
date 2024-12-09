#!/bin/bash

export CPATH="$SPACK_VIEW/include_r8:${CPATH:-}"
export LIBRARY_PATH="$SPACK_VIEW/lib64:$SPACK_VIEW/lib:${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="$SPACK_VIEW/lib64:$SPACK_VIEW/lib:${LD_LIBRARY_PATH:-}"
