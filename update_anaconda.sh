#!/bin/bash
conda build purge # remove intermediate builds

anaconda login
conda config --set anaconda_upload yes

for pkg in pgcore; do
    for py in 3.7; do # 3.9 3.7 3.10; do
    #name=`conda build $pkg --python $py --output`
    #echo "Building $name"
    #sleep 5
    conda build -c conda-forge --python $py $pkg
    done
done
