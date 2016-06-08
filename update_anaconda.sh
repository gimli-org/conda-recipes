#!/bin/bash
export PATH=~/miniconda3:$PATH
anaconda login
conda build --python 3.5 pygimli && anaconda upload --force ~/miniconda3/conda-bld/linux-64/pygimli-1.0rc-py35_0.tar.bz2
conda build --python 3.5 pybert && anaconda upload --force ~/miniconda3/conda-bld/linux-64/pybert-2.0-py35_0.tar.bz2
