#!/bin/bash


GREEN='\[\033[0;32m\]'
RED='\[\033[0;31m\]'
BLUE='\[\033[0;34m\]'
PINK='\[\e[37;1;35m\]'
WHITE='\[\033[1;37m\]'
BLACK='\[\033[0;30m\]'
YELLOW='\[\033[0;33m\]'
PURPLE='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'
GRAY='\[\033[1;30m\]'
NORMAL='\[\033[00m\]'

LIGHT_BLUE='\[\033[1;34m\]'
LIGHT_GREEN='\[\033[1;32m\]'
LIGHT_CYAN='\[\033[1;36m\]'
LIGHT_RED='\[\033[1;31m\]'
LIGHT_PURPLE='\[\033[1;35m\]'
LIGHT_YELLOW='\[\033[1;33m\]'
LIGHT_GRAY='\[\033[0;37m\]'

# Stole these from Steve Losh
# TODO: 
D=$'\e[37;40m'
PINK=$'\e[35;40m'
GREEN=$'\e[32;40m'
ORANGE=$'\e[33;40m'

# Stolen from Steve Losh
function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    echo '○'
}

function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "*"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/[\1$(parse_git_dirty)]/"
}