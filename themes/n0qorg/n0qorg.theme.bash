#!/bin/bash
# n0qorg theme by Florian Baumann <flo@noqqe.de>

## look-a-like
# host directory (branch*)»
# for example:
# ananas ~/Code/bash-it/themes (master*)»
PROMPT="${bold_blue}\[\$(hostname)\]${normal} \w${normal} ${bold_white}\[\$(git_prompt_info)\]${normal}» "

## git-theme
# feel free to change git chars.
GIT_THEME_PROMPT_DIRTY="${bold_blue}*${bold_white}"
GIT_THEME_PROMPT_CLEAN=""
GIT_THEME_PROMPT_PREFIX="${bold_blue}(${bold_white}"
GIT_THEME_PROMPT_SUFFIX="${bold_blue})"

## alternate chars
# 
SCM_THEME_PROMPT_DIRTY="*"
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX="("
SCM_THEME_PROMPT_SUFFIX=")"
