#!/bin/bash

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
#unset LD_LIBRARY_PATH
#unset PYTHONPATH
export CONDA_BUILD=1

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

export LIBRARY_PATH=${PREFIX}/lib
export INCLUDE_PATH=${PREFIX}/include

py=$(echo $PY_VER | sed -e 's/\.//g')

# Install castxml from binary to avoid any clang/llvm related issues
if [ "$(uname)" == "Darwin" ];
then
    # for Mac OSX
    curl -O https://midas3.kitware.com/midas/download/item/318762/castxml-macosx.tar.gz
    tar -xzf castxml-macosx.tar.gz
    export BLAS=libopenblas.dylib
    export PYTHONSPECS=-DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython${PY_VER}m.dylib
    export BOOST=-DBoost_PYTHON_LIBRARY=${CONDA_PREFIX}/lib/libboost_python3.dylib
elif [ "$(uname)" == "Linux" ]
then
    # for Linux
    curl -O https://midas3.kitware.com/midas/download/item/318227/castxml-linux.tar.gz
    tar -xzf castxml-linux.tar.gz
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

export CASTXML=`pwd`/castxml/bin/castxml
CMAKE_FLAGS="-DCASTER_EXECUTABLE=$CASTXML"

export AVOID_GIMLI_TEST=1

pushd $GIMLI_BUILD

    export LDFLAGS="-L${PREFIX}/lib"
    export CPPFLAGS="-I${PREFIX}/include"
    export CMAKE_PREFIX_PATH=${CONDA_PREFIX}

    CLEAN=1 cmake $GIMLI_SOURCE $PYTHONSPECS $BOOST $CMAKE_FLAGS \
        -DCMAKE_LD_FLAGS='-L${CONDA_PREFIX}/lib/' \
        -DCMAKE_SHARED_LINKER_FLAGS='-L${CONDA_PREFIX}/lib/' \
        -DCMAKE_EXE_LINKER_FLAGS='-L${CONDA_PREFIX}/lib/' \
        -DCMAKE_CXX_FLAGS='-I${CONDA_PREFIX}/include' \
        -DAVOID_CPPUNIT=TRUE \
        -DCMAKE_INSTALL_PREFIX=$PREFIX \
        -DCMAKE_INSTALL_LIBDIR=$PREFIX/lib \
        -DCMAKE_INCLUDE_PATH=$INCLUDE_PATH \
        -DCMAKE_LIBRARY_PATH=$LIBRARY_PATH \
        -DAVOID_READPROC=TRUE \
        -DLAPACK_LIBRARIES=${CONDA_PREFIX}/lib/$BLAS \
        -DBLAS_LIBRARIES=${CONDA_PREFIX}/lib/$BLAS || (cat CMakeFiles/CMakeError.log && exit 1)

    make -j$PARALLEL_BUILD VERBOSE=1
    make apps -j$PARALLEL_BUILD
    make pygimli J=$PARALLEL_BUILD
popd

# Make conda find GIMLi libraries and executables
echo "Installing at .. " $PREFIX
# C++ part
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp -v $GIMLI_BUILD/lib/*.so $PREFIX/lib

if [ "$(uname)" == "Darwin" ];
then
    # for Mac OSX
    cp -v $GIMLI_BUILD/lib/*.dylib $PREFIX/lib
fi

mv -v $GIMLI_SOURCE/src $PREFIX/include/gimli # header files for bert
#cp -v $GIMLI_BUILD/bin/* $PREFIX/bin
# Python part
pushd $GIMLI_SOURCE/python
     python setup.py install --prefix $PREFIX
popd
