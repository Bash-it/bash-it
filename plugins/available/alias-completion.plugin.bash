# shellcheck shell=bash
# stub for renamed file

_enable-completion aliases && _disable-plugin alias-completion
# shellcheck disable=SC1091
source "${BASH_IT?}/completion/available/aliases.completion.bash"
