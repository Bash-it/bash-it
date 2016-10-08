#!/usr/bin/env bash

# apm-bash-completion is written by Ugur Ozyilmazel
# repo: https://github.com/vigo/apm-bash-completion

__apm(){
    local cur prev options apm_command
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    __apm_get_command
    if [[ $cur = -* ]]; then
        options="--color"
        if [[ -z $apm_command ]]; then
            options="$options --version --help"
        fi
        if [[ $apm_command && $apm_command = publish ]]; then
            options="--tag --rename"
        fi
    else
        if [[ -z $apm_command || $apm_command = help ]]; then
            options="help clean config dedupe deinstall delete dev develop docs erase featured home init install link linked links list ln lns login ls open outdated publish rebuild rebuild-module-cache remove rm search show star starred stars test uninstall unlink unpublish unstar update upgrade view"
        fi
        if [[ $apm_command && $apm_command = publish ]]; then
            options="major minor patch build"
        fi
        if [[ $apm_command && $apm_command = config ]]; then
            options="set get delete list edit"
        fi
    fi
    COMPREPLY=($(compgen -W "$options" -- "$cur"))
}
__apm_get_command() {
    local i
    for ((i=1; i < $COMP_CWORD; ++i)); do
        local arg=${COMP_WORDS[$i]}
        case $arg in
        [^-]*)
            apm_command=$arg
            return;;
        --version)
            apm_command=-
            return;;
        --help)
            apm_command=help
            return;;
        publish)
            apm_command=publish
            return;;
        config)
            apm_command=config
            return;;
        esac
    done
}
complete -F __apm -o bashdefault -o default apm
