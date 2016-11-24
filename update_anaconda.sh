#!/bin/bash
export PATH=~/miniconda3:$PATH
rm -f ~/miniconda3/conda-bld/*.tar.bz2

anaconda login
for py in 3.5 3.4 2.7; do
    conda build --python $py pygimli && anaconda upload --force ~/miniconda3/conda-bld/linux-64/pygimli-1.1rc-py${py//./}_0.tar.bz2
    conda build --python $py pybert && anaconda upload --force ~/miniconda3/conda-bld/linux-64/pybert-2.1.2-py${py//./}_0.tar.bz2
done
