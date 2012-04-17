#!/usr/bin/env bash

# tmux completion
# See: http://www.debian-administration.org/articles/317 for how to write more.
# Usage: Put "source bash_completion_tmux.sh" into your .bashrc
# Based upon the example at http://paste-it.appspot.com/Pj4mLycDE

_tmux_expand () 
{ 
    [ "$cur" != "${cur%\\}" ] && cur="$cur"'\';
    if [[ "$cur" == \~*/* ]]; then
        eval cur=$cur;
    else
        if [[ "$cur" == \~* ]]; then
            cur=${cur#\~};
            COMPREPLY=($( compgen -P '~' -u $cur ));
            return ${#COMPREPLY[@]};
        fi;
    fi
}

_tmux_filedir () 
{ 
    local IFS='
';
    _tmux_expand || return 0;
    if [ "$1" = -d ]; then
        COMPREPLY=(${COMPREPLY[@]} $( compgen -d -- $cur ));
        return 0;
    fi;
    COMPREPLY=(${COMPREPLY[@]} $( eval compgen -f -- \"$cur\" ))
}

function _tmux_complete_client() {
    local IFS=$'\n'
    local cur="${1}"
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$(tmux -q list-clients | cut -f 1 -d ':')" -- "${cur}") )
}
function _tmux_complete_session() {
    local IFS=$'\n'
    local cur="${1}"
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "$(tmux -q list-sessions | cut -f 1 -d ':')" -- "${cur}") )
}
function _tmux_complete_window() {
    local IFS=$'\n'
    local cur="${1}"
    local session_name="$(echo "${cur}" | sed 's/\\//g' | cut -d ':' -f 1)"
    local sessions
    
    sessions="$(tmux -q list-sessions | sed -re 's/([^:]+:).*$/\1/')"
    if [[ -n "${session_name}" ]]; then
        sessions="${sessions}
$(tmux -q list-windows -t "${session_name}" | sed -re 's/^([^:]+):.*$/'"${session_name}"':\1/')"
    fi
    cur="$(echo "${cur}" | sed -e 's/:/\\\\:/')"
    sessions="$(echo "${sessions}" | sed -e 's/:/\\\\:/')"
    COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "${sessions}" -- "${cur}") )
}

_tmux() {
    local cur prev
    local i cmd cmd_index option option_index
    local opts=""
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [ ${prev} == -f ]; then
        _tmux_filedir
    else
    # Search for the command
    local skip_next=0
    for ((i=1; $i<=$COMP_CWORD; i++)); do
        if [[ ${skip_next} -eq 1 ]]; then
            #echo "Skipping"
            skip_next=0;
        elif [[ ${COMP_WORDS[i]} != -* ]]; then
            cmd="${COMP_WORDS[i]}"
            cmd_index=${i}
            break
        elif [[ ${COMP_WORDS[i]} == -f ]]; then
            skip_next=1
        fi
    done

    # Search for the last option command
    skip_next=0
    for ((i=1; $i<=$COMP_CWORD; i++)); do
        if [[ ${skip_next} -eq 1 ]]; then
            #echo "Skipping"
            skip_next=0;
        elif [[ ${COMP_WORDS[i]} == -* ]]; then
            option="${COMP_WORDS[i]}"
            option_index=${i}
            if [[ ${COMP_WORDS[i]} == -- ]]; then
                break;
            fi
        elif [[ ${COMP_WORDS[i]} == -f ]]; then
            skip_next=1
        fi
    done

    if [[ $COMP_CWORD -le $cmd_index ]]; then
        # The user has not specified a command yet
        local all_commands="$(tmux -q list-commands | cut -f 1 -d ' ')"
        COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "${all_commands}" -- "${cur}") )
    else        
        case ${cmd} in
            attach-session|attach)
            case "$prev" in
                -t) _tmux_complete_session "${cur}" ;;
                *) options="-t -d" ;;
            esac ;;
            detach-client|detach)
            case "$prev" in
                -t) _tmux_complete_client "${cur}" ;;
                *) options="-t" ;;
            esac ;;
            lock-client|lockc)
            case "$prev" in
                -t) _tmux_complete_client "${cur}" ;;
                *) options="-t" ;;
            esac ;;
            lock-session|locks)
            case "$prev" in
                -t) _tmux_complete_session "${cur}" ;;
                *) options="-t -d" ;;
            esac ;;
            new-session|new)
            case "$prev" in
                -t) _tmux_complete_session "${cur}" ;;
                -[n|d|s]) options="-d -n -s -t --" ;;
                *) 
                if [[ ${COMP_WORDS[option_index]} == -- ]]; then
                    _command_offset ${option_index}
                else
                    options="-d -n -s -t --"
                fi
                ;;
            esac
            ;;
            refresh-client|refresh)
            case "$prev" in
                -t) _tmux_complete_client "${cur}" ;;
                *) options="-t" ;;
            esac ;;
            rename-session|rename)
            case "$prev" in
                -t) _tmux_complete_session "${cur}" ;;
                *) options="-t" ;;
            esac ;;
            source-file|source) _tmux_filedir ;;
            has-session|has|kill-session)
            case "$prev" in
                -t) _tmux_complete_session "${cur}" ;;
                *) options="-t" ;;
            esac ;;
            suspend-client|suspendc)
            case "$prev" in
                -t) _tmux_complete_client "${cur}" ;;
                *) options="-t" ;;
            esac ;;
            switch-client|switchc)
            case "$prev" in
                -c) _tmux_complete_client "${cur}" ;;
                -t) _tmux_complete_session "${cur}" ;;
                *) options="-l -n -p -c -t" ;;
            esac ;;
            
            send-keys|send)
            case "$option" in
                -t) _tmux_complete_window "${cur}" ;;
                *) options="-t" ;;
            esac ;;
          esac # case ${cmd}
        fi # command specified
      fi # not -f 
            
      if [[ -n "${options}" ]]; then
          COMPREPLY=( ${COMPREPLY[@]:-} $(compgen -W "${options}" -- "${cur}") )
      fi
            
      return 0

}
complete -F _tmux tmux

# END tmux completion

