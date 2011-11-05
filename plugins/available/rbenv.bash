#!/bin/bash

# Load rbebv, if you are using it
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Check to make sure that RVM is actually loaded before adding
# the customizations to it.
if [ "$rvm_path" ]
then
    # Load the auto-completion script if rbenv was loaded.
    source ~/.rbenv/completions/rbenv.bash
fi