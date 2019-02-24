#!/bin/bash

# ------------------------------------
# Original Credits : https://github.com/claudiodangelis/dart-bash_completion
# ------------------------------------
if command -v docgen > /dev/null; then
    _dartfmt() {
        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # Options
        opts="--help --write --transform --max_line_length --machine"

        # TODO: complete only *.dart files

        if [[ ${cur} == -* ]] ; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        else
            COMPREPLY=()
            return 0
        fi

    }

    complete -o default -F _dartfmt dartfmt
fi