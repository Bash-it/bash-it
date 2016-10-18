#!/usr/bin/env bash

source "$BASH_IT/themes/doubletime/doubletime.theme.bash"

function prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  PS1="
$(clock_prompt) $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color] $(virtualenv_prompt)$(ruby_version_prompt)
\w
$(doubletime_scm_prompt)$reset_color $ "
  PS2='> '
  PS4='+ '
}

safe_append_prompt_command prompt_setter
