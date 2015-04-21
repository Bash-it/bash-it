#!/usr/bin/env bash
# Bash completion support for the 'dirs' plugin (commands G, R).

_dirs-complete() {
    local CURRENT_PROMPT="${COMP_WORDS[COMP_CWORD]}"

    # parse all defined shortcuts from ~/.dirs
    if [ -r "$HOME/.dirs" ]; then
        COMPREPLY=($(compgen -W "$(grep -v '^#' ~/.dirs | sed -e 's/\(.*\)=.*/\1/')" -- ${CURRENT_PROMPT}) )
    fi

    return 0
}

complete -o default -o nospace -F _dirs-complete G R
