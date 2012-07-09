#!/usr/bin/env bash
SCM_THEME_PROMPT_DIRTY=" ${red}※"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}※"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function prompt_command() {
  # Adding timestamp
  # Adding full information about the current position using ssh/scp format => user@host:path
  #   Colors on user is based on privileges (root, su, ...)
  #   Colors on host is based on connection (ssh, local, telnet, ...)
  #   Colors on path is based on credentials (write access or not)
  PS1="\n${reset_color}[\T]${purple}$(ruby_version_prompt) $(user_type_color_prompt)\u${reset_color}@$(host_connection_color_prompt)\h${reset_color}:$(writeable_path_color_prompt)\w\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} "
}

PROMPT_COMMAND=prompt_command;
