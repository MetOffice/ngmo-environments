#!/bin/bash
set -ex

export LIBDIR_OUT=${PREFIX}
export SHUM_OPENMP=true

# Make sure that the conda-provided toolchain is used
sed -i "s;FPP=cpp;FPP=${CPP};" make/vm-x86-gfortran-gcc.mk
sed -i "/FC=gfortran/d" make/vm-x86-gfortran-gcc.mk
sed -i "/CC=gcc/d" make/vm-x86-gfortran-gcc.mk
sed -i "s;AR=ar;AR=${AR};" make/vm-x86-gfortran-gcc.mk

# Build the libraries
make -f make/vm-x86-gfortran-gcc.mk

# Run tests
make -f make/vm-x86-gfortran-gcc.mk check

# Clean up
make -f make/vm-x86-gfortran-gcc.mk clean-temp
rm -r ${PREFIX}/tests
rm ${PREFIX}/include/{fruit.mod,fruit_util.mod}
rm ${PREFIX}/lib/{libfruit.a,libfruit.so}
