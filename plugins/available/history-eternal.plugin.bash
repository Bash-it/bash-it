# shellcheck shell=bash
about-plugin 'eternal bash history'
url "https://github.com/Bash-it/bash-it"

if [[ ${BASH_VERSINFO[0]} -lt 4 ]] || [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 3 ]]; then
	_log_warning "Bash version 4.3 introduced the 'unlimited' history size capability."
	_log_warning "Disabling history-eternal plugin (current version: $BASH_VERSION)"
	_disable-plugin history-eternal
	return 0
fi

# Modify history sizes before changing location to avoid unintentionally
# truncating the history file early.

# "Numeric values less than zero result in every command being saved on the history list (there is no limit)"
HISTSIZE=-1 2> /dev/null || true

# "Non-numeric values and numeric values less than zero inhibit truncation"
HISTFILESIZE='unlimited' 2> /dev/null || true

# Use a custom history file location so history is not truncated
# if the environment ever loses this "eternal" configuration.
HISTDIR="${XDG_STATE_HOME:-${HOME?}/.local/state}/bash"
[[ -d ${HISTDIR?} ]] || mkdir -p "${HISTDIR?}"
HISTFILE="${HISTDIR?}/history" 2> /dev/null || true
