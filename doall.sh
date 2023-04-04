#!/bin/bash
# If you experience problems with downloading third party sources you can specifiy a local source path for copy them from instead downloading them
# export GIMLI_THIRDPARTY_SRC=
#
# Perform manual build e.g., conda build -c conda-forge --python 3.8 pgcore
#
function help(){
    echo "usage: ${0##*/} package [py]"
    echo "############################"
    echo "Examples:"
    echo "bash ${0##*/} pgcore # pgcore for all supported python versions"
    echo "bash ${0##*/} pgcore 3.10 # pgcore for python-3.10"
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
    echo 'Anaconda already logged in.'
fi
}

# no argument -> help
[ $# -lt 1 ] && help 

PKG=$1

[ $# -gt 1 ] && ALLPY=$2 || ALLPY=(3.8 3.9 3.10, 3.11)
[ $# -gt 2 ] && ALLNP=$3 || ALLNP=(1.20 1.21 1.22, 1.23)

echo "Building package: $PKG for py=${ALLPY[@]} np=${ALLNP[@]}"

echo "purging old builds ..."
conda build purge # remove intermediate builds
echo "... done"

# check if already logged in
# manually log off with 'anaconda logout'
ensureAnacondaLogin
if [[ $PKG = *pgcore* ]]; then
    for PY in ${ALLPY[@]}; do
        for NP in ${ALLNP[@]}; do
            echo "Generating build name for $PKG (py=$PY, np=$NP)..."
            name=`conda build $PKG --python $PY --numpy $NP --output`
            echo "Building $name"
            sleep 1
            conda mambabuild -c conda-forge --python $PY --numpy $NP $PKG
        done
    done
else
    echo "Generating building name for $PKG ..."
    name=`conda build $PKG --output`
    echo "Building $name"
    sleep 1
    conda mambabuild -c conda-forge $PKG
fi

