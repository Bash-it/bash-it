#!/usr/bin/env bash

prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  PS1="$yellow(\t)$reset_color $(scm_char) [$cyan\u$reset_color@$green\H$reset_color] $blue\w${reset_color}$red$(scm_prompt_info)$reset_color # "
  PS2='> '
  PS4='+ '
}

PROMPT_COMMAND=prompt_setter

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${red}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${red}"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
