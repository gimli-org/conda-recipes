#!/bin/bash
conda build purge # remove intermediate builds

anaconda login
for pkg in pgcore; do
#for pkg in pygimli; do
    for py in 3.8 3.7 3.9; do
    name=`conda build $pkg --python $py --output`
    echo "Building $name"
    sleep 5
    conda build -c conda-forge --python $py $pkg && anaconda upload --force $name
done
done
