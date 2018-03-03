#!/bin/bash
export PATH=~/miniconda3:$PATH
conda build purge # remove intermediate builds

anaconda login
for py in 3.6 3.5; do
    for numpy in 1.14 1.13; do
        for pkg in pygimli pybert; do
            params="$pkg --python $py --numpy $numpy"
            name=`conda build $params --output`
            echo "Building $name"
            sleep 5
            conda build --skip-existing -c conda-forge $params && anaconda upload --force $name
        done
    done
done
