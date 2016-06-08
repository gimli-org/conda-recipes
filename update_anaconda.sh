#!/bin/bash
export PATH=~/miniconda3:$PATH
anaconda login
for py in 2.7 3.4 3.5; do
    conda build --python $py pygimli && anaconda upload --force ~/miniconda3/conda-bld/linux-64/pygimli-1.0rc-py${py//./}_0.tar.bz2
    conda build --python $py pybert && anaconda upload --force ~/miniconda3/conda-bld/linux-64/pybert-2.0-py${py//./}_0.tar.bz2
done
