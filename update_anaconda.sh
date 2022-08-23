#!/bin/bash
# If you experience problems with downloading third party sources you can specifiy a local source path for copy them from instead downloading them
# export GIMLI_THIRDPARTY_SRC=
#
# Perform manual build e.g., conda build -c conda-forge --python 3.8 pgcore
#
function help(){
    echo "usage: ${0##*/} package"
    exit
}

function ensureAnacondaLogin(){
python << END
from subprocess import PIPE, run, sys
def syscall(command):
    result = run(command, stdout=PIPE, stderr=PIPE, 
                 universal_newlines=True, shell=True)
    return result.stdout, result.stderr
out, err = syscall('anaconda whoami')
if 'Anonymous User' in err:
    sys.exit(1)
else:
    sys.exit(0)
END
ret=$?
if [ "$ret" == "1" ]; then
    echo 'Anaconda login needed.'
    anaconda login
    conda config --set anaconda_upload yes
else
    echo 'Anaconda login skipped.'
fi
}

# no argument -> help
[ $# -lt 1 ] && help 

PKG=$1

echo "Building package: $PKG"

echo "purging old builds ..."
conda build purge # remove intermediate builds
echo "... done"

# check if already logged in
# manuell log off with 'anaconda logout'
ensureAnacondaLogin

if [ "$PKG" == "pgcore" ]; then
    #for py in 3.10 3.9 3.8; do
    for PY in 3.9 3.8; do
        echo "Generating building name ..."
        name=`conda build $PKG --python $PY --output`
        echo "Building $name"
        sleep 1
        conda build -c conda-forge --python $PY $PKG
    done
else
    echo "Generating building name ..."
    name=`conda build $PKG --output`
    echo "Building $name"
    sleep 1
    conda build -c conda-forge $PKG
fi

