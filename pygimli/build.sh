#!/bin/sh

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
mkdir trunk
mv !(trunk) trunk

# Build only on half of the cores to avoid memory overload
declare -i cores
cores=${CPU_COUNT}/2

# otherwise triangle build fails due to missing crt1.o
cp /usr/lib/x86_64-linux-gnu/*.o $PREFIX/lib

# avoid conflict, because this variable is used by conda and buildThirdParty.sh
CONDA_PREFIX=$PREFIX
unset PREFIX

mkdir build
cd build

# Make cmake find dependencies in conda environment rather than system-wide
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib
export CMAKE_PREFIX_PATH=$CONDA_PREFIX

cmake ../trunk

make -j $cores gimli
make pygimli J=$cores
cd apps
make
cd ..

# Make conda find GIMLi libraries and executables

# C++ part
mkdir -p $CONDA_PREFIX/bin
mkdir -p $CONDA_PREFIX/lib
cp -v lib/*.so $CONDA_PREFIX/lib
cp -v bin/* $CONDA_PREFIX/bin

# Python part
cd ../trunk/python
python setup.py install --prefix $CONDA_PREFIX
