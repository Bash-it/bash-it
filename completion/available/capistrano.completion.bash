#!/usr/bin/env bash
# Bash completion support for Capistrano.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_capcomplete() {
    if [ -f Capfile ]; then
        recent=`ls -t .cap_tasks~ Capfile **/*.cap 2> /dev/null | head -n 1`
        if [[ $recent != '.cap_tasks~' ]]; then
            cap --tool --tasks | cut -d " " -f 2 > .cap_tasks~
        fi
        COMPREPLY=($(compgen -W "`cat .cap_tasks~`" -- ${COMP_WORDS[COMP_CWORD]}))
        return 0
    fi
}

complete -o default -o nospace -F _capcomplete cap
