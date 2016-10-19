#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX="(${yellow}"
SCM_THEME_PROMPT_SUFFIX="${normal})"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX="(${yellow}"
GIT_THEME_PROMPT_SUFFIX="${normal})"

RVM_THEME_PROMPT_PREFIX=""
RVM_THEME_PROMPT_SUFFIX=""

function prompt_command() {
    dtime="$(clock_prompt)"
    user_host="${green}\u@${cyan}\h${normal}"
    current_dir="${bold_blue}\w${normal}"
    rvm_ruby="${bold_red}$(ruby_version_prompt)${normal}"
    git_branch="$(scm_prompt_info)${normal}"
    prompt="${bold_green}\$${normal} "
    arrow="${bold_white}▶${normal} "
    prompt="${bold_green}\$${normal} "

    PS1="${dtime}${user_host}:${current_dir} ${rvm_ruby} ${git_branch}
      $arrow $prompt"
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"$yellow"}
THEME_CLOCK_FORMAT=${THEME_TIME_FORMAT:-"%I:%M:%S "}

safe_append_prompt_command prompt_command
