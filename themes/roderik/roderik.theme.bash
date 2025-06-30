#!/usr/bin/env bash

export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWSTASHSTATE=true

export PROMPT_DIRTRIM=3

function prompt_command() {
	if [[ ${EUID} == 0 ]]; then
		PS1="[$(clock_prompt)]${yellow}[${red}\u@\h ${green}\w${yellow}]${red}$(__git_ps1 "(%s)")${normal}\\$ "
	else
		PS1="[$(clock_prompt)]${yellow}[${cyan}\u@\h ${green}\w${yellow}]${red}$(__git_ps1 "(%s)")${normal}\\$ "
	fi
}

safe_append_prompt_command prompt_command
