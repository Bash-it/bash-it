#!/usr/bin/env bash
# vim: ft=bash ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for BASH
#
# (Converted from ZSH theme by Kenny Root)
# https://gist.github.com/kruton/8345450
#
# Updated & fixed by Erik Selberg erik@selberg.org 1/14/17
# Tested on MacOSX, Ubuntu, Amazon Linux
# Bash v3 and v4
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
# I recommend: https://github.com/powerline/fonts.git
# > git clone https://github.com/powerline/fonts.git fonts
# > cd fonts
# > install.sh

# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.

# Install:

# I recommend the following:
# $ cd home
# $ mkdir -p .bash/themes/agnoster-bash
# $ git clone https://github.com/speedenator/agnoster-bash.git .bash/themes/agnoster-bash

# then add the following to your .bashrc:

# export THEME=$HOME/.bash/themes/agnoster-bash/agnoster.bash
# if [[ -f $THEME ]]; then
#     export DEFAULT_USER=`whoami`
#     source $THEME
# fi

#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

# Generally speaking, this script has limited support for right
# prompts (ala powerlevel9k on zsh), but it's pretty problematic in Bash.
# The general pattern is to write out the right prompt, hit \r, then
# write the left. This is problematic for the following reasons:
# - Doesn't properly resize dynamically when you resize the terminal
# - Changes to the prompt (like clearing and re-typing, super common) deletes the prompt
# - Getting the right alignment via columns / tput cols is pretty problematic (and is a bug in this version)
# - Bash prompt escapes (like \h or \w) don't get interpolated
#
# all in all, if you really, really want right-side prompts without a
# ton of work, recommend going to zsh for now. If you know how to fix this,
# would appreciate it!

# note: requires bash v4+... Mac users - you often have bash3.
# 'brew install bash' will set you free
PROMPT_DIRTRIM=2 # bash4 and above

######################################################################
DEBUG=0
debug() {
	if [[ ${DEBUG} -ne 0 ]]; then
		echo >&2 -e $*
	fi
}

######################################################################
### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'
CURRENT_RBG='NONE'
SEGMENT_SEPARATOR=''
RIGHT_SEPARATOR=''
LEFT_SUBSEG=''
RIGHT_SUBSEG=''

text_effect() {
	case "$1" in
		reset) echo 0 ;;
		bold) echo 1 ;;
		underline) echo 4 ;;
	esac
}

# to add colors, see
# http://bitmote.com/index.php?post/2012/11/19/Using-ANSI-Color-Codes-to-Colorize-Your-Bash-Prompt-on-Linux
# under the "256 (8-bit) Colors" section, and follow the example for orange below
fg_color() {
	case "$1" in
		black) echo 30 ;;
		red) echo 31 ;;
		green) echo 32 ;;
		yellow) echo 33 ;;
		blue) echo 34 ;;
		magenta) echo 35 ;;
		cyan) echo 36 ;;
		white) echo 37 ;;
		orange) echo 38\;5\;166 ;;
	esac
}

bg_color() {
	case "$1" in
		black) echo 40 ;;
		red) echo 41 ;;
		green) echo 42 ;;
		yellow) echo 43 ;;
		blue) echo 44 ;;
		magenta) echo 45 ;;
		cyan) echo 46 ;;
		white) echo 47 ;;
		orange) echo 48\;5\;166 ;;
	esac
}

# TIL: declare is global not local, so best use a different name
# for codes (mycodes) as otherwise it'll clobber the original.
# this changes from BASH v3 to BASH v4.
ansi() {
	local seq
	declare -a mycodes=("${!1}")

	debug "ansi: ${!1} all: $* aka ${mycodes[@]}"

	seq=""
	for ((i = 0; i < ${#mycodes[@]}; i++)); do
		if [[ -n $seq ]]; then
			seq="${seq};"
		fi
		seq="${seq}${mycodes[$i]}"
	done
	debug "ansi debug:" '\\[\\033['${seq}'m\\]'
	echo -ne '\[\033['${seq}'m\]'
	# PR="$PR\[\033[${seq}m\]"
}

ansi_single() {
	echo -ne '\[\033['$1'm\]'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
	local bg fg
	declare -a codes

	debug "Prompting $1 $2 $3"

	# if commented out from kruton's original... I'm not clear
	# if it did anything, but it messed up things like
	# prompt_status - Erik 1/14/17

	#    if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
	codes=("${codes[@]}" $(text_effect reset))
	#    fi
	if [[ -n $1 ]]; then
		bg=$(bg_color $1)
		codes=("${codes[@]}" $bg)
		debug "Added $bg as background to codes"
	fi
	if [[ -n $2 ]]; then
		fg=$(fg_color $2)
		codes=("${codes[@]}" $fg)
		debug "Added $fg as foreground to codes"
	fi

	debug "Codes: "
	# declare -p codes

	if [[ $CURRENT_BG != NONE && $1 != $CURRENT_BG ]]; then
		declare -a intermediate=($(fg_color $CURRENT_BG) $(bg_color $1))
		debug "pre prompt " $(ansi intermediate[@])
		PR="$PR $(ansi intermediate[@])$SEGMENT_SEPARATOR"
		debug "post prompt " $(ansi codes[@])
		PR="$PR$(ansi codes[@]) "
	else
		debug "no current BG, codes is $codes[@]"
		PR="$PR$(ansi codes[@]) "
	fi
	CURRENT_BG=$1
	[[ -n $3 ]] && PR="$PR$3"
}

# End the prompt, closing any open segments
prompt_end() {
	if [[ -n $CURRENT_BG ]]; then
		declare -a codes=($(text_effect reset) $(fg_color $CURRENT_BG))
		PR="$PR $(ansi codes[@])$SEGMENT_SEPARATOR"
	fi
	declare -a reset=($(text_effect reset))
	PR="$PR $(ansi reset[@])"
	CURRENT_BG=''
}

### virtualenv prompt
prompt_virtualenv() {
	if [[ -n $VIRTUAL_ENV ]]; then
		color=cyan
		prompt_segment $color $PRIMARY_FG
		ve=$(basename "$VIRTUAL_ENV")
		prompt_segment $color white "$ve"
	fi
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
	local user=$(whoami)

	if [[ $user != $DEFAULT_USER || -n $SSH_CLIENT ]]; then
		prompt_segment black default "$user@\h"
	fi
}

# prints history followed by HH:MM, useful for remembering what
# we did previously
prompt_histdt() {
	prompt_segment black default "\! [\A]"
}

git_status_dirty() {
	dirty=$(git status -s 2> /dev/null | tail -n 1)
	[[ -n $dirty ]] && echo " ●"
}

# Git: branch/detached head, dirty status
prompt_git() {
	local ref dirty
	if $(git rev-parse --is-inside-work-tree > /dev/null 2>&1); then
		ZSH_THEME_GIT_PROMPT_DIRTY='±'
		dirty=$(git_status_dirty)
		ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev | head -n1 2> /dev/null)"
		if [[ -n $dirty ]]; then
			prompt_segment yellow black
		else
			prompt_segment green black
		fi
		PR="$PR${ref/refs\/heads\// }$dirty"
	fi
}

# Dir: current working directory
prompt_dir() {
	prompt_segment blue black '\w'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
	local symbols
	symbols=()
	[[ $RETVAL -ne 0 ]] && symbols+="$(ansi_single $(fg_color red))✘"
	[[ $UID -eq 0 ]] && symbols+="$(ansi_single $(fg_color yellow))⚡"
	[[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="$(ansi_single $(fg_color cyan))⚙"

	[[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

######################################################################
#
# experimental right prompt stuff
# requires setting prompt_foo to use PRIGHT vs PR
# doesn't quite work per above

rightprompt() {
	printf "%*s" $COLUMNS "$PRIGHT"
}

# quick right prompt I grabbed to test things.
__command_rprompt() {
	local times= n=$COLUMNS tz
	for tz in ZRH:Europe/Zurich PIT:US/Eastern \
		MTV:US/Pacific TOK:Asia/Tokyo; do
		[ $n -gt 40 ] || break
		times="$times ${tz%%:*}\e[30;1m:\e[0;36;1m"
		times="$times$(TZ=${tz#*:} date +%H:%M)\e[0m"
		n=$(($n - 10))
	done
	[ -z "$times" ] || printf "%${n}s$times\\r" ''
}
# PROMPT_COMMAND=__command_rprompt

# this doens't wrap code in \[ \]
ansi_r() {
	local seq
	declare -a mycodes2=("${!1}")

	debug "ansi: ${!1} all: $* aka ${mycodes2[@]}"

	seq=""
	for ((i = 0; i < ${#mycodes2[@]}; i++)); do
		if [[ -n $seq ]]; then
			seq="${seq};"
		fi
		seq="${seq}${mycodes2[$i]}"
	done
	debug "ansi debug:" '\\[\\033['${seq}'m\\]'
	echo -ne '\033['${seq}'m'
	# PR="$PR\[\033[${seq}m\]"
}

# Begin a segment on the right
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_right_segment() {
	local bg fg
	declare -a codes

	debug "Prompt right"
	debug "Prompting $1 $2 $3"

	# if commented out from kruton's original... I'm not clear
	# if it did anything, but it messed up things like
	# prompt_status - Erik 1/14/17

	#    if [[ -z $1 || ( -z $2 && $2 != default ) ]]; then
	codes=("${codes[@]}" $(text_effect reset))
	#    fi
	if [[ -n $1 ]]; then
		bg=$(bg_color $1)
		codes=("${codes[@]}" $bg)
		debug "Added $bg as background to codes"
	fi
	if [[ -n $2 ]]; then
		fg=$(fg_color $2)
		codes=("${codes[@]}" $fg)
		debug "Added $fg as foreground to codes"
	fi

	debug "Right Codes: "
	# declare -p codes

	# right always has a separator
	# if [[ $CURRENT_RBG != NONE && $1 != $CURRENT_RBG ]]; then
	#     $CURRENT_RBG=
	# fi
	declare -a intermediate2=($(fg_color $1) $(bg_color $CURRENT_RBG))
	# PRIGHT="$PRIGHT---"
	debug "pre prompt " $(ansi_r intermediate2[@])
	PRIGHT="$PRIGHT$(ansi_r intermediate2[@])$RIGHT_SEPARATOR"
	debug "post prompt " $(ansi_r codes[@])
	PRIGHT="$PRIGHT$(ansi_r codes[@]) "
	# else
	#     debug "no current BG, codes is $codes[@]"
	#     PRIGHT="$PRIGHT$(ansi codes[@]) "
	# fi
	CURRENT_RBG=$1
	[[ -n $3 ]] && PRIGHT="$PRIGHT$3"
}

######################################################################
## Emacs prompt --- for dir tracking
# stick the following in your .emacs if you use this:

# (setq dirtrack-list '(".*DIR *\\([^ ]*\\) DIR" 1 nil))
# (defun dirtrack-filter-out-pwd-prompt (string)
#   "dirtrack-mode doesn't remove the PWD match from the prompt.  This does."
#   ;; TODO: support dirtrack-mode's multiline regexp.
#   (if (and (stringp string) (string-match (first dirtrack-list) string))
#       (replace-match "" t t string 0)
#     string))
# (add-hook 'shell-mode-hook
#           #'(lambda ()
#               (dirtrack-mode 1)
#               (add-hook 'comint-preoutput-filter-functions
#                         'dirtrack-filter-out-pwd-prompt t t)))

prompt_emacsdir() {
	# no color or other setting... this will be deleted per above
	PR="DIR \w DIR$PR"
}

######################################################################
## Main prompt

build_prompt() {
	[[ ! -z ${AG_EMACS_DIR+x} ]] && prompt_emacsdir
	prompt_status
	#[[ -z ${AG_NO_HIST+x} ]] && prompt_histdt
	[[ -z ${AG_NO_CONTEXT+x} ]] && prompt_context
	prompt_virtualenv
	prompt_dir
	prompt_git
	prompt_end
}

# from orig...
# export PS1='$(ansi_single $(text_effect reset)) $(build_prompt) '
# this doesn't work... new model: create a prompt via a PR variable and
# use that.

set_bash_prompt() {
	RETVAL=$?
	PR=""
	PRIGHT=""
	CURRENT_BG=NONE
	PR="$(ansi_single $(text_effect reset))"
	build_prompt

	# uncomment below to use right prompt
	#     PS1='\[$(tput sc; printf "%*s" $COLUMNS "$PRIGHT"; tput rc)\]'$PR
	PS1=$PR
}

PROMPT_COMMAND=set_bash_prompt
