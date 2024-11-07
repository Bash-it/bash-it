# shellcheck shell=bash
about-plugin 'eternal bash history'

if [[ ${BASH_VERSINFO[0]} -lt 4 ]] || [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -lt 3 ]]; then
	_log_warning "Bash version 4.3 introduced the 'unlimited' history size capability."
	return 1
fi

# Modify history sizes before changing location to avoid unintentionally
# truncating the history file early.

# "Numeric values less than zero result in every command being saved on the history list (there is no limit)"
readonly HISTSIZE=-1 2> /dev/null || true

# "Non-numeric values and numeric values less than zero inhibit truncation"
readonly HISTFILESIZE='unlimited' 2> /dev/null || true

# Use a custom history file location so history is not truncated
# if the environment ever loses this "eternal" configuration.
HISTDIR="${XDG_STATE_HOME:-${HOME?}/.local/state}/bash"
[[ -d ${HISTDIR?} ]] || mkdir -p "${HISTDIR?}"
readonly HISTFILE="${HISTDIR?}/history" 2> /dev/null || true
