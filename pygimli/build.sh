#!/bin/bash

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

export PARALLEL_BUILD=$PARALLEL_BUILD/4
export UPDATE_ONLY=0
export BRANCH=dev

# Install castxml from binary to avoid any clang/llvm related issues
if [ "$(uname)" == "Darwin" ];
then
    # for Mac OSX
    curl -O https://midas3.kitware.com/midas/download/item/318762/castxml-macosx.tar.gz
    tar -xzf castxml-macosx.tar.gz
    export BLAS=libopenblas.dylib
    export CONDAPATH="$HOME/miniconda3"
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython3.6m.dylib
    export BOOST=-DBoost_PYTHON_LIBRARY=$CONDAPATH/lib/libboost_python3.dylib
elif [ "$(uname)" == "Linux" ]
then
    # for Linux
    curl -O https://midas3.kitware.com/midas/download/item/318227/castxml-linux.tar.gz
    tar -xzf castxml-linux.tar.gz
    export BLAS=libopenblas.so
    if [ $PY3K -eq 1 ]; then
        export CONDAPATH="~/miniconda3"
        export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython3.so
        export BOOST=-DBoost_PYTHON_LIBRARY=$CONDAPATH/lib/libboost_python3.so
    else
        export CONDAPATH="~/miniconda2"
        export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython2.7.so
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
    export CMAKE_PREFIX_PATH=$PREFIX

    CLEAN=1 cmake $GIMLI_SOURCE $PYTHONSPECS $BOOST $CMAKE_FLAGS \
        -DCMAKE_SHARED_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DCMAKE_EXE_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DAVOID_CPPUNIT=TRUE \
        -DAVOID_READPROC=TRUE \
        -DLAPACK_LIBRARIES=$PREFIX/lib/$BLAS \
        -DBLAS_LIBRARIES=$PREFIX/lib/$BLAS
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
cp -v $GIMLI_BUILD/lib/*.dylib $PREFIX/lib
mv -v $GIMLI_SOURCE/src $PREFIX/include/gimli # header files for bert
#cp -v $GIMLI_BUILD/bin/* $PREFIX/bin
# Python part
pushd $GIMLI_SOURCE/python
     python setup.py install --prefix $PREFIX
popd
