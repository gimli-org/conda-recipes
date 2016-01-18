#!/bin/sh

# Copy everything to trunk (necessary because of lib and thirdParty backcopying)
# TODO: We need more flexible structures here (i.e. in the abensence of trunk)
shopt -s extglob
unset LD_LIBRARY_PATH
unset PYTHONPATH

mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

typeset -i PARALLEL_BUILD
PARALLEL_BUILD=$CPU_COUNT #/2

echo "CC = gcc " >> SuiteSparse_config/SuiteSparse_config.mk

echo "INSTALL_LIB = $PREFIX/lib" >> SuiteSparse_config/SuiteSparse_config.mk
echo "INSTALL_INCLUDE = $PREFIX/include" >> SuiteSparse_config/SuiteSparse_config.mk

#         MODULE='.'
#         if [ -n "$1" ]; then
#             MODULES=$1
#         fi
#         echo "Installing $MODULES"
#        pushd $MODULE
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-std=c90 -I${PREFIX}/include"
export CFLAGS="-std=c90 -I${PREFIX}/include"

make -j$PARALLEL_BUILD library
make install
