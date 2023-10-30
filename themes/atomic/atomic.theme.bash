# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Atomic Bash Prompt for Bash-it
# By lfelipe base on the theme brainy of MunifTanjim

############
## Colors ##
############
IRed="\e[1;49;31m"
IGreen="\e[1;49;32m"
IYellow="\e[1;49;33m"
IWhite="\e[1;49;37m"
BIWhite="\e[1;49;37m"
BICyan="\e[1;49;36m"

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

function ____atomic_top_left_parse() {
	local ifs_old="${IFS}"
	local IFS="|"
	read -r -a args <<< "$@"
	IFS="${ifs_old}"
	if [[ -n "${args[3]:-}" ]]; then
		_TOP_LEFT+="${args[2]?}${args[3]?}"
	fi
	_TOP_LEFT+="${args[0]?}${args[1]:-}"
	if [[ -n "${args[4]:-}" ]]; then
		_TOP_LEFT+="${args[2]?}${args[4]?}"
	fi
	_TOP_LEFT+=""
}

function ____atomic_top_right_parse() {
	local ifs_old="${IFS}"
	local IFS="|"
	read -r -a args <<< "$@"
	IFS="${ifs_old}"
	_TOP_RIGHT+=" "
	if [[ -n "${args[3]:-}" ]]; then
		_TOP_RIGHT+="${args[2]?}${args[3]?}"
	fi
	_TOP_RIGHT+="${args[0]?}${args[1]:-}"
	if [[ -n "${args[4]:-}" ]]; then
		_TOP_RIGHT+="${args[2]?}${args[4]?}"
	fi
	__TOP_RIGHT_LEN=$((__TOP_RIGHT_LEN + ${#args[1]} + ${#args[3]} + ${#args[4]} + 1))
	((__SEG_AT_RIGHT += 1))
}

function ____atomic_bottom_parse() {
	local ifs_old="${IFS}"
	local IFS="|"
	read -r -a args <<< "$@"
	IFS="${ifs_old}"
	_BOTTOM+="${args[0]?}${args[1]?${FUNCNAME[0]}}"
	[[ ${#args[1]} -gt 0 ]] && _BOTTOM+=" "
}

function ____atomic_top() {
	_TOP_LEFT=""
	_TOP_RIGHT=""
	__TOP_RIGHT_LEN=0
	__SEG_AT_RIGHT=0

	for seg in ${___ATOMIC_TOP_LEFT}; do
		info="$(___atomic_prompt_"${seg}")"
		[[ -n "${info}" ]] && ____atomic_top_left_parse "${info}"
	done

	___cursor_right="\e[500C"
	_TOP_LEFT+="${___cursor_right}"

	for seg in ${___ATOMIC_TOP_RIGHT}; do
		info="$(___atomic_prompt_"${seg}")"
		[[ -n "${info}" ]] && ____atomic_top_right_parse "${info}"
	done

	[[ $__TOP_RIGHT_LEN -gt 0 ]] && __TOP_RIGHT_LEN=$((__TOP_RIGHT_LEN - 0))
	___cursor_adjust="\e[${__TOP_RIGHT_LEN}D"
	_TOP_LEFT+="${___cursor_adjust}"

	printf "%s%s" "${_TOP_LEFT}" "${_TOP_RIGHT}"
}

function ____atomic_bottom() {
	_BOTTOM=""
	for seg in $___ATOMIC_BOTTOM; do
		info="$(___atomic_prompt_"${seg}")"
		[[ -n "${info}" ]] && ____atomic_bottom_parse "${info}"
	done
	printf "\n%s" "${_BOTTOM}"
}

##############
## Segments ##
##############

function ___atomic_prompt_user_info() {
	local color="${white?}" box
	local info="${IYellow}\u${IRed}@${IGreen}\h"
	box="${normal?}${LineA?}\$([[ \$? != 0 ]] && echo \"${BIWhite?}[${IRed?}${SX?}${BIWhite?}]${normal?}${Line?}\")${Line?}${BIWhite?}[|${BIWhite?}]${normal?}${Line?}"

	printf "%s|%s|%s|%s" "${color}" "${info}" "${white?}" "${box}"
}

function ___atomic_prompt_dir() {
	local color="${IRed?}"
	local box="[|]${normal}"
	local info="\w"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white?}" "${box}"
}

function ___atomic_prompt_scm() {
	[[ "${THEME_SHOW_SCM:-}" != "true" ]] && return
	local color="${bold_green?}" box info
	box="${Line?}[${IWhite?}$(scm_char)] "
	info="$(scm_prompt_info)"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white?}" "${box}"
}

function ___atomic_prompt_python() {
	[[ "${THEME_SHOW_PYTHON:-}" != "true" ]] && return
	local color="${bold_yellow?}"
	local box="[|]" info
	info="$(python_version_prompt)"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_blue?}" "${box}"
}

function ___atomic_prompt_ruby() {
	[[ "${THEME_SHOW_RUBY:-}" != "true" ]] && return
	local color="${bold_white?}"
	local box="[|]" info
	info="rb-$(ruby_version_prompt)"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_red?}" "${box}"
}

function ___atomic_prompt_todo() {
	[[ "${THEME_SHOW_TODO:-}" != "true" ||
		-z "$(which todo.sh)" ]] && return
	local color="${bold_white?}"
	local box="[|]" info
	info="t:$(todo.sh ls | grep -E "TODO: [0-9]+ of ([0-9]+)" | awk '{ print $4 }')"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_green?}" "${box}"
}

function ___atomic_prompt_clock() {
	[[ "${THEME_SHOW_CLOCK:-}" != "true" ]] && return
	local color="${THEME_CLOCK_COLOR:-}"
	local box="[|]" info
	info="$(date +"${THEME_CLOCK_FORMAT}")"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white?}" "${box}"
}

function ___atomic_prompt_battery() {
	local batp box info
	! _command_exists battery_percentage \
		|| [[ "${THEME_SHOW_BATTERY:-}" != "true" ]] \
		|| [[ "$(battery_percentage)" = "no" ]] && return

	batp=$(battery_percentage)
	if [[ "$batp" -eq 50 || "$batp" -gt 50 ]]; then
		color="${bold_green?}"
	elif [[ "$batp" -lt 50 && "$batp" -gt 25 ]]; then
		color="${bold_yellow?}"
	elif [[ "$batp" -eq 25 || "$batp" -lt 25 ]]; then
		color="${IRed?}"
	fi
	box="[|]"
	ac_adapter_connected && info="+"
	ac_adapter_disconnected && info="-"
	info+=$batp
	[[ "$batp" -eq 100 || "$batp" -gt 100 ]] && info="AC"
	printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white?}" "${box}"
}

function ___atomic_prompt_exitcode() {
	[[ "${THEME_SHOW_EXITCODE:-}" != "true" ]] && return
	local color="${bold_purple?}"
	[[ "${exitcode?}" -ne 0 ]] && printf "%s|%s" "${color}" "${exitcode}"
}

function ___atomic_prompt_char() {
	local color="${white?}"
	local prompt_char="${__ATOMIC_PROMPT_CHAR_PS1?}"
	if [[ "${THEME_SHOW_SUDO:-}" == "true" ]]; then
		if sudo -vn 1> /dev/null 2>&1; then
			prompt_char="${__ATOMIC_PROMPT_CHAR_PS1_SUDO?}"
		fi
	fi
	printf "%s|%s" "${color}" "${prompt_char}"
}

#########
## cli ##
#########

function __atomic_show() {
	local _seg="${1?}"
	export "THEME_SHOW_${_seg}"=true
}

function __atomic_hide() {
	local _seg="${1?}"
	export "THEME_SHOW_${_seg}"=false
}

function _atomic_completion() {
	local cur _action actions segments
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	_action="${COMP_WORDS[1]}"
	actions="show hide"
	segments="battery clock exitcode python ruby scm sudo todo"
	case "${_action}" in
		show | hide)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "${segments}" -- "${cur}"))
			return 0
			;;
	esac

	# shellcheck disable=SC2207
	COMPREPLY=($(compgen -W "${actions}" -- "${cur}"))
	return 0
}

function atomic() {
	local action="${1?}"
	shift
	local segs=("${@?}")
	local func
	case "${action}" in
		show)
			func=__atomic_show
			;;
		hide)
			func=__atomic_hide
			;;
		*)
			_log_error "${FUNCNAME[0]}: unknown action '${action}'"
			return 1
			;;
	esac
	for seg in "${segs[@]}"; do
		seg="$(printf "%s" "${seg}" | tr '[:lower:]' '[:upper:]')"
		"${func}" "${seg}"
	done
}

complete -F _atomic_completion atomic

###############
## Variables ##
###############

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

RBENV_THEME_PROMPT_PREFIX=""
RBENV_THEME_PROMPT_SUFFIX=""
RBFU_THEME_PROMPT_PREFIX=""
RBFU_THEME_PROMPT_SUFFIX=""
RVM_THEME_PROMPT_PREFIX=""
RVM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"

: "${THEME_SHOW_SUDO:="true"}"
: "${THEME_SHOW_SCM:="true"}"
: "${THEME_SHOW_RUBY:="false"}"
: "${THEME_SHOW_PYTHON:="false"}"
: "${THEME_SHOW_CLOCK:="true"}"
: "${THEME_SHOW_TODO:="false"}"
: "${THEME_SHOW_BATTERY:="true"}"
: "${THEME_SHOW_EXITCODE:="false"}"

: "${THEME_CLOCK_COLOR:=${BICyan?}}"
: "${THEME_CLOCK_FORMAT:="%a %b %d - %H:%M"}"

__ATOMIC_PROMPT_CHAR_PS1=${THEME_PROMPT_CHAR_PS1:-"${normal?}${LineB?}${bold_white?}${Circle?}"}
__ATOMIC_PROMPT_CHAR_PS2=${THEME_PROMPT_CHAR_PS2:-"${normal?}${LineB?}${bold_white?}${Circle?}"}

__ATOMIC_PROMPT_CHAR_PS1_SUDO=${THEME_PROMPT_CHAR_PS1_SUDO:-"${normal?}${LineB?}${bold_red?}${Face?}"}
__ATOMIC_PROMPT_CHAR_PS2_SUDO=${THEME_PROMPT_CHAR_PS2_SUDO:-"${normal?}${LineB?}${bold_red?}${Face?}"}

: "${___ATOMIC_TOP_LEFT:="user_info dir scm"}"
: "${___ATOMIC_TOP_RIGHT:="exitcode python ruby todo clock battery"}"
: "${___ATOMIC_BOTTOM:="char"}"

############
## Prompt ##
############

function __atomic_ps1() {
	printf "%s%s%s" "$(____atomic_top)" "$(____atomic_bottom)" "${normal?}"
}

function __atomic_ps2() {
	color="${bold_white?}"
	printf "%s%s%s" "${color}" "${__ATOMIC_PROMPT_CHAR_PS2?}  " "${normal?}"
}

function _atomic_prompt() {
	exitcode="$?"

	PS1="$(__atomic_ps1)"
	PS2="$(__atomic_ps2)"
}

safe_append_prompt_command _atomic_prompt
