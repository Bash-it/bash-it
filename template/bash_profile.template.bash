#!/bin/bash

# Load RVM
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Add rvm gems and nginx to the path
export PATH=$PATH:~/.gem/ruby/1.8/bin:/opt/nginx/sbin

# Path to the bash it configuration
export BASH=$HOME/.bash_it
export LOAD_COLORS=$BASH/themes/base.theme.bash

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_THEME='bobby'

# Load the color configuration file, if you want to add colors to the GIT THEME PROMPTs
source $LOAD_COLORS

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'
export GIT_THEME_PROMPT_DIRTY=' ${RED}✗${LIGHT_GREEN}' # This shows how to use sample the colors
export GIT_THEME_PROMPT_CLEAN=' ✓'
export GIT_THEME_PROMPT_PREFIX='('
export GIT_THEME_PROMPT_SUFFIX=')'

# Set my editor and git editor
export EDITOR="/usr/bin/mate -w" 
export GIT_EDITOR='/usr/bin/mate -w'

# Set the path nginx
export NGINX_PATH='/opt/nginx'

# Don't check mail when opening terminal.
unset MAILCHECK

# Load Bash It
source $BASH/bash_it.sh
