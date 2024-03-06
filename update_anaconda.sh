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

echo "purging old builds ..."
conda build purge # remove intermediate builds
echo "... done"

# check if already logged in
# manuell log off with 'anaconda logout'
conda mambabuild -c conda-forge $PKG --skip-existing
