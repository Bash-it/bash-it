#!/usr/bin/env bash
# vim: ft=bash:

# @author:	Konstantin Gredeskoul
# @since: 	04/08/2021

# @description Defines a functino for quickly changing theme color

function bashit.colorscheme() {
  local scheme="$1"

  [[ -z "${scheme}" ]] && {
    if [[ "${ITERM_PROFILE}" =~ "Light" || "${ITERM_PROFILE}" =~ "light" ]]; then
      export scheme=light
    else
      export scheme=dark
    fi
  }

  local theme="${BASH_IT}/colorschemes/${scheme}.colorscheme.bash"
  if [[ -f ${theme} ]]; then
    source "${theme}"
  else
    echo "Invlaid theme name: ${scheme}, file ${theme} ain't a livin thang."
  fi
}

function promptly.color() {
	bashit.colorsscheme "$@"
}

export THEME_RUBRIC="ruby scm cwd | time "

function promptly() {
	echo
}

function promptlyt() {
	echo
}

function powerline.prompt.templates() {
	local t=${1}
	bashit.colorsscheme "$@"
}

powerline.prompt.git.max

powerline.prompt.left   aws ruby haskell go scm cwd
powerline.prompt.right  user_info clock battery

bashit.colorscheme dark

