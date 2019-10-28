#!/bin/bash

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
unset PYTHONPATH

GIMLI_ROOT=$(pwd)
export GIMLI_BUILD=$GIMLI_ROOT/gimli/build
export GIMLI_SOURCE=$GIMLI_ROOT/gimli/gimli
mkdir -p $GIMLI_SOURCE
mv !(gimli) $GIMLI_SOURCE
mkdir -p $GIMLI_BUILD

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT

export PARALLEL_BUILD=$PARALLEL_BUILD/2
export UPDATE_ONLY=0
export BRANCH=dev

py=$(echo $PY_VER | sed -e 's/\.//g')

# Install castxml from binary to avoid any clang/llvm related issues
if [ "$(uname)" == "Darwin" ];
then
    export BLAS=libopenblas.dylib
    export PYTHONSPECS=-DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython${PY_VER}m.dylib
    export BOOST=-DBoost_PYTHON_LIBRARY=${CONDA_PREFIX}/lib/libboost_python3.dylib
elif [ "$(uname)" == "Linux" ]
then
    export BLAS=libopenblas.so
    if [ $PY3K -eq 1 ]; then
        export PYTHONSPECS=-DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython${PY_VER}m.so
        export BOOST=-DBoost_PYTHON_LIBRARY=${CONDA_PREFIX}/lib/libboost_python$py.so
    else
        export PYTHONSPECS=-DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython$PY_VER.so
        export BOOST=-DBoost_PYTHON_LIBRARY=${CONDA_PREFIX}/lib/libboost_python$py.so
    fi
else
    echo "This system is unsupported by our toolchain."
    exit 1
fi

export AVOID_GIMLI_TEST=1

pushd $GIMLI_BUILD

    CLEAN=1 cmake $GIMLI_SOURCE $BOOST \
          -DCMAKE_PREFIX_PATH=$CONDA_PREFIX \
          -DAVOID_CPPUNIT=TRUE \
          -DAVOID_READPROC=TRUE || (cat CMakeFiles/CMakeError.log && exit 1)

    make -j$PARALLEL_BUILD #VERBOSE=0
    #make apps -j$PARALLEL_BUILD
    make pygimli J=$PARALLEL_BUILD
popd

# Make conda find GIMLi libraries and executables
echo "Installing at .. " $PREFIX
# C++ part
#mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp -v $GIMLI_BUILD/lib/*.so $PREFIX/lib

if [ "$(uname)" == "Darwin" ];
then
    # for Mac OSX
    cp -v $GIMLI_BUILD/lib/*.dylib $PREFIX/lib
fi

mkdir -p $PREFIX/include/gimli
mv -v $GIMLI_SOURCE/src $PREFIX/include/gimli # header files for bert
#cp -v $GIMLI_BUILD/bin/* $PREFIX/bin
# Python part
export PYTHONUSERBASE=$PREFIX
pushd $GIMLI_SOURCE/python
     python setup.py install --user
popd
