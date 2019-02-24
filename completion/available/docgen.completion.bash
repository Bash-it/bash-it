#!/bin/bash

# ------------------------------------
# Original Credits : https://github.com/claudiodangelis/dart-bash_completion
# ------------------------------------
if command -v docgen > /dev/null; then
    _docgen() {
        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # Options
        opts="--help --verbose --include-private --no-include-sdk --include-sdk \
            --parse-sdk --package-root --compile --serve --no-docs --introduction \
            --out --exclude-lib --no-include-dependent-packages \
            --include-dependent-packages --sdk --start-page --no-indent-json \
            --indent-json"


        if [[ ${cur} == -* ]] ; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        else
            COMPREPLY=()
            return 0
        fi

    }

    complete -o default -F _docgen docgen
fi