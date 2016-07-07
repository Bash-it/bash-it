#!/bin/bash

# Two line prompt showing the following information:
# (time) SCM [username@hostname] pwd (SCM branch SCM status) 
# → 
#
# Example:
# (14:00:26) ± [foo@bar] ~/.bash_it (master ✓) 
# → 
#
# The arrow on the second line is showing the exit status of the last command:
# * Green: 0 exit status
# * Red: non-zero exit status
#
# The exit code functionality currently doesn't work if you are using the 'fasd' plugin,
# since 'fasd' is messing with the $PROMPT_COMMAND


PROMPT_END_CLEAN="${green}→${reset_color}"
PROMPT_END_DIRTY="${red}→${reset_color}"

function prompt_end() {
  echo -e "$PROMPT_END"
}

prompt_setter() {
  local exit_status=$?
  if [[ $exit_status -eq 0 ]]; then PROMPT_END=$PROMPT_END_CLEAN
    else PROMPT_END=$PROMPT_END_DIRTY
  fi
  # Save history
  history -a
  history -c
  history -r
  PS1="(\t) $(scm_char) [${blue}\u${reset_color}@${green}\H${reset_color}] ${yellow}\w${reset_color}$(scm_prompt_info) ${reset_color}\n$(prompt_end) "
  PS2='> '
  PS4='+ '
}

safe_append_prompt_command prompt_setter

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
