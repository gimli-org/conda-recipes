#!/bin/bash

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
unset LD_LIBRARY_PATH
unset PYTHONPATH

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT

export PARALLEL_BUILD=$PARALLEL_BUILD
##
# Mac specific                                                                                                                                                                    
if [ "$(uname)" == "Darwin" ]; then                                                                                                                                               
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"                                                                                                                                                     skiprpath="-DCMAKE_SKIP_RPATH=TRUE"                                                                                                                                             
else                                                                                                                                                                              
  skiprpath=""                                                                                                                                                                    
fi        

BERT_ROOT=$(pwd)
export BERT_BUILD=$BERT_ROOT/bert/build
export BERT_SOURCE=$BERT_ROOT/bert/bert
mkdir -p $BERT_SOURCE
mv !(bert) $BERT_SOURCE
mkdir -p $BERT_BUILD

export LDFLAGS="-L${CONDA_PREFIX}/lib"
export CPPFLAGS="-I${CONDA_PREFIX}/include -I${CONDA_PREFIX}/include/gimli"
export CMAKE_PREFIX_PATH=$CONDA_PREFIX

pushd $BERT_BUILD
    cmake $BERT_SOURCE \
        -DGIMLI_LIBRARIES="${CONDA_PREFIX}/lib/libgimli${SHLIB_EXT}" \
        -DGIMLI_INCLUDE_DIR="${CONDA_PREFIX}/include/gimli/src" $skiprpath
    VERBOSE=1 make -j$PARALLEL_BUILD bert1 dcinv dcmod dcedit
popd

# Make conda find libraries and executables
echo "Installing at .. " $PREFIX
# C++ part
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp -v $BERT_BUILD/lib/*${SHLIB_EXT} $PREFIX/lib
cp -v $BERT_BUILD/bin/* $PREFIX/bin
cp -vr $BERT_SOURCE/examples $PREFIX/share
#cp -v ~/git/bert/trunk/doc/tutorial/bert-tutorial.pdf $PREFIX/share
# Python part
pushd $BERT_SOURCE/python
    export PYTHONUSERBASE=$PREFIX
    python setup.py install --user
popd
