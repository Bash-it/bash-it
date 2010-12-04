#!/bin/bash
# Bash completion support for ssh.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_sshcomplete() {
    if [ -f $HOME/.ssh/config ]; then
        COMPREPLY=($(compgen -W "`ruby -e"puts open('${HOME}/.ssh/config', 'r') { |f| f.readlines }.find_all { |l| l =~ /^Host/ }.inject([]) { |hosts, line| hosts << line[5..-1].split }.flatten.sort.uniq"`" -- ${COMP_WORDS[COMP_CWORD]}))
        return 0
    fi
}

complete -o default -o nospace -F _sshcomplete ssh
