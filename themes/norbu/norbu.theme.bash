#!/usr/bin/env bash

function set_prompt_symbol () {
    if test $1 -eq 0 ; then
	PROMPT_SYMBOL=">_"
    else
	PROMPT_SYMBOL="${orange}>_${normal}"
    fi
}
function prompt_command() {
    set_prompt_symbol $?
    if test -z "$VIRTUAL_ENV" ; then
	PYTHON_VIRTUALENV=""
    else
	PYTHON_VIRTUALENV="${bold_yellow}[`basename \"$VIRTUAL_ENV\"`]"
    fi

    PS1="${bold_orange}${PYTHON_VIRTUALENV}${reset_color}${bold_green}[\w]${bold_blue}\[$(scm_prompt_info)\]${normal} \n${PROMPT_SYMBOL} "
}

# scm themeing
SCM_THEME_PROMPT_DIRTY=" ✗"
SCM_THEME_PROMPT_CLEAN=" ✓"
SCM_THEME_PROMPT_PREFIX="["
SCM_THEME_PROMPT_SUFFIX="]"

safe_append_prompt_command prompt_command
