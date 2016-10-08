# link: https://github.com/ginatrapani/todo.txt-cli/blob/master/todo_completion

_todo()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local -r OPTS="-@ -@@ -+ -++ -d -f -h -p -P -PP -a -n -t -v -vv -V -x"
    local -r COMMANDS="\
        add a addto addm append app archive command del  \
        rm depri dp do help list ls listaddons listall lsa listcon  \
        lsc listfile lf listpri lsp listproj lsprj move \
        mv prepend prep pri p replace report shorthelp"
    local -r MOVE_COMMAND_PATTERN='^(move|mv)$'

    local _todo_sh=${_todo_sh:-todo.sh}
    local completions
    if [ $COMP_CWORD -eq 1 ]; then
        completions="$COMMANDS $(eval TODOTXT_VERBOSE=0 $_todo_sh command listaddons) $OPTS"
    elif [[ $COMP_CWORD -gt 2 && ( \
        "${COMP_WORDS[COMP_CWORD-2]}" =~ $MOVE_COMMAND_PATTERN || \
        "${COMP_WORDS[COMP_CWORD-3]}" =~ $MOVE_COMMAND_PATTERN ) ]]; then
        completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listfile)
    else
        case "$prev" in
            command)
                completions=$COMMANDS;;
            help)
                completions="$COMMANDS $(eval TODOTXT_VERBOSE=0 $_todo_sh command listaddons)";;
            addto|listfile|lf)
                completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listfile);;
            -*) completions="$COMMANDS $(eval TODOTXT_VERBOSE=0 $_todo_sh command listaddons) $OPTS";;
            *)  case "$cur" in
                    +*) completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listproj)
                        COMPREPLY=( $( compgen -W "$completions" -- $cur ))
                        [ ${#COMPREPLY[@]} -gt 0 ] && return 0
                        completions=$(eval 'TODOTXT_VERBOSE=0 TODOTXT_SOURCEVAR=\$DONE_FILE' $_todo_sh command listproj)
                        ;;
                    @*) completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listcon)
                        COMPREPLY=( $( compgen -W "$completions" -- $cur ))
                        [ ${#COMPREPLY[@]} -gt 0 ] && return 0
                        completions=$(eval 'TODOTXT_VERBOSE=0 TODOTXT_SOURCEVAR=\$DONE_FILE' $_todo_sh command listcon)
                        ;;
                    *)  if [[ "$cur" =~ ^[0-9]+$ ]]; then
                            local todo=$( \
                                eval TODOTXT_VERBOSE=0 $_todo_sh '-@ -+ -p -x command ls "^ *${cur} "' | \
                                sed -e 's/^ *[0-9]\{1,\} //' -e 's/^\((.) \)\{0,1\}[0-9]\{2,4\}-[0-9]\{2\}-[0-9]\{2\} /\1/' \
                                    -e 's/^\([xX] \)\([0-9]\{2,4\}-[0-9]\{2\}-[0-9]\{2\} \)\{1,2\}/\1/' \
                                    -e 's/[[:space:]]*$//' \
                                    -e '1q' \
                            )
                            [ "$todo" ] && COMPREPLY[0]="$cur # $todo"
                            return 0
                        else
                            return 0
                        fi
                        ;;
                esac
                ;;
        esac
    fi

    COMPREPLY=( $( compgen -W "$completions" -- $cur ))
    return 0
}

complete -F _todo todo.sh
complete -F _todo t
