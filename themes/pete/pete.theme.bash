#!/bin/bash

# prompt themeing
PROMPT="(\t) \$(prompt_char) [\[$blue\]\u\[$normal_color\]@\[$green\]\h\[$reset_color\]] \[$yellow\]\w\[$reset_color\]\$(git_prompt_info)\$(rvm_version_prompt) \$\[$reset_color\] "

GIT_THEME_PROMPT_DIRTY=" ✗"
GIT_THEME_PROMPT_CLEAN=" ✓"
GIT_THEME_PROMPT_PREFIX=" ("
GIT_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
