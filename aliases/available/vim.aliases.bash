# shellcheck shell=bash
about-alias 'vim abbreviations'

_command_exists vim || return

alias v='vim'
# open the vim help in fullscreen incorporated from
# https://stackoverflow.com/a/4687513
alias vimh='vim -c ":h | only"'

# open vim in new tab is taken from
# http://stackoverflow.com/questions/936501/let-gvim-always-run-a-single-instancek
_command_exists mvim && function mvimt { command mvim --remote-tab-silent "$@" || command mvim "$@"; }
_command_exists gvim && function gvimt { command gvim --remote-tab-silent "$@" || command gvim "$@"; }
