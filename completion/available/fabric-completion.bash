#!/usr/bin/env bash
#
# Bash completion support for Fabric (http://fabfile.org/)
#
#
# Copyright (C) 2011 by Konstantin Bakulin
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Thanks to:
# - Adam Vandenberg,
#   https://github.com/adamv/dotfiles/blob/master/completion_scripts/fab_completion.bash
#
# - Enrico Batista da Luz,
#   https://github.com/ricobl/dotfiles/blob/master/bin/fab_bash_completion
#


# Use cache files for fab tasks or not.
# If set to "false" command "fab --shortlist" will be executed every time.
export FAB_COMPLETION_CACHE_TASKS=true

# File name where tasks cache will be stored (in current dir).
export FAB_COMPLETION_CACHED_TASKS_FILENAME=".fab_tasks~"


# Set command to get time of last file modification as seconds since Epoch
case `uname` in
    Darwin|FreeBSD)
        __FAB_COMPLETION_MTIME_COMMAND="stat -f '%m'"
        ;;
    *)
        __FAB_COMPLETION_MTIME_COMMAND="stat -c '%Y'"
        ;;
esac


#
# Get time of last fab cache file modification as seconds since Epoch
#
function __fab_chache_mtime() {
    ${__FAB_COMPLETION_MTIME_COMMAND} \
        $FAB_COMPLETION_CACHED_TASKS_FILENAME | xargs -n 1 expr
}


#
# Get time of last fabfile file/module modification as seconds since Epoch
#
function __fab_fabfile_mtime() {
    local f="fabfile"
    if [[ -e "$f.py" ]]; then
        ${__FAB_COMPLETION_MTIME_COMMAND} "$f.py" | xargs -n 1 expr
    else
        # Suppose that it's a fabfile dir
        find $f/*.py -exec ${__FAB_COMPLETION_MTIME_COMMAND} {} + \
            | xargs -n 1 expr | sort -n -r | head -1
    fi
}


#
# Completion for "fab" command
#
function __fab_completion() {
    # Return if "fab" command doesn't exists
    [[ -e `which fab 2> /dev/null` ]] || return 0

    # Variables to hold the current word and possible matches
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts=()

    # Generate possible matches and store them in variable "opts"
    case "${cur}" in
        -*)
            if [[ -z "${__FAB_COMPLETION_LONG_OPT}" ]]; then
                export __FAB_COMPLETION_LONG_OPT=$(
                    fab --help | egrep -o "\-\-[A-Za-z_\-]+\=?" | sort -u)
            fi
            opts="${__FAB_COMPLETION_LONG_OPT}"
            ;;

        # Completion for short options is not nessary.
        # It's left here just for history.
        # -*)
        #     if [[ -z "${__FAB_COMPLETION_SHORT_OPT}" ]]; then
        #         export __FAB_COMPLETION_SHORT_OPT=$(
        #             fab --help | egrep -o "^ +\-[A-Za-z_\]" | sort -u)
        #     fi
        #     opts="${__FAB_COMPLETION_SHORT_OPT}"
        #     ;;

        *)
            # If "fabfile.py" or "fabfile" dir with "__init__.py" file exists
            local f="fabfile"
            if [[ -e "$f.py" || (-d "$f" && -e "$f/__init__.py") ]]; then
                # Build a list of the available tasks
                if $FAB_COMPLETION_CACHE_TASKS; then
                    # If use cache
                    if [[ ! -s ${FAB_COMPLETION_CACHED_TASKS_FILENAME} ||
                          $(__fab_fabfile_mtime) -gt $(__fab_chache_mtime) ]]; then
                        fab --shortlist > ${FAB_COMPLETION_CACHED_TASKS_FILENAME} \
                            2> /dev/null
                    fi
                    opts=$(cat ${FAB_COMPLETION_CACHED_TASKS_FILENAME})
                else
                    # Without cache
                    opts=$(fab --shortlist 2> /dev/null)
                fi
            fi
            ;;
    esac

    # Set possible completions
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
}
complete -o default -o nospace -F __fab_completion fab
