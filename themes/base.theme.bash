#!/bin/bash

# Normal Colors
GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
BLUE=$'\e[0;34m'
WHITE=$'\e[1;37m'
BLACK=$'\e[0;30m'
YELLOW=$'\e[0;33m'
PURPLE=$'\e[0;35m'
CYAN=$'\e[0;36m'
GRAY=$'\e[1;30m'
PINK=$'\e[37;1;35m'
ORANGE=$'\e[33;40m'

# Revert color back to the normal color
NORMAL=$'\e[00m'

# LIGHT COLORS
LIGHT_BLUE=$'\e[1;34m'
LIGHT_GREEN=$'\e[1;32m'
LIGHT_CYAN=$'\e[1;36m'
LIGHT_RED=$'\e[1;31m'
LIGHT_PURPLE=$'\e[1;35m'
LIGHT_YELLOW=$'\e[1;33m'
LIGHT_GRAY=$'\e[0;37m'


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