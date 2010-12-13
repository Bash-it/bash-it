#!/bin/bash
# hcht.plugin.bash: the handmade commandline history tool
# Copyright: (C) 2010 Florian Baumann <flo@noqqe.de>
# License: GPL-3 <http://www.gnu.org/licenses/gpl-3.0.txt>
# Date: Dienstag 2010-11-30

### readme 
# basiclly the handmade commandline history tool was made for storing
# informations. yeah, you're right. sounds a bit boring. many other
# applications can do this much better. but storing things from commandline? 
# 
# hcht was fitted to work at your terminal. 
# your daily stuff like notices, todos, commands or output from a command. 
# all these things will be stored without complex syntax. 
# 
# once you defined your storing-directory you will be able to easily
# save all the stuff listed above. 
#

### create a file
# the basic feature. open a file, do stuff and save.
#
# $ hcht evilcommand.hch
#
# this will create a new file or edit a existing one. 
# paste your command or notice in your favorite editor

### show all stored informations
# to get an overview of your storedir:
#
# $ hcht

### todo with a whole sentence
# you can give hcht a bunch of parameters
#
# $ hcht this is a long reminder about a anything

### save last executed command
# lets say you did a great hack at your system and you
# want to save it without complicated use of coping:
#
# $ hcht !! 
#
# the "!!" will repeat the _last_ command you executed at 
# your terminal. after asking you about a name the hch file 
# will be saved.  

### read from stdin
# hcht is also able to read anything from stdin. 
#
# $ cat any_important_logfile | hcht anylog 
#
# "anylog" will be the name of the saved file.  

hcht() {
    # configured?
    if [ -z $hchtstoredir ]; then
        echo "ERROR: handmade commandline history tool isn't configured."
        return 1
    else
        hchtstoredir=$(echo $hchtstoredir | sed -e 's/\/$//')
    fi

    # dir available?
    if [ ! -d $hchtstoredir ]; then
        echo "ERROR: No such directory: $hchtstoredir"
        return 1
    fi

    # get favorite editor
    if [ -z $EDITOR ]; then
        EDITOR=$(which vim || which nano)
    fi

    # check if stdin-data is present and save content
    if [ "$(tty)" = "not a tty" ]; then
        hchname=$(echo $1 | sed -e 's/\ //g')
        if [ -z $hchname ]; then
            cat < /dev/stdin >> $hchtstoredir/$(date +%Y%m%d%H%M%S).hch
        else
            cat < /dev/stdin >> $hchtstoredir/$hchname.hch
        fi
        return 0
    fi

    # list all hch files if no parameter is given
    if [ $# -eq 0 ]; then
        for file in $(ls $hchtstoredir); do
            echo $file
        done
        return 0
    fi

    # if a *.hch file is given start editing or creating it
    if [ "$#" -eq "1" ]; then 
        if echo "$1" | grep -q -e ".*.hch$" ; then
            $EDITOR ${hchtstoredir}/${1}
            return 0
        else 
            $EDITOR ${hchtstoredir}/${1}.hch
            return 0
        fi
    fi

    # autocreate a new hch  
    if [ "$#" -gt "1" ]; then
        echo -n "define a name: " ; read hchname
        hchname=$(echo $hchname | sed -e 's/\ /_/g')
        if [ -z "$hchname" ]; then
            echo "$*" > $hchtstoredir/${1}-$(date +%Y%m%d%H%M%S).hch
        else
            echo "$*" > ${hchtstoredir}/${hchname}.hch
        fi
        return 0
    fi    
}
