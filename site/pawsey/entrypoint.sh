#!/bin/bash

# Isolate Spack
export SPACK_DISABLE_LOCAL_CONFIG=true

# These variables are set during the install process
NGMOENVS_CONTAINER_BASEDIR=''
NGMOENVS_ENVIRONMENT=''

# Add host and cce libraries as a fallback
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/cray/pe/lib64:/opt/cray/pe/lib64/cce:/host/lib64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib64:/host/lib64"

# Activate the base environment
if [[ -f "$NGMOENVS_CONTAINER_BASEDIR/bin/activate" ]]; then
    source "$NGMOENVS_CONTAINER_BASEDIR/bin/activate"
fi

# Activate the actual environment
if [[ -f "$NGMOENVS_CONTAINER_BASEDIR/env/bin/activate" ]]; then
    source "$NGMOENVS_CONTAINER_BASEDIR/env/bin/activate" 
fi

# Run the given command
exec "$@"
