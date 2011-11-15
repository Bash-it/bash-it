#!/bin/bash

# make sure virtualenvwrapper is enabled if availalbe
[[ `which virtualenvwrapper.sh` ]] && . virtualenvwrapper.sh

# create a new virtualenv for this directory
function mkvenv {
  cwd=`basename \`pwd\``
  mkvirtualenv --no-site-packages --distribute $cwd
}
