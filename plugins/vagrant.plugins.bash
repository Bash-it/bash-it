#!/bin/bash
_vagrant()
{
    local cur prev commands 
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # The commands we will complete
    commands="box destroy halt help init package provision reload resume ssh ssh_config status suspend up version"

    case "${prev}" in
    "remove"|"repackage")
        #local vagrantlist=$(gem list -l|grep '([0-9].*)'|awk 'BEGIN {ORS=" "} { print $1}'|sort)
        #local vagrantlist=$(command ls --color=none -l $HOME/.vagrant/boxes 2>/dev/null | sed -e 's/ /\\ /g' | awk 'BEGIN {ORS=" "} {print $2}' )
        local vagrantlist=$(find $HOME/.vagrant/boxes/* -maxdepth 0 -type d -printf '%f ')
        COMPREPLY=($(compgen -W "${vagrantlist}" -- ${cur}))
        return 0
        ;;
    "box")
        commands="add help list remove repackage"
        COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
        return 0
        ;;
    *)
        ;;
    esac

    COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
    return 0
}
complete -F _vagrant vagrant
complete -F _vagrant vagrant-e

