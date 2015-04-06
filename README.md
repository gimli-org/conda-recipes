# Conda build recipes for GIMLi

This repository contains recipes to build GIMLi (http://www.gimli.org) and its
dependencies using the cross-platform package manager conda
(http://conda.pydata.org/).

## Installation
Compiled packages can be found on our Binstar channel
(https://binstar.org/giml) and installed by:

``` bash
conda install -c gimli pygimli
```

## Creating a new release

``` bash
git clone https://github.com/gimli-org/conda-recipes
cd conda-recipes
conda install conda-build # necessary to build packages
conda config --add channels http://conda.binstar.org/menpo # for boost & suitesparse
conda build pygimli
conda install binstar # necessary to upload packages to binstar.org
```


## License

The recipe is licensed under the MIT terms (http://opensource.org/licenses/MIT). License information on GIMLi itself can be found here: http://www.pygimli.org/COPYING.html#sec-license.
