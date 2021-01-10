#!/usr/bin/env bash
# Completion for gem


__gem_completions() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}
    case $prev in
        install)
            # list the remote gems and add to completion
            if [ -z "$REMOTE_GEMS" ]
            then
                REMOTE_GEMS=( $(gem list --remote --no-versions | sed 's/\*\*\* REMOTE GEMS \*\*\*//' | tr '\n' ' ') )
            fi

            local cur=${COMP_WORDS[COMP_CWORD]}
            COMPREPLY=( $(compgen -W "${REMOTE_GEMS[*]}" -- $cur) )
        ;;
        uninstall)
            # list all local installed gems and add to completion
            if [ -z "$LOCAL_GEMS" ]
            then
                LOCAL_GEMS=( $(gem list --no-versions | sed 's/\*\*\* LOCAL GEMS \*\*\*//' | tr '\n' ' ') )
            fi

            local cur=${COMP_WORDS[COMP_CWORD]}
            COMPREPLY=( $(compgen -W "${LOCAL_GEMS[*]}" -- $cur) )
        ;;
    esac
    local commands=(build cert check cleanup contents dependency environment fetch generate_index help install list lock outdated owner pristine push query rdoc search server sources specification stale uninstall unpack update which)
    COMPREPLY=( $(compgen -W "${commands[*]}" -- $cur) )
}

complete -F __gem_completions gem
