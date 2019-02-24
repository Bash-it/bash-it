#!/bin/bash

# ------------------------------------
# Original Credits : https://github.com/claudiodangelis/dart-bash_completion
# ------------------------------------
if command -v dart2js > /dev/null; then
    _dart2js() {
        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # Options
        opts="--help -o -c -m -h -v --minify --checked"

        if [[ ${cur} == -* ]] ; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        # This part is buggy
        elif [[ ${prev} != "*.dart" ]] ; then
            local dart_scripts=$(for d in `ls  -1 *.dart 2>/dev/null`; do echo ${d}; done)
            COMPREPLY=( $(compgen -W "${dart_scripts}" -- ${cur}) )
        else
            COMPREPLY=()
            return 0
        fi
    }

    complete -o default -F _dart2js dart2js

fi