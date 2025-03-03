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
#PBS -P ${PROJECT}
#PBS -q copyq
#PBS -l walltime=00:20:00,mem=50GB,ncpus=1
#PBS -l jobfs=50GB
#PBS -l storage=gdata/${PROJECT}+scratch/${PROJECT}+gdata/rt52+gdata/dk92+gdata/ux62+gdata/wr45
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER" 
#PBS -N prepare_ICs_test_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"
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
qsub << EOF
#-------------------------------------------------------------------------------
#PBS -P ${PROJECT}
#PBS -q copyq
#PBS -l walltime=00:10:00,mem=50GB,ncpus=1
#PBS -l jobfs=50GB
#PBS -l storage=gdata/${PROJECT}+scratch/${PROJECT}
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER" 
#PBS -N download_model_weights_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"
module load "$ENVIRONMENT/$VERSION"
module list

envrun ./run_AIFS.py opendata_aifs.yaml

#-------------------------------------------------------------------------------
EOF

# Test for running AIFS model
qsub << EOF
#-------------------------------------------------------------------------------
#PBS -P ${PROJECT}
#PBS -q dgxa100
#PBS -l walltime=00:20:00,mem=500GB,ncpus=16,ngpus=1
#PBS -l jobfs=50GB
#PBS -l storage=gdata/${PROJECT}+scratch/${PROJECT}
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER" 
#PBS -N run_model_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"
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
#PBS -P ${PROJECT}
#PBS -q normal
#PBS -l walltime=00:20:00,mem=50GB,ncpus=4
#PBS -l jobfs=50GB
#PBS -l storage=gdata/${PROJECT}+scratch/${PROJECT}+gdata/rt52
#PBS -l wd
#PBS -v "PROJECT,ENVIRONMENT,VERSION,USER" 
#PBS -N prepare_ICs_test_${ENVIRONMENT}
#PBS -W umask=0022
#PBS -j oe
#-------------------------------------------------------------------------------

# Load the environment
module purge
module use "/scratch/$PROJECT/$USER/ngmo-envs/modules"
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

















e qsub \
    -P dx2
    -N "IC-preparation-test-$ENVIRONMENT" \
    -q copyq \
    -l ncpus=1 \
    -l walltime=0:20:00 \
    -l mem=50gb \
    -l storage=gdata/dx2+scratch/dx2+gdata/rt52+gdata/dk92+gdata/ux62+gdata/wr45 \
    -l jobfs=50gb \
    -l wd \
    -j oe \
    -W umask=0022 \
    -- bash "" "$SITE_DIR/install-stage-one.sh" "$ENVIRONMENT"
    EXIT=$?


qsub -I -P dx2 -q normal -l walltime=02:30:00,mem=160GB,storage=gdata/dx2+scratch/dx2+gdata/dp9+scratch/dp9+gdata/rt52+gdata/dk92+gdata/ux62+gdata/wr45,ncpus=32 -l wd
envrun ./prepare_ICs.py opendata_aifs.yaml

# Test for 


if [[ ! -d "$BASEDIR/lfric_core" ]]; then
    envrun fcm co fcm:lfric.xm/trunk "$BASEDIR/lfric_core"

    # Fix for recent ifort
    patch -p0 --forward --directory "$BASEDIR/lfric_core" <<EOF
--- infrastructure/build/fortran/ifort.mk       (revision 50286)
+++ infrastructure/build/fortran/ifort.mk       (working copy)
@@ -33,7 +33,7 @@
 # created. This adds unecessary files to the build so we disable that
 # behaviour.
 #
-FFLAGS_WARNINGS           = -warn all -warn errors -gen-interfaces nosource
+FFLAGS_WARNINGS           = -warn all -gen-interfaces nosource
 FFLAGS_UNIT_WARNINGS      = -warn all -gen-interfaces nosource
 FFLAGS_INIT               = -ftrapuv
EOF
fi

APP=gravity_wave

pushd "$BASEDIR"

# Clean any previous build
rm -rf "$BASEDIR/lfric_apps/applications/$APP/working"

# Build lfric
envrun lfric_apps/build/local_build.py --application "$APP" --core_source "$BASEDIR/lfric_core"

# Run example
pushd "$BASEDIR/lfric_apps/applications/$APP/example"
envrun mpirun -n 6 "../bin/$APP" configuration.nml

cat PET0.*.Log

cat <<EOF

LFRic app $APP successfully ran!
EOF
