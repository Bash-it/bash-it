#!/bin/bash

# green=$'\e[0;32m'
# red=$'\e[0;31m'
# blue=$'\e[0;34m'
# white=$'\e[1;37m'
# black=$'\e[0;30m'
# yellow=$'\e[0;33m'
# purple=$'\e[0;35m'
# cyan=$'\e[0;36m'
# orange=$'\e[33;40m'
# 
# 
# bold_green=$'\e[1;32m'
# bold_red=$'\e[1;31m'
# bold_blue=$'\e[1;34m'
# bold_yellow=$'\e[1;33m'
# bold_purple=$'\e[1;35m'
# bold_cyan=$'\e[1;36m'
# bold_orange=$'\e[1;33;40m'
# 
# normal=$'\e[00m'
# reset_color=$'\e[39m'



ESC="\033"
NON_BOLD=0
BOLD=1

# Foreground
FG_BLACK=30
FG_RED=31
FG_GREEN=32
FG_YELLOW=33
FG_BLUE=34
FG_VIOLET=35
FG_CYAN=36
FG_WHITE=37
FG_ORANGE='33;40'
FG_NULL=00

# Background
BG_BLACK=40
BG_RED=41
BG_GREEN=42
BG_YELLOW=43
BG_BLUE=44
BG_VIOLET=45
BG_CYAN=46
BG_WHITE=47
BG_NULL=00


normal="\[$ESC[m\]"
reset_color="\[$ESC[${NON_BOLD};${FG_WHITE};${BG_NULL}m\]"

# Non-bold
black="\[$ESC[${NON_BOLD};${FG_BLACK}m\]"
red="\[$ESC[${NON_BOLD};${FG_RED}m\]"
green="\[$ESC[${NON_BOLD};${FG_GREEN}m\]"
yellow="\[$ESC[${NON_BOLD};${FG_YELLOW}m\]"
blue="\[$ESC[${NON_BOLD};${FG_BLUE}m\]"
purple="\[$ESC[${NON_BOLD};${FG_VIOLET}m\]"
cyan="\[$ESC[${NON_BOLD};${FG_CYAN}m\]"
white="\[$ESC[${NON_BOLD};${FG_WHITE}m\]"
orange="\[$ESC[${NON_BOLD};${FG_ORANGE}m\]"


# Bold
bold_black="\[$ESC[${BOLD};${FG_BLACK}m\]"
bold_red="\[$ESC[${BOLD};${FG_RED}m\]"
bold_green="\[$ESC[${BOLD};${FG_GREEN}m\]"
bold_yellow="\[$ESC[${BOLD};${FG_YELLOW}m\]"
bold_blue="\[$ESC[${BOLD};${FG_BLUE}m\]"
bold_purple="\[$ESC[${BOLD};${FG_VIOLET}m\]"
bold_cyan="\[$ESC[${BOLD};${FG_CYAN}m\]"
bold_white="\[$ESC[${BOLD};${FG_WHITE}m\]"
bold_orange="\[$ESC[${BOLD};${FG_ORANGE}m\]"