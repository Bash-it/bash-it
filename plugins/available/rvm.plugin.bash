#!/bin/bash

# Load RVM, if you are using it
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Load the auto-completion script if RVM was loaded.
if [ "$rvm_path" ]
then
    [[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion
fi

switch () {
  rvm $1
  local v=$(rvm_version)
  rvm wrapper $1 textmate
  echo "Switch to Ruby version: "$v
}

rvm_default () {
  rvm --default $1
  rvm wrapper $1 textmate
}

function rvm_version () {
  ruby --version
}