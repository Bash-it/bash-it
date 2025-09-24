# shellcheck shell=bash
# shellcheck disable=SC1090

# Make sure pew is installed
_bash-it-completion-helper-necessary pew || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient pew || return

# shellcheck disable=SC1090
source "$(pew shell_config)"
