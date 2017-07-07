#!/bin/bash

# Build bert conda package. Requires gimli package to be built first.
# conda build pygimli
# conda build --keep-old-work pybert

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
unset LD_LIBRARY_PATH
unset PYTHONPATH

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT

export PARALLEL_BUILD=$PARALLEL_BUILD
##

BERT_ROOT=$(pwd)
export BERT_BUILD=$BERT_ROOT/bert/build
export BERT_SOURCE=$BERT_ROOT/bert/bert
mkdir -p $BERT_SOURCE
mv !(bert) $BERT_SOURCE
mkdir -p $BERT_BUILD

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CMAKE_PREFIX_PATH=$PREFIX

pushd $BERT_BUILD
    cmake $BERT_SOURCE \
        -DCMAKE_SHARED_LINKER_FLAGS="-L$CONDAPATH/envs/_build/lib/" \
        -DCMAKE_EXE_LINKER_FLAGS="-L$CONDAPATH/envs/_build/lib/" \
        -DGIMLI_LIBRARIES="${PREFIX}/lib/libgimli.so" \
        -DGIMLI_INCLUDE_DIR="${PREFIX}/include/gimli"
    VERBOSE=1 make -j$PARALLEL_BUILD bert1 dcinv dcmod dcedit
popd

# Make conda find libraries and executables
echo "Installing at .. " $PREFIX
# C++ part
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp -v $BERT_BUILD/lib/*.so $PREFIX/lib
cp -v $BERT_BUILD/bin/* $PREFIX/bin
cp -vr $BERT_SOURCE/examples $PREFIX/share
#cp -v ~/git/bert/trunk/doc/tutorial/bert-tutorial.pdf $PREFIX/share
# Python part
pushd $BERT_SOURCE/python
     python setup.py install --prefix $PREFIX
popd
