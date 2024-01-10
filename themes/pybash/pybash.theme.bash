#!/usr/bin/env bash

# Created by Qiuyi Hong 

# It is also available on Github: https://github.com/Qiuyi-Hong/pybash

# This is the modified version of the Atomic theme based on Bash-it framework for Python developers 

# PyBash is inspired by the Atomic theme by lfelipe


############
## Colors ##
############
IRed="\e[1;49;31m"
IGreen="\e[1;49;32m"
IYellow="\e[1;49;33m"
IWhite="\e[1;49;37m"
BIWhite="\e[1;49;37m"
BICyan="\e[1;49;36m"
IBlue="\e[1;49;34m"
IPurple="\e[1;49;35m"

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

____pybash_top_left_parse() {
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

____pybash_top_right_parse() {
  ifs_old="${IFS}"
  IFS="|"
  args=( $1 )
  IFS="${ifs_old}"

  # Add Line only if it's not the first segment
  if (( __SEG_AT_RIGHT > 0 )); then
    _TOP_RIGHT+="${normal}${Line}"
  else
    _TOP_RIGHT+=" "
  fi

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


____pybash_bottom_parse() {
  ifs_old="${IFS}"
  IFS="|"
  args=( $1 )
  IFS="${ifs_old}"
  _BOTTOM+="${args[0]}${args[1]}"
  [ ${#args[1]} -gt 0 ] && _BOTTOM+=" "
}

____pybash_top() {
  _TOP_LEFT=""
  _TOP_RIGHT=""
  __TOP_RIGHT_LEN=0
  __SEG_AT_RIGHT=0
  
  for seg in ${___PYBASH_TOP_LEFT}; do
    info="$(___pybash_prompt_"${seg}")"
    [ -n "${info}" ] && ____pybash_top_left_parse "${info}"
  done
  
  ___cursor_right="\e[500C"
  _TOP_LEFT+="${___cursor_right}"
  
  for seg in ${___PYBASH_TOP_RIGHT}; do
    info="$(___pybash_prompt_"${seg}")"
    [ -n "${info}" ] && ____pybash_top_right_parse "${info}"
  done
  
  [ $__TOP_RIGHT_LEN -gt 0 ] && __TOP_RIGHT_LEN=$(( __TOP_RIGHT_LEN - 0 ))
  ___cursor_adjust="\e[${__TOP_RIGHT_LEN}D"
  _TOP_LEFT+="${___cursor_adjust}"
  
  printf "%s%s" "${_TOP_LEFT}" "${_TOP_RIGHT}"
}

____pybash_bottom() {
  _BOTTOM=""
  for seg in $___PYBASH_BOTTOM; do
    info="$(___pybash_prompt_"${seg}")"
    [ -n "${info}" ] && ____pybash_bottom_parse "${info}"
  done
  printf "\n%s" "${_BOTTOM}"
}

##############
## Segments ##
##############

___pybash_prompt_user_info() {
  color=$white
  box="${normal}${LineA}\$([[ \$? != 0 ]] && echo \"${IRed}[${IRed}${SX}${IRed}]${normal}${Line}\")${BICyan}[|${BICyan}]${normal}${Line}"
  info="${IYellow}\u${BICyan}@${IGreen}\h"
  
  printf "%s|%s|%s|%s" "${color}" "${info}" "${white}" "${box}"
}

___pybash_prompt_dir() {
  color=${IBlue}
  box="[|]${normal}${Line}"
  info="\w"
  printf "%s|%s|%s|%s" "${color}" "${info}" "${IBlue}" "${box}"
}

___pybash_prompt_scm() {
  [ "${THEME_SHOW_SCM}" != "true" ] && return
  color=$IGreen
  scm_info="$(scm_prompt_info)"
  
  # Apply green color to scm_char, and use normal color for Line and scm_info
  if [ -n "$scm_info" ]; then
      # scm_char in green, Line in normal color
      box="[${IGreen}$(scm_char)]${normal}${Line}"
      # scm_info in green color
      info="${IGreen}[${scm_info}${IGreen}]${normal}"
  else
      box="[${IGreen}$(scm_char)] "
      info=""
  fi

  printf "%s|%s|%s|%s" "${color}" "${info}" "${IGreen}" "${box}"
}


___pybash_prompt_python() {
  [ "${THEME_SHOW_PYTHON}" != "true" ] && return
  color=$BICyan
  box="[|]"

  # Get the combined output of python_version_prompt
  local combined_py="$(python_version_prompt)"
  
  # Use pattern matching to split 'envnamepythonversion' into 'envname pythonversion'
  local py_env="${combined_py%py-*}"     # Extracts the environment part
  local py_ver="py-${combined_py#*py-}"  # Extracts the version part, prefixed with 'py-'

  # Combine them with a space
  info="${py_env} ${py_ver}"

  printf "%s|%s|%s|%s" "${color}" "${info}" "${BICyan}" "${box}"
}

___pybash_prompt_ruby() {
  [ "${THEME_SHOW_RUBY}" != "true" ] && return
  color=$bold_white
  box="[|]"
  info="rb-$(ruby_version_prompt)"
  printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_red}" "${box}"
}

___pybash_prompt_todo() {
  [ "${THEME_SHOW_TODO}" != "true" ] ||
  [ -z "$(which todo.sh)" ] && return
  color=$bold_white
  box="[|]"
  info="t:$(todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+)" | awk '{ print $4 }' )"
  printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_green}" "${box}"
}

___pybash_prompt_clock() {
  [ "${THEME_SHOW_CLOCK}" != "true" ] && return
  color=$THEME_CLOCK_COLOR
  box="[|]"
  info="$(date +"${THEME_CLOCK_FORMAT}")"
  printf "%s|%s|%s|%s" "${color}" "${info}" "${IYellow}" "${box}" # change to IYellow from bold_white
}

___pybash_prompt_battery() {
  ! _command_exists battery_percentage ||
  [ "${THEME_SHOW_BATTERY}" != "true" ] ||
  [ "$(battery_percentage)" = "no" ] && return

  batp=$(battery_percentage)
  if [ "$batp" -eq 50 ] || [ "$batp" -gt 50 ]; then
    color=$bold_green
    elif [ "$batp" -lt 50 ] && [ "$batp" -gt 25 ]; then
    color=$bold_yellow
    elif [ "$batp" -eq 25 ] || [ "$batp" -lt 25 ]; then
    color=$IRed
  fi
  box="[|]"
  ac_adapter_connected && info="+"
  ac_adapter_disconnected && info="-"
  info+=$batp
  [ "$batp" -eq 100 ] || [ "$batp" -gt 100 ] && info="AC"
  printf "%s|%s|%s|%s" "${color}" "${info}" "${bold_white}" "${box}"
}

___pybash_prompt_exitcode() {
  [ "${THEME_SHOW_EXITCODE}" != "true" ] && return
  color=$bold_purple
  [ "$exitcode" -ne 0 ] && printf "%s|%s" "${color}" "${exitcode}"
}

___pybash_prompt_char() {
  color=$white
  prompt_char="${__PYBASH_PROMPT_CHAR_PS1}"
  if [ "${THEME_SHOW_SUDO}" == "true" ]; then
    if [ $(sudo -n id -u 2>&1 | grep 0) ]; then
      prompt_char="${__PYBASH_PROMPT_CHAR_PS1_SUDO}"
    fi
  fi
  printf "%s|%s" "${color}" "${prompt_char}"
}

#########
## cli ##
#########

__pybash_show() {
  typeset _seg=${1:-}
  shift
  export THEME_SHOW_${_seg}=true
}

__pybash_hide() {
  typeset _seg=${1:-}
  shift
  export THEME_SHOW_${_seg}=false
}

_pybash_completion() {
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

pybash() {
  typeset action=${1:-}
  shift
  typeset segs=${*:-}
  typeset func
  case $action in
    show)
    func=__pybash_show;;
    hide)
    func=__pybash_hide;;
  esac
  for seg in ${segs}; do
    seg=$(printf "%s" "${seg}" | tr '[:lower:]' '[:upper:]')
    $func "${seg}"
  done
}

complete -F _pybash_completion pybash

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

export SCM_THEME_PROMPT_DIRTY=" ${IRed}✗${normal}"
export SCM_THEME_PROMPT_CLEAN=" ${IGreen}✓${normal}"

THEME_SHOW_SUDO=${THEME_SHOW_SUDO:-"true"}
THEME_SHOW_SCM=${THEME_SHOW_SCM:-"true"}
THEME_SHOW_RUBY=${THEME_SHOW_RUBY:-"false"}
THEME_SHOW_PYTHON=${THEME_SHOW_PYTHON:-"true"} # change to false if you don't want to see python version
THEME_SHOW_CLOCK=${THEME_SHOW_CLOCK:-"true"}
THEME_SHOW_TODO=${THEME_SHOW_TODO:-"false"}
THEME_SHOW_BATTERY=${THEME_SHOW_BATTERY:-"true"}
THEME_SHOW_EXITCODE=${THEME_SHOW_EXITCODE:-"false"}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"${IYellow}"}
THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:-"%a %d %b %H:%M:%S"} # switch the date and month order and add %S for seconds

__PYBASH_PROMPT_CHAR_PS1=${THEME_PROMPT_CHAR_PS1:-"${normal}${LineB}${IWhite}${Circle}"}
__PYBASH_PROMPT_CHAR_PS2=${THEME_PROMPT_CHAR_PS2:-"${normal}${LineB}${IWhite}${Circle}"}

__PYBASH_PROMPT_CHAR_PS1_SUDO=${THEME_PROMPT_CHAR_PS1_SUDO:-"${normal}${LineB}${IRed}${Face}"}
__PYBASH_PROMPT_CHAR_PS2_SUDO=${THEME_PROMPT_CHAR_PS2_SUDO:-"${normal}${LineB}${IRed}${Face}"}

___PYBASH_TOP_LEFT=${___PYBASH_TOP_LEFT:-"user_info dir scm"}
___PYBASH_TOP_RIGHT=${___PYBASH_TOP_RIGHT:-"exitcode python ruby todo clock battery"}
___PYBASH_BOTTOM=${___PYBASH_BOTTOM:-"char"}

############
## Prompt ##
############

__pybash_ps1() {
  printf "%s%s%s" "$(____pybash_top)" "$(____pybash_bottom)" "${normal}"
}

__pybash_ps2() {
  color=$bold_white
  printf "%s%s%s" "${color}" "${__PYBASH_PROMPT_CHAR_PS2}  " "${normal}"
}

_pybash_prompt() {
  exitcode="$?"
  
  PS1="$(__pybash_ps1)"
  PS2="$(__pybash_ps2)"
}

safe_append_prompt_command _pybash_prompt