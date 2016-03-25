#!/usr/bin/env bash
# Bash completion support for ssh.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_sshcomplete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"
    if [[ ${CURRENT_PROMPT} == *@*  ]] ; then
      local OPTIONS="-P ${CURRENT_PROMPT/@*/}@ -- ${CURRENT_PROMPT/*@/}"
    else
      local OPTIONS=" -- ${CURRENT_PROMPT}"
    fi

    
    # parse all defined hosts from .ssh/config
    if [ -r "$HOME/.ssh/config" ]; then
        COMPREPLY=($(compgen -W "$(grep ^Host "$HOME/.ssh/config" | awk '{for (i=2; i<=NF; i++) print $i}' )" ${OPTIONS}) )
    fi

    # parse all hosts found in .ssh/known_hosts
    if [ -r "$HOME/.ssh/known_hosts" ]; then
        if grep -v -q -e '^ ssh-rsa' "$HOME/.ssh/known_hosts" ; then
            COMPREPLY=( ${COMPREPLY[@]} $(compgen -W "$( awk '{print $1}' "$HOME/.ssh/known_hosts" | grep -v ^\| | cut -d, -f 1 | sed -e 's/\[//g' | sed -e 's/\]//g' | cut -d: -f1 | grep -v ssh-rsa)" ${OPTIONS}) )
        fi
    fi

    # parse hosts defined in /etc/hosts
    if [ -r /etc/hosts ]; then
        COMPREPLY=( ${COMPREPLY[@]} $(compgen -W "$( grep -v '^[[:space:]]*$' /etc/hosts | grep -v '^#' | awk '{for (i=2; i<=NF; i++) print $i}' )" ${OPTIONS}) )
    fi
    
    return 0
}

complete -o default -o nospace -F _sshcomplete ssh

