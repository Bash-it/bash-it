# shellcheck shell=bash
# shellcheck disable=SC1090

# Make sure travis is installed
_bash-it-completion-helper-necessary travis || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient travis || return

if [[ -s "${_travis_bash_completion_script:=${TRAVIS_CONFIG_PATH:-${HOME}/.travis}/travis.sh}" ]]; then
	# shellcheck disable=SC1090
	source "${_travis_bash_completion_script}"
fi
unset "${!_travis_bash_completion@}"
