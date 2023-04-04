# Conda build recipes for GIMLi
[![Anaconda-Server Badge](https://anaconda.org/gimli/pygimli/badges/installer/conda.svg)](https://conda.anaconda.org/gimli) [![Anaconda-Server Badge](https://anaconda.org/gimli/pygimli/badges/downloads.svg)](https://anaconda.org/gimli/pygimli)

This repository contains recipes to build GIMLi (http://www.gimli.org) and its
dependencies using the cross-platform package manager conda
(http://conda.pydata.org/).

## Installation
Compiled packages can be found on our Anaconda channel
(https://anaconda.org/gimli/pygimli) and installed by:

``` bash
# Add gimli and conda-forge channels (only once)
conda config --add channels gimli --add channels conda-forge

# Install pygimli
conda install pygimli
```

Please see the installation instructions on www.pygimli.org for more details.

## Creating a new release

``` bash
git clone https://github.com/gimli-org/conda-recipes
cd conda-recipes
conda install -y conda-build boa # necessary to build packages
conda install -y anaconda-client # necessary to upload packages
conda activate base

bash update_anaconda.sh recipePath [pyversion]
```


## License

The recipe is licensed under the MIT terms
(http://opensource.org/licenses/MIT). License information on GIMLi itself can
be found here: http://www.pygimli.org/COPYING.html#sec-license.
