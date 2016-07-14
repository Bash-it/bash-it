#!/usr/bin/env bash

SCM_THEME_PROMPT_PREFIX="${cyan} on ${green}"
SCM_THEME_PROMPT_SUFFIX=""
SCM_THEME_PROMPT_DIRTY=" ${red}with changes"
SCM_THEME_PROMPT_CLEAN=""

venv() {
  if [ ! -z "$VIRTUAL_ENV" ]
  then
    local env=$VIRTUAL_ENV
    echo "${gray} in ${orange}${env##*/} "
  fi
}

last_two_dirs() {
  pwd|rev|awk -F / '{print $1,$2}'|rev|sed s_\ _/_|sed "s|$(sed 's,\/,,'<<<$HOME)|~|g"
}

prompt() {
  PS1="${yellow}# ${reset_color}$(last_two_dirs)$(scm_prompt_info)${reset_color}$(venv)${reset_color} ${cyan}\n> ${reset_color}"
}

safe_append_prompt_command prompt
