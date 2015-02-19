#!/usr/bin/env bash
# Bash completion support for Capistrano.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_capcomplete() {
    if [ -f Capfile ]; then
        recent=`ls -t .cap_tasks~ Capfile **/*.cap 2> /dev/null | head -n 1`
        if [[ $recent != '.cap_tasks~' ]]; then
            cap --version | grep 'Capistrano v2.' > /dev/null
            if [ $? -eq 0 ]; then
              # Capistrano 2.x
              cap --tool --verbose --tasks | cut -d " " -f 2 > .cap_tasks~
            else
              # Capistrano 3.x
              cap --all --tasks | cut -d " " -f 2 > .cap_tasks~
            fi
        fi
        COMPREPLY=($(compgen -W "`cat .cap_tasks~`" -- ${COMP_WORDS[COMP_CWORD]}))
        return 0
    fi
}

complete -o default -o nospace -F _capcomplete cap
