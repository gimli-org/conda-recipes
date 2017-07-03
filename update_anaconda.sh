#!/bin/bash
export PATH=~/miniconda3:$PATH
rm -f ~/miniconda3/conda-bld/*.tar.bz2

anaconda login
for py in 3.6 3.5 2.7; do
    for pkg in pygimli pybert; do
        for numpy in 1.12 1.13; do
            params="$pkg --python $py --numpy $numpy"
            name=`conda build $params --output`
            echo "Building $name"
            sleep 5
            conda build -c conda-forge $params && anaconda upload --force $name
        done
    done
done
