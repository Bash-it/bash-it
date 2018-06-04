SCM_THEME_PROMPT_PREFIX=${SCM_THEME_PROMPT_SUFFIX}
SCM_THEME_PROMPT_DIRTY="${bold_red} ✗${normal}"
SCM_THEME_PROMPT_CLEAN="${bold_green} ✓${normal}"
SCM_GIT_CHAR="${green}±${normal}"

scm_prompt() {
    CHAR=$(scm_char)
    if [ $CHAR = $SCM_NONE_CHAR ]
        then
            return
        else
            echo " [$(scm_char)$(scm_prompt_info)]"
    fi
}

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
  PS1="$(user_host_path_prompt)$(virtualenv_prompt)$(scm_prompt) $(mark_prompt) "
}

share_history() {
  history -a
  history -c
  history -r
}

safe_append_prompt_command share_history
safe_append_prompt_command prompt
