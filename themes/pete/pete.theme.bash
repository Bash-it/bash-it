# shellcheck shell=bash

prompt_setter() {
  # Save history
  _save-and-reload-history 1
  PS1="($(clock_prompt)) $(scm_char) [$blue\u$reset_color@$green\H$reset_color] $yellow\w${reset_color}$(scm_prompt_info)$(ruby_version_prompt) $reset_color "
  PS2='> '
  PS4='+ '
}

safe_append_prompt_command prompt_setter

SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
RVM_THEME_PROMPT_PREFIX=" ("
RVM_THEME_PROMPT_SUFFIX=")"
