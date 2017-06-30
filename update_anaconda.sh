#!/bin/bash
export PATH=~/miniconda3:$PATH
rm -f ~/miniconda3/conda-bld/*.tar.bz2

anaconda login
for py in 3.6 3.5 2.7; do
    for pkg in pybert; do
        name=`conda build $pkg --output --python $py`
        echo "Building $name"
        sleep 5
        conda build -c conda-forge $pkg --python $py && anaconda upload --force $name
    done
done
