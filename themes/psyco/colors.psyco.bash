#!/usr/bin/env bash

if [[ $COLORTERM = gnome-* && $TERM = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
        export TERM=gnome-256color
elif [[ $TERM != dumb ]] && infocmp xterm-256color >/dev/null 2>&1; then
        export TERM=xterm-256color
fi

if tput setaf 1 &> /dev/null; then
    tput sgr0
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
        red=$(tput setaf 9)      
        magenta=$(tput setaf 198)
        orange=$(tput setaf 202)
        green=$(tput setaf 28)
        purple=$(tput setaf 13)
        yellow=$(tput setaf 226)
        cyan=$(tput setaf 39)
        white=$(tput setaf 7)
        black=$(tput setaf 0)
        light_gray=$(tput setaf 240)
        dark_gray=$(tput setaf 235)
    else
        red=$(tput setaf 1)
        magenta=$(tput setaf 5)
        orange=$(tput setaf 4)
        green=$(tput setaf 2)
        purple=$(tput setaf 5)
        yellow=$(tput setaf 3)
        cyan=$(tput setaf 6)
        white=$(tput setaf 7)
        black=$(tput setaf 0)
        light_gray=$(tput setaf 0 && tput dim)
        dark_gray=$(tput setaf 0 && tput dim)
    fi
    bold=$(tput bold)
    dim=$(tput dim)
    underline=$(tput smul)
    reverse=$(tput rev)
    reset=$(tput sgr0)
else
    red="\033[31m"
    magenta="\033[95m"
    orange="\033[33m"
    green="\033[32m"
    purple="\033[35m"
    yellow="\033[93m"
    cyan="\033[36m"
    white="\033[97m"
    black="\033[30m"
    light_gray="\033[37m"
    dark_gray="\033[90m"
    bold="\033[1m"
    dim="\033[2m"
    underline="\033[4m"
    reverse="\033[7m"
    reset="\033[m"
fi

