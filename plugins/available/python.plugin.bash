#!/bin/bash

if [ $(uname) = "Linux" ]
then
  alias http='python2 -m SimpleHTTPServer'
else
  alias http='python -m SimpleHTTPServer'
fi

