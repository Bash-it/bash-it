#!/usr/bin/env bash


function __reset2 {
  next=$1 && shift
  out="$(__$next $@)"
  echo "1${out:+;${out}}"
}


light_blue="$(color reset2 blue)"
light_red="$(color reset2 red)"

echo_light_blue="$(echo_color reset2 blue)"
echo_light_red="$(echo_color reset2 red)"

SCM_THEME_PROMPT_DIRTY=" ${bold_yellow}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ${light_blue}scm:("
SCM_THEME_PROMPT_SUFFIX="${light_blue})"

GIT_THEME_PROMPT_DIRTY=" ${bold_yellow}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${light_blue}git:("
GIT_THEME_PROMPT_SUFFIX="${light_blue})"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX${echo_light_red}$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}


function prompt_command() {
    PS1="${bold_green}➜  ${bold_cyan}\W${reset_color}$(scm_prompt_info)${reset_color} "
}

PROMPT_COMMAND=prompt_command;
