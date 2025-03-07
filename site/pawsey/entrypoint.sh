#!/bin/bash

# Isolate Spack
export SPACK_DISABLE_LOCAL_CONFIG=true

NGMOENVS_CONTAINER_BASEDIR=''
NGMOENVS_ENVIRONMENT=''

# Activate the base environment
source "$NGMOENVS_CONTAINER_BASEDIR/bin/activate"

# Activate the actual environment
if [[ -f "$NGMOENVS_CONTAINER_BASEDIR/envs/$NGMOENVS_ENVIRONMENT/bin/activate" ]]; then
    source "$NGMOENVS_CONTAINER_BASEDIR/envs/$NGMOENVS_ENVIRONMENT/bin/activate" 
fi

# Run the given command
exec "$@"
