#!/bin/bash

cite about-plugin
about-plugin '/etc/hosts based operations'

___HOST_FILE="/etc/hosts"

function ___hosts_add {
    local ENTRY=`grep "$2" $___HOST_FILE`
    if  [[ $ENTRY != "" ]]
    then
        echo "Host "$2" already added"
        echo $ENTRY
    else
        echo "$1 $2" | sudo tee -a $___HOST_FILE > /dev/null
        echo "Added $1 $2 to hosts file"
        exit 1
    fi
}

function ___hosts_list {
    cat $___HOST_FILE
}

function ___hosts_remove {
    local ENTRY=`grep "$1" $___HOST_FILE`
    if  [[ $ENTRY != "" ]]
    then
        DELETED=`grep -w -v $1 $___HOST_FILE`
        echo "$DELETED" | sudo tee $___HOST_FILE > /dev/null
        echo "Removed \""$ENTRY"\" from hosts file"
    else
        echo "Host "$1" not found"
        exit 1
    fi
}

function ___hosts_help {
    echo -e "usage: hosts [add|list|remove] ip_address host_name"
    echo
    echo -e  "commands:"
    echo -e "\tadd\tMaps the hostname with ip and adds it to $___HOST_FILE"
    echo -e "\tlist\tList all the hostname and ip in $___HOST_FILE"
    echo -e "\tremove\tRemoved the entry from $___HOST_FILE based on host_name"
    echo
    echo -e "examples:"
    echo -e "\t$ host add 127.0.0.1 my_localhost"
    
}

# the validator function
function ___hosts_validate {
    if [[ $1 == "" || $2 == "" ]]
    then
        return 0;
    else
        return 1;
    fi
}


function hosts {
    # entry point
    case $1 in
        "add")
            ___hosts_validate $2 $3
            if [[ $? == 0 ]]
            then
                ___hosts_help
                exit 1
            else
                ___hosts_add $2 $3
            fi
        ;;
        "list")
            ___hosts_list
        ;;
        "remove")
            ___hosts_validate $2 "dummy" # sending dummy to verify only one argument
            if [[ $? == 0 ]]
            then
                ___hosts_help
                exit 1
            else
                ___hosts_remove $2
            fi
        ;;
        *)
            ___hosts_help
        ;;
    esac
}