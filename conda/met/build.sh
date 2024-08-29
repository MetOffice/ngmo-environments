#!/bin/bash
#  Copyright 2024 Bureau of Meteorology
#  Author Scott Wales

set -eu
set -o pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "$(readlink -f ${BASH_SOURCE[0]})" )" &> /dev/null && pwd )

export MET_PYTHON_BIN_EXE=$(which python3)
export MET_PYTHON_CC=$(python3-config --includes)
export MET_PYTHON_LD=-lpython${PY_VER}

export MET_FREETYPEINC=$PREFIX/include/freetype2
export MET_FREETYPELIB=$PREFIX/lib
export MET_CAIROINC=$PREFIX/include/cairo
export MET_CAIROLIB=$PREFIX/lib

export GRIB2CLIB_NAME=-lg2c
export BUFRLIB_NAME=-lbufr_4

env | grep MET


./configure \
    --enable-python \
    --enable-lidar2nc \
    --enable-modis \
    --enable-mode_graphics \
    --enable-grib2 \
    --prefix=$PREFIX

# Force using Conda's ar
for mk in $(find . -name Makefile); do
    sed -e '/^AR = ar$/d' -i $mk
done

make

make install

make test
