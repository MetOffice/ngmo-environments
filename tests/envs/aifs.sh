#!/bin/bash

set -eu
set -o pipefail

cat <<EOF
Running aifs test in $BASEDIR/aifs/aifs-single

EOF

# Grab version of container branch
export SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR
export VERSION="$(git symbolic-ref --short HEAD)"
popd

# Check out aifs scripts
[[ -d "$BASEDIR/aifs" ]] || git clone https://git.nci.org.au/bom/cm/aifs_scripts.git "$BASEDIR/aifs"
pushd "$BASEDIR/aifs/aifs-single"

# Test for ICs preparation
qsub << EOF
#-------------------------------------------------------------------------------
#PBS -P dx2
#PBS -q copyq
#PBS -l walltime=00:10:00,mem=10GB,ncpus=1
#PBS -l jobfs=10GB
#PBS -l storage=gdata/dx2+scratch/dx2+gdata/rt52+gdata/dk92+gdata/ux62+gdata/wr45
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER,NGMOENVS_BASEDIR" 
#PBS -N prepare_ICs_test_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#PBS -W block=true
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "$NGMOENVS_BASEDIR/modules"
module load "$ENVIRONMENT/$VERSION"
module list

envrun ./prepare_ICs.py opendata_aifs.yaml

#-------------------------------------------------------------------------------
EOF
EXIT=$?

if ! [[ $EXIT -eq 0 ]]; then
    error "Preparing ICs"
    exit $EXIT
fi

# Download model weights (needs Internet and would abort with no gpu found error)
set +e
qsub << EOF
#-------------------------------------------------------------------------------
#PBS -P dx2
#PBS -q copyq
#PBS -l walltime=00:10:00,mem=50GB,ncpus=1
#PBS -l jobfs=50GB
#PBS -l storage=gdata/dx2+scratch/dx2
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER,NGMOENVS_BASEDIR" 
#PBS -N download_model_weights_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#PBS -W block=true
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "$NGMOENVS_BASEDIR/modules"
module load "$ENVIRONMENT/$VERSION"
module list

envrun ./run_AIFS.py opendata_aifs.yaml

#-------------------------------------------------------------------------------
EOF

# Test for running AIFS model
set -e
qsub << EOF
#-------------------------------------------------------------------------------
#PBS -P dx2
#PBS -q dgxa100
#PBS -l walltime=00:10:00,mem=50GB,ncpus=16,ngpus=1
#PBS -l jobfs=10GB
#PBS -l storage=gdata/dx2+scratch/dx2
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER,NGMOENVS_BASEDIR" 
#PBS -N run_model_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#PBS -W block=true
#-------------------------------------------------------------------------------

# Load the environment
module purge
# dgxa100 needs intel-mkl module for gpus to be available for pytorch
module load intel-mkl/2023.2.0
module use "$NGMOENVS_BASEDIR/modules"
module load "$ENVIRONMENT/$VERSION"
module list

envrun ./run_AIFS.py opendata_aifs.yaml

#-------------------------------------------------------------------------------
EOF
EXIT=$?

if ! [[ $EXIT -eq 0 ]]; then
    error "Run model"
    exit $EXIT
fi

# Test for post-processing

qsub << EOF
#-------------------------------------------------------------------------------
#PBS -P dx2
#PBS -q normal
#PBS -l walltime=00:20:00,mem=100GB,ncpus=4
#PBS -l jobfs=50GB
#PBS -l storage=gdata/dx2+scratch/dx2+gdata/rt52
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER,NGMOENVS_BASEDIR" 
#PBS -N postprocess_test_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#PBS -W block=true
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "$NGMOENVS_BASEDIR/modules"
module load "$ENVIRONMENT/$VERSION"
module list

envrun ./postprocess_forecast.py opendata_aifs.yaml

#-------------------------------------------------------------------------------
EOF
EXIT=$?

if ! [[ $EXIT -eq 0 ]]; then
    error "Postprocessing"
    exit $EXIT
fi

cat <<EOF

$ENVIRONMENT successfully ran!
EOF





