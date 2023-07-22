#!/usr/bin/env bash
# Bash completion support for the 'dirs' plugin (commands G, R).

function _dirs-complete() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    # parse all defined shortcuts from ~/.dirs
    if [ -r "${HOME}/.dirs" ] 
     then
        COMPREPLY=($(compgen -W "$(grep -v '^#' ~/.dirs | sed -e 's/\(.*\)=.*/\1/')" -- ${CURRENT_PROMPT}) )
    fi

    return 0
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

complete -o default -o nospace -F _dirs-complete G R
