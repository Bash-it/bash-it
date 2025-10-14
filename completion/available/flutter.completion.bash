# shellcheck shell=bash

cite "about-completion"
about-completion "flutter - Google's UI toolkit for building cross-platform applications"
group "mobile"
url "https://flutter.dev"

# Make sure flutter is installed
_bash-it-completion-helper-necessary flutter || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient flutter || return

eval "$(flutter bash-completion)"
