#!/usr/bin/bash

if command -v vue > /dev/null; then
    __vuejs_completion()  {
        local OPTS=("--version --help create add invoke inspect serve build ui init config upgrade info")
        COMPREPLY=()
        for _opt_ in ${OPTS[@]}; do
            if [[ "$_opt_" == "$2"* ]]; then
                COMPREPLY+=("$_opt_")
            fi
        done
    }
    
    complete -F __vuejs_completion vue
fi
