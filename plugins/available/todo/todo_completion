#!/bin/bash source-this-script
[ "$BASH_VERSION" ] || return

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

    local _todo_sh=${_todo_sh:-todo.sh}
    local completions
    if [ $COMP_CWORD -eq 1 ]; then
        completions="$COMMANDS $(eval TODOTXT_VERBOSE=0 $_todo_sh command listaddons) $OPTS"
    elif [[ $COMP_CWORD -gt 2 && ( \
        "${COMP_WORDS[COMP_CWORD-2]}" =~ ^(move|mv)$ || \
        "${COMP_WORDS[COMP_CWORD-3]}" =~ ^(move|mv)$ ) ]]; then
        # "move ITEM# DEST [SRC]" has file arguments on positions 2 and 3.
        completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listfile)
    else
        case "$prev" in
            command)
                completions=$COMMANDS;;
            addto|listfile|lf)
                completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listfile);;
            -*) completions="$COMMANDS $(eval TODOTXT_VERBOSE=0 $_todo_sh command listaddons) $OPTS";;
            *)  case "$cur" in
                    +*) completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listproj)
                        COMPREPLY=( $( compgen -W "$completions" -- $cur ))
                        [ ${#COMPREPLY[@]} -gt 0 ] && return 0
                        # Fall back to projects extracted from done tasks.
                        completions=$(eval 'TODOTXT_VERBOSE=0 TODOTXT_SOURCEVAR=\$DONE_FILE' $_todo_sh command listproj)
                        ;;
                    @*) completions=$(eval TODOTXT_VERBOSE=0 $_todo_sh command listcon)
                        COMPREPLY=( $( compgen -W "$completions" -- $cur ))
                        [ ${#COMPREPLY[@]} -gt 0 ] && return 0
                        # Fall back to contexts extracted from done tasks.
                        completions=$(eval 'TODOTXT_VERBOSE=0 TODOTXT_SOURCEVAR=\$DONE_FILE' $_todo_sh command listcon)
                        ;;
                    *)  if [[ "$cur" =~ ^[0-9]+$ ]]; then
                            # Remove the (padded) task number; we prepend the
                            # user-provided $cur instead.
                            # Remove the timestamp prepended by the -t option,
                            # and the done date (for done tasks); there's no
                            # todo.txt option for that yet.
                            # But keep priority and "x"; they're short and may
                            # provide useful context.
                            # Remove any trailing whitespace; the Bash
                            # completion inserts a trailing space itself.
                            # Finally, limit the output to a single line just as
                            # a safety check of the ls action output.
                            local todo=$( \
                                eval TODOTXT_VERBOSE=0 $_todo_sh '-@ -+ -p -x command ls "^ *${cur} "' | \
                                sed -e 's/^ *[0-9]\{1,\} //' -e 's/\((.) \)[0-9]\{2,4\}-[0-9]\{2\}-[0-9]\{2\} /\1/' \
                                    -e 's/\([xX] \)\([0-9]\{2,4\}-[0-9]\{2\}-[0-9]\{2\} \)\{1,2\}/\1/' \
                                    -e 's/[[:space:]]*$//' \
                                    -e '1q' \
                            )
                            # Append task text as a shell comment. This
                            # completion can be a safety check before a
                            # destructive todo.txt operation.
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

# If you define an alias (e.g. "t") to todo.sh, you need to explicitly enable
# completion for it, too:
#complete -F _todo t

# If you have renamed the todo.sh executable, or if it is not accessible through
# PATH, you need to add and use a wrapper completion function, like this:
#_todoElsewhere()
#{
#    local _todo_sh='/path/to/todo2.sh'
#    _todo "$@"
#}
#complete -F _todoElsewhere /path/to/todo2.sh

# If you use aliases to use different configuration(s), you need to add and use
# a wrapper completion function for each configuration if you want to complete
# fron the actual configured task locations:
#alias todo2='todo.sh -d "$HOME/todo2.cfg"'
#_todo2()
#{
#    local _todo_sh='todo.sh -d "$HOME/todo2.cfg"'
#    _todo "$@"
#}
#complete -F _todo2 todo2
