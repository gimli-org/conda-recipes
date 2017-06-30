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
conda install -f pygimli
```

For now this works on:

- [x] Linux (64 bit) [![Build Status](https://travis-ci.org/gimli-org/conda-recipes.svg)](https://travis-ci.org/gimli-org/conda-recipes)
- [ ] Mac OS (64 bit)
- [ ] Windows (32 bit)
- [ ] Windows (64 bit)

## Creating a new release

``` bash
git clone https://github.com/gimli-org/conda-recipes
cd conda-recipes
conda install -y conda-build # necessary to build packages
conda install -y anaconda-client # necessary to upload packages

bash update_anaconda.sh
```


## License

The recipe is licensed under the MIT terms
(http://opensource.org/licenses/MIT). License information on GIMLi itself can
be found here: http://www.pygimli.org/COPYING.html#sec-license.
