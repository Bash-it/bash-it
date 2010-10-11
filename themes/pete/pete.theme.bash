#!/bin/bash

# prompt themeing
PROMPT="(\t) \$(prompt_char) [\[$bold_blue\]\u\[$white\]@\[$green\]\h\[$white\]] \[$bold_yellow\]\w\[$white\]\$(git_prompt_info)\$(rvm_version_prompt) \\$\[$reset_color\] "

GIT_THEME_PROMPT_DIRTY=" ✗"
GIT_THEME_PROMPT_CLEAN=" ✓"
GIT_THEME_PROMPT_PREFIX=" ("
GIT_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
