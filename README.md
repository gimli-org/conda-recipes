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

## Building the packages

The recipes use the `recipe.yaml` format and are built with
[`rattler-build`](https://github.com/prefix-dev/rattler-build).

``` bash
git clone https://github.com/gimli-org/conda-recipes
cd conda-recipes

# Install rattler-build
conda install -y -c conda-forge rattler-build

# Build a package (e.g., pgcore or pygimli)
rattler-build build --recipe pgcore/recipe.yaml -c conda-forge
```

Upload the resulting package to the `gimli` channel on anaconda.org with
`rattler-build upload` (see the
[rattler-build authentication and upload docs](https://rattler-build.prefix.dev/latest/authentication_and_upload/#uploading-packages)
for setting up credentials):

``` bash
rattler-build upload anaconda -o gimli output/<subdir>/<package>-<version>-<build>.conda
```


## License

The recipe is licensed under the MIT terms
(http://opensource.org/licenses/MIT). License information on GIMLi itself can
be found here: http://www.pygimli.org/COPYING.html#sec-license.
