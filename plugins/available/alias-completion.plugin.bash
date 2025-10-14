# shellcheck shell=bash

cite "about-plugin"
about-plugin "Compatibility stub - redirects to aliases completion (DEPRECATED)"
group "bash-it"
url "https://github.com/Bash-it/bash-it"

# stub for renamed file

_enable-completion aliases && _disable-plugin alias-completion
# shellcheck disable=SC1091
source "${BASH_IT?}/completion/available/aliases.completion.bash"
