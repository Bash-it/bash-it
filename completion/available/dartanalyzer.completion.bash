#!/bin/bash

# ------------------------------------
# Original Credits : https://github.com/claudiodangelis/dart-bash_completion
# ------------------------------------
if command -v dartanalyzer > /dev/null; then
    _dartanalyzer() {
        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        # Options
        opts="--help --batch --dart-sdk --package-root --format --machine \
            --version --no-hints --ignore-unrecognized-flags --fatal-warnings \
            --package-warnings --show-package-warnings --perf --warnings \
            --show-sdk-warnings"

        # TODO: complete only *.dart files

        if [[ ${cur} == -* ]] ; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
        else
            COMPREPLY=()
            return 0
        fi

    }

    complete -o default -F _dartanalyzer dartanalyzer
fi