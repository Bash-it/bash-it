# shellcheck shell=bash
cite about-plugin
about-plugin 'Search&Select history with percol'

# Notice
## You have to upgrade bash to bash 4.x on Mac OS X.
## http://stackoverflow.com/questions/16416195/how-do-i-upgrade-bash-in-mac-osx-mountain-lion-and-set-it-the-correct-path

# Install
## (sudo) pip install percol
## bash-it enable percol

# Usage
## C-r to search&select from history

_command_exists percol || return

if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
	_log_warning "You have to upgrade Bash to Bash v4.x to use the 'percol' plugin."
	_log_warning "Your current Bash version is $BASH_VERSION."
	return
fi

function _replace_by_history() {
	local HISTTIMEFORMAT= # Ensure we can parse history properly
	#TODO: "${histlines[@]/*( )+([[:digit:]])*( )/}"
	local l
	l="$(history | tail -r | sed -e 's/^\ *[0-9]*\ *//' | percol --query "${READLINE_LINE:-}")"
	READLINE_LINE="${l}"
	READLINE_POINT=${#l}
}
bind -x '"\C-r": _replace_by_history'
