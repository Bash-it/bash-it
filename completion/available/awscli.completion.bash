# shellcheck shell=bash

cite "about-completion"
about-completion "aws - Amazon Web Services command-line interface"
group "cloud"
url "https://aws.amazon.com/cli/"

# Make sure aws is installed
_bash-it-completion-helper-necessary aws aws_completer || return

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient aws || return

complete -C aws_completer aws
