#!/bin/bash
conda build purge # remove intermediate builds

anaconda login
for pkg in pygimli pybert; do
    for py in 3.6 3.7; do
    name=`conda build $pkg --python $py --output`
    echo "Building $name"
    sleep 5
    conda build -c defaults -c conda-forge --python $py $pkg && anaconda upload --force $name
done
done
