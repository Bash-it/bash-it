#!/usr/bin/env bash

# Brainy Bash Prompt for Bash-it
# by MunifTanjim Edited By lfelipe

############
## Colors ##
############
IRed="\e[1;49;31m"
IGreen="\e[1;49;32m"
IYellow="\e[1;49;33m"
ICyan="\e[1;49;36m"
IWhite="\e[1;49;37m"
White="\e[0;49;37m"
BIWhite="\e[1;49;37m"
BICyan="\e[1;49;36m"
ResetColor="\e[0;49;37m"

#############
## Symbols ##
#############
Line="\342\224\200"
LineA="\342\224\214\342\224\200"
SX="\342\234\227"
LineB="\342\224\224\342\224\200\342\224\200"
Circle="\342\227\217"
Face="\342\230\273"

#############
## Parsers ##
#############

____brainy_top_left_parse() {
	ifs_old="${IFS}"
	IFS="|"
	args=( $1 )
	IFS="${ifs_old}"
	if [ -n "${args[3]}" ]; then
		_TOP_LEFT+="${args[2]}${args[3]}"
	fi
	_TOP_LEFT+="${args[0]}${args[1]}"
	if [ -n "${args[4]}" ]; then
		_TOP_LEFT+="${args[2]}${args[4]}"
	fi
	_TOP_LEFT+=""
}

____brainy_top_right_parse() {
	ifs_old="${IFS}"
	IFS="|"
	args=( $1 )
	IFS="${ifs_old}"
	_TOP_RIGHT+=" "
	if [ -n "${args[3]}" ]; then
		_TOP_RIGHT+="${args[2]}${args[3]}"
	fi
	_TOP_RIGHT+="${args[0]}${args[1]}"
	if [ -n "${args[4]}" ]; then
		_TOP_RIGHT+="${args[2]}${args[4]}"
	fi
	__TOP_RIGHT_LEN=$(( __TOP_RIGHT_LEN + ${#args[1]} + ${#args[3]} + ${#args[4]} + 1 ))
	(( __SEG_AT_RIGHT += 1 ))
}

____brainy_bottom_parse() {
	ifs_old="${IFS}"
	IFS="|"
	args=( $1 )
	IFS="${ifs_old}"
	_BOTTOM+="${args[0]}${args[1]}"
	[ ${#args[1]} -gt 0 ] && _BOTTOM+=""
}

____brainy_top() {
	_TOP_LEFT=""
	_TOP_RIGHT=""
	__TOP_RIGHT_LEN=0
	__SEG_AT_RIGHT=0

	for seg in ${___BRAINY_TOP_LEFT}; do
		info="$(___brainy_prompt_"${seg}")"
		[ -n "${info}" ] && ____brainy_top_left_parse "${info}"
	done

	___cursor_right="\033[500C"
	_TOP_LEFT+="${___cursor_right}"

	for seg in ${___BRAINY_TOP_RIGHT}; do
		info="$(___brainy_prompt_"${seg}")"
		[ -n "${info}" ] && ____brainy_top_right_parse "${info}"
	done

	[ $__TOP_RIGHT_LEN -gt 0 ] && __TOP_RIGHT_LEN=$(( __TOP_RIGHT_LEN - 0 ))
	___cursor_adjust="\033[${__TOP_RIGHT_LEN}D"
	_TOP_LEFT+="${___cursor_adjust}"

	printf "%s%s" "${_TOP_LEFT}" "${_TOP_RIGHT}"
}

____brainy_bottom() {
	_BOTTOM=""
	for seg in $___BRAINY_BOTTOM; do
		info="$(___brainy_prompt_"${seg}")"
		[ -n "${info}" ] && ____brainy_bottom_parse "${info}"
	done
	printf "\n%s" "${_BOTTOM}"
}

##############
## Segments ##
##############

___brainy_prompt_user_info() {
	color=$white	
	box="${ResetColor}${LineA}\$([[ \$? != 0 ]] && echo \"${BIWhite}[${IRed}${SX}${BIWhite}]${ResetColor}${Line}\")${ResetColor}${Line}${BIWhite}[|${BIWhite}]${ResetColor}${Line}"
	info="${IYellow}\u${IRed}@${IGreen}\h"
	
	printf "%s|%s|%s|%s" "${color}" "${info}" "${white}" "${box}"
}

___brainy_prompt_dir() {
	color=${IRed}
	box="${BIWhite}[|${BIWhite}]"
	info="\W"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${white}" "${box}"
}

___brainy_prompt_scm() {
	[ "${THEME_SHOW_SCM}" != "true" ] && return
	color=$bold_green
	box="${ResetColor}${Line}${BIWhite}[${IWhite}$(scm_char)${BIWhite}] "
	info="$(scm_prompt_info)"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${white}" "${box}"
}

___brainy_prompt_python() {
	[ "${THEME_SHOW_PYTHON}" != "true" ] && return
	color=$bold_yellow
	box="[|]"
	info="$(python_version_prompt)"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_blue}" "${box}"
}

___brainy_prompt_ruby() {
	[ "${THEME_SHOW_RUBY}" != "true" ] && return
	color=$bold_white
	box="[|]"
	info="rb-$(ruby_version_prompt)"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_red}" "${box}"
}

___brainy_prompt_todo() {
	[ "${THEME_SHOW_TODO}" != "true" ] ||
	[ -z "$(which todo.sh)" ] && return
	color=$bold_white
	box="[|]"
	info="t:$(todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+)" | awk '{ print $4 }' )"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_green}" "${box}"
}

___brainy_prompt_clock() {
	[ "${THEME_SHOW_CLOCK}" != "true" ] && return
	color=$THEME_CLOCK_COLOR
	box="[|]"
	info="$(date +"${THEME_CLOCK_FORMAT}")"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white}" "${box}"
}

___brainy_prompt_battery() {
	[ ! -e $BASH_IT/plugins/enabled/battery.plugin.bash ] ||
	[ "${THEME_SHOW_BATTERY}" != "true" ] && return
	batp=$(battery_percentage)
	if [ "$batp" -gt 50 ]; then
		color=$bold_green
	elif [ "$batp" -lt 50 ] && [ "$batp" -gt 25 ]; then
		color=$bold_yellow
	elif [ "$batp" -lt 25 ]; then
		color=$ColorRed
	fi
	box="[|]"
	ac_adapter_disconnected && info="-"
	ac_adapter_connected && info="+"
	info+=$batp
	[ "$info" == "+100" ] && info="AC"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white}" "${box}"
}

___brainy_prompt_exitcode() {
	[ "${THEME_SHOW_EXITCODE}" != "true" ] && return
	color=$bold_purple
	[ "$exitcode" -ne 0 ] && printf "%s|%s" "${color}" "${exitcode}"
}

___brainy_prompt_char() {
	color=$bold_red
	prompt_char="${__BRAINY_PROMPT_CHAR_PS1}"
	if [ "${THEME_SHOW_SUDO}" == "true" ]; then
		if [ $(sudo -n id -u 2>&1 | grep 0) ]; then
			prompt_char="${__BRAINY_PROMPT_CHAR_PS1_SUDO}"
		fi
	fi
	printf "%s|%s" "${color}" "${prompt_char}"
}

#########
## cli ##
#########

__brainy_show() {
  typeset _seg=${1:-}
	shift
	export THEME_SHOW_${_seg}=true
}

__brainy_hide() {
	typeset _seg=${1:-}
	shift
	export THEME_SHOW_${_seg}=false
}

_brainy_completion() {
	local cur _action actions segments
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	_action="${COMP_WORDS[1]}"
	actions="show hide"
	segments="battery clock exitcode python ruby scm sudo todo"
	case "${_action}" in
		show)
			COMPREPLY=( $(compgen -W "${segments}" -- "${cur}") )
			return 0
			;;
		hide)
			COMPREPLY=( $(compgen -W "${segments}" -- "${cur}") )
			return 0
			;;
	esac

	COMPREPLY=( $(compgen -W "${actions}" -- "${cur}") )
	return 0
}

brainy() {
	typeset action=${1:-}
	shift
	typeset segs=${*:-}
	typeset func
	case $action in
		show)
			func=__brainy_show;;
		hide)
			func=__brainy_hide;;
	esac
	for seg in ${segs}; do
		seg=$(printf "%s" "${seg}" | tr '[:lower:]' '[:upper:]')
		$func "${seg}"
	done
}

complete -F _brainy_completion brainy

###############
## Variables ##
###############

export SCM_THEME_PROMPT_PREFIX=""
export SCM_THEME_PROMPT_SUFFIX=""

export RBENV_THEME_PROMPT_PREFIX=""
export RBENV_THEME_PROMPT_SUFFIX=""
export RBFU_THEME_PROMPT_PREFIX=""
export RBFU_THEME_PROMPT_SUFFIX=""
export RVM_THEME_PROMPT_PREFIX=""
export RVM_THEME_PROMPT_SUFFIX=""

export SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
export SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"

THEME_SHOW_SUDO=${THEME_SHOW_SUDO:-"true"}
THEME_SHOW_SCM=${THEME_SHOW_SCM:-"true"}
THEME_SHOW_RUBY=${THEME_SHOW_RUBY:-"false"}
THEME_SHOW_PYTHON=${THEME_SHOW_PYTHON:-"false"}
THEME_SHOW_CLOCK=${THEME_SHOW_CLOCK:-"true"}
THEME_SHOW_TODO=${THEME_SHOW_TODO:-"false"}
THEME_SHOW_BATTERY=${THEME_SHOW_BATTERY:-"true"}
THEME_SHOW_EXITCODE=${THEME_SHOW_EXITCODE:-"false"}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"${BICyan}"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%a %b %d - %H:%M"}

__BRAINY_PROMPT_CHAR_PS1=${THEME_PROMPT_CHAR_PS1:-"${ResetColor}${LineB}${BIWhite}${Circle} ${ResetColor}"}
__BRAINY_PROMPT_CHAR_PS2=${THEME_PROMPT_CHAR_PS2:-"${ResetColor}${LineB}${BIWhite}${Circle} ${ResetColor}"}

__BRAINY_PROMPT_CHAR_PS1_SUDO=${THEME_PROMPT_CHAR_PS1_SUDO:-"${ResetColor}${LineB}${IRed}${Face} ${ResetColor}"}
__BRAINY_PROMPT_CHAR_PS2_SUDO=${THEME_PROMPT_CHAR_PS2_SUDO:-"${ResetColor}${LineB}${IRed}${Face} ${ResetColor}"}

___BRAINY_TOP_LEFT=${___BRAINY_TOP_LEFT:-"user_info dir scm"}
___BRAINY_TOP_RIGHT=${___BRAINY_TOP_RIGHT:-"python ruby todo clock battery"}
___BRAINY_BOTTOM=${___BRAINY_BOTTOM:-"exitcode char"}

############
## Prompt ##
############

__brainy_ps1() {
	printf "%s%s%s" "$(____brainy_top)" "$(____brainy_bottom)" "${normal}"
}

__brainy_ps2() {
	color=$bold_white
	printf "%s%s%s" "${color}" "${__BRAINY_PROMPT_CHAR_PS2}  " "${normal}"
}

_brainy_prompt() {
    exitcode="$?"

    PS1="$(__brainy_ps1)"
    PS2="$(__brainy_ps2)"
}

safe_append_prompt_command _brainy_prompt
