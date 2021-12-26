# shellcheck shell=bash
about-plugin 'eternal bash history'

# Load after the history plugin
# BASH_IT_LOAD_PRIORITY: 375

# Modify history sizes before changing location to avoid unintentionally
# truncating the history file early.

# "Numeric values less than zero result in every command being saved on the history list (there is no limit)"
export HISTSIZE=-1

# "Non-numeric values and numeric values less than zero inhibit truncation"
export HISTFILESIZE='unlimited'

# Use a custom history file location so history is not truncated
# if the environment ever loses this "eternal" configuration.
HISTDIR="${XDG_STATE_HOME:-${HOME?}/.local/state}/bash"
[[ -d ${HISTDIR?} ]] || mkdir -p "${HISTDIR?}"
export HISTFILE="${HISTDIR?}/history"
