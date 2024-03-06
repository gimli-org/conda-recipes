#!/bin/bash

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
unset PYTHONPATH
unset CMAKE_PREFIX_PATH

PYTHON_EXEC=$(which python3)
PYTHON_INC=$(python3 -c 'import sysconfig; print(sysconfig.get_path("include"))')
PYTHON_LIB=$(python3-config --configdir)

export CPLUS_INCLUDE_PATH=$PYTHON_INC

GIMLI_ROOT=$(pwd)
export GIMLI_BUILD=$GIMLI_ROOT/build
export GIMLI_SOURCE=$GIMLI_ROOT/gimli
mkdir -p $GIMLI_BUILD

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT
export PARALLEL_BUILD=$PARALLEL_BUILD-2 # Number of CPUs -2

export UPDATE_ONLY=0
export BRANCH=dev

# Python version without point, i.e. "36".
py=$(echo $PY_VER | sed -e 's/\.//g')

# Mac specific
declare -a CMAKE_PLATFORM_FLAGS
if [ "$(uname)" == "Darwin" ]; then
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"
  CMAKE_PLATFORM_FLAGS+=(-DCMAKE_OSX_SYSROOT="${CONDA_BUILD_SYSROOT}")
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  skiprpath=""
  sysroot=""
fi

export SYSTEM_VERSION_COMPAT=1

export BLAS=libopenblas${SHLIB_EXT}
export PYTHONSPECS=-DPYTHON_LIBRARY=${CONDA_PREFIX}/lib/libpython${PY_VER}${SHLIB_EXT}
export BOOST=-DBoost_PYTHON_LIBRARY=${CONDA_PREFIX}/lib/libboost_python${py}${SHLIB_EXT}

export AVOID_GIMLI_TEST=1

pushd $GIMLI_BUILD

rm -rf CMakeCache.txt

CLEAN=1 cmake $GIMLI_SOURCE $BOOST $PYTHONSPECS $skiprpath \
  -DPYTHON_EXECUTABLE=$PYTHON_EXEC -DPYTHON_LIBRARY=$PYTHON_LIB -DPYTHON_INCLUDE_DIR=$PYTHON_INC \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DPYTHON_EXECUTABLE=$PREFIX/bin/python \
  -DAVOID_CPPUNIT=TRUE \
  "${CMAKE_PLATFORM_FLAGS[@]}" \
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
cp -v $GIMLI_SOURCE/core/src/*.h $PREFIX/include/gimli # header files for bert
mkdir -p $PREFIX/include/gimli/bert
cp -v $GIMLI_SOURCE/core/src/bert/*.h $PREFIX/include/gimli/bert # header files for bert
# Python part
cp -v $GIMLI_SOURCE/pygimli/core/*.so $GIMLI_ROOT/pgcore/pgcore

export PYTHONUSERBASE=$PREFIX
pushd $GIMLI_ROOT/pgcore
python setup.py install --user
popd
