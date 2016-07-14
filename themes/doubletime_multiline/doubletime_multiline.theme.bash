#!/usr/bin/env bash

source "$BASH_IT/themes/doubletime/doubletime.theme.bash"

function prompt_setter() {
  # Save history
  history -a
  history -c
  history -r
  if [[ -z "$THEME_PROMPT_CLOCK_FORMAT" ]]
  then
      clock="\t"
  else
      clock=$THEME_PROMPT_CLOCK_FORMAT
  fi
  PS1="
$clock $(scm_char) [$THEME_PROMPT_HOST_COLOR\u@${THEME_PROMPT_HOST}$reset_color] $(virtualenv_prompt)$(ruby_version_prompt)
\w
$(doubletime_scm_prompt)$reset_color $ "
  PS2='> '
  PS4='+ '
}

safe_append_prompt_command prompt_setter
