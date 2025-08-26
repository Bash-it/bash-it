# shellcheck shell=bash

# Make sure pipenv is installed
_bash-it-completion-helper-necessary pipenv || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient pipenv || return

eval "$(_PIPENV_COMPLETE=bash_source pipenv)"
