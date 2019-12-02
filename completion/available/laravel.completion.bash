#!/usr/bin/bash

if command -v laravel > /dev/null; then
    __laravel_completion()  {
        local OPTS=("-h --help -q --quiet --ansi --no-ansi -n --no-interaction -v -vv -vvv --verbose help list new")
        COMPREPLY=()
        for _opt_ in ${OPTS[@]}; do
            if [[ "$_opt_" == "$2"* ]]; then
                COMPREPLY+=("$_opt_")
            fi
        done
    }
    
    complete -F __laravel_completion laravel
fi

