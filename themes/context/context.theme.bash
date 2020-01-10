#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${bold_red}⊘${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_THEME_PROMPT_PREFIX="${reset_color}( "
SCM_THEME_PROMPT_SUFFIX=" ${reset_color})"

GIT_THEME_PROMPT_DIRTY=" ${bold_red}⊘${normal}"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
GIT_THEME_PROMPT_PREFIX="${reset_color}( "
GIT_THEME_PROMPT_SUFFIX=" ${reset_color})"

STATUS_THEME_PROMPT_BAD="${bold_red}❯${reset_color}${normal} "
STATUS_THEME_PROMPT_OK="${bold_green}❯${reset_color}${normal} "
CONTEXT_THEME_PROMPT_COLOR="${CONTEXT_THEME_PROMPT_COLOR:=$blue}"

function k8s_context_prompt {
  if _command_exists kubectl; then
    current_context="$(kubectl config current-context 2> /dev/null)"
    if [[ -n "${current_context}" ]]; then
      echo "(${bold_blue}Kube-Context:${normal} ${current_context})"
    fi
  fi
}

function prompt_command() {
    local ret_status="$( [ $? -eq 0 ] && echo -e "$STATUS_THEME_PROMPT_OK" || echo -e "$STATUS_THEME_PROMPT_BAD")"
    PS1="\n${CONTEXT_THEME_PROMPT_COLOR}\w $(scm_prompt_info) $(k8s_context_prompt)\n${ret_status} "
}

safe_append_prompt_command prompt_command
