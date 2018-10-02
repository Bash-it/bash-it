#!/usr/bin/env bash
# bash completion for virsh - main CLI of libvirt

# This script provides bash completion for virsh,
# borrowed from https://github.com/LuyaoHuang/virsh-bash-completion



_contain_cmd()
{
    local e f
    local array1=($1) array2=($2)
    
    for e in "${array1[@]}"
    do
        for f in "${array2[@]}"
        do
            if [[ "$e" == "$f" ]] ; then
                echo $e
                return
            fi
        done
    done

    echo "notfound"
    return
}

_virsh_list_networks()
{
    local flag_all=$1 flags

    if [ "$flag_all" -eq 1 ]; then
        flags="--all"
    else
        flags="--inactive"
    fi
    virsh -q net-list $flags | cut -d\  -f2 | awk '{print $1}'
}

_virsh_list_domains()
{
    local flag_all=$1 flags

    if [ "$flag_all" -eq 1 ]; then
        flags="--all"
    else
        flags="--inactive"
    fi
    virsh -q list $flags | cut -d\  -f7 | awk '{print $1}'
}

_virsh_list_pools()
{
    local flag_all=$1 flags

    if [ "$flag_all" -eq 1 ]; then
        flags="--all"
    else
        flags="--inactive"
    fi
    virsh -q pool-list $flags | cut -d\  -f2 | awk '{print $1}'
}

_virsh_list_ifaces()
{
    local flag_all=$1 flags

    if [ "$flag_all" -eq 1 ]; then
        flags="--all"
    else
        flags="--inactive"
    fi
    virsh -q iface-list $flags | cut -d\  -f2 | awk '{print $1}'
}

_virsh_list_nwfilters()
{

    virsh -q nwfilter-list | cut -d\  -f4 | awk '{print $1}'
}

_virsh() 
{
    local cur prev cmds doms options nets pools cmds_help
    local flag_all=1 array ret a b ifaces nwfilters files

#   not must use bash-completion now :)
#    _init_completion -s || return
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    cmds=$( echo "$(virsh -h| grep '^    ' | cut -d\  -f5)" \
            "$(virsh -h| grep '\--' | cut -d\  -f7 | cut -d= -f1)")
    cmds_help=$(virsh help| grep '^    ' | cut -d\  -f5)
    case "$prev" in
        --domain)
            doms=$(_virsh_list_domains "$flag_all")
            COMPREPLY=( $(compgen -W "$doms" -- "$cur") )
            return 0
            ;;
        --network)
            nets=$(_virsh_list_networks "$flag_all")
            COMPREPLY=( $(compgen -W "$nets" -- "$cur") )
            return 0
            ;;
        --pool)
            pools=$(_virsh_list_pools "$flag_all")
            COMPREPLY=( $(compgen -W "$pools" -- "$cur") )
            return 0
            ;;
        --interface)
            ifaces=$(_virsh_list_ifaces "$flag_all")
            COMPREPLY=( $(compgen -W "$ifaces" -- "$cur") )
            return 0
            ;;
        --nwfilter)
            nwfilters=$(_virsh_list_nwfilters)
            COMPREPLY=( $(compgen -W "$nwfilters" -- "$cur") )
            return 0
            ;;
        --file|--xml)
            files=$(ls)
            COMPREPLY=( $(compgen -W "$files" -- "$cur") )
            return 0
            ;;
    esac

    array=$(IFS=$'\n'; echo "${COMP_WORDS[*]}")
    ret=$(_contain_cmd "$array" "$cmds_help")

    if [[ "$ret" != "notfound" && "$ret" != "$cur" ]]; then
        a=$(virsh help "$ret" |grep '^    --'|cut -d\  -f5)
        b=$(virsh help "$ret" |grep '^    \[--'|cut -d\  -f5|cut -d[  -f2|cut -d]  -f1)
        options=$( echo $a $b )
        COMPREPLY=( $(compgen -W "$options" -- "$cur") )
        return 0
    fi

    case "$cur" in
        *)
            COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
            return 0
            ;;
    esac
} &&
complete -o default -F _virsh virsh
