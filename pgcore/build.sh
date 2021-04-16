#!/bin/bash

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
unset PYTHONPATH
unset CMAKE_PREFIX_PATH

GIMLI_ROOT=$(pwd)
export GIMLI_BUILD=$GIMLI_ROOT/build
export GIMLI_SOURCE=$GIMLI_ROOT/gimli
mkdir -p $GIMLI_SOURCE
mv !(gimli) $GIMLI_SOURCE
mkdir -p $GIMLI_BUILD

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT
export PARALLEL_BUILD=$PARALLEL_BUILD/2 # only use half of CPUs

export UPDATE_ONLY=0
export BRANCH=dev

# Python version without point, i.e. "36".
py=$(echo $PY_VER | sed -e 's/\.//g')

# Mac specific
if [ "$(uname)" == "Darwin" ]; then
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  skiprpath=""
fi

export BLAS=libopenblas${SHLIB_EXT}
export PYTHONSPECS=-DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython3${SHLIB_EXT}
export BOOST=-DBoost_PYTHON_LIBRARY=${CONDA_PREFIX}/lib/libboost_python${py}${SHLIB_EXT}

export AVOID_GIMLI_TEST=1

pushd $GIMLI_BUILD

CLEAN=1 cmake $GIMLI_SOURCE $BOOST $PYTHONSPECS $skiprpath \
  -DCMAKE_PREFIX_PATH=$CONDA_PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DPYTHON_EXECUTABLE=$PREFIX/bin/python \
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
cp -v $GIMLI_BUILD/lib/*${SHLIB_EXT} $PREFIX/lib

mkdir -p $PREFIX/include/gimli
mv -v $GIMLI_SOURCE/core/src $PREFIX/include/gimli # header files for bert
#cp -v $GIMLI_BUILD/bin/* $PREFIX/bin
# Python part
mv -v $GIMLI_SOURCE/pygimli/core/*${SHLIB_EXT} $GIMLI_ROOT/pgcore/pgcore

export PYTHONUSERBASE=$PREFIX
pushd $GIMLI_ROOT/pgcore
python setup.py install --user
popd
