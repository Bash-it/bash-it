# ------------------------------------------------------------------#
#          FILE: cooperkid.zsh-theme                                #
#            BY: Alfredo Bejarano                                   #
#      BASED ON: Mr Briggs by Matt Brigg (matt@mattbriggs.net)      #
# ------------------------------------------------------------------#

SCM_THEME_PROMPT_DIRTY="${red} ✗${reset_color}"
SCM_THEME_PROMPT_AHEAD="${yellow} ↑${reset_color}"
SCM_THEME_PROMPT_CLEAN="${green} ✓${reset_color}"
SCM_THEME_PROMPT_PREFIX=" "
SCM_THEME_PROMPT_SUFFIX=""
GIT_SHA_PREFIX="${blue}"
GIT_SHA_SUFFIX="${reset_color}"

function rvm_version_prompt {
  if which rvm &> /dev/null; then
    rvm=$(rvm-prompt) || return
    if [ -n "$rvm" ]; then
      echo -e "$rvm"
    fi
  fi
}

function git_short_sha() {
  SHA=$(git rev-parse --short HEAD 2> /dev/null) && echo "$GIT_SHA_PREFIX$SHA$GIT_SHA_SUFFIX"
}

function prompt() {
    local return_status=""
    local ruby="${red}$(ruby_version_prompt)${reset_color}"
    local user_host="${green}\h @ \w${reset_color}"
    local git_branch="$(git_short_sha)${cyan}$(scm_prompt_info)${reset_color}"
    local prompt_symbol=' '
    local prompt_char="${purple}>_${reset_color} "

    PS1="\n${user_host}${prompt_symbol}${ruby} ${git_branch} ${return_status}\n${prompt_char}"
}

PROMPT_COMMAND=prompt
