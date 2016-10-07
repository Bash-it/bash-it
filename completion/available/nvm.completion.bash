#!/usr/bin/env bash

# nvm (Node Version Manager) completion

if [ -r $NVM_DIR/bash_completion ]
then
  . $NVM_DIR/bash_completion
else
  echo "Enable nvm plugin first"
fi
