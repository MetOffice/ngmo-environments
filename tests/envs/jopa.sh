#!/bin/bash

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f "${BASH_SOURCE[0]}")" )" &> /dev/null && pwd )


cat <<EOF
Running jopa test in $BASEDIR

EOF

pushd "$BASEDIR"

export jedi_cmake_ROOT=$(envrun spack find --format '{prefix}' jedi-cmake)

if [[ "${TEST_STAGE:-}" != "two" ]]; then
    # Download sources

    if [[ ! -d "$BASEDIR/jedi-bundle" ]]; then
        envrun git clone -b 8.0.0 https://github.com/JCSDA/jedi-bundle
    fi

    #sed -i jedi-bundle/CMakeLists.txt -e '/mom6/D'
    #sed -i jedi-bundle/CMakeLists.txt -e '/soca/s/UPDATE )/UPDATE RECURSIVE )/'

    mkdir -p build
    pushd build


    # Download bundle packages
    envrun ecbuild -- ../jedi-bundle

    # Fixup FMS linking
    sed -i ../jedi-bundle/mom6/CMakeLists.txt \
        -e 's/target_link_libraries(\(.*\) fms)/target_link_libraries(\1 FMS::fms_r8)/'
    sed -i ../jedi-bundle/fv3-jedi-lm/src/CMakeLists.txt \
        -e 's/list( APPEND FV3JEDILM_LIB_DEP fms )/list( APPEND FV3JEDILM_LIB_DEP FMS::fms_r8 )/'
    sed -i ../jedi-bundle/fv3/model/fv_control.F90 \
        -e 's/,\s*INPUT_STR_LENGTH//'
    sed -i ../jedi-bundle/fv3/CMakeLists.txt \
        -e 's/PUBLIC_LIBS\s\+fms/PUBLIC_LIBS FMS::fms_r8/'
    sed -i ../jedi-bundle/soca/src/soca/CMakeLists.txt \
        -e 's/target_link_libraries(\(.*\) fms\s*)/target_link_libraries(\1 FMS::fms_r8)/'

    # Reprocess after patches
    # envrun ecbuild -- ../jedi-bundle

    popd
fi


if [[ "${TEST_STAGE:-}" != "one" ]]; then
    pushd build

    # Build package
    envrun make VERBOSE=1 -j ${PBS_NCPUS:-4}

    popd
fi
