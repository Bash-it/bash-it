#!/usr/bin/env bash

prompt() {
  PS1="${green}\w${reset_color} $(__git_ps1 [${red}%s${reset_color}])$ "
}

PROMPT_COMMAND=prompt
