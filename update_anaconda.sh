#!/bin/bash
export PATH=~/miniconda3/bin:$PATH
conda build purge # remove intermediate builds

anaconda login
for pkg in pygimli pybert; do
    name=`conda build $pkg --output`
    echo "Building $name"
    sleep 5
    #conda build --skip-existing -c defaults -c conda-forge $pkg && anaconda upload --force $name
    conda build -c defaults -c conda-forge $pkg && anaconda upload --force $name
done
