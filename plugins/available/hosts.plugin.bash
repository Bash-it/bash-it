#!/bin/bash

# cite about-plugin
# about-plugin '/etc/hosts based operations'

FILE="/etc/hosts"

function hosts_add {
    local ENTRY=`grep "$2" $FILE`
    if  [[ $ENTRY != "" ]]
    then
        echo "Host "$2" already added"
        echo $ENTRY
    else
        echo "$1 $2" | sudo tee -a /etc/hosts > /dev/null
        echo "Added $1 $2 to hosts file"
        exit 1
    fi
}

function hosts_list {
    cat $FILE
}

function hosts_remove {
    local ENTRY=`grep "$1" $FILE`
    if  [[ $ENTRY != "" ]]
    then
        DELETED=`grep -w -v $1 $FILE`
        echo "$DELETED" | sudo tee /etc/hosts > /dev/null
        echo "Removed \""$ENTRY"\" from hosts file"
    else
        echo "Host "$1" not found"
        exit 1
    fi
}

function help {
    echo -e "usage: hosts [add|list|remove] ip_address host_name"
    echo
    echo -e  "commands:"
    echo -e "\tadd\tMaps the hostname with ip and adds it to $FILE"
    echo -e "\tlist\tList all the hostname and ip in $FILE"
    echo -e "\tremove\tRemoved the entry from $FILE based on host_name"
    echo
    echo -e "examples:"
    echo -e "\t$ host add 127.0.0.1 my_localhost"
    
}

# the validator function
function validate {
    if [[ $1 == "" || $2 == "" ]]
    then
        return 0;
    else
        return 1;
    fi
}


# entry point
case $1 in
    "add")
        validate $2 $3
        if [[ $? == 0 ]]
        then
            help
            exit 1
        else
            hosts_add $2 $3
        fi
    ;;
    "list")
        hosts_list
    ;;
    "remove")
        validate $2 "dummy" # sending dummy to verify only one argument
        if [[ $? == 0 ]]
        then
            help
            exit 1
        else
            hosts_remove $2
        fi
    ;;
    *)
        help
    ;;
esac