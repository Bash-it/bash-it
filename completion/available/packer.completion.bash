#!/usr/bin/env bash

# Packer (http://www.packer.io) bash completion
#
# This script provides bash completion for packer and supports:
#
# - template filename completion (*.json) in cwd
# - support for basic options (i.e.. -debug)
# - support for complex options (i.e. -parallel=[true|false]
#
# The scirpt has been successfully tested with packer-0.6.0 and the
# following OS:
#
# - OS X 10.9
# - CentOS-6.5
# - Ubuntu 12.04 Server
#
# The script technically is heavily inspired by the git-completion.bash
# script. Kudos to Shawn O. Pearce <spearce@spearce.org> and all other
# contributors for the inspiration and especially to the bash-completion
# team in general.
#
# Copyright (c) 2014 IT Services Department, University of Bern
#
# This script is licensed under the MIT License (MIT)
# For licsense details see the LICENSE file included in the repository
# or read the license text at http://opensource.org/licenses/MIT.
#

# Generates completion reply, appending a space to possible completion words,
# if necessary.
# It accepts 2 arguments though the second is optional:
# 1: List of possible completion words.
# 2: Generate possible completion matches for this word (optional).
__packercomp ()
{
    local cur_="${2-$cur}"

    case "$cur_" in
    -*=)
        ;;
    *)
        local c i=0 IFS=$' \t\n'
        for c in $1; do
            if [[ $c == "$cur_"* ]]; then
                case $c in
                    -*=*|*.) ;;
                    *) c="$c " ;;
                esac
                COMPREPLY[i++]="$c"
            fi
        done
        ;;
    esac
}

# Generates completion reply for template files in cwd.
__packercomp_template_file ()
{
    local IFS=$'\n'

    COMPREPLY=($(compgen -S " " -A file -X '!*.json' -- "${cur}"))
}

# Generates completion for the build command.
__packer_build ()
{
    local builders="
        amazon-ebs amazon-instance amazon-chroot digitalocean docker
        googlecompute openstack parallels-iso parallels-pvm qemu
        virtualbox-iso virtualbox-ovf vmware-iso vmware-vmx"

    case "$cur" in
        -parallel=*)
            __packercomp "false true" "${cur##-parallel=}"
            return
            ;;
        -except=*)
            __packercomp "$builders" "${cur##-except=}"
            return
            ;;
        -only=*)
            __packercomp "$builders" "${cur##-only=}"
            return
            ;;
        -*)
            __packercomp "-debug -force -machine-readable -except= -only= -parallel= -var -var-file"
            return
            ;;
        *)
    esac

    __packercomp_template_file
}

# Generates completion for the fix command.
__packer_fix ()
{
    __packercomp_template_file
}

# Generates completion for the inspect command.
__packer_inspect ()
{
    case "$cur" in
        -*)
            __packercomp "-machine-readable"
            return
            ;;
        *)
    esac

    __packercomp_template_file
}

# Generates completion for the validate command.
__packer_validate ()
{
    __packercomp_template_file
}

# Main function for packer completion.
#
# Searches for a command in $COMP_WORDS. If one is found
# the appropriate function from above is called, if not
# completion for global options is done.
_packer_completion ()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    # Words containing an equal sign get split into tokens in bash > 4, which
    # doesn't come in handy here.
    # This is handled here. bash < 4 does not split.
    declare -f _get_comp_words_by_ref >/dev/null && _get_comp_words_by_ref -n = cur

    COMPREPLY=()
    local i c=1 command

    while [ $c -lt $COMP_CWORD ]; do
        i="${COMP_WORDS[c]}"
        case "$i" in
            -*) ;;
            *) command="$i"; break ;;
        esac
        ((c++))
    done

    if [ -z $command ]; then
        case "$cur" in
            '-'*)
                __packercomp "-machine-readable --help --version"
                ;;
            *)
                __packercomp "build fix inspect validate"
                ;;
        esac
        return
    fi

    local completion_func="__packer_${command}"
    declare -f $completion_func >/dev/null && $completion_func
}

complete -o nospace -F _packer_completion packer

