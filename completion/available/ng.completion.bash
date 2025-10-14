# shellcheck shell=bash

cite "about-completion"
about-completion "ng - Angular CLI for scaffolding and managing Angular applications"
group "javascript"
url "https://angular.io/cli"

# Make sure ng is installed
_bash-it-completion-helper-necessary ng || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient ng || return

# No longer supported, please see https://github.com/angular/angular-cli/issues/11043
# Fix courtesy of https://stackoverflow.com/questions/50194674/ng-completion-no-longer-exists
# source <(ng completion --bash)

_ng_bash_completion_candidates=("add" "build" "config" "doc" "e2e" "generate" "help" "lint" "new" "run" "serve" "test" "update" "version" "xi18n")
complete -W "${_ng_bash_completion_candidates[*]}" ng
unset "${!_ng_bash_completion@}"
