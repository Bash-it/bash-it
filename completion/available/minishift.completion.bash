
# Copyright 2016 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# bash completion for minishift                            -*- shell-script -*-

__debug()
{
    if [[ -n ${BASH_COMP_DEBUG_FILE} ]]; then
        echo "$*" >> "${BASH_COMP_DEBUG_FILE}"
    fi
}

# Homebrew on Macs have version 1.3 of bash-completion which doesn't include
# _init_completion. This is a very minimal version of that function.
__my_init_completion()
{
    COMPREPLY=()
    _get_comp_words_by_ref "$@" cur prev words cword
}

__index_of_word()
{
    local w word=$1
    shift
    index=0
    for w in "$@"; do
        [[ $w = "$word" ]] && return
        index=$((index+1))
    done
    index=-1
}

__contains_word()
{
    local w word=$1; shift
    for w in "$@"; do
        [[ $w = "$word" ]] && return
    done
    return 1
}

__handle_reply()
{
    __debug "${FUNCNAME[0]}"
    case $cur in
        -*)
            if [[ $(type -t compopt) = "builtin" ]]; then
                compopt -o nospace
            fi
            local allflags
            if [ ${#must_have_one_flag[@]} -ne 0 ]; then
                allflags=("${must_have_one_flag[@]}")
            else
                allflags=("${flags[*]} ${two_word_flags[*]}")
            fi
            COMPREPLY=( $(compgen -W "${allflags[*]}" -- "$cur") )
            if [[ $(type -t compopt) = "builtin" ]]; then
                [[ "${COMPREPLY[0]}" == *= ]] || compopt +o nospace
            fi

            # complete after --flag=abc
            if [[ $cur == *=* ]]; then
                if [[ $(type -t compopt) = "builtin" ]]; then
                    compopt +o nospace
                fi

                local index flag
                flag="${cur%%=*}"
                __index_of_word "${flag}" "${flags_with_completion[@]}"
                COMPREPLY=()
                if [[ ${index} -ge 0 ]]; then
                    PREFIX=""
                    cur="${cur#*=}"
                    ${flags_completion[${index}]}
                    if [ -n "${ZSH_VERSION}" ]; then
                        # zfs completion needs --flag= prefix
                        eval "COMPREPLY=( \"\${COMPREPLY[@]/#/${flag}=}\" )"
                    fi
                fi
            fi
            return 0;
            ;;
    esac

    # check if we are handling a flag with special work handling
    local index
    __index_of_word "${prev}" "${flags_with_completion[@]}"
    if [[ ${index} -ge 0 ]]; then
        ${flags_completion[${index}]}
        return
    fi

    # we are parsing a flag and don't have a special handler, no completion
    if [[ ${cur} != "${words[cword]}" ]]; then
        return
    fi

    local completions
    completions=("${commands[@]}")
    if [[ ${#must_have_one_noun[@]} -ne 0 ]]; then
        completions=("${must_have_one_noun[@]}")
    fi
    if [[ ${#must_have_one_flag[@]} -ne 0 ]]; then
        completions+=("${must_have_one_flag[@]}")
    fi
    COMPREPLY=( $(compgen -W "${completions[*]}" -- "$cur") )

    if [[ ${#COMPREPLY[@]} -eq 0 && ${#noun_aliases[@]} -gt 0 && ${#must_have_one_noun[@]} -ne 0 ]]; then
        COMPREPLY=( $(compgen -W "${noun_aliases[*]}" -- "$cur") )
    fi

    if [[ ${#COMPREPLY[@]} -eq 0 ]]; then
        declare -F __custom_func >/dev/null && __custom_func
    fi

    __ltrim_colon_completions "$cur"
}

# The arguments should be in the form "ext1|ext2|extn"
__handle_filename_extension_flag()
{
    local ext="$1"
    _filedir "@(${ext})"
}

__handle_subdirs_in_dir_flag()
{
    local dir="$1"
    pushd "${dir}" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1
}

__handle_flag()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    # if a command required a flag, and we found it, unset must_have_one_flag()
    local flagname=${words[c]}
    local flagvalue
    # if the word contained an =
    if [[ ${words[c]} == *"="* ]]; then
        flagvalue=${flagname#*=} # take in as flagvalue after the =
        flagname=${flagname%%=*} # strip everything after the =
        flagname="${flagname}=" # but put the = back
    fi
    __debug "${FUNCNAME[0]}: looking for ${flagname}"
    if __contains_word "${flagname}" "${must_have_one_flag[@]}"; then
        must_have_one_flag=()
    fi

    # if you set a flag which only applies to this command, don't show subcommands
    if __contains_word "${flagname}" "${local_nonpersistent_flags[@]}"; then
      commands=()
    fi

    # keep flag value with flagname as flaghash
    if [ -n "${flagvalue}" ] ; then
        flaghash[${flagname}]=${flagvalue}
    elif [ -n "${words[ $((c+1)) ]}" ] ; then
        flaghash[${flagname}]=${words[ $((c+1)) ]}
    else
        flaghash[${flagname}]="true" # pad "true" for bool flag
    fi

    # skip the argument to a two word flag
    if __contains_word "${words[c]}" "${two_word_flags[@]}"; then
        c=$((c+1))
        # if we are looking for a flags value, don't show commands
        if [[ $c -eq $cword ]]; then
            commands=()
        fi
    fi

    c=$((c+1))

}

__handle_noun()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    if __contains_word "${words[c]}" "${must_have_one_noun[@]}"; then
        must_have_one_noun=()
    elif __contains_word "${words[c]}" "${noun_aliases[@]}"; then
        must_have_one_noun=()
    fi

    nouns+=("${words[c]}")
    c=$((c+1))
}

__handle_command()
{
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"

    local next_command
    if [[ -n ${last_command} ]]; then
        next_command="_${last_command}_${words[c]//:/__}"
    else
        if [[ $c -eq 0 ]]; then
            next_command="_$(basename "${words[c]//:/__}")"
        else
            next_command="_${words[c]//:/__}"
        fi
    fi
    c=$((c+1))
    __debug "${FUNCNAME[0]}: looking for ${next_command}"
    declare -F "$next_command" >/dev/null && $next_command
}

__handle_word()
{
    if [[ $c -ge $cword ]]; then
        __handle_reply
        return
    fi
    __debug "${FUNCNAME[0]}: c is $c words[c] is ${words[c]}"
    if [[ "${words[c]}" == -* ]]; then
        __handle_flag
    elif __contains_word "${words[c]}" "${commands[@]}"; then
        __handle_command
    elif [[ $c -eq 0 ]] && __contains_word "$(basename "${words[c]}")" "${commands[@]}"; then
        __handle_command
    else
        __handle_noun
    fi
    __handle_word
}

_minishift_addons_apply()
{
    last_command="minishift_addons_apply"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--addon-env=")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--addon-env=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons_disable()
{
    last_command="minishift_addons_disable"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons_enable()
{
    last_command="minishift_addons_enable"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--priority=")
    local_nonpersistent_flags+=("--priority=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons_install()
{
    last_command="minishift_addons_install"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--defaults")
    local_nonpersistent_flags+=("--defaults")
    flags+=("--enable")
    local_nonpersistent_flags+=("--enable")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons_list()
{
    last_command="minishift_addons_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--verbose")
    local_nonpersistent_flags+=("--verbose")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons_remove()
{
    last_command="minishift_addons_remove"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--addon-env=")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--addon-env=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons_uninstall()
{
    last_command="minishift_addons_uninstall"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_addons()
{
    last_command="minishift_addons"
    commands=()
    commands+=("apply")
    commands+=("disable")
    commands+=("enable")
    commands+=("install")
    commands+=("list")
    commands+=("remove")
    commands+=("uninstall")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_completion()
{
    last_command="minishift_completion"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--help")
    flags+=("-h")
    local_nonpersistent_flags+=("--help")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_config_get()
{
    last_command="minishift_config_get"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--global")
    local_nonpersistent_flags+=("--global")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_config_set()
{
    last_command="minishift_config_set"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--global")
    local_nonpersistent_flags+=("--global")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_config_unset()
{
    last_command="minishift_config_unset"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--global")
    local_nonpersistent_flags+=("--global")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_config_view()
{
    last_command="minishift_config_view"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--format=")
    local_nonpersistent_flags+=("--format=")
    flags+=("--global")
    local_nonpersistent_flags+=("--global")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_config()
{
    last_command="minishift_config"
    commands=()
    commands+=("get")
    commands+=("set")
    commands+=("unset")
    commands+=("view")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_console()
{
    last_command="minishift_console"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--machine-readable")
    local_nonpersistent_flags+=("--machine-readable")
    flags+=("--request-oauth-token")
    local_nonpersistent_flags+=("--request-oauth-token")
    flags+=("--url")
    local_nonpersistent_flags+=("--url")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_delete()
{
    last_command="minishift_delete"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--clear-cache")
    local_nonpersistent_flags+=("--clear-cache")
    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_docker-env()
{
    last_command="minishift_docker-env"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--no-proxy")
    local_nonpersistent_flags+=("--no-proxy")
    flags+=("--shell=")
    local_nonpersistent_flags+=("--shell=")
    flags+=("--unset")
    flags+=("-u")
    local_nonpersistent_flags+=("--unset")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_hostfolder_add()
{
    last_command="minishift_hostfolder_add"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--instance-only")
    local_nonpersistent_flags+=("--instance-only")
    flags+=("--interactive")
    flags+=("-i")
    local_nonpersistent_flags+=("--interactive")
    flags+=("--options=")
    local_nonpersistent_flags+=("--options=")
    flags+=("--source=")
    local_nonpersistent_flags+=("--source=")
    flags+=("--target=")
    local_nonpersistent_flags+=("--target=")
    flags+=("--type=")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--type=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_hostfolder_list()
{
    last_command="minishift_hostfolder_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_hostfolder_mount()
{
    last_command="minishift_hostfolder_mount"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_hostfolder_remove()
{
    last_command="minishift_hostfolder_remove"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_hostfolder_umount()
{
    last_command="minishift_hostfolder_umount"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_hostfolder()
{
    last_command="minishift_hostfolder"
    commands=()
    commands+=("add")
    commands+=("list")
    commands+=("mount")
    commands+=("remove")
    commands+=("umount")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_cache-config_add()
{
    last_command="minishift_image_cache-config_add"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_cache-config_remove()
{
    last_command="minishift_image_cache-config_remove"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_cache-config_view()
{
    last_command="minishift_image_cache-config_view"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_cache-config()
{
    last_command="minishift_image_cache-config"
    commands=()
    commands+=("add")
    commands+=("remove")
    commands+=("view")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_delete()
{
    last_command="minishift_image_delete"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    flags+=("-a")
    local_nonpersistent_flags+=("--all")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_export()
{
    last_command="minishift_image_export"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--log-to-file")
    local_nonpersistent_flags+=("--log-to-file")
    flags+=("--overwrite")
    local_nonpersistent_flags+=("--overwrite")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_import()
{
    last_command="minishift_image_import"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--all")
    local_nonpersistent_flags+=("--all")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image_list()
{
    last_command="minishift_image_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--vm")
    local_nonpersistent_flags+=("--vm")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_image()
{
    last_command="minishift_image"
    commands=()
    commands+=("cache-config")
    commands+=("delete")
    commands+=("export")
    commands+=("import")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_ip()
{
    last_command="minishift_ip"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--set-dhcp")
    local_nonpersistent_flags+=("--set-dhcp")
    flags+=("--set-static")
    local_nonpersistent_flags+=("--set-static")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_logs()
{
    last_command="minishift_logs"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--follow")
    flags+=("-f")
    local_nonpersistent_flags+=("--follow")
    flags+=("--tail=")
    two_word_flags+=("-t")
    local_nonpersistent_flags+=("--tail=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_oc-env()
{
    last_command="minishift_oc-env"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--no-proxy")
    local_nonpersistent_flags+=("--no-proxy")
    flags+=("--shell=")
    local_nonpersistent_flags+=("--shell=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_component_add()
{
    last_command="minishift_openshift_component_add"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_component_list()
{
    last_command="minishift_openshift_component_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_component()
{
    last_command="minishift_openshift_component"
    commands=()
    commands+=("add")
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_config_set()
{
    last_command="minishift_openshift_config_set"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--patch=")
    local_nonpersistent_flags+=("--patch=")
    flags+=("--target=")
    local_nonpersistent_flags+=("--target=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_config_view()
{
    last_command="minishift_openshift_config_view"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--target=")
    local_nonpersistent_flags+=("--target=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_config()
{
    last_command="minishift_openshift_config"
    commands=()
    commands+=("set")
    commands+=("view")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_registry()
{
    last_command="minishift_openshift_registry"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_restart()
{
    last_command="minishift_openshift_restart"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_service_list()
{
    last_command="minishift_openshift_service_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--namespace=")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_service()
{
    last_command="minishift_openshift_service"
    commands=()
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--https")
    local_nonpersistent_flags+=("--https")
    flags+=("--in-browser")
    local_nonpersistent_flags+=("--in-browser")
    flags+=("--namespace=")
    two_word_flags+=("-n")
    local_nonpersistent_flags+=("--namespace=")
    flags+=("--url")
    flags+=("-u")
    local_nonpersistent_flags+=("--url")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_version_list()
{
    last_command="minishift_openshift_version_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift_version()
{
    last_command="minishift_openshift_version"
    commands=()
    commands+=("list")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_openshift()
{
    last_command="minishift_openshift"
    commands=()
    commands+=("component")
    commands+=("config")
    commands+=("registry")
    commands+=("restart")
    commands+=("service")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_profile_copy()
{
    last_command="minishift_profile_copy"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_profile_delete()
{
    last_command="minishift_profile_delete"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_profile_list()
{
    last_command="minishift_profile_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_profile_set()
{
    last_command="minishift_profile_set"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_profile()
{
    last_command="minishift_profile"
    commands=()
    commands+=("copy")
    commands+=("delete")
    commands+=("list")
    commands+=("set")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_services_list()
{
    last_command="minishift_services_list"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_services_start()
{
    last_command="minishift_services_start"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_services_stop()
{
    last_command="minishift_services_stop"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_services()
{
    last_command="minishift_services"
    commands=()
    commands+=("list")
    commands+=("start")
    commands+=("stop")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_setup()
{
    last_command="minishift_setup"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--yes")
    flags+=("-y")
    local_nonpersistent_flags+=("--yes")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_ssh()
{
    last_command="minishift_ssh"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_start()
{
    last_command="minishift_start"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--addon-env=")
    two_word_flags+=("-a")
    local_nonpersistent_flags+=("--addon-env=")
    flags+=("--cpus=")
    local_nonpersistent_flags+=("--cpus=")
    flags+=("--disk-size=")
    local_nonpersistent_flags+=("--disk-size=")
    flags+=("--docker-env=")
    local_nonpersistent_flags+=("--docker-env=")
    flags+=("--docker-opt=")
    local_nonpersistent_flags+=("--docker-opt=")
    flags+=("--host-only-cidr=")
    local_nonpersistent_flags+=("--host-only-cidr=")
    flags+=("--http-proxy=")
    local_nonpersistent_flags+=("--http-proxy=")
    flags+=("--https-proxy=")
    local_nonpersistent_flags+=("--https-proxy=")
    flags+=("--insecure-registry=")
    local_nonpersistent_flags+=("--insecure-registry=")
    flags+=("--iso-url=")
    local_nonpersistent_flags+=("--iso-url=")
    flags+=("--memory=")
    local_nonpersistent_flags+=("--memory=")
    flags+=("--network-nameserver=")
    local_nonpersistent_flags+=("--network-nameserver=")
    flags+=("--no-proxy=")
    local_nonpersistent_flags+=("--no-proxy=")
    flags+=("--openshift-version=")
    local_nonpersistent_flags+=("--openshift-version=")
    flags+=("--password=")
    local_nonpersistent_flags+=("--password=")
    flags+=("--public-hostname=")
    local_nonpersistent_flags+=("--public-hostname=")
    flags+=("--registry-mirror=")
    local_nonpersistent_flags+=("--registry-mirror=")
    flags+=("--remote-ipaddress=")
    local_nonpersistent_flags+=("--remote-ipaddress=")
    flags+=("--remote-ssh-key=")
    local_nonpersistent_flags+=("--remote-ssh-key=")
    flags+=("--remote-ssh-user=")
    local_nonpersistent_flags+=("--remote-ssh-user=")
    flags+=("--routing-suffix=")
    local_nonpersistent_flags+=("--routing-suffix=")
    flags+=("--server-loglevel=")
    local_nonpersistent_flags+=("--server-loglevel=")
    flags+=("--skip-registration")
    local_nonpersistent_flags+=("--skip-registration")
    flags+=("--skip-registry-check")
    local_nonpersistent_flags+=("--skip-registry-check")
    flags+=("--skip-startup-checks")
    local_nonpersistent_flags+=("--skip-startup-checks")
    flags+=("--timezone=")
    local_nonpersistent_flags+=("--timezone=")
    flags+=("--username=")
    local_nonpersistent_flags+=("--username=")
    flags+=("--vm-driver=")
    local_nonpersistent_flags+=("--vm-driver=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_status()
{
    last_command="minishift_status"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_stop()
{
    last_command="minishift_stop"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--skip-unregistration")
    local_nonpersistent_flags+=("--skip-unregistration")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_update()
{
    last_command="minishift_update"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--force")
    flags+=("-f")
    local_nonpersistent_flags+=("--force")
    flags+=("--http-proxy=")
    local_nonpersistent_flags+=("--http-proxy=")
    flags+=("--https-proxy=")
    local_nonpersistent_flags+=("--https-proxy=")
    flags+=("--update-addons")
    local_nonpersistent_flags+=("--update-addons")
    flags+=("--version=")
    local_nonpersistent_flags+=("--version=")
    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift_version()
{
    last_command="minishift_version"
    commands=()

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

_minishift()
{
    last_command="minishift"
    commands=()
    commands+=("addons")
    commands+=("completion")
    commands+=("config")
    commands+=("console")
    commands+=("delete")
    commands+=("docker-env")
    commands+=("hostfolder")
    commands+=("image")
    commands+=("ip")
    commands+=("logs")
    commands+=("oc-env")
    commands+=("openshift")
    commands+=("profile")
    commands+=("services")
    commands+=("setup")
    commands+=("ssh")
    commands+=("start")
    commands+=("status")
    commands+=("stop")
    commands+=("update")
    commands+=("version")

    flags=()
    two_word_flags=()
    local_nonpersistent_flags=()
    flags_with_completion=()
    flags_completion=()

    flags+=("--alsologtostderr")
    flags+=("--log_backtrace_at=")
    flags+=("--log_dir=")
    flags+=("--logtostderr")
    flags+=("--profile=")
    flags+=("--show-libmachine-logs")
    flags+=("--stderrthreshold=")
    flags+=("--v=")
    two_word_flags+=("-v")
    flags+=("--vmodule=")

    must_have_one_flag=()
    must_have_one_noun=()
    noun_aliases=()
}

__start_minishift()
{
    local cur prev words cword
    declare -A flaghash 2>/dev/null || :
    if declare -F _init_completion >/dev/null 2>&1; then
        _init_completion -s || return
    else
        __my_init_completion -n "=" || return
    fi

    local c=0
    local flags=()
    local two_word_flags=()
    local local_nonpersistent_flags=()
    local flags_with_completion=()
    local flags_completion=()
    local commands=("minishift")
    local must_have_one_flag=()
    local must_have_one_noun=()
    local last_command
    local nouns=()

    __handle_word
}

if [[ $(type -t compopt) = "builtin" ]]; then
    complete -o default -F __start_minishift minishift
else
    complete -o default -o nospace -F __start_minishift minishift
fi

# ex: ts=4 sw=4 et filetype=sh
