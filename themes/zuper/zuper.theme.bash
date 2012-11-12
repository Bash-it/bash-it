#!/usr/bin/env bash
#⚡
#
SCM_THEME_PROMPT_DIRTY=" ${red}✖${reset_color}"
SCM_THEME_PROMPT_AHEAD=" ${red}!${reset_color}"
SCM_THEME_PROMPT_CLEAN=" ${green}✔${reset_color}"
SCM_THEME_PROMPT_PREFIX="${white} ❮${cyan} "
SCM_THEME_PROMPT_SUFFIX="${white} ❯"
#GIT_SHA_PREFIX="${white} ❮ ${yellow}"
#GIT_SHA_SUFFIX="${reset_color}"

#HG_SHA_PREFIX="${white} ❮ ${yellow}"
#HG_SHA_SUFFIX="${reset_color}"



function git_short_sha() {
  SHA=$(git rev-parse --short HEAD 2> /dev/null) && echo "$GIT_SHA_PREFIX$SHA$GIT_SHA_SUFFIX"
}

prompt() {
    local git_branch="$(scm_prompt_info)"
    PS1="${white}\n[ ${yellow}\u@\H ${white}] ${green}\w${git_branch}\n${white}[ ${red}\t${white} ] →${white} "
}

PROMPT_COMMAND=prompt