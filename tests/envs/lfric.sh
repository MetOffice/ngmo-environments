#!/bin/bash

set -x
set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )

cat <<EOF
Running lfric_apps test in $BASEDIR

EOF

# Check out lfric source
[[ -d "$BASEDIR/lfric_apps" ]] || envrun fcm co fcm:lfric_apps.xm/trunk "$BASEDIR/lfric_apps"
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

    # Fix for oneapi
    patch -p0 --forward --directory "$BASEDIR/lfric_core" < "$SCRIPT_DIR/lfric-oneapi.patch"
fi

APP=gravity_wave

pushd "$BASEDIR"

# Clean any previous build
# rm -rf "$BASEDIR/lfric_apps/applications/$APP/working"

# Build lfric
envrun lfric_apps/build/local_build.py --application "$APP" --core_source "$BASEDIR/lfric_core"

# Run example
pushd "$BASEDIR/lfric_apps/applications/$APP/example"
# envrun mpirun -n 6 "../bin/$APP" configuration.nml
srun -n 6 envrun "../bin/$APP" configuration.nml

cat PET0.*.Log

cat <<EOF

LFRic app $APP successfully ran!
EOF
