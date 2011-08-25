#!/bin/bash

# For generic functions.

function ips {
  ifconfig | grep "inet " | awk '{ print $2 }'
}

function down4me() {
  curl -s "http://www.downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
}

function myip {
  res=$(curl -s checkip.dyndns.org | grep -Eo '[0-9\.]+')
  echo "Your public IP is: ${bold_green} $res ${normal}"
}

pass() {
  which gshuf &> /dev/null
  if [ $? -eq 1 ]
  then
    echo "Error: shuf isn't installed!"
    return 1
  fi

  pass=$(shuf -n4 /usr/share/dict/words | tr '\n' ' ')
  echo "With spaces (easier to memorize): $pass"
  echo "Without (use this as the pass): $(echo $pass | tr -d ' ')"
}

# Function for previewing markdown files in the browser

function pmdown() {
  if command -v markdown &>/dev/null
  then
    markdown $1 | browser
  else
    echo "You don't have a markdown command installed!"
  fi
}

# Make a directory and immediately 'cd' into it

function mkcd() {
  mkdir -p "$*"
  cd "$*"
}

# Search through directory contents with grep

function lsgrep(){
  ls | grep "$*"
}

# View man documentation in Preview
pman () {
   man -t "${1}" | open -f -a $PREVIEW
}


pcurl() {
  curl "${1}" | open -f -a $PREVIEW
}

pri() {
  ri -T "${1}" | open -f -a $PREVIEW
}

quiet() {
	$* &> /dev/null &
}

banish-cookies() {
	rm -r ~/.macromedia ~/.adobe
	ln -s /dev/null ~/.adobe
	ln -s /dev/null ~/.macromedia
}

# disk usage per directory
# in Mac OS X and Linux
usage ()
{
    if [ $(uname) = "Darwin" ]; then
        if [ -n $1 ]; then
            du -hd $1
        else
            du -hd 1
        fi

    elif [ $(uname) = "Linux" ]; then
        if [ -n $1 ]; then
            du -h --max-depth=1 $1
        else
            du -h --max-depth=1
        fi
    fi
}

# One thing todo
function t() {
	 if [[ "$*" == "" ]] ; then
		 cat ~/.t
	 else
		 echo "$*" > ~/.t
	 fi
}

# Checks for existence of a command
command_exists () {
    type "$1" &> /dev/null ;
}

# List all plugins and functions defined by bash-it
function plugins-help() {
    
    echo "bash-it Plugins Help-Message"
    echo 

    set | grep "()" \
    | sed -e "/^_/d" | grep -v "BASH_ARGC=()" \
    | sed -e "/^\s/d" | grep -v "BASH_LINENO=()" \
    | grep -v "BASH_ARGV=()" \
    | grep -v "BASH_SOURCE=()" \
    | grep -v "DIRSTACK=()" \
    | grep -v "GROUPS=()" \
    | grep -v "BASH_CMDS=()" \
    | grep -v "BASH_ALIASES=()" \
    | grep -v "COMPREPLY=()" | sed -e "s/()//"
}

# back up file with timestamp
# useful for administrators and configs
buf () {
    filename=$1
    filetime=$(date +%Y%m%d_%H%M%S)
    cp ${filename} ${filename}_${filetime}
}
