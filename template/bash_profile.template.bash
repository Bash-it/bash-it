#!/bin/bash

# Load RVM, if you are using it
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

# Add rvm gems and nginx to the path
export PATH=$PATH:~/.gem/ruby/1.8/bin:/opt/nginx/sbin

# Path to the bash it configuration
export BASH=$HOME/.bash_it

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_THEME='bobby'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Set my editor and git editor
export EDITOR="/usr/bin/mate -w"
export GIT_EDITOR='/usr/bin/mate -w'

# Set the path nginx
export NGINX_PATH='/opt/nginx'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to the path of your local jekyll root to use the jekyll aliases

export JEKYLL_LOCAL_ROOT="~/Sites/mrminimalist"

# And change this to the remote server and root

export JEKYLL_REMOTE_ROOT="user@server:/path/to/jekyll/root"

# Change this to your console based IRC client of choice.

export IRC_CLIENT='irssi'

# Load Bash It
source $BASH/bash_it.sh
