#!/usr/bin/env bash
#⚡
# looks good on dark bakground
SCM_THEME_PROMPT_DIRTY=" ${red}✖${reset_color}"
SCM_THEME_PROMPT_AHEAD=" ${red}!${reset_color}"
SCM_THEME_PROMPT_CLEAN=" ${green}✔${reset_color}"
SCM_THEME_PROMPT_PREFIX="${white} ❮ "
SCM_THEME_PROMPT_SUFFIX="${white} ❯"
GIT_SHA_PREFIX="${white} ❮ $(scm_char)${cyan} "
GIT_SHA_SUFFIX="${white} ❯"

#SCM_GIT_CHAR="git ${red}|${white} "
#SCM_HG_CHAR="hg | "
#SCM_SVN_CHAR="svn ${red}|${white} "

#HG_SHA_PREFIX="${white} ❮ ${yellow}"
#HG_SHA_SUFFIX="${reset_color}"


function zuper_hg_prompt_info() {
  hg_prompt_vars
  echo -e "$SCM_PREFIX${magenta}$(scm_char) ${cyan}$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
}

function hg_prompt_vars {
    if [[ -n $(hg status 2> /dev/null) ]]; then
      SCM_DIRTY=1
        SCM_STATE=${HG_THEME_PROMPT_DIRTY:-$SCM_THEME_PROMPT_DIRTY}
    else
      SCM_DIRTY=0
        SCM_STATE=${HG_THEME_PROMPT_CLEAN:-$SCM_THEME_PROMPT_CLEAN}
    fi
    SCM_PREFIX=${HG_THEME_PROMPT_PREFIX:-$SCM_THEME_PROMPT_PREFIX}
    SCM_SUFFIX=${HG_THEME_PROMPT_SUFFIX:-$SCM_THEME_PROMPT_SUFFIX}
    SCM_BRANCH=$(hg summary 2> /dev/null | grep branch: | awk '{print $2}')
    SCM_CHANGE=$(hg summary 2> /dev/null | grep parent: | awk '{print $2}')
}

function zuper_git_prompt_info {
  git_prompt_vars
  echo -e "$SCM_PREFIX${magenta}$(scm_char) ${blue}$SCM_BRANCH$SCM_STATE$SCM_SUFFIX"
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
    # » ➜ 
    local my_branch="$(zuper_scm_prompt_info)"
    PS1="${white}\n[${yellow} \u@\H ${red}\t${white} ] ${green}\w${my_branch}\n${white}➜${normal} "
}

PROMPT_COMMAND=prompt
