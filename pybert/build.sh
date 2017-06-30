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

mkdir gimli
cd gimli
mkdir build
git clone https://github.com/gimli-org/gimli
cd gimli
git checkout dev
cd ../build

if [ $PY3K -eq 1 ]; then
    export CONDAPATH="~/miniconda3"
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython3.so
    export BOOST=-DBoost_PYTHON_LIBRARY=$CONDAPATH/lib/libboost_python3.so
else
    export CONDAPATH="~/miniconda2"
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython2.7.so
fi

export AVOID_GIMLI_TEST=1

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CMAKE_PREFIX_PATH=$PREFIX

CLEAN=1 cmake $BERT_ROOT/gimli/gimli $PYTHONSPECS $BOOST $CMAKE_FLAGS \
    -DCMAKE_SHARED_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
    -DCMAKE_EXE_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
    -DAVOID_CPPUNIT=TRUE \
    -DAVOID_READPROC=TRUE\
    -DLAPACK_LIBRARIES=$PREFIX/lib/libopenblas.so \
    -DBLAS_LIBRARIES=$PREFIX/lib/libopenblas.so
make -j$PARALLEL_BUILD

pushd $BERT_BUILD
    export LDFLAGS="-L${PREFIX}/lib"
    export CPPFLAGS="-I${PREFIX}/include"
    export CMAKE_PREFIX_PATH=$PREFIX

    # HACK
    CLEAN=1 cmake $BERT_SOURCE \
        -DCMAKE_SHARED_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DCMAKE_EXE_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DGIMLI_LIBRARIES='../../gimli/build/lib/libgimli.so'
    make -j$PARALLEL_BUILD bert1 dcinv dcmod dcedit
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
