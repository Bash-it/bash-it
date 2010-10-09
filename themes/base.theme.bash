#!/bin/bash

# Stolen from Steve Losh
function prompt_char {
    git branch >/dev/null 2>/dev/null && echo -e '±' && return
    hg root >/dev/null 2>/dev/null && echo -e '☿' && return
    echo -e '○'
}

function parse_git_dirty {
  if [[ -n $(git status -s 2> /dev/null) ]]; then
    echo -e "$GIT_THEME_PROMPT_DIRTY"
  else
    echo -e "$GIT_THEME_PROMPT_CLEAN"
  fi
}

function git_prompt_info() {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo -e "$GIT_THEME_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$GIT_THEME_PROMPT_SUFFIX"
}