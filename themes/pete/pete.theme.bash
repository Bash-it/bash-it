#!/bin/bash

prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  PS1="(\t) $(prompt_char) [\[$blue\]\u\[$reset_color\]@\[$green\]\H\[$reset_color\]] \[$yellow\]\w\[$reset_color\]$(git_prompt_info)$(rvm_version_prompt) $\[$reset_color\] "
  PS2='> '
  PS4='+ '
}

PROMPT_COMMAND=prompt_setter

GIT_THEME_PROMPT_DIRTY=" ✗"
GIT_THEME_PROMPT_CLEAN=" ✓"
GIT_THEME_PROMPT_PREFIX=" ("
GIT_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
