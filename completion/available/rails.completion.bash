#! bash
# bash completion for the `rails` command.
#
# Copyright (c) 2008-2017 Daniel Luz <dev at mernen dot com>.
# Distributed under the MIT license.
# http://mernen.com/projects/completion-ruby
#
# To use, source this file on bash:
#   . completion-rails

# Sets $rails_command and $rails_subcommand
__rails_get_command() {
    local i
    for ((i=1; i < $COMP_CWORD; ++i)); do
        local arg=${COMP_WORDS[$i]}

        case $arg in
        -b | --builder | -r | --ruby | --root | -m | --template |\
        -s | --source  | -e | --environment)
            # Ignore next argument
            ((++i))
            ;;
        [^-]*)
            if [[ -n $rails_command ]]; then
                rails_subcommand=$arg
                return
            else
                rails_command=$arg
                case $arg in
                generate | g | destroy | plugin)
                    # Continue processing, looking for a subcommand
                    ;;
                *)
                    # End processing
                    return;;
                esac
            fi
            ;;
        esac
    done
}

__rails_complete_environments() {
    local environments=(config/environments/*.rb)
    if [[ -f $environments ]]; then
        environments=("${environments[@]##*/}")
        environments=("${environments[@]%.rb}")
    else
        environments=(development test production)
    fi
    COMPREPLY=($(compgen -W "${environments[*]}" -- "$1"))
}


# __rails_exec <command>
# __rails_exec <command> \| <script>
#
# Performs the given `rails` command and caches the result. If a Ruby script is
# given as a final argument separated by a pipe, the output of `rails` is piped
# to `ruby -ne <script>`.
__rails_exec() {
    # Lockfile is inferred here, and might not be correct (if running the
    # command on a subdirectory). However, a wrong file path won't be a
    # cadastrophic mistake, as it's never read; its main practical use is to
    # ensure we're not offering completion on a project with data from another.
    #
    # Additionally, we're assuming the change of available commands is tied to
    # a change in gems available, which should hold mostly true in practice.
    local lockfile=$PWD/Gemfile.lock
    local cachedir=${XDG_CACHE_HOME:-~/.cache}/completion-ruby
    local cachefile=$cachedir/rails--exec
    local rails_bin=(${rails_bin[@]:-rails})

    # A representation of all arguments with newlines replaced by spaces, used
    # as a cache identifier
    local cache_id_line="$PWD: ${rails_bin[*]} ${*//$'\n'/ }"

    if [[ (! -f $gemfile || $cachefile -nt $gemfile) &&
          $(head -n 1 -- "$cachefile" 2>/dev/null) = "$cache_id_line" ]]; then
        tail -n +2 -- "$cachefile"
    else
        local output
        if [[ ${@: -2:1} = \| ]]; then
            # ruby pipe follows
            local args=${@:1:$#-2}
            local ruby_script=${@: -1}
            output=$("${rails_bin[@]}" "${args[@]}" 2>/dev/null |
                     ruby -ne "$ruby_script" 2>/dev/null)
        else
            output=$("${rails_bin[@]}" "$@" 2>/dev/null)
        fi
        if [[ $? -eq 0 ]]; then
            (mkdir -p -- "$cachedir" &&
             echo "$cache_id_line"$'\n'"$output" >$cachefile) 2>/dev/null
            echo "$output"
        fi
    fi
}


__rails() {
    local rails_bin=("${_RUBY_COMMAND_PREFIX[@]}" "$1")
    local cur=$2
    local prev=$3
    local rails_command rails_subcommand
    __rails_get_command
    COMPREPLY=()

    case $prev in
    -b | --builder | -r | --ruby | --root | -m | --template | -s | --source)
        # Leave it to complete the path
        return;;
    -e | --environment)
        __rails_complete_environments "$cur"
        return;;
    --mode)
        if [[ $rails_command = dbconsole || $rails_command = db ]]; then
            local options="html list line column"
            COMPREPLY=($(compgen -W "$options" -- "$cur"))
            return
        fi
        ;;
    esac

    local options
    if [[ $cur = -* ]]; then
        if [[ -z $rails_command ]]; then
            options="-h --help -v --version"
        else
            local param
            options=$(__rails_exec "$rails_command" $rails_subcommand --help \|\
                      'puts $_.scan(/(-\w)|(--\w[-\w]*)/)')
        fi
    else
        case $rails_command in
        "")
            options=$(__rails_exec \|\
                      'puts $1 if ~/^  rails (\S+)/;
                       puts $1 if ~/^ (\S+)/;
                       puts $1 if ~/alias: "(\S+)"/')
            # If you've already typed one character, let's skip the
            # single-character shortcuts; this way, typing in "rails c<TAB>"
            # will instantly complete to "console", rather than just beeping
            # for ambiguity
            [[ -n $cur ]] && options=$(grep .. <<<"$options")
            ;;
        server | s)
            # Load list dynamically?
            options="mongrel thin"
            ;;
        console | c | dbconsole | db)
            __rails_complete_environments "$cur"
            return;;
        generate | g | destroy)
            options=$(__rails_exec "$rails_command" --help \|\
                      'puts $1 if ~/^  (\w\S*)/')
            ;;
        plugin)
            options="install remove"
        esac
    fi
    COMPREPLY=($(compgen -W "$options" -- "$cur"))
}


complete -F __rails -o bashdefault -o default rails
# vim: ai ft=sh sw=4 sts=4 et
