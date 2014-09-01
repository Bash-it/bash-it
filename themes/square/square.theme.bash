#!/usr/bin/env bash

function git_short_sha() {
  SHA=$(git rev-parse --short HEAD 2> /dev/null) && echo "$SHA"
}

prompt() {
  local sha="${yellow}$(git_short_sha)${reset_color}"
  local branch="$(__git_ps1 ${red}%s${reset_color})"
  # failed attempt to merge the two above
  #local branch="$(__git_ps1 ${red}%s${reset_color} ${sha})"

  # the original
  #PS1="${green}\w${reset_color} $(__git_ps1 [${red}%s${reset_color}])$ "

  # with persistent brackets
  #PS1="${green}\w${reset_color} [${branch} ${sha}]$ "
  # without any brackets
  PS1="${green}\w${reset_color} ${branch} ${sha}$ "
  # failed attempt at conditional brackets
  #PS1="${green}\w${reset_color} ${branch}$ "
}

PROMPT_COMMAND=prompt
