SCM_THEME_PROMPT_PREFIX=${SCM_THEME_PROMPT_SUFFIX}
SCM_THEME_PROMPT_DIRTY="${bold_red} ✗${normal}"
SCM_THEME_PROMPT_CLEAN="${bold_green} ✓${normal}"
SCM_GIT_CHAR="${green}±${normal}"

mark_prompt() {
    echo "${green}\$${normal}"
}

user_host_path_prompt() {
    ps_user="${green}\u${normal}";
    ps_host="${blue}\H${normal}";
    ps_path="${yellow}\w${normal}";
    echo "$ps_user@$ps_host:$ps_path"
}

prompt() {
  SCM_PROMPT_FORMAT=' [%s%s]'
  PS1="$(user_host_path_prompt)$(virtualenv_prompt)$(scm_prompt) $(mark_prompt) "
}

share_history() {
  history -a
  history -c
  history -r
}

safe_append_prompt_command share_history
safe_append_prompt_command prompt
