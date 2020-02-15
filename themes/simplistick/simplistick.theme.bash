#!/usr/bin/env bash
SCM_GIT_CHAR=""
SCM_HG_CHAR=""
SCM_SVN_CHAR=""
SCM_NONE_CHAR=""
SCM_THEME_PROMPT_DIRTY=" ${red}â"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}â"
SCM_THEME_PROMPT_PREFIX="("
SCM_THEME_PROMPT_SUFFIX="${green}) "
SCM_GIT_AHEAD_CHAR="${green}â²"
SCM_GIT_BEHIND_CHAR="${red}â¼"

GIT_THEME_PROMPT_DIRTY=" ${bold_red}â"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}â"
GIT_THEME_PROMPT_PREFIX="${white}("
GIT_THEME_PROMPT_SUFFIX="${white}) "

RVM_THEME_PROMPT_PREFIX="("
RVM_THEME_PROMPT_SUFFIX=") "

VIRTUALENV_THEME_PROMPT_PREFIX="("
VIRTUALENV_THEME_PROMPT_SUFFIX=") "

RBENV_THEME_PROMPT_PREFIX="("
RBENV_THEME_PROMPT_SUFFIX=") "

RBFU_THEME_PROMPT_PREFIX="("
RBFU_THEME_PROMPT_SUFFIX=") "

function rvm_version_prompt {
  if which rvm &> /dev/null; then
    rvm_current=$(rvm tools identifier) || return
    rvm_default=$(rvm strings default) || return
    [ "$rvm_current" !=  "$rvm_default" ] && ( echo -e "$RVM_THEME_PROMPT_PREFIX$rvm_current$RVM_THEME_PROMPT_SUFFIX" )
  fi
}

function git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX${yellow}$SCM_BRANCH$SCM_STATE$SCM_GIT_AHEAD$SCM_GIT_BEHIND$SCM_GIT_STASH$SCM_SUFFIX"
}

LAST_PROMPT=""
function prompt_command() {
    local prompt="${green}%"
    local new_PS1="${white}>$(scm_char) $(scm_prompt_info)$(ruby_version_prompt)${bold_cyan}${green}\w"
    local wrap_char="\n"
    PS1="${new_PS1}${wrap_char}${prompt}${reset_color} "
}

safe_append_prompt_command prompt_command