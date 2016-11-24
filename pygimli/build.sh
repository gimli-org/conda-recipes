#!/bin/sh

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
#unset LD_LIBRARY_PATH
#unset PYTHONPATH

GIMLI_ROOT=$(pwd)
export GIMLI_BUILD=$GIMLI_ROOT/gimli/build
export GIMLI_SOURCE=$GIMLI_ROOT/gimli/gimli
mkdir -p $GIMLI_SOURCE
mv !(gimli) $GIMLI_SOURCE
mkdir -p $GIMLI_BUILD

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT

export PARALLEL_BUILD=$PARALLEL_BUILD
export UPDATE_ONLY=0
export BRANCH=dev

#export CASTXML=~/src/gimli/thirdParty/dist-GNU-4.8.4-64/bin/castxml
#export CASTXML=~/git/gimli/thirdParty/dist-Clang-3.8.1-64/bin/castxml

if [ $PY3K -eq 1 ]; then
    export CONDAPATH="~/miniconda3"
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython3.so
else
    export CONDAPATH="~/miniconda2"
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython2.7.so
fi

export AVOID_GIMLI_TEST=1

pushd $GIMLI_BUILD

    export LDFLAGS="-L${PREFIX}/lib"
    export CPPFLAGS="-I${PREFIX}/include"
    export CMAKE_PREFIX_PATH=$PREFIX

    CLEAN=1 cmake $GIMLI_SOURCE $PYTHONSPECS \
        -DCMAKE_SHARED_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DCMAKE_EXE_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DAVOID_CPPUNIT=TRUE \
        -DAVOID_READPROC=TRUE\
        -DLAPACK_LIBRARIES=$PREFIX/lib/libopenblas.so \
        -DBLAS_LIBRARIES=$PREFIX/lib/libopenblas.so
    make -j$PARALLEL_BUILD

    make apps -j$PARALLEL_BUILD
    make pygimli J=$PARALLEL_BUILD
popd

# Make conda find GIMLi libraries and executables
echo "Installing at .. " $PREFIX
# C++ part
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp -v $GIMLI_BUILD/lib/*.so $PREFIX/lib
#cp -v $GIMLI_BUILD/bin/* $PREFIX/bin
# Python part
pushd $GIMLI_SOURCE/python
     python setup.py install --prefix $PREFIX
popd
