#!/bin/bash

# ------------------------------------
# Original Credits : https://github.com/claudiodangelis/dart-bash_completion
# ------------------------------------
if command -v pub > /dev/null; then
    _pub() {

        local cur prev opts
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        prevprev="${COMP_WORDS[COMP_CWORD-2]}"

        # Commands
        cmds="build cache deps get global help publish run serve upgrade uploader \
            version"

        # Per-command subcommands
        cache_cmds="add repair"
        global_cmds="activate deactivate run"


        # Global options
        opts="--help --version --no-trace --trace --verbosity --verbose"

        # Per-command options
        build_opts="--help --mode --all --format --output"
        cache_opts="--help"
        deps_opts="--help --style"
        get_opts="--help --no-offline --offline"
        global_opts="--help"
        help_opts="--help" # We can probably get rid of this
        publish_opts="--help --dry-run --force --server"
        run_opts="--help"
        serve_opts="--help --mode --all --hostname --port --no-dart2js --dart2js \
            --no-force-poll --force-poll"

        upgrade_opts="--help --no-offline --offline"
        uploader_opts="--help --server --package"
        version_opts="--help" # We can probably get rid of this

        if [[ ${cur} == -* ]] ; then
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        else
            COMPREPLY=( $(compgen -W "${cmds}" -- ${cur}) )
        fi

        case "${prev}" in
            build)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${build_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;

            cache)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${cache_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=( $(compgen -W "${cache_cmds}" -- ${cur}) )
                    return 0
                fi
                ;;

            deps)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${deps_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;


            get)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${get_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;

            global)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${global_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=( $(compgen -W "${global_cmds}" -- ${cur}) )
                    return 0
                fi
                ;;


            help)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${help_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;


            publish)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${publish_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;

            run)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${run_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;


            serve)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${serve_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;


            upgrade)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${upgrade_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;


            uploader)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${uploader_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;


            version)
                if [[ ${cur} == -* ]] ; then
                    COMPREPLY=( $(compgen -W "${version_opts}" -- ${cur}) )
                    return 0
                else
                    COMPREPLY=()
                    return 0
                fi
                ;;

                *)
                ;;

            esac

    }

    complete -o default -F _pub pub
fi