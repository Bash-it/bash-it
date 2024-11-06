# shellcheck shell=bash
# Directory stack navigation:
#
# Add to stack with: pu /path/to/directory
# Delete current dir from stack with: po
# Show stack with: d
# Jump to location by number.

cite about-plugin
about-plugin 'directory stack navigation'

# Show directory stack
alias d="dirs -v -l"

# Change to location in stack by number
alias 1="pushd"
alias 2="pushd +2"
alias 3="pushd +3"
alias 4="pushd +4"
alias 5="pushd +5"
alias 6="pushd +6"
alias 7="pushd +7"
alias 8="pushd +8"
alias 9="pushd +9"

# Clone this location
alias pc='pushd "${PWD}"'

# Push new location
alias pu="pushd"

# Pop current location
alias po="popd"

function dirs-help() {
	about 'directory navigation alias usage'
	group 'dirs'

	echo "Directory Navigation Alias Usage"
	echo
	echo "Use the power of directory stacking to move"
	echo "between several locations with ease."
	echo
	echo "d	: Show directory stack."
	echo "po	: Remove current location from stack."
	echo "pc	: Adds current location to stack."
	echo "pu <dir>: Adds given location to stack."
	echo "1	: Change to stack location 1."
	echo "2	: Change to stack location 2."
	echo "3	: Change to stack location 3."
	echo "4	: Change to stack location 4."
	echo "5	: Change to stack location 5."
	echo "6	: Change to stack location 6."
	echo "7	: Change to stack location 7."
	echo "8	: Change to stack location 8."
	echo "9	: Change to stack location 9."
}

# Add bookmarking functionality
# Usage:

: "${BASH_IT_DIRS_BKS:=${XDG_STATE_HOME:-${HOME}/.local/state}/bash_it/dirs}"
if [[ -f "${BASH_IT_DIRS_BKS?}" ]]; then
	# shellcheck disable=SC1090
	source "${BASH_IT_DIRS_BKS?}"
else
	mkdir -p "${BASH_IT_DIRS_BKS%/*}"
	if [[ -f ~/.dirs ]]; then
		mv -vn ~/.dirs "${BASH_IT_DIRS_BKS?}"
		# shellcheck disable=SC1090
		source "${BASH_IT_DIRS_BKS?}"
	else
		touch "${BASH_IT_DIRS_BKS?}"
	fi
fi

alias L='cat "${BASH_IT_DIRS_BKS?}"'

# Goes to destination dir, otherwise stay in the dir
function G() {
	about 'goes to destination dir'
	param '1: directory'
	example '$ G ..'
	group 'dirs'

	cd "${1:-${PWD}}" || return
}

function S() {
	about 'save a bookmark'
	param '1: bookmark name'
	example '$ S mybkmrk'
	group 'dirs'

	[[ $# -eq 1 ]] || {
		echo "${FUNCNAME[0]} function requires 1 argument"
		return 1
	}

	sed "/$1/d" "${BASH_IT_DIRS_BKS?}" > "${BASH_IT_DIRS_BKS?}.new"
	command mv "${BASH_IT_DIRS_BKS?}.new" "${BASH_IT_DIRS_BKS?}"
	echo "$1"=\""${PWD}"\" >> "${BASH_IT_DIRS_BKS?}"
	# shellcheck disable=SC1090
	source "${BASH_IT_DIRS_BKS?}"
}

function R() {
	about 'remove a bookmark'
	param '1: bookmark name'
	example '$ R mybkmrk'
	group 'dirs'

	[[ $# -eq 1 ]] || {
		echo "${FUNCNAME[0]} function requires 1 argument"
		return 1
	}

	sed "/$1/d" "${BASH_IT_DIRS_BKS?}" > "${BASH_IT_DIRS_BKS?}.new"
	command mv "${BASH_IT_DIRS_BKS?}.new" "${BASH_IT_DIRS_BKS?}"
}

alias U='source "${BASH_IT_DIRS_BKS?}"' # Update bookmark stack
