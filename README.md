# Conda build recipes for GIMLi
[![Anaconda-Server Badge](https://anaconda.org/gimli/pygimli/badges/installer/conda.svg)](https://conda.anaconda.org/gimli) [![Anaconda-Server Badge](https://anaconda.org/gimli/pygimli/badges/downloads.svg)](https://anaconda.org/gimli/pygimli)

This repository contains recipes to build GIMLi (http://www.gimli.org) and its
dependencies using the cross-platform package manager conda
(http://conda.pydata.org/).

## Installation
Compiled packages can be found on our Anaconda channel
(https://anaconda.org/gimli/pygimli) and installed by:

``` bash
conda install -c gimli pygimli
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
conda install conda-build # necessary to build packages
conda config --add channels http://conda.binstar.org/gimli
conda build pygimli
conda install anaconda-client # necessary to upload packages to binstar.org
```


## License

The recipe is licensed under the MIT terms
(http://opensource.org/licenses/MIT). License information on GIMLi itself can
be found here: http://www.pygimli.org/COPYING.html#sec-license.
