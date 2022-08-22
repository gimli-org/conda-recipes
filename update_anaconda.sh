#!/bin/bash
# If you experience problems with downloading third party sources you can specifiy a local source path for copy them from instead downloading them
# export GIMLI_THIRDPARTY_SRC=

conda build purge # remove intermediate builds

anaconda login
conda config --set anaconda_upload yes

##Build e.g., conda build -c conda-forge --python 3.8 pgcore

for pkg in pgcore; do
    for py in 3.10 3.9 3.8; do
        name=`conda build $pkg --python $py --output`
        echo "Building $name"
        sleep 3
        conda build -c conda-forge --python $py $pkg
    done
done
