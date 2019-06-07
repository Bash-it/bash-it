#!/usr/bin/bash

if command -v hosts > /dev/null; then
    __hosts_completions()  {
        local OPTS=("add list remove")
        COMPREPLY=()
        for _opt_ in ${OPTS[@]}; do
            if [[ "$_opt_" == "$2"* ]]; then
                COMPREPLY+=("$_opt_")
            fi
        done
    }
    
    complete -F __hosts_completions
fi
