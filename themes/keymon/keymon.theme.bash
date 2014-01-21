#!/usr/bin/env bash

__my_rvm_ruby_version() {
  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"
  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
  echo "$version$gemset"
}


prompt_setter() {
  local return_code=$?
  local return_color
  [ "z${return_code}" == "z0" ] && return_color="" || return_color=$red

  local scm_info=$(scm_prompt_info)

  local head_ps1="${return_color:-$green}r:${return_code} \t${reset_color}${scm_info} rb:$(__my_rvm_ruby_version) ${reset_color}"
  local base_ps1="${return_color:-$green}\u$reset_color@${return_color:-$yellow}\H$reset_color:${return_color:-$cyan}\w${reset_color}\$"
  
  TITLEBAR="\033]0;${scm_info} \u@\H:\W\007"
  
  PS1="$TITLEBAR┌${head_ps1}\n└${base_ps1} "  
  PS2='> '
  PS4='+ '


  # Save history
  history -a
  history -c
  history -r 
}

PROMPT_COMMAND=prompt_setter

SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX=" ("
SCM_THEME_PROMPT_SUFFIX=")"
