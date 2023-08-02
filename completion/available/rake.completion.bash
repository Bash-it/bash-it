#!/usr/bin/env bash
# Bash completion support for Rake, Ruby Make.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

function _rakecomplete() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    if [ -f Rakefile ] 
     then
        recent=`ls -t .rake_tasks~ Rakefile **/*.rake 2> /dev/null | head -n 1`
        if [[ ${recent} != '.rake_tasks~' ]] 
     then
            rake --silent --tasks | cut -d " " -f 2 > .rake_tasks~
        fi
        COMPREPLY=($(compgen -W "`cat .rake_tasks~`" -- ${COMP_WORDS[COMP_CWORD]}))
        return 0
    fi
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

complete -o default -o nospace -F _rakecomplete rake
