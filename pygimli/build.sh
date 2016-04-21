#!/bin/sh

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
#unset LD_LIBRARY_PATH
#unset PYTHONPATH

export GIMLI_ROOT=$(pwd)
export GIMLI_BUILD=$GIMLI_ROOT/build
export GIMLI_SOURCE=$GIMLI_ROOT/gimli

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT #/2

export PARALLEL_BUILD=$PARALLEL_BUILD
export UPDATE_ONLY=0
export BRANCH=dev
export PYTHON_MAJOR=3
export CONDAPATH="~/miniconda$PYTHON_MAJOR"

#export CASTXML=~/src/gimli/thirdParty/dist-GNU-4.8.4-64/bin/castxml

if [ $PY3K -eq 1 ]; then
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython3.so
else
    export PYTHONSPECS=-DPYTHON_LIBRARY=$CONDAPATH/lib/libpython2.7.so
fi

export AVOID_GIMLI_TEST=1

mkdir $GIMLI_SOURCE
mv !(gimli) $GIMLI_SOURCE

#bash $GIMLI_SOURCE/scripts/install/install_linux_gimli.sh
mkdir -p $GIMLI_BUILD
pushd $GIMLI_BUILD

    export LDFLAGS="-L${PREFIX}/lib"
    export CPPFLAGS="-I${PREFIX}/include"
    export CMAKE_PREFIX_PATH=$PREFIX

    CLEAN=1 cmake $GIMLI_SOURCE $PYTHONSPECS \
        -DCMAKE_SHARED_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DCMAKE_EXE_LINKER_FLAGS='-L$CONDAPATH/envs/_build/lib/' \
        -DCASTER_EXECUTABLE=$CASTXML \
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
