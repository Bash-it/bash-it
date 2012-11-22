#!/usr/bin/env bash
#⚡
# looks good on dark bakground
SCM_THEME_PROMPT_DIRTY=" ${red}✖${reset_color}"
SCM_THEME_PROMPT_AHEAD=" ${red}!${reset_color}"
SCM_THEME_PROMPT_CLEAN=" ${green}✔${reset_color}"
SCM_THEME_PROMPT_PREFIX="${white} ❮ $(scm_char)${cyan} "
SCM_THEME_PROMPT_SUFFIX="${white} ❯"
GIT_SHA_PREFIX="${white} ❮ $(scm_char)${cyan} "
GIT_SHA_SUFFIX="${white} ❯"

#HG_SHA_PREFIX="${white} ❮ ${yellow}"
#HG_SHA_SUFFIX="${reset_color}"


function zuper_hg_prompt_info() {
  hg_prompt_vars
  echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function zuper_git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function zuper_scm_prompt_info {
  scm
  scm_prompt_char
  SCM_DIRTY=0
  SCM_STATE=''
  [[ $SCM == $SCM_GIT ]] && zuper_git_prompt_info && return
  [[ $SCM == $SCM_HG ]] && zuper_hg_prompt_info && return
  [[ $SCM == $SCM_SVN ]] && svn_prompt_info && return
}



prompt() {
    local my_branch="$(zuper_scm_prompt_info)"
    PS1="${white}\n[ ${yellow}\u@\H ${white}] ${green}\w${my_branch}\n${white}[ ${red}\t${bold_white} ] →${normal} "
}

PROMPT_COMMAND=prompt
